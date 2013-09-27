Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 96DC06B0039
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:00 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so2769671pab.20
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:00 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/63] mm: Wait for THP migrations to complete during NUMA hinting faults
Date: Fri, 27 Sep 2013 14:26:50 +0100
Message-Id: <1380288468-5551-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The locking for migrating THP is unusual. While normal page migration
prevents parallel accesses using a migration PTE, THP migration relies on
a combination of the page_table_lock, the page lock and the existance of
the NUMA hinting PTE to guarantee safety but there is a bug in the scheme.

If a THP page is currently being migrated and another thread traps a
fault on the same page it checks if the page is misplaced. If it is not,
then pmd_numa is cleared. The problem is that it checks if the page is
misplaced without holding the page lock meaning that the racing thread
can be migrating the THP when the second thread clears the NUMA bit
and faults a stale page.

This patch checks if the page is potentially being migrated and stalls
using the lock_page if it is potentially being migrated before checking
if the page is misplaced or not.

Not-signed-off-by: Peter Zijlstra
---
 mm/huge_memory.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5c37cd2..d0a3fce 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1307,13 +1307,14 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (current_nid == numa_node_id())
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
-	target_nid = mpol_misplaced(page, vma, haddr);
-	if (target_nid == -1) {
-		put_page(page);
-		goto clear_pmdnuma;
-	}
+	/*
+	 * Acquire the page lock to serialise THP migrations but avoid dropping
+	 * page_table_lock if at all possible
+	 */
+	if (trylock_page(page))
+		goto got_lock;
 
-	/* Acquire the page lock to serialise THP migrations */
+	/* Serialise against migrationa and check placement check placement */
 	spin_unlock(&mm->page_table_lock);
 	lock_page(page);
 
@@ -1324,9 +1325,17 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		put_page(page);
 		goto out_unlock;
 	}
-	spin_unlock(&mm->page_table_lock);
+
+got_lock:
+	target_nid = mpol_misplaced(page, vma, haddr);
+	if (target_nid == -1) {
+		unlock_page(page);
+		put_page(page);
+		goto clear_pmdnuma;
+	}
 
 	/* Migrate the THP to the requested node */
+	spin_unlock(&mm->page_table_lock);
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
 				pmdp, pmd, addr, page, target_nid);
 	if (!migrated)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
