From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 15:04:04 +1000 (EST)
Subject: [PATCH 12/15] PTI: Finish calling iterators
In-Reply-To: <Pine.LNX.4.61.0505211455390.8979@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211500180.8979@wagner.orchestra.cse.unsw.EDU.AU>
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
 <Pine.LNX.4.61.0505211455390.8979@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 12 of 15.

This patch continues to call the read iterator

 	*abstracts sync_page_range in msync.c
 	*abstracts unuse_vma in swapfile.c
 	*abstracts verify_pages in mempolicy.c
 	*abstracts try_to_umap_cluster in rmap.c
 	 Some defines moved to mlpt-iterators as
 	 part of this process.
 	*This finishes all the calls to the read
 	 iterator.

  include/mm/mlpt-iterators.h |    3 +
  mm/mempolicy.c              |   64 +++++++++++--------------
  mm/msync.c                  |   89 +++++++++--------------------------
  mm/rmap.c                   |  111 
+++++++++++++++++++++-----------------------
  mm/swapfile.c               |   91 ++++++++++--------------------------
  5 files changed, 133 insertions(+), 225 deletions(-)

Index: linux-2.6.12-rc4/mm/msync.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/msync.c	2005-05-19 17:01:14.000000000 
+1000
+++ linux-2.6.12-rc4/mm/msync.c	2005-05-19 18:27:40.000000000 +1000
@@ -13,8 +13,8 @@
  #include <linux/mman.h>
  #include <linux/hugetlb.h>
  #include <linux/syscalls.h>
+#include <linux/page_table.h>

-#include <asm/pgtable.h>
  #include <asm/tlbflush.h>

  /*
@@ -22,85 +22,42 @@
   * threads/the swapper from ripping pte's out from under us.
   */

-static void sync_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end)
-{
-	pte_t *pte;
-
-	pte = pte_offset_map(pmd, addr);
-	do {
-		unsigned long pfn;
-		struct page *page;
-
-		if (!pte_present(*pte))
-			continue;
-		pfn = pte_pfn(*pte);
-		if (!pfn_valid(pfn))
-			continue;
-		page = pfn_to_page(pfn);
-		if (PageReserved(page))
-			continue;
-
-		if (ptep_clear_flush_dirty(vma, addr, pte) ||
-		    page_test_and_clear_dirty(page))
-			set_page_dirty(page);
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
-}
-
-static inline void sync_pmd_range(struct vm_area_struct *vma, pud_t *pud,
-				unsigned long addr, unsigned long end)
+struct sync_page_struct
  {
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		sync_pte_range(vma, pmd, addr, next);
-	} while (pmd++, addr = next, addr != end);
-}
+	struct vm_area_struct *vma;
+};

-static inline void sync_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
-				unsigned long addr, unsigned long end)
+int sync_range_pte(struct mm_struct *mm, pte_t *pte, unsigned long 
address, void *data)
  {
-	pud_t *pud;
-	unsigned long next;
+	unsigned long pfn;
+	struct page *page;

-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		sync_pmd_range(vma, pud, addr, next);
-	} while (pud++, addr = next, addr != end);
+	if (!pte_present(*pte))
+		return 0;
+	pfn = pte_pfn(*pte);
+	if (!pfn_valid(pfn))
+		return 0;
+	page = pfn_to_page(pfn);
+	if (PageReserved(page))
+		return 0;
+
+	if (ptep_clear_flush_dirty(((struct sync_page_struct *)data)->vma, 
address, pte) ||
+	    page_test_and_clear_dirty(page))
+		set_page_dirty(page);
+	return 0;
  }

  static void sync_page_range(struct vm_area_struct *vma,
  				unsigned long addr, unsigned long end)
  {
  	struct mm_struct *mm = vma->vm_mm;
-	pgd_t *pgd;
-	unsigned long next;
-
-	/* For hugepages we can't go walking the page table normally,
-	 * but that's ok, hugetlbfs is memory based, so we don't need
-	 * to do anything more on an msync() */
-	if (is_vm_hugetlb_page(vma))
-		return;
+	struct sync_page_struct data;

+	data.vma = vma;
  	BUG_ON(addr >= end);
-	pgd = pgd_offset(mm, addr);
  	flush_cache_range(vma, addr, end);
  	spin_lock(&mm->page_table_lock);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		sync_pud_range(vma, pgd, addr, next);
-	} while (pgd++, addr = next, addr != end);
+	page_table_read_iterator(mm, addr, end, sync_range_pte, &data);
  	spin_unlock(&mm->page_table_lock);
  }

Index: linux-2.6.12-rc4/mm/swapfile.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/swapfile.c	2005-05-19 17:01:14.000000000 
+1000
+++ linux-2.6.12-rc4/mm/swapfile.c	2005-05-19 18:27:40.000000000 
+1000
@@ -26,8 +26,8 @@
  #include <linux/security.h>
  #include <linux/backing-dev.h>
  #include <linux/syscalls.h>
+#include <linux/page_table.h>

