From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 01:13:08 +1100
Message-Id: <20070112141308.11603.49518.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 0/29] PTI - Page Table Interface
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 00

        A CLEAN PAGE TABLE INTERFACE FOR LINUX by Gelato@UNSW

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

This patch series provides:
   1. Architecture independent page table interface to try on i386 and IA64
   2. Architecture dependent page table interface for IA64
   3. An alternative page table implementation (guarded page table) for IA64

   The GPT is a a compile time alternative to the current page table on IA64.  
   This is running rough at the moment and is intended as an example of
   an alternative page table running under the PTI.

Benchmarking results for the full page table interface on IA64
 * There is negligable regression demonstrated across the board
 demonstrated by testing so far.  For benchmarks, see the link below.
 
Benchmarking results for the arch independent PTI running on i386
 * There is negligable regression demonstrated across the board
 demonstrated by testing so far.  For benchmarks see the link below.

Benchmarking of the GPT shows poor performance and is intended
as a demonstration of an alternate implementation under the PTI.
The GPT is still "under construction".  For benchmarks see the link below.

INSTRUCTIONS,BENCHMARKS and further information at the site below:
 
http://www.gelato.unsw.edu.au/IA64wiki/PageTableInterface/PTI-LCA

                PAGE TABLE INTERFACE

int create_user_page_table(struct mm_struct *mm);

void destroy_user_page_table(struct mm_struct *mm);

pte_t *build_page_table(struct mm_struct *mm, unsigned long address,
		pt_path_t *pt_path);

pte_t *lookup_page_table(struct mm_struct *mm, unsigned long address,
		pt_path_t *pt_path);

void free_pt_range(struct mmu_gather **tlb, unsigned long addr,
		unsigned long end, unsigned long floor, unsigned long ceiling);

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

void change_protection_read_iterator(struct vm_area_struct *vma,
		unsigned long addr, unsigned long end, pgprot_t newprot,
		int dirty_accountable);

void vunmap_read_iterator(unsigned long addr, unsigned long end);

int vmap_build_iterator(unsigned long addr,
		unsigned long end, pgprot_t prot, struct page ***pages);

int unuse_vma_read_iterator(struct vm_area_struct *vma,
		unsigned long addr, unsigned long end, swp_entry_t entry, struct page *page);

void smaps_read_iterator(struct vm_area_struct *vma,
		unsigned long addr, unsigned long end, struct mem_size_stats *mss);

int check_policy_read_iterator(struct vm_area_struct *vma,
		unsigned long addr, unsigned long end, const nodemask_t *nodes,
		unsigned long flags, void *private);

unsigned long move_page_tables(struct vm_area_struct *vma,
		unsigned long old_addr, struct vm_area_struct *new_vma,
		unsigned long new_addr, unsigned long len);


Paul Davies
Gelato@UNSW

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 0 files changed
PATCH 00

        A CLEAN PAGE TABLE INTERFACE FOR LINUX by Gelato@UNSW

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

This patch series provides:
   1. Architecture independent page table interface to try on i386 and IA64
   2. Architecture dependent page table interface for IA64
   3. An alternative page table implementation (guarded page table)

   The GPT is a a compile time alternative to the current page table on IA64.  
   This is running rough at the moment and is intended as an example of
   an alternative page table running under the PTI.

Benchmarking results for the full page table interface on IA64
 * There is negligable regression demonstrated at the moment for testing
 so far.  For benchmarks see the link below.
Benchmarking results for the arch independent PTI running on i386
 * There is negligable regression demonstrated at the moment for testing
 so far.  For benchmarks see link below.

INSTRUCTIONS,BENCHMARKS and further information at the site below:
 
http://www.gelato.unsw.edu.au/IA64wiki/PageTableInterface/PTI-LCA
and benchmarking results.

                PAGE TABLE INTERFACE

int create_user_page_table(struct mm_struct *mm);

void destroy_user_page_table(struct mm_struct *mm);

pte_t *build_page_table(struct mm_struct *mm, unsigned long address,
		pt_path_t *pt_path);

pte_t *lookup_page_table(struct mm_struct *mm, unsigned long address,
		pt_path_t *pt_path);

void free_pt_range(struct mmu_gather **tlb, unsigned long addr,
		unsigned long end, unsigned long floor, unsigned long ceiling);

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

void change_protection_read_iterator(struct vm_area_struct *vma,
		unsigned long addr, unsigned long end, pgprot_t newprot,
		int dirty_accountable);

void vunmap_read_iterator(unsigned long addr, unsigned long end);

int vmap_build_iterator(unsigned long addr,
		unsigned long end, pgprot_t prot, struct page ***pages);

int unuse_vma_read_iterator(struct vm_area_struct *vma,
		unsigned long addr, unsigned long end, swp_entry_t entry, struct page *page);

void smaps_read_iterator(struct vm_area_struct *vma,
		unsigned long addr, unsigned long end, struct mem_size_stats *mss);

int check_policy_read_iterator(struct vm_area_struct *vma,
		unsigned long addr, unsigned long end, const nodemask_t *nodes,
		unsigned long flags, void *private);

unsigned long move_page_tables(struct vm_area_struct *vma,
		unsigned long old_addr, struct vm_area_struct *new_vma,
		unsigned long new_addr, unsigned long len);

Please send questions regarding the PTI to pauld@cse.unsw.edu.au

UNSW PhD student Adam Wiggins is the GPT author, questions regarding his
GPT model should be addressed to awiggins@cse.unsw.edu.au.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
