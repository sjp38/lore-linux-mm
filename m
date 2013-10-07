Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id F1AF29C0034
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:36 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so7006344pde.10
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:36 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 56/63] sched: numa: be more careful about joining numa groups
Date: Mon,  7 Oct 2013 11:29:34 +0100
Message-Id: <1381141781-10992-57-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

Due to the way the pid is truncated, and tasks are moved between
CPUs by the scheduler, it is possible for the current task_numa_fault
to group together tasks that do not actually share memory together.

This patch adds a few easy sanity checks to task_numa_fault, joining
tasks together if they share the same tsk->mm, or if the fault was on
a page with an elevated mapcount, in a shared VMA.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  1 +
 kernel/sched/fair.c   | 16 +++++++++++-----
 mm/memory.c           |  7 +++++++
 3 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 390004b..b859621 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1444,6 +1444,7 @@ struct task_struct {
 
 #define TNF_MIGRATED	0x01
 #define TNF_NO_GROUP	0x02
+#define TNF_SHARED	0x04
 
 #ifdef CONFIG_NUMA_BALANCING
 extern void task_numa_fault(int last_node, int node, int pages, int flags);
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 88225b7..baa2276 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1381,7 +1381,7 @@ static void double_lock(spinlock_t *l1, spinlock_t *l2)
 	spin_lock_nested(l2, SINGLE_DEPTH_NESTING);
 }
 
-static void task_numa_group(struct task_struct *p, int cpupid)
+static void task_numa_group(struct task_struct *p, int cpupid, int flags)
 {
 	struct numa_group *grp, *my_grp;
 	struct task_struct *tsk;
@@ -1439,10 +1439,16 @@ static void task_numa_group(struct task_struct *p, int cpupid)
 	if (my_grp->nr_tasks == grp->nr_tasks && my_grp > grp)
 		goto unlock;
 
-	if (!get_numa_group(grp))
-		goto unlock;
+	/* Always join threads in the same process. */
+	if (tsk->mm == current->mm)
+		join = true;
+
+	/* Simple filter to avoid false positives due to PID collisions */
+	if (flags & TNF_SHARED)
+		join = true;
 
-	join = true;
+	if (join && !get_numa_group(grp))
+		join = false;
 
 unlock:
 	rcu_read_unlock();
@@ -1539,7 +1545,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 	} else {
 		priv = cpupid_match_pid(p, last_cpupid);
 		if (!priv && !(flags & TNF_NO_GROUP))
-			task_numa_group(p, last_cpupid);
+			task_numa_group(p, last_cpupid, flags);
 	}
 
 	/*
diff --git a/mm/memory.c b/mm/memory.c
index 9898eeb..823720c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3584,6 +3584,13 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!pte_write(pte))
 		flags |= TNF_NO_GROUP;
 
+	/*
+	 * Flag if the page is shared between multiple address spaces. This
+	 * is later used when determining whether to group tasks together
+	 */
+	if (page_mapcount(page) > 1 && (vma->vm_flags & VM_SHARED))
+		flags |= TNF_SHARED;
+
 	last_cpupid = page_cpupid_last(page);
 	page_nid = page_to_nid(page);
 	target_nid = numa_migrate_prep(page, vma, addr, page_nid);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
