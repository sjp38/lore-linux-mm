Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 11C366B0031
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 22:03:59 -0400 (EDT)
Message-ID: <522FCF82.90403@redhat.com>
Date: Tue, 10 Sep 2013 22:03:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/50] Basic scheduler support for automatic NUMA balancing
 V7
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Content-Type: multipart/mixed;
 boundary="------------040901090407070100070706"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------040901090407070100070706
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 09/10/2013 05:31 AM, Mel Gorman wrote:
> It has been a long time since V6 of this series and time for an update. Much
> of this is now stabilised with the most important addition being the inclusion
> of Peter and Rik's work on grouping tasks that share pages together.
> 
> This series has a number of goals. It reduces overhead of automatic balancing
> through scan rate reduction and the avoidance of TLB flushes. It selects a
> preferred node and moves tasks towards their memory as well as moving memory
> toward their task. It handles shared pages and groups related tasks together.

The attached two patches should fix the task grouping issues
we discussed on #mm earlier.

Now on to the load balancer. When specjbb takes up way fewer
CPUs than what are available on a node, it is possible for
multiple specjbb processes to end up on the same NUMA node,
and the load balancer makes no attempt to move some of them
to completely idle loads.

I have not figured out yet how to fix that behaviour...

-- 
All rights reversed

--------------040901090407070100070706
Content-Type: text/x-patch;
 name="0061-exec-leave-numa-group.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0061-exec-leave-numa-group.patch"

Subject: sched,numa: call task_numa_free from do_execve

It is possible for a task in a numa group to call exec, and
have the new (unrelated) executable inherit the numa group
association from its former self.

This has the potential to break numa grouping, and is trivial
to fix.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 fs/exec.c             | 1 +
 include/linux/sched.h | 4 ++++
 kernel/sched/sched.h  | 5 -----
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index ffd7a81..a6da73b 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1548,6 +1548,7 @@ static int do_execve_common(const char *filename,
 	current->fs->in_exec = 0;
 	current->in_execve = 0;
 	acct_update_integrals(current);
+	task_numa_free(current);
 	free_bprm(bprm);
 	if (displaced)
 		put_files_struct(displaced);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 97df20f..44a7cc7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1453,6 +1453,7 @@ struct task_struct {
 extern void task_numa_fault(int last_node, int node, int pages, int flags);
 extern pid_t task_numa_group_id(struct task_struct *p);
 extern void set_numabalancing_state(bool enabled);
+extern void task_numa_free(struct task_struct *p);
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
 				   int flags)
@@ -1465,6 +1466,9 @@ static inline pid_t task_numa_group_id(struct task_struct *p)
 static inline void set_numabalancing_state(bool enabled)
 {
 }
+static inline void task_numa_free(struct task_struct *p)
+{
+}
 #endif
 
 static inline struct pid *task_pid(struct task_struct *task)
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 1fae56e..93fa176 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -559,11 +559,6 @@ static inline u64 rq_clock_task(struct rq *rq)
 extern void sched_setnuma(struct task_struct *p, int node);
 extern int migrate_task_to(struct task_struct *p, int cpu);
 extern int migrate_swap(struct task_struct *, struct task_struct *);
-extern void task_numa_free(struct task_struct *p);
-#else /* CONFIG_NUMA_BALANCING */
-static inline void task_numa_free(struct task_struct *p)
-{
-}
 #endif /* CONFIG_NUMA_BALANCING */
 
 #ifdef CONFIG_SMP

--------------040901090407070100070706
Content-Type: text/x-patch;
 name="0062-numa-join-group-carefully.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0062-numa-join-group-carefully.patch"

Subject: sched,numa: be more careful about joining numa groups

Due to the way the pid is truncated, and tasks are moved between
CPUs by the scheduler, it is possible for the current task_numa_fault
to group together tasks that do not actually share memory together.

This patch adds a few easy sanity checks to task_numa_fault, joining
tasks together if they share the same tsk->mm, or if the fault was on
a page with an elevated mapcount, in a shared VMA.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/sched.h |  6 ++++--
 kernel/sched/fair.c   | 23 +++++++++++++++++------
 mm/huge_memory.c      |  4 +++-
 mm/memory.c           |  8 ++++++--
 4 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 44a7cc7..de942a8 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1450,13 +1450,15 @@ struct task_struct {
 #define TNF_NO_GROUP	0x02
 
 #ifdef CONFIG_NUMA_BALANCING
-extern void task_numa_fault(int last_node, int node, int pages, int flags);
+extern void task_numa_fault(int last_node, int node, int pages, int flags,
+			    struct vm_area_struct *vma, int mapcount);
 extern pid_t task_numa_group_id(struct task_struct *p);
 extern void set_numabalancing_state(bool enabled);
 extern void task_numa_free(struct task_struct *p);
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
-				   int flags)
+				   int flags, struct vm_area_struct *vma,
+				   int mapcount)
 {
 }
 static inline pid_t task_numa_group_id(struct task_struct *p)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 8b3d877..22e859f 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1323,7 +1323,8 @@ static void double_lock(spinlock_t *l1, spinlock_t *l2)
 	spin_lock_nested(l2, SINGLE_DEPTH_NESTING);
 }
 
