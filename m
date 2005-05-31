Received: From wagner (for linux-mm@kvack.org) With LocalMail ;
	Tue, 31 May 2005 20:06:57 +1000
From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Tue, 31 May 2005 20:06:56 +1000
Subject: [Patch 0/15] PTI: Explation of Clean Page Table Interface
Message-ID: <20050531100656.GC16986@cse.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
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

		          BASIC FUNCTIONALITY

/* Create a user page table */
static inline pgd_t *
init_page_table(void);

/* Destroy a user page table */
static inline void
free_page_table(pgd_t *pgd);

/* Look up a page table - user or kernel */
static inline pte_t *
lookup_page_table(struct mm_struct *mm, unsigned long address);

/* Build a user page table for insertion */
static inline pte_t *
build_page_table(struct mm_struct *mm, unsigned long address);

/* Look up a user page table for a nested pte */
static inline pte_t *
lookup_nested_pte(struct mm_struct *mm, unsigned long address);

/* lookup a pte in the gate page region */
static inline pte_t *
lookup_page_table_gate(struct mm_struct *mm, unsigned long start);

/* Tear down a page table between a range of addresses */
void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct
	*vma, unsigned long floor, unsigned long ceiling);

                         THE ITERATORS

Each iterator is passed a function and arguments to operate on
the pte being iterated over.  There are three iterators for
slightly different purposes.

/* Build a page table between a range of addresses */
static inline int page_table_build_iterator(struct mm_struct *mm,
	unsigned long addr, unsigned long end, pte_callback_t func,
	void *args);

/* Read a page table between a range of addresses */
static inline int page_table_read_iterator(
	struct mm_struct *mm, unsigned long addr, unsigned long end,
	pte_callback_t func, void *args);

/* Duplicate a page table between a range of addresses */
static int dual_pte_range(struct mm_struct *dst_mm, struct mm_struct
	*src_mm, pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
	unsigned long end, pte_rw_iterator_callback_t func, void *args);

I have put the general interface in include/mm/ and I have put
the remaining MLPT implementation in mm/fixed-mlpt.  I will be
moving the MLPT implementation back into mm/ in the next iteration
of patches. The current page table allocation functions in
asm/pgalloc.h have been effectively moved behind the interface.
The page tables are now accessed via a new header page_table.h

The second part of the interface is architecture dependent.  An
architecture that never wants to move away from an MLPT need not
do anything here.  Each architecture that wants to run a
different page table will have to provide an interface and move
the MLPT behind it.  For IA64 this interface is as follows:

/* build kernel page table for insertion */
static inline pte_t *
build_kernel_page_table(unsigned long address);

/* add the memory map to the kernel page table */
static inline pte_t *
build_memory_map(unsigned long address);

/* lookup kernel page table */
static inline pte_t *
lookup_kernel_page_table(unsigned long address);

I have put the IA64 interface into arch/ia64/mm/fixed-mlpt/ for
the same reasons as above.  Similarly this will move back
to arch/ia64/mm/ in the next iteration of patches.


I am extremely keen to hear from anyone planning to put a
new page table implementation into the kernel. Is there
anything in my patch that could be changed to better
accommodate you?

Paul Davies on behalf of Gelato@UNSW.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
