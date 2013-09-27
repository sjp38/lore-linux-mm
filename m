Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id B4B4F900026
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:38 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so2569532pbc.22
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:38 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 46/63] mm: numa: Do not group on RO pages
Date: Fri, 27 Sep 2013 14:27:31 +0100
Message-Id: <1380288468-5551-47-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <peterz@infradead.org>

And here's a little something to make sure not the whole world ends up
in a single group.

As while we don't migrate shared executable pages, we do scan/fault on
them. And since everybody links to libc, everybody ends up in the same
group.

[riel@redhat.com: mapcount 1]
Suggested-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  7 +++++--
 kernel/sched/fair.c   |  5 +++--
 mm/huge_memory.c      | 15 +++++++++++++--
 mm/memory.c           | 30 ++++++++++++++++++++++++++----
 4 files changed, 47 insertions(+), 10 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 4fad1f17..15888f5 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1434,13 +1434,16 @@ struct task_struct {
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
+#define TNF_MIGRATED	0x01
+#define TNF_NO_GROUP	0x02
+
 #ifdef CONFIG_NUMA_BALANCING
-extern void task_numa_fault(int last_node, int node, int pages, bool migrated);
+extern void task_numa_fault(int last_node, int node, int pages, int flags);
 extern pid_t task_numa_group_id(struct task_struct *p);
 extern void set_numabalancing_state(bool enabled);
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
-				   bool migrated)
+				   int flags)
 {
 }
 static inline pid_t task_numa_group_id(struct task_struct *p)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index abdbb7c..896cf87 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1361,9 +1361,10 @@ void task_numa_free(struct task_struct *p)
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int last_cpupid, int node, int pages, bool migrated)
+void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 {
 	struct task_struct *p = current;
+	bool migrated = flags & TNF_MIGRATED;
 	int priv;
 
 	if (!numabalancing_enabled)
@@ -1394,7 +1395,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, bool migrated)
 		priv = 1;
 	} else {
 		priv = cpupid_match_pid(p, last_cpupid);
-		if (!priv)
+		if (!priv && !(flags & TNF_NO_GROUP))
 			task_numa_group(p, last_cpupid);
 	}
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 048d4b2..aaf46dc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1297,6 +1297,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int target_nid, last_cpupid = -1;
 	bool page_locked;
 	bool migrated = false;
+	int flags = 0;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
@@ -1311,6 +1312,14 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
 	/*
+	 * Avoid grouping on DSO/COW pages in specific and RO pages
+	 * in general, RO pages shouldn't hurt as much anyway since
+	 * they can be in shared cache state.
+	 */
+	if (!pmd_write(pmd))
+		flags |= TNF_NO_GROUP;
+
+	/*
 	 * Acquire the page lock to serialise THP migrations but avoid dropping
 	 * page_table_lock if at all possible
 	 */
@@ -1355,8 +1364,10 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spin_unlock(&mm->page_table_lock);
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
 				pmdp, pmd, addr, page, target_nid);
-	if (migrated)
+	if (migrated) {
+		flags |= TNF_MIGRATED;
 		page_nid = target_nid;
+	}
 
 	goto out;
 clear_pmdnuma:
@@ -1374,7 +1385,7 @@ out:
 		page_unlock_anon_vma_read(anon_vma);
 
 	if (page_nid != -1)
-		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR, migrated);
+		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR, flags);
 
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index f779403..1aa4187 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3558,6 +3558,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int last_cpupid;
 	int target_nid;
 	bool migrated = false;
+	int flags = 0;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3586,6 +3587,14 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 	BUG_ON(is_zero_pfn(page_to_pfn(page)));
 
+	/*
+	 * Avoid grouping on DSO/COW pages in specific and RO pages
+	 * in general, RO pages shouldn't hurt as much anyway since
+	 * they can be in shared cache state.
+	 */
+	if (!pte_write(pte))
+		flags |= TNF_NO_GROUP;
+
 	last_cpupid = page_cpupid_last(page);
 	page_nid = page_to_nid(page);
 	target_nid = numa_migrate_prep(page, vma, addr, page_nid);
@@ -3597,12 +3606,14 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	/* Migrate to the requested node */
 	migrated = migrate_misplaced_page(page, vma, target_nid);
-	if (migrated)
+	if (migrated) {
 		page_nid = target_nid;
+		flags |= TNF_MIGRATED;
+	}
 
 out:
 	if (page_nid != -1)
-		task_numa_fault(last_cpupid, page_nid, 1, migrated);
+		task_numa_fault(last_cpupid, page_nid, 1, flags);
 	return 0;
 }
 
@@ -3643,6 +3654,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		int page_nid = -1;
 		int target_nid;
 		bool migrated = false;
+		int flags = 0;
 
 		if (!pte_present(pteval))
 			continue;
@@ -3662,20 +3674,30 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (unlikely(!page))
 			continue;
 
+		/*
+		 * Avoid grouping on DSO/COW pages in specific and RO pages
+		 * in general, RO pages shouldn't hurt as much anyway since
+		 * they can be in shared cache state.
+		 */
+		if (!pte_write(pteval))
+			flags |= TNF_NO_GROUP;
+
 		last_cpupid = page_cpupid_last(page);
 		page_nid = page_to_nid(page);
 		target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 		pte_unmap_unlock(pte, ptl);
 		if (target_nid != -1) {
 			migrated = migrate_misplaced_page(page, vma, target_nid);
-			if (migrated)
+			if (migrated) {
 				page_nid = target_nid;
+				flags |= TNF_MIGRATED;
+			}
 		} else {
 			put_page(page);
 		}
 
 		if (page_nid != -1)
-			task_numa_fault(last_cpupid, page_nid, 1, migrated);
+			task_numa_fault(last_cpupid, page_nid, 1, flags);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