-#include <asm/pgtable.h>
  #include <asm/tlbflush.h>
  #include <linux/swapops.h>

@@ -435,70 +435,35 @@
  	activate_page(page);
  }

-static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
+struct unuse_vma_struct
  {
-	pte_t *pte;
-	pte_t swp_pte = swp_entry_to_pte(entry);
-
-	pte = pte_offset_map(pmd, addr);
-	do {
-		/*
-		 * swapoff spends a _lot_ of time in this loop!
-		 * Test inline before going to call unuse_pte.
-		 */
-		if (unlikely(pte_same(*pte, swp_pte))) {
-			unuse_pte(vma, pte, addr, entry, page);
-			pte_unmap(pte);
-			return 1;
-		}
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
-	return 0;
-}
-
-static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
-				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		if (unuse_pte_range(vma, pmd, addr, next, entry, page))
-			return 1;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
+	struct vm_area_struct *vma;
+	swp_entry_t entry;
+	struct page *page;
+};

-static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
-				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
+int unuse_vma_pte(struct mm_struct *mm, pte_t *pte, unsigned long 
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
-		if (unuse_pmd_range(vma, pud, addr, next, entry, page))
-			return 1;
-	} while (pud++, addr = next, addr != end);
+	pte_t swp_pte = swp_entry_to_pte( ((struct unuse_vma_struct 
*)data)->entry );
+	/*
+	 * swapoff spends a _lot_ of time in this loop!
+	 * Test inline before going to call unuse_pte.
+	 */
+	if (unlikely(pte_same(*pte, swp_pte))) {
+		unuse_pte(((struct unuse_vma_struct *)data)->vma, pte, 
address,
+			((struct unuse_vma_struct *)data)->entry,
+			((struct unuse_vma_struct *)data)->page);
+		pte_unmap(pte);
+		return 1;
+	}
  	return 0;
  }

  static int unuse_vma(struct vm_area_struct *vma,
  				swp_entry_t entry, struct page *page)
  {
-	pgd_t *pgd;
-	unsigned long addr, end, next;
+	unsigned long addr, end;
+	struct unuse_vma_struct data;

  	if (page->mapping) {
  		addr = page_address_in_vma(page, vma);
@@ -510,15 +475,11 @@
  		addr = vma->vm_start;
  		end = vma->vm_end;
  	}
-
-	pgd = pgd_offset(vma->vm_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		if (unuse_pud_range(vma, pgd, addr, next, entry, page))
-			return 1;
-	} while (pgd++, addr = next, addr != end);
+
+	data.vma = vma;
+	data.entry = entry;
+	data.page = page;
+	page_table_read_iterator(vma->vm_mm, addr, end, unuse_vma_pte, 
&data);
  	return 0;
  }

Index: linux-2.6.12-rc4/mm/mempolicy.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/mempolicy.c	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/mm/mempolicy.c	2005-05-19 18:27:40.000000000 
+1000
@@ -76,6 +76,7 @@
  #include <linux/init.h>
  #include <linux/compat.h>
  #include <linux/mempolicy.h>
+#include <linux/page_table.h>
  #include <asm/tlbflush.h>
  #include <asm/uaccess.h>

@@ -238,46 +239,37 @@
  }

  /* Ensure all existing pages follow the policy. */
+
+struct verify_pages_struct
+{
+	unsigned long *nodes;
+};
+
+int verify_page(struct mm_struct *mm, pte_t *pte, unsigned long address, 
void *data)
+{
+	struct page *p;
+	unsigned long *nodes = ((struct verify_pages_struct 
*)data)->nodes;
+
+	p = NULL;
+	if (pte_present(*pte))
+		p = pte_page(*pte);
+	pte_unmap(pte);
+	if (p) {
+		unsigned nid = page_to_nid(p);
+		if (!test_bit(nid, nodes))
+			return -EIO;
+	}
+	return 0;
+}
+
  static int
  verify_pages(struct mm_struct *mm,
  	     unsigned long addr, unsigned long end, unsigned long *nodes)
  {
-	while (addr < end) {
-		struct page *p;
-		pte_t *pte;
-		pmd_t *pmd;
-		pud_t *pud;
-		pgd_t *pgd;
-		pgd = pgd_offset(mm, addr);
-		if (pgd_none(*pgd)) {
-			unsigned long next = (addr + PGDIR_SIZE) & 
PGDIR_MASK;
-			if (next > addr)
-				break;
-			addr = next;
-			continue;
-		}
-		pud = pud_offset(pgd, addr);
-		if (pud_none(*pud)) {
-			addr = (addr + PUD_SIZE) & PUD_MASK;
-			continue;
-		}
-		pmd = pmd_offset(pud, addr);
-		if (pmd_none(*pmd)) {
-			addr = (addr + PMD_SIZE) & PMD_MASK;
-			continue;
-		}
-		p = NULL;
-		pte = pte_offset_map(pmd, addr);
-		if (pte_present(*pte))
-			p = pte_page(*pte);
-		pte_unmap(pte);
-		if (p) {
-			unsigned nid = page_to_nid(p);
-			if (!test_bit(nid, nodes))
-				return -EIO;
-		}
-		addr += PAGE_SIZE;
-	}
+	struct verify_pages_struct data;
+
+	data.nodes = nodes;
+	page_table_read_iterator(mm, addr, end, verify_page, &data);
  	return 0;
  }

