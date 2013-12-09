Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 92D066B0035
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 02:09:20 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so1336133eak.16
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 23:09:20 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e2si8231291eeg.93.2013.12.08.23.09.16
        for <linux-mm@kvack.org>;
        Sun, 08 Dec 2013 23:09:16 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/18] mm: numa: Call MMU notifiers on THP migration
Date: Mon,  9 Dec 2013 07:08:56 +0000
Message-Id: <1386572952-1191-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-1-git-send-email-mgorman@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

MMU notifiers must be called on THP page migration or secondary MMUs will
get very confused.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 2cabbd5..be787d5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -36,6 +36,7 @@
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
 #include <linux/balloon_compaction.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/tlbflush.h>
 
@@ -1716,12 +1717,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 				struct page *page, int node)
 {
 	spinlock_t *ptl;
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
@@ -1756,10 +1758,12 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
 fail_putback:
 		spin_unlock(ptl);
+		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 		/* Reverse changes made by migrate_page_copy() */
 		if (TestClearPageActive(new_page))
@@ -1800,15 +1804,16 @@ fail_putback:
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
-		set_pmd_at(mm, haddr, pmd, orig_entry);
-		flush_tlb_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
+		set_pmd_at(mm, mmun_start, pmd, orig_entry);
+		flush_tlb_range(vma, mmun_start, mmun_end);
 		update_mmu_cache_pmd(vma, address, &entry);
 		page_remove_rmap(new_page);
 		goto fail_putback;
@@ -1823,6 +1828,7 @@ fail_putback:
 	 */
 	mem_cgroup_end_migration(memcg, page, new_page, true);
 	spin_unlock(ptl);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 	unlock_page(new_page);
 	unlock_page(page);
@@ -1843,7 +1849,7 @@ out_dropref:
 	ptl = pmd_lock(mm, pmd);
 	if (pmd_same(*pmd, entry)) {
 		entry = pmd_mknonnuma(entry);
-		set_pmd_at(mm, haddr, pmd, entry);
+		set_pmd_at(mm, mmun_start, pmd, entry);
 		update_mmu_cache_pmd(vma, address, &entry);
 	}
 	spin_unlock(ptl);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
