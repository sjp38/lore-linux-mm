Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2F16B0039
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:29:51 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so7146727pab.41
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:29:51 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/63] mm: Prevent parallel splits during THP migration
Date: Mon,  7 Oct 2013 11:28:44 +0100
Message-Id: <1381141781-10992-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

THP migrations are serialised by the page lock but on its own that does
not prevent THP splits. If the page is split during THP migration then
the pmd_same checks will prevent page table corruption but the unlock page
and other fix-ups potentially will cause corruption. This patch takes the
anon_vma lock to prevent parallel splits during migration.

Cc: stable <stable@vger.kernel.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 44 ++++++++++++++++++++++++++++++--------------
 1 file changed, 30 insertions(+), 14 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f362363..1d6334f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1278,18 +1278,18 @@ out:
 int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp)
 {
+	struct anon_vma *anon_vma = NULL;
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
 	int target_nid;
 	int current_nid = -1;
-	bool migrated;
+	bool migrated, page_locked;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
 		goto out_unlock;
 
 	page = pmd_page(pmd);
-	get_page(page);
 	current_nid = page_to_nid(page);
 	count_vm_numa_event(NUMA_HINT_FAULTS);
 	if (current_nid == numa_node_id())
@@ -1299,12 +1299,29 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * Acquire the page lock to serialise THP migrations but avoid dropping
 	 * page_table_lock if at all possible
 	 */
-	if (trylock_page(page))
-		goto got_lock;
+	page_locked = trylock_page(page);
+	target_nid = mpol_misplaced(page, vma, haddr);
+	if (target_nid == -1) {
+		/* If the page was locked, there are no parallel migrations */
+		if (page_locked) {
+			unlock_page(page);
+			goto clear_pmdnuma;
+		}
 
-	/* Serialise against migrationa and check placement check placement */
+		/* Otherwise wait for potential migrations and retry fault */
+		spin_unlock(&mm->page_table_lock);
+		wait_on_page_locked(page);
+		goto out;
+	}
+
+	/* Page is misplaced, serialise migrations and parallel THP splits */
+	get_page(page);
 	spin_unlock(&mm->page_table_lock);
-	lock_page(page);
+	if (!page_locked) {
+		lock_page(page);
+		page_locked = true;
+	}
+	anon_vma = page_lock_anon_vma_read(page);
 
 	/* Confirm the PMD did not change while page_table_lock was released */
 	spin_lock(&mm->page_table_lock);
@@ -1314,14 +1331,6 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_unlock;
 	}
 
-got_lock:
-	target_nid = mpol_misplaced(page, vma, haddr);
-	if (target_nid == -1) {
-		unlock_page(page);
-		put_page(page);
-		goto clear_pmdnuma;
-	}
-
 	/* Migrate the THP to the requested node */
 	spin_unlock(&mm->page_table_lock);
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
@@ -1330,6 +1339,8 @@ got_lock:
 		goto check_same;
 
 	task_numa_fault(target_nid, HPAGE_PMD_NR, true);
+	if (anon_vma)
+		page_unlock_anon_vma_read(anon_vma);
 	return 0;
 
 check_same:
@@ -1346,6 +1357,11 @@ clear_pmdnuma:
 	update_mmu_cache_pmd(vma, addr, pmdp);
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
+
+out:
+	if (anon_vma)
+		page_unlock_anon_vma_read(anon_vma);
+
 	if (current_nid != -1)
 		task_numa_fault(current_nid, HPAGE_PMD_NR, false);
 	return 0;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