Index: linux-2.6.12-rc4/include/mm/mlpt-iterators.h
===================================================================
--- linux-2.6.12-rc4.orig/include/mm/mlpt-iterators.h	2005-05-19 
18:12:36.000000000 +1000
+++ linux-2.6.12-rc4/include/mm/mlpt-iterators.h	2005-05-19 
18:27:40.000000000 +1000
@@ -344,5 +344,8 @@
  	return 0;
  }

+#define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
+#define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
+

  #endif
Index: linux-2.6.12-rc4/mm/rmap.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/rmap.c	2005-05-19 18:01:20.000000000 
+1000
+++ linux-2.6.12-rc4/mm/rmap.c	2005-05-19 18:27:40.000000000 +1000
@@ -609,22 +609,63 @@
   * there there won't be many ptes located within the scan cluster.  In 
this case
   * maybe we could scan further - to the end of the pte page, perhaps.
   */
-#define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
-#define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
+
+struct unmap_cluster_struct
+{
+	unsigned int *mapcount;
+	struct vm_area_struct *vma;
+};
+
+int unmap_cluster(struct mm_struct *mm, pte_t *pte, unsigned long 
address, void *data)
+{
+	unsigned int *mapcount = ((struct unmap_cluster_struct 
*)data)->mapcount;
+	struct vm_area_struct *vma = ((struct unmap_cluster_struct 
*)data)->vma;
+
+	unsigned long pfn;
+	struct page *page;
+	pte_t pteval;
+
+	if (!pte_present(*pte))
+		return 0;
+
+	pfn = pte_pfn(*pte);
+	if (!pfn_valid(pfn))
+		return 0;
+
+	page = pfn_to_page(pfn);
+	BUG_ON(PageAnon(page));
+	if (PageReserved(page))
+		return 0;
+
+	if (ptep_clear_flush_young(vma, address, pte))
+		return 0;
+
+	/* Nuke the page table entry. */
+	flush_cache_page(vma, address, pfn);
+	pteval = ptep_clear_flush(vma, address, pte);
+
+	/* If nonlinear, store the file page offset in the pte. */
+	if (page->index != linear_page_index(vma, address))
+		set_pte_at(mm, address, pte, pgoff_to_pte(page->index));
+
+	/* Move the dirty bit to the physical page now the pte is gone. */
+	if (pte_dirty(pteval))
+		set_page_dirty(page);
+
+	page_remove_rmap(page);
+	page_cache_release(page);
+	dec_mm_counter(mm, rss);
+	(*mapcount)--;
+	return 0;
+}

  static void try_to_unmap_cluster(unsigned long cursor,
  	unsigned int *mapcount, struct vm_area_struct *vma)
  {
  	struct mm_struct *mm = vma->vm_mm;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-	pte_t pteval;
-	struct page *page;
  	unsigned long address;
  	unsigned long end;
-	unsigned long pfn;
+	struct unmap_cluster_struct data;

  	/*
  	 * We need the page_table_lock to protect us from page faults,
@@ -639,56 +680,10 @@
  	if (end > vma->vm_end)
  		end = vma->vm_end;

-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		goto out_unlock;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		goto out_unlock;
-
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
-		goto out_unlock;
-
-	for (pte = pte_offset_map(pmd, address);
-			address < end; pte++, address += PAGE_SIZE) {
-
-		if (!pte_present(*pte))
-			continue;
-
-		pfn = pte_pfn(*pte);
-		if (!pfn_valid(pfn))
-			continue;
-
-		page = pfn_to_page(pfn);
-		BUG_ON(PageAnon(page));
-		if (PageReserved(page))
-			continue;
-
-		if (ptep_clear_flush_young(vma, address, pte))
-			continue;
-
-		/* Nuke the page table entry. */
-		flush_cache_page(vma, address, pfn);
-		pteval = ptep_clear_flush(vma, address, pte);
-
-		/* If nonlinear, store the file page offset in the pte. */
-		if (page->index != linear_page_index(vma, address))
-			set_pte_at(mm, address, pte, 
pgoff_to_pte(page->index));
-
-		/* Move the dirty bit to the physical page now the pte is 
gone. */
-		if (pte_dirty(pteval))
-			set_page_dirty(page);
-
-		page_remove_rmap(page);
-		page_cache_release(page);
-		dec_mm_counter(mm, rss);
-		(*mapcount)--;
-	}
+	data.mapcount =	mapcount;
+	data.vma = vma;
+	page_table_read_iterator(mm, address, end, unmap_cluster, &data);

-	pte_unmap(pte);
-out_unlock:
  	spin_unlock(&mm->page_table_lock);
  }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
