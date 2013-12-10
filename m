Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id C63B76B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:51:38 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id hq4so5529333wib.3
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:51:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id v6si4218320eel.133.2013.12.10.07.51.37
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 07:51:38 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 01/18] mm: numa: Serialise parallel get_user_page against THP migration
Date: Tue, 10 Dec 2013 15:51:19 +0000
Message-Id: <1386690695-27380-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Base pages are unmapped and flushed from cache and TLB during normal page
migration and replaced with a migration entry that causes any parallel or
gup to block until migration completes. THP does not unmap pages due to
a lack of support for migration entries at a PMD level. This allows races
with get_user_pages and get_user_pages_fast which commit 3f926ab94 ("mm:
Close races between THP migration and PMD numa clearing") made worse by
introducing a pmd_clear_flush().

This patch forces get_user_page (fast and normal) on a pmd_numa page to
go through the slow get_user_page path where it will serialise against THP
migration and properly account for the NUMA hinting fault. On the migration
side the page table lock is taken for each PTE update.

Cc: stable@vger.kernel.org
Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/mm/gup.c | 13 +++++++++++++
 mm/huge_memory.c  | 24 ++++++++++++++++--------
 mm/migrate.c      | 38 +++++++++++++++++++++++++++++++-------
 3 files changed, 60 insertions(+), 15 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index dd74e46..0596e8e 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -83,6 +83,12 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 		pte_t pte = gup_get_pte(ptep);
 		struct page *page;
 
+		/* Similar to the PMD case, NUMA hinting must take slow path */
+		if (pte_numa(pte)) {
+			pte_unmap(ptep);
+			return 0;
+		}
+
 		if ((pte_flags(pte) & (mask | _PAGE_SPECIAL)) != mask) {
 			pte_unmap(ptep);
 			return 0;
@@ -167,6 +173,13 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
 			return 0;
 		if (unlikely(pmd_large(pmd))) {
+			/*
+			 * NUMA hinting faults need to be handled in the GUP
+			 * slowpath for accounting purposes and so that they
+			 * can be serialised against THP migration.
+			 */
+			if (pmd_numa(pmd))
+				return 0;
 			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
 				return 0;
 		} else {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bccd5a6..deae592 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1243,6 +1243,10 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 	if ((flags & FOLL_DUMP) && is_huge_zero_pmd(*pmd))
 		return ERR_PTR(-EFAULT);
 
+	/* Full NUMA hinting faults to serialise migration in fault paths */
+	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
+		goto out;
+
 	page = pmd_page(*pmd);
 	VM_BUG_ON(!PageHead(page));
 	if (flags & FOLL_TOUCH) {
@@ -1323,23 +1327,27 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		/* If the page was locked, there are no parallel migrations */
 		if (page_locked)
 			goto clear_pmdnuma;
+	}
 
-		/*
-		 * Otherwise wait for potential migrations and retry. We do
-		 * relock and check_same as the page may no longer be mapped.
-		 * As the fault is being retried, do not account for it.
-		 */
+	/*
+	 * If there are potential migrations, wait for completion and retry. We
+	 * do not relock and check_same as the page may no longer be mapped.
+	 * Furtermore, even if the page is currently misplaced, there is no
+	 * guarantee it is still misplaced after the migration completes.
+	 */
+	if (!page_locked) {
 		spin_unlock(ptl);
 		wait_on_page_locked(page);
 		page_nid = -1;
 		goto out;
 	}
 
-	/* Page is misplaced, serialise migrations and parallel THP splits */
+	/*
+	 * Page is misplaced. Page lock serialises migrations. Acquire anon_vma
+	 * to serialises splits
+	 */
 	get_page(page);
 	spin_unlock(ptl);
-	if (!page_locked)
-		lock_page(page);
 	anon_vma = page_lock_anon_vma_read(page);
 
 	/* Confirm the PMD did not change while page_table_lock was released */
diff --git a/mm/migrate.c b/mm/migrate.c
index bb94004..2cabbd5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1722,6 +1722,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	struct page *new_page = NULL;
 	struct mem_cgroup *memcg = NULL;
 	int page_lru = page_is_file_cache(page);
+	pmd_t orig_entry;
 
 	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
@@ -1756,7 +1757,8 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 	/* Recheck the target PMD */
 	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_same(*pmd, entry))) {
+	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
+fail_putback:
 		spin_unlock(ptl);
 
 		/* Reverse changes made by migrate_page_copy() */
@@ -1786,16 +1788,34 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	 */
 	mem_cgroup_prepare_migration(page, new_page, &memcg);
 
+	orig_entry = *pmd;
 	entry = mk_pmd(new_page, vma->vm_page_prot);
-	entry = pmd_mknonnuma(entry);
-	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 	entry = pmd_mkhuge(entry);
+	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 
+	/*
+	 * Clear the old entry under pagetable lock and establish the new PTE.
+	 * Any parallel GUP will either observe the old page blocking on the
+	 * page lock, block on the page table lock or observe the new page.
+	 * The SetPageUptodate on the new page and page_add_new_anon_rmap
+	 * guarantee the copy is visible before the pagetable update.
+	 */
+	flush_cache_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
+	page_add_new_anon_rmap(new_page, vma, haddr);
 	pmdp_clear_flush(vma, haddr, pmd);
 	set_pmd_at(mm, haddr, pmd, entry);
-	page_add_new_anon_rmap(new_page, vma, haddr);
 	update_mmu_cache_pmd(vma, address, &entry);
+
+	if (page_count(page) != 2) {
+		set_pmd_at(mm, haddr, pmd, orig_entry);
+		flush_tlb_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
+		update_mmu_cache_pmd(vma, address, &entry);
+		page_remove_rmap(new_page);
+		goto fail_putback;
+	}
+
 	page_remove_rmap(page);
+
 	/*
 	 * Finish the charge transaction under the page table lock to
 	 * prevent split_huge_page() from dividing up the charge
@@ -1820,9 +1840,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 out_fail:
 	count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
 out_dropref:
-	entry = pmd_mknonnuma(entry);
-	set_pmd_at(mm, haddr, pmd, entry);
-	update_mmu_cache_pmd(vma, address, &entry);
+	ptl = pmd_lock(mm, pmd);
+	if (pmd_same(*pmd, entry)) {
+		entry = pmd_mknonnuma(entry);
+		set_pmd_at(mm, haddr, pmd, entry);
+		update_mmu_cache_pmd(vma, address, &entry);
+	}
+	spin_unlock(ptl);
 
 	unlock_page(page);
 	put_page(page);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
