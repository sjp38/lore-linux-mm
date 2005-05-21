From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 14:58:45 +1000 (EST)
Subject: [PATCH 11/15] PTI: Continue calling iterators
In-Reply-To: <Pine.LNX.4.61.0505211417450.26645@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211455390.8979@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211344350.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211352170.28095@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211400351.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211409350.26645@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211417450.26645@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 11 of 15.

This patch starts calling the read iterator.

 	*It abstracts unmap_page_range in memory.c
 	*It abstracts unmap_vm_area in vmalloc.c
 	*It abstracts change_protection in mprotect.c

  mm/memory.c   |  174 
++++++++++++++++++++++++----------------------------------
  mm/mprotect.c |   78 +++++++-------------------
  mm/vmalloc.c  |   52 +----------------
  3 files changed, 98 insertions(+), 206 deletions(-)

Index: linux-2.6.12-rc4/mm/memory.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/memory.c	2005-05-19 18:15:26.000000000 
+1000
+++ linux-2.6.12-rc4/mm/memory.c	2005-05-19 18:21:20.000000000 
+1000
@@ -175,127 +175,97 @@
  	return err;
  }

-static void zap_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
-				unsigned long addr, unsigned long end,
-				struct zap_details *details)
+struct unmap_page_range_struct
  {
-	pte_t *pte;
+	struct mmu_gather *tlb;
+	struct zap_details *details;
+};

