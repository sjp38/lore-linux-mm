Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4AFFD900007
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:06 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so2787412pab.31
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:05 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/63] mm: Close races between THP migration and PMD numa clearing
Date: Fri, 27 Sep 2013 14:26:56 +0100
Message-Id: <1380288468-5551-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

THP migration uses the page lock to guard against parallel allocations
but there are cases like this still open

Task A						Task B
do_huge_pmd_numa_page				do_huge_pmd_numa_page
lock_page
mpol_misplaced == -1
unlock_page
goto clear_pmdnuma
						lock_page
						mpol_misplaced == 2
						migrate_misplaced_transhuge
pmd = pmd_mknonnuma
set_pmd_at

During hours of testing, one crashed with weird errors and while I have
no direct evidence, I suspect something like the race above happened.
This patch extends the page lock to being held until the pmd_numa is
cleared to prevent migration starting in parallel while the pmd_numa is
being cleared. It also flushes the old pmd entry and orders pagetable
insertion before rmap insertion.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 33 +++++++++++++++------------------
 mm/migrate.c     | 19 +++++++++++--------
 2 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 485b534..ac5af18 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1316,24 +1316,25 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	target_nid = mpol_misplaced(page, vma, haddr);
 	if (target_nid == -1) {
 		/* If the page was locked, there are no parallel migrations */
-		if (page_locked) {
-			unlock_page(page);
+		if (page_locked)
 			goto clear_pmdnuma;
-		}
 
-		/* Otherwise wait for potential migrations and retry fault */
+		/*
+		 * Otherwise wait for potential migrations and retry. We do
+		 * relock and check_same as the page may no longer be mapped.
+		 * As the fault is being retried, do not account for it.
+		 */
 		spin_unlock(&mm->page_table_lock);
 		wait_on_page_locked(page);
+		page_nid = -1;
 		goto out;
 	}
 
 	/* Page is misplaced, serialise migrations and parallel THP splits */
 	get_page(page);
 	spin_unlock(&mm->page_table_lock);
-	if (!page_locked) {
+	if (!page_locked)
 		lock_page(page);
-		page_locked = true;
-	}
 	anon_vma = page_lock_anon_vma_read(page);
 
 	/* Confirm the PMD did not change while page_table_lock was released */
@@ -1341,32 +1342,28 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pmd_same(pmd, *pmdp))) {
 		unlock_page(page);
 		put_page(page);
+		page_nid = -1;
 		goto out_unlock;
 	}
 
-	/* Migrate the THP to the requested node */
+	/*
+	 * Migrate the THP to the requested node, returns with page unlocked
+	 * and pmd_numa cleared.
+	 */
 	spin_unlock(&mm->page_table_lock);
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
 				pmdp, pmd, addr, page, target_nid);
 	if (migrated)
 		page_nid = target_nid;
-	else
-		goto check_same;
 
 	goto out;
-
-check_same:
-	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(pmd, *pmdp))) {
-		/* Someone else took our fault */
-		page_nid = -1;
-		goto out_unlock;
-	}
 clear_pmdnuma:
+	BUG_ON(!PageLocked(page));
 	pmd = pmd_mknonnuma(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
 	VM_BUG_ON(pmd_numa(*pmdp));
 	update_mmu_cache_pmd(vma, addr, pmdp);
+	unlock_page(page);
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 6f0c244..a7146a0 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1710,12 +1710,12 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		unlock_page(new_page);
 		put_page(new_page);		/* Free it */
 
-		unlock_page(page);
+		/* Retake the callers reference and putback on LRU */
+		get_page(page);
 		putback_lru_page(page);
-
-		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
-		isolated = 0;
-		goto out;
+		mod_zone_page_state(page_zone(page),
+			 NR_ISOLATED_ANON + page_lru, -HPAGE_PMD_NR);
+		goto out_fail;
 	}
 
 	/*
@@ -1732,9 +1732,9 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 	entry = pmd_mkhuge(entry);
 
-	page_add_new_anon_rmap(new_page, vma, haddr);
-
+	pmdp_clear_flush(vma, address, pmd);
 	set_pmd_at(mm, haddr, pmd, entry);
+	page_add_new_anon_rmap(new_page, vma, haddr);
 	update_mmu_cache_pmd(vma, address, &entry);
 	page_remove_rmap(page);
 	/*
@@ -1753,7 +1753,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
 	count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
 
-out:
 	mod_zone_page_state(page_zone(page),
 			NR_ISOLATED_ANON + page_lru,
 			-HPAGE_PMD_NR);
@@ -1762,6 +1761,10 @@ out:
 out_fail:
 	count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
 out_dropref:
+	entry = pmd_mknonnuma(entry);
+	set_pmd_at(mm, haddr, pmd, entry);
+	update_mmu_cache_pmd(vma, address, &entry);
+
 	unlock_page(page);
 	put_page(page);
 	return 0;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
