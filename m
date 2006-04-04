Date: Mon, 3 Apr 2006 23:58:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060404065800.24532.61232.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 4/6] Swapless V1: remove migration ptes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, lhms-devel@lists.sourceforge.net, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add ability to remove migration ptes.

1. Modify page_check_address to support matching on ptes with
   SWP_TYPE_MIGRATION

2. Add functions to scan the anon vma and replace SWAP_TYPE_MIGRATION
   ptes with regular ones.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc1/mm/rmap.c
===================================================================
--- linux-2.6.17-rc1.orig/mm/rmap.c	2006-04-03 22:50:00.000000000 -0700
+++ linux-2.6.17-rc1/mm/rmap.c	2006-04-03 22:57:08.000000000 -0700
@@ -291,7 +291,7 @@ pte_t *page_check_address(struct page *p
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *pte;
+	pte_t *ptep, pte;
 	spinlock_t *ptl;
 
 	pgd = pgd_offset(mm, address);
@@ -306,23 +306,84 @@ pte_t *page_check_address(struct page *p
 	if (!pmd_present(*pmd))
 		return NULL;
 
-	pte = pte_offset_map(pmd, address);
+	ptep = pte_offset_map(pmd, address);
+	pte = *ptep;
 	/* Make a quick check before getting the lock */
-	if (!pte_present(*pte)) {
-		pte_unmap(pte);
+	if (pte_none(pte) || pte_file(pte)) {
+		pte_unmap(ptep);
 		return NULL;
 	}
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
-	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
-		*ptlp = ptl;
-		return pte;
+	if (pte_present(pte)) {
+		if (page_to_pfn(page) == pte_pfn(pte)) {
+			*ptlp = ptl;
+			return ptep;
+		}
+	} else {
+		/* Could still be a migration entry pointing to the page */
+		swp_entry_t entry = pte_to_swp_entry(pte);
+
+		if (swp_type(entry) == SWP_TYPE_MIGRATION &&
+			swp_offset(entry) == page_to_pfn(page)) {
+				*ptlp = ptl;
+				return ptep;
+		}
 	}
 	pte_unmap_unlock(pte, ptl);
 	return NULL;
 }
 
+#ifdef CONFIG_MIGRATION
+/*
+ * Restore a potential migration pte to a working pte entry for
+ * anonymous pages.
+ */
+static void remove_migration_pte(struct vm_area_struct *vma, unsigned long addr,
+		struct page *old, struct page *new)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t *ptep;
+	spinlock_t *ptl;
+
+	ptep = page_check_address(old, mm, addr, &ptl);
+	if (!ptep)
+		return;
+
+	get_page(new);
+	set_pte_at(mm, addr, ptep, pte_mkold(mk_pte(new, vma->vm_page_prot)));
+	page_add_anon_rmap(new, vma, addr);
+
+	spin_unlock(ptl);
+}
+
+/*
+ * Get rid of all migration entries and replace them by
+ * references to the indicated page.
+ *
+ * Must hold mmap_sem lock on at least one of the vmas containing
+ * the page so that the anon_vma cannot vanish.
+ */
+void remove_migration_ptes(struct page *page, struct page *newpage)
+{
+	struct anon_vma *anon_vma;
+	struct vm_area_struct *vma;
+
+	if (!PageAnon(newpage))
+		return;
+
+	anon_vma = page_lock_anon_vma(newpage);
+	BUG_ON(!anon_vma);
+
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
+		remove_migration_pte(vma, page_address_in_vma(newpage, vma),
+				page, newpage);
+
+	spin_unlock(&anon_vma->lock);
+}
+#endif
+
 /*
  * Subfunctions of page_referenced: page_referenced_one called
  * repeatedly from either page_referenced_anon or page_referenced_file.
Index: linux-2.6.17-rc1/include/linux/rmap.h
===================================================================
--- linux-2.6.17-rc1.orig/include/linux/rmap.h	2006-04-02 20:22:10.000000000 -0700
+++ linux-2.6.17-rc1/include/linux/rmap.h	2006-04-03 22:57:08.000000000 -0700
@@ -105,6 +105,11 @@ pte_t *page_check_address(struct page *,
  */
 unsigned long page_address_in_vma(struct page *, struct vm_area_struct *);
 
+/*
+ * Used by page migration to restore ptes of anonymous pages
+ */
+void remove_migration_ptes(struct page *page, struct page *newpage);
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
