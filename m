From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:26:30 +1000
Message-Id: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/18] PTI - Explanation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
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

TESTING on IA64
* Patch series has been booted on a NUMA machine with 2 nodes at UNSW
* Booted on UP and SMP machines at UNSW
* Passes relevant LTP test on an SMP machine on an IA64.
* Compiles on i386.

INSTRUCTIONS:
1) Apply to 2.6.17.2.
2) Turn off HugeTLB

PATCH SERIES GOAL:
This patch series is intended to provide a cleaner and clearer interface
for page table developers.  It has the following enhancements against the patch
series fed to linux-mm on 30/05/06.
* Introduction of page table type and removal of references to pgds.
* Moved the majority of default page table implementation from headers
back to C files.
* Iterators no longer call functions using function pointers.  Function 
pointers will be used in the future in an attempt to create generic 
read and build iterators but only for non performance critical iterators.
* Numerous bug fixes.
* File renaming and general cleaningup.


		PAGE TABLE INTERFACE

int create_user_page_table(struct mm_struct *mm);

void destroy_user_page_table(struct mm_struct *mm);

pte_t *build_page_table(struct mm_struct *mm,
	unsigned long address, pt_path_t *pt_path);

pte_t *lookup_page_table(struct mm_struct *mm,
	unsigned long address, pt_path_t *pt_path);

pte_t *lookup_gate_area(struct mm_struct *mm,
	unsigned long pg);

void coallesce_vmas(struct vm_area_struct **vma_p,
	struct vm_area_struct **next_p);

void free_page_table_range(struct mmu_gather **tlb,
	unsigned long addr, unsigned long end,
	unsigned long floor, unsigned long ceiling);

/* memory.c iterators */
int copy_dual_iterator(struct mm_struct *dst_mm, struct mm_struct *src_mm,
	unsigned long addr, unsigned long end, struct vm_area_struct *vma);

unsigned long unmap_page_range_iterator(struct mmu_gather *tlb,
	struct vm_area_struct *vma, unsigned long addr, unsigned long end,
	long *zap_work, struct zap_details *details);

int zeromap_build_iterator(struct mm_struct *mm,
	unsigned long addr, unsigned long end, pgprot_t prot);

int remap_build_iterator(struct mm_struct *mm,
	unsigned long addr, unsigned long end, unsigned long pfn,
	pgprot_t prot);

/* vmalloc.c iterators */

void vunmap_read_iterator(unsigned long addr, unsigned long end);

int vmap_build_iterator(unsigned long addr,
	unsigned long end, pgprot_t prot, struct page ***pages);

/* mprotect.c iterator */
void change_protection_read_iterator(struct vm_area_struct *vma,
	unsigned long addr, unsigned long end, pgprot_t newprot);

/* msync.c iterator */
unsigned long msync_read_iterator(struct vm_area_struct *vma,
	unsigned long addr, unsigned long end);

/* swapfile.c iterator */
int unuse_vma_read_iterator(struct vm_area_struct *vma,
	unsigned long addr, unsigned long end, swp_entry_t entry, 
	struct page *page);

/* smaps */

void smaps_read_range(struct vm_area_struct *vma,
	unsigned long addr, unsigned long end, struct mem_size_stats *mss);

/* movepagetables */
unsigned long move_page_tables(struct vm_area_struct *vma,
	unsigned long old_addr, struct vm_area_struct *new_vma,
	unsigned long new_addr, unsigned long len);

/* mempolicy.c */
int check_policy_read_iterator(struct vm_area_struct *vma,
	unsigned long addr, unsigned long end,
	const nodemask_t *nodes, unsigned long flags,
	void *private);


I am keen to hear from anyone planning to put a
new page table implementation into the kernel. Is there
anything in my patch that could be changed to better
accommodate you?

Results and progress will be documented on the Gelato@UNSW wiki in the 
very near future.

http://www.gelato.unsw.edu.au/IA64wiki/PageTableInterface

Paul Davies on behalf of Gelato@UNSW.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 0 files changed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
