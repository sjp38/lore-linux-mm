Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id ECFF76B0039
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 03:52:07 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so262017eek.29
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 00:52:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h45si2242642eeo.130.2013.12.03.00.52.07
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 00:52:07 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/15] mm: numa: Call MMU notifiers on THP migration
Date: Tue,  3 Dec 2013 08:51:52 +0000
Message-Id: <1386060721-3794-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1386060721-3794-1-git-send-email-mgorman@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

MMU notifiers must be called on THP page migration or secondary MMUs will
get very confused.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index c4743d6..3a87511 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -36,6 +36,7 @@
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
 #include <linux/balloon_compaction.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/tlbflush.h>
 
@@ -1703,12 +1704,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 				unsigned long address,
 				struct page *page, int node)
 {
-	unsigned long haddr = address & HPAGE_PMD_MASK;
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated = 0;
 	struct page *new_page = NULL;
 	struct mem_cgroup *memcg = NULL;
 	int page_lru = page_is_file_cache(page);
+	unsigned long mmun_start = address & HPAGE_PMD_MASK;
+	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
 	pmd_t orig_entry;
 
 	/*
@@ -1750,10 +1752,12 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
 fail_putback:
 		spin_unlock(&mm->page_table_lock);
+		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 		/* Reverse changes made by migrate_page_copy() */
 		if (TestClearPageActive(new_page))
@@ -1794,10 +1798,11 @@ fail_putback:
 	 * The SetPageUptodate on the new page and page_add_new_anon_rmap
 	 * guarantee the copy is visible before the pagetable update.
 	 */
-	flush_cache_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
-	page_add_new_anon_rmap(new_page, vma, haddr);
-	pmdp_clear_flush(vma, haddr, pmd);
-	set_pmd_at(mm, haddr, pmd, entry);
+	flush_cache_range(vma, mmun_start, mmun_end);
+	page_add_new_anon_rmap(new_page, vma, mmun_start);
+	pmdp_clear_flush(vma, mmun_start, pmd);
+	set_pmd_at(mm, mmun_start, pmd, entry);
+	flush_tlb_range(vma, mmun_start, mmun_end);
 	update_mmu_cache_pmd(vma, address, &entry);
 
 	if (page_count(page) != 2) {
@@ -1817,6 +1822,7 @@ fail_putback:
 	 */
 	mem_cgroup_end_migration(memcg, page, new_page, true);
 	spin_unlock(&mm->page_table_lock);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 	unlock_page(new_page);
 	unlock_page(page);
@@ -1837,7 +1843,7 @@ out_dropref:
 	spin_lock(&mm->page_table_lock);
 	if (pmd_same(*pmd, entry)) {
 		entry = pmd_mknonnuma(entry);
-		set_pmd_at(mm, haddr, pmd, entry);
+		set_pmd_at(mm, mmun_start, pmd, entry);
 		update_mmu_cache_pmd(vma, address, &entry);
 	}
 	spin_unlock(&mm->page_table_lock);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