-static void task_numa_group(struct task_struct *p, int cpu, int pid)
+static void task_numa_group(struct task_struct *p, int cpu, int pid,
+			    struct vm_area_struct *vma, int mapcount)
 {
 	struct numa_group *grp, *my_grp;
 	struct task_struct *tsk;
@@ -1380,10 +1381,19 @@ static void task_numa_group(struct task_struct *p, int cpu, int pid)
 	if (my_grp->nr_tasks == grp->nr_tasks && my_grp > grp)
 		goto unlock;
 
-	if (!get_numa_group(grp))
-		goto unlock;
+	/* Always join threads in the same process. */
+	if (tsk->mm == current->mm)
+		join = true;
+
+	/*
+	 * Simple filter to avoid false positives due to PID collisions,
+	 * accesses on KSM shared pages, etc...
+	 */
+	if (mapcount > 1 && (vma->vm_flags & VM_SHARED))
+		join = true;
 
-	join = true;
+	if (join && !get_numa_group(grp))
+		join = false;
 
 unlock:
 	rcu_read_unlock();
@@ -1437,7 +1447,8 @@ void task_numa_free(struct task_struct *p)
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int last_cpupid, int node, int pages, int flags)
+void task_numa_fault(int last_cpupid, int node, int pages, int flags,
+		     struct vm_area_struct *vma, int mapcount)
 {
 	struct task_struct *p = current;
 	bool migrated = flags & TNF_MIGRATED;
@@ -1478,7 +1489,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 
 		priv = (pid == (p->pid & LAST__PID_MASK));
 		if (!priv && !(flags & TNF_NO_GROUP))
-			task_numa_group(p, cpu, pid);
+			task_numa_group(p, cpu, pid, vma, mapcount);
 	}
 
 	/*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6f883df..a175191 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1298,6 +1298,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	bool page_locked;
 	bool migrated = false;
 	int flags = 0;
+	int mapcount = 0;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
@@ -1306,6 +1307,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	page = pmd_page(pmd);
 	BUG_ON(is_huge_zero_page(page));
 	page_nid = page_to_nid(page);
+	mapcount = page_mapcount(page);
 	last_cpupid = page_cpupid_last(page);
 	count_vm_numa_event(NUMA_HINT_FAULTS);
 	if (page_nid == this_nid)
@@ -1388,7 +1390,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_unlock_anon_vma_read(anon_vma);
 
 	if (page_nid != -1)
-		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR, flags);
+		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR, flags, vma, mapcount);
 
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 2e1d43b..8cef83c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3545,6 +3545,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int target_nid;
 	bool migrated = false;
 	int flags = 0;
+	int mapcount = 0;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3583,6 +3584,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	last_cpupid = page_cpupid_last(page);
 	page_nid = page_to_nid(page);
+	mapcount = page_mapcount(page);
 	target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 	pte_unmap_unlock(ptep, ptl);
 	if (target_nid == -1) {
@@ -3599,7 +3601,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 out:
 	if (page_nid != -1)
-		task_numa_fault(last_cpupid, page_nid, 1, flags);
+		task_numa_fault(last_cpupid, page_nid, 1, flags, vma, mapcount);
 	return 0;
 }
 
@@ -3641,6 +3643,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		int target_nid;
 		bool migrated = false;
 		int flags = 0;
+		int mapcount;
 
 		if (!pte_present(pteval))
 			continue;
@@ -3670,6 +3673,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 		last_cpupid = page_cpupid_last(page);
 		page_nid = page_to_nid(page);
+		mapcount = page_mapcount(page);
 		target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 		pte_unmap_unlock(pte, ptl);
 		if (target_nid != -1) {
@@ -3683,7 +3687,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 
 		if (page_nid != -1)
-			task_numa_fault(last_cpupid, page_nid, 1, flags);
+			task_numa_fault(last_cpupid, page_nid, 1, flags, vma, mapcount);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}

--------------040901090407070100070706--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
