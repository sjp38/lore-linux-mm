Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By note With Smtp ;
	Tue, 30 May 2006 17:01:48 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:01:47 +1000 (EST)
Subject: [Patch 0/17] PTI: Explation of Clean Page Table Interface
Message-ID: <Pine.LNX.4.61.0605301334520.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linux currently uses the same page table format regardless of
architecture.  Access to the page table is open-coded in a variety of
places.  Architectures that walk a different page table format in
hardware set up a hardware-walkable cache in their native format, that
then has to be kept in step with Linux's page table.

The first step to allowing different page table formats is to split
the page table implementation into separate files from its use.
This patch series abstracts the page table implementation, and cleans
it up, so that:
    1.  All page table operations are in one place, making future
        maintenance easier
    2.  Generic code no longer knows what format the page table is,
        opening the way to experimentation with different
        page table formats.

The interface is separated into two parts.  The first part is
architecture independent. All architectures must run through
this interface regardless of whether or not that architecture
can or will ever want to change page tables.

This patch series provides the architectural independent interface.
It has been tested and benchmarked for IA64 using lmbench.  It also passes
all relevant tests in the Linux Test Project (LTP) on IA64.  This patch
should 5~also compile and run for i386.  To run on other architectures add
CONFIG_DEFAULT_PT to the architectures config.  Turn off HugeTLB.

Summary of performance degradation using lmbench on IA64:
~3.5% deterioration in fork latency on IA64.
~1.0% deterioration in mmap latency on IA64

The interface has been designed in such a way so as to avoid changing
kernel functionality, and causing minimal deterioration in performance.
As a result there are a large number of iterators.  With feedback
from the community it should be possible to patch the kernel to produce a 
general
set of iterators with a few specialised iterators.  (We actually have
a guarded page table running under an interface with general iterators
on an older kernel).

                           BASIC FUNCTIONALITY

This in contained in include/linux/default-pt.h and mm/default-pt.c

/*
  * This is the structure representing the path of the pte in
  * the page table.  For efficiency reasons we store the partial
  * path only
  */
typedef struct pt_struct { pmd_t *pmd; } pt_path_t;

/* Create user page table */
static inline int create_user_page_table(struct mm_struct *mm);

/* Destroy user page table */
static inline void destroy_user_page_table(struct mm_struct *mm);

/* Look up user or kernel page table - saving the path */
static inline pte_t *lookup_page_table(struct mm_struct *mm,
                 unsigned long address, pt_path_t *pt_path);

/* Lookup gate are of page table for fast system calls */
static inline pte_t *lookup_gate_area(struct mm_struct *mm,
                         unsigned long pg);
/* Free page table range */
void free_page_table_range(struct mmu_gather **tlb, unsigned long addr,
         unsigned long end, unsigned long floor, unsigned long ceiling);

/* Provided to keep free_pgtables implementation independent */
static inline void coallesce_vmas(struct vm_area_struct **vma_p,
                 struct vm_area_struct **next_p);

                          PTI WORKER FUNCTIONS
/*
  * Locks the ptes notionally pointed to by the page table path.
  */
#define lock_pte(mm, pt_path)

/*
  * Unlocks the ptes notionally pointed to by the
  * page table path.
  */
#define unlock_pte(mm, pt_path)

/*
  * Looks up a page table from a saved path.  It also
  * locks the page table.
  */
#define lookup_page_table_fast(mm, pt_path, address)

/*
  * Check that the original pte hasn't change.
  */
#define atomic_pte_same(mm, pte, orig_pte, pt_path)

                          THE ITERATORS

Each iterator is passed a function and arguments to operate on
the pte being iterated over.  There are three classes of iterator
for slightly different purposes.

1) Dual iterators - Build a page table while it reads a page table.

Contained in default-pt-dual-iterators.h (included in default-pt.h)

/* For duplicating page table regions for fork and mmap */
static inline int copy_dual_iterator(struct mm_struct *dst_mm,
         struct mm_struct *src_mm, unsigned long addr, unsigned long end,
         struct vm_area_struct *vma, pte_rw_iterator_callback_t func);

/* For mremap sys call - source and destination page table is the same
    for this dual iterator */
static inline unsigned long move_page_tables(struct vm_area_struct *vma,
         unsigned long old_addr, struct vm_area_struct *new_vma,
         unsigned long new_addr, unsigned long len, mremap_callback_t 
func);

2) Build iterators - build a page table between a range of addresses.

Contained in default-pt-build-iterators.h (included in default-pt.h)

static inline int vmap_pte_range(pmd_t *pmd, unsigned long addr,
         unsigned long end, pgprot_t prot, struct page ***pages,
         vmap_callback_t func)

static inline int zeromap_build_iterator(struct mm_struct *mm,
         unsigned long addr, unsigned long end,
         pgprot_t prot, zeromap_callback_t func);

static inline int remap_build_iterator(struct mm_struct *mm,
         unsigned long addr, unsigned long end, unsigned long pfn,
         pgprot_t prot, remap_pfn_callback_t func);

3) Read iterators - read a page table between a range of addresses.

Contained in default-pt-read-iterators.h (included in default-pt.h).

static inline unsigned long unmap_page_range_iterator(struct mmu_gather 
*tlb,
         struct vm_area_struct *vma, unsigned long addr, unsigned long end,
         long *zap_work, struct zap_details *details, zap_pte_callback_t 
func);

static inline void vunmap_read_iterator(unsigned long addr,
         unsigned long end, vunmap_callback_t func);

static inline unsigned long msync_read_iterator(struct vm_area_struct 
*vma,
         unsigned long addr, unsigned long end, msync_callback_t func);

static inline void change_protection_read_iterator(struct vm_area_struct 
*vma,
         unsigned long addr, unsigned long end, pgprot_t newprot,
         change_prot_callback_t func);

static inline int unuse_vma_read_iterator(struct vm_area_struct *vma,
         unsigned long addr, unsigned long end, swp_entry_t entry,
         struct page *page, unuse_pte_callback_t func);

static inline int check_policy_read_iterator(struct vm_area_struct *vma,
         unsigned long addr, unsigned long end, const nodemask_t *nodes,
         unsigned long flags, void *private, mempolicy_check_pte_t func);

static inline void smaps_read_iterator(struct vm_area_struct *vma,
         unsigned long addr, unsigned long end,
         struct mem_size_stats *mss, smaps_pte_callback_t func);

I am keen to hear from anyone planning to put a
new page table implementation into the kernel. Is there
anything in my patch that could be changed to better
accommodate you?

Results and progress will be documented on the Gelato@UNSW wiki in the 
very near future.

http://www.gelato.unsw.edu.au/IA64wiki/PageTableInterface

Paul Davies on behalf of Gelato@UNSW.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