-	pte = pte_offset_map(pmd, addr);
-	do {
-		pte_t ptent = *pte;
-		if (pte_none(ptent))
-			continue;
-		if (pte_present(ptent)) {
-			struct page *page = NULL;
-			unsigned long pfn = pte_pfn(ptent);
-			if (pfn_valid(pfn)) {
-				page = pfn_to_page(pfn);
-				if (PageReserved(page))
-					page = NULL;
-			}
-			if (unlikely(details) && page) {
-				/*
-				 * unmap_shared_mapping_pages() wants to
-				 * invalidate cache without truncating:
-				 * unmap shared but keep private pages.
-				 */
-				if (details->check_mapping &&
-				    details->check_mapping != 
page->mapping)
-					continue;
-				/*
-				 * Each page->index must be checked when
-				 * invalidating or truncating nonlinear.
-				 */
-				if (details->nonlinear_vma &&
-				    (page->index < details->first_index ||
-				     page->index > details->last_index))
-					continue;
-			}
-			ptent = ptep_get_and_clear(tlb->mm, addr, pte);
-			tlb_remove_tlb_entry(tlb, pte, addr);
-			if (unlikely(!page))
-				continue;
-			if (unlikely(details) && details->nonlinear_vma
-			    && linear_page_index(details->nonlinear_vma,
-						addr) != page->index)
-				set_pte_at(tlb->mm, addr, pte,
-					   pgoff_to_pte(page->index));
-			if (pte_dirty(ptent))
-				set_page_dirty(page);
-			if (PageAnon(page))
-				dec_mm_counter(tlb->mm, anon_rss);
-			else if (pte_young(ptent))
-				mark_page_accessed(page);
-			tlb->freed++;
-			page_remove_rmap(page);
-			tlb_remove_page(tlb, page);
-			continue;
+static int zap_one_pte(struct mm_struct *mm, pte_t *pte, unsigned long 
addr, void *data)
+{
+	struct mmu_gather *tlb = ((struct unmap_page_range_struct 
*)data)->tlb;
+	struct zap_details *details = ((struct unmap_page_range_struct 
*)data)->details;
+
+	pte_t ptent = *pte;
+	if (pte_present(ptent)) {
+		struct page *page = NULL;
+		unsigned long pfn = pte_pfn(ptent);
+		if (pfn_valid(pfn)) {
+			page = pfn_to_page(pfn);
+			if (PageReserved(page))
+				page = NULL;
  		}
-		/*
-		 * If details->check_mapping, we leave swap entries;
-		 * if details->nonlinear_vma, we leave file entries.
-		 */
-		if (unlikely(details))
-			continue;
-		if (!pte_file(ptent))
-			free_swap_and_cache(pte_to_swp_entry(ptent));
-		pte_clear(tlb->mm, addr, pte);
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
-}

-static inline void zap_pmd_range(struct mmu_gather *tlb, pud_t *pud,
-				unsigned long addr, unsigned long end,
-				struct zap_details *details)
-{
-	pmd_t *pmd;
-	unsigned long next;
+		if (unlikely(details) && page) {
+			/*
+			 * unmap_shared_mapping_pages() wants to
+			 * invalidate cache without truncating:
+			 * unmap shared but keep private pages.
+			 */
+			if (details->check_mapping &&
+			    details->check_mapping != page->mapping)
+				return 0;
+			/*
+			 * Each page->index must be checked when
+			 * invalidating or truncating nonlinear.
+			 */
+			if (details->nonlinear_vma &&
+			    (page->index < details->first_index ||
+			     page->index > details->last_index))
+				return 0;
+		}

-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		zap_pte_range(tlb, pmd, addr, next, details);
-	} while (pmd++, addr = next, addr != end);
-}
+		ptent = ptep_get_and_clear(tlb->mm, addr, pte);
+		tlb_remove_tlb_entry(tlb, pte, addr);
+		if (unlikely(!page))
+			return 0;

-static inline void zap_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
-				unsigned long addr, unsigned long end,
-				struct zap_details *details)
-{
-	pud_t *pud;
-	unsigned long next;
+		if (unlikely(details) && details->nonlinear_vma
+		    && linear_page_index(details->nonlinear_vma,
+					addr) != page->index)
+			set_pte_at(tlb->mm, addr, pte,
+				   pgoff_to_pte(page->index));
+		if (pte_dirty(ptent))
+			set_page_dirty(page);
+		if (PageAnon(page))
+			dec_mm_counter(tlb->mm, anon_rss);
+		else if (pte_young(ptent))
+			mark_page_accessed(page);
+		tlb->freed++;
+		page_remove_rmap(page);
+		tlb_remove_page(tlb, page);
+		return 0;
+
+	}

-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		zap_pmd_range(tlb, pud, addr, next, details);
-	} while (pud++, addr = next, addr != end);
+	/*
+	 * If details->check_mapping, we leave swap entries;
+	 * if details->nonlinear_vma, we leave file entries.
+	 */
+	if (unlikely(details))
+		return 0;
+
+	if (!pte_file(ptent))
+		free_swap_and_cache(pte_to_swp_entry(ptent));
+	pte_clear(tlb->mm, addr, pte);
+	return 0;
  }

  static void unmap_page_range(struct mmu_gather *tlb, struct 
vm_area_struct *vma,
  				unsigned long addr, unsigned long end,
  				struct zap_details *details)
  {
-	pgd_t *pgd;
-	unsigned long next;
+	struct unmap_page_range_struct data;

  	if (details && !details->check_mapping && !details->nonlinear_vma)
  		details = NULL;

+	data.tlb = tlb;
+	data.details = details;
+
  	BUG_ON(addr >= end);
  	tlb_start_vma(tlb, vma);
-	pgd = pgd_offset(vma->vm_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		zap_pud_range(tlb, pgd, addr, next, details);
-	} while (pgd++, addr = next, addr != end);
+	page_table_read_iterator(vma->vm_mm, addr, end, zap_one_pte, 
&data);
  	tlb_end_vma(tlb, vma);
  }

Index: linux-2.6.12-rc4/mm/vmalloc.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/vmalloc.c	2005-05-19 18:15:26.000000000 
+1000
+++ linux-2.6.12-rc4/mm/vmalloc.c	2005-05-19 18:21:20.000000000 
+1000
@@ -24,63 +24,21 @@
  DEFINE_RWLOCK(vmlist_lock);
  struct vm_struct *vmlist;

-static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned 
long end)
+int unmap_vm_pte(struct mm_struct *mm, pte_t *pte, unsigned long address, 
void *args)
  {
-	pte_t *pte;
-
-	pte = pte_offset_kernel(pmd, addr);
-	do {
-		pte_t ptent = ptep_get_and_clear(&init_mm, addr, pte);
-		WARN_ON(!pte_none(ptent) && !pte_present(ptent));
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-}
-
-static inline void vunmap_pmd_range(pud_t *pud, unsigned long addr,
-						unsigned long end)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		vunmap_pte_range(pmd, addr, next);
-	} while (pmd++, addr = next, addr != end);
-}
-
-static inline void vunmap_pud_range(pgd_t *pgd, unsigned long addr,
-						unsigned long end)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		vunmap_pmd_range(pud, addr, next);
-	} while (pud++, addr = next, addr != end);
+	pte_t ptent = ptep_get_and_clear(&init_mm, address, pte);
+	WARN_ON(!pte_none(ptent) && !pte_present(ptent));
+	return 0;
  }

  void unmap_vm_area(struct vm_struct *area)
  {
-	pgd_t *pgd;
-	unsigned long next;
  	unsigned long addr = (unsigned long) area->addr;
  	unsigned long end = addr + area->size;

  	BUG_ON(addr >= end);
-	pgd = pgd_offset_k(addr);
  	flush_cache_vunmap(addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		vunmap_pud_range(pgd, addr, next);
-	} while (pgd++, addr = next, addr != end);
+	page_table_read_iterator(&init_mm, addr, end, unmap_vm_pte, NULL);
  	flush_tlb_kernel_range((unsigned long) area->addr, end);
  }

Index: linux-2.6.12-rc4/mm/mprotect.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/mprotect.c	2005-05-19 17:01:14.000000000 
+1000
+++ linux-2.6.12-rc4/mm/mprotect.c	2005-05-19 18:21:20.000000000 
+1000
@@ -19,82 +19,46 @@
  #include <linux/mempolicy.h>
  #include <linux/personality.h>
  #include <linux/syscalls.h>
+#include <linux/page_table.h>

  #include <asm/uaccess.h>
-#include <asm/pgtable.h>
  #include <asm/cacheflush.h>
  #include <asm/tlbflush.h>

-static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
-		unsigned long addr, unsigned long end, pgprot_t newprot)
-{
-	pte_t *pte;
-
-	pte = pte_offset_map(pmd, addr);
-	do {
-		if (pte_present(*pte)) {
-			pte_t ptent;
-
-			/* Avoid an SMP race with hardware updated 
dirty/clean
-			 * bits by wiping the pte and then setting the new 
pte
-			 * into place.
-			 */
-			ptent = pte_modify(ptep_get_and_clear(mm, addr, 
pte), newprot);
-			set_pte_at(mm, addr, pte, ptent);
-			lazy_mmu_prot_update(ptent);
-		}
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
-}
-
-static inline void change_pmd_range(struct mm_struct *mm, pud_t *pud,
-		unsigned long addr, unsigned long end, pgprot_t newprot)
+struct change_prot_struct
  {
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		change_pte_range(mm, pmd, addr, next, newprot);
-	} while (pmd++, addr = next, addr != end);
-}
+	pgprot_t newprot;
+};

-static inline void change_pud_range(struct mm_struct *mm, pgd_t *pgd,
-		unsigned long addr, unsigned long end, pgprot_t newprot)
+int change_prot_pte(struct mm_struct *mm, pte_t *pte, unsigned long 
address, void *data)
  {
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		change_pmd_range(mm, pud, addr, next, newprot);
-	} while (pud++, addr = next, addr != end);
+	if (pte_present(*pte)) {
+		pte_t ptent;
+		/* Avoid an SMP race with hardware updated dirty/clean
+		 * bits by wiping the pte and then setting the new pte
+		 * into place.
+		 */
+		ptent = pte_modify(ptep_get_and_clear(mm, address, pte),
+			((struct change_prot_struct *)data)->newprot);
+		set_pte_at(mm, address, pte, ptent);
+		lazy_mmu_prot_update(ptent);
+		return 0;
+	}
+	return 0;
  }

  static void change_protection(struct vm_area_struct *vma,
  		unsigned long addr, unsigned long end, pgprot_t newprot)
  {
  	struct mm_struct *mm = vma->vm_mm;
-	pgd_t *pgd;
-	unsigned long next;
  	unsigned long start = addr;
+	struct change_prot_struct data;

+	data.newprot = newprot;
  	BUG_ON(addr >= end);
-	pgd = pgd_offset(mm, addr);
  	flush_cache_range(vma, addr, end);
  	spin_lock(&mm->page_table_lock);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		change_pud_range(mm, pgd, addr, next, newprot);
-	} while (pgd++, addr = next, addr != end);
+	page_table_read_iterator(mm, addr, end, change_prot_pte, &data);
  	flush_tlb_range(vma, start, end);
  	spin_unlock(&mm->page_table_lock);
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
