Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 6F7A66B005A
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 04:27:03 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so2067994pbb.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 01:27:02 -0800 (PST)
Date: Thu, 8 Nov 2012 01:27:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm, oom: fix race when specifying a thread as the oom
 origin
In-Reply-To: <alpine.DEB.2.00.1211080125150.3450@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1211080126390.3450@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1211080125150.3450@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

test_set_oom_score_adj() and compare_swap_oom_score_adj() are used to
specify that current should be killed first if an oom condition occurs in
between the two calls.

The usage is

	short oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
	...
	compare_swap_oom_score_adj(OOM_SCORE_ADJ_MAX, oom_score_adj);

to store the thread's oom_score_adj, temporarily change it to the maximum
score possible, and then restore the old value if it is still the same.

This happens to still be racy, however, if the user writes
OOM_SCORE_ADJ_MAX to /proc/pid/oom_score_adj in between the two calls.
The compare_swap_oom_score_adj() will then incorrectly reset the old
value prior to the write of OOM_SCORE_ADJ_MAX.

To fix this, introduce a new oom_flags_t member in struct signal_struct
that will be used for per-thread oom killer flags.  KSM and swapoff can
now use a bit in this member to specify that threads should be killed
first in oom conditions without playing around with oom_score_adj.

This also allows the correct oom_score_adj to always be shown when
reading /proc/pid/oom_score.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h   |   19 +++++++++++++++++--
 include/linux/sched.h |    1 +
 include/linux/types.h |    1 +
 mm/ksm.c              |    7 ++-----
 mm/oom_kill.c         |   49 +++++++------------------------------------------
 mm/swapfile.c         |    5 ++---
 6 files changed, 30 insertions(+), 52 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -29,8 +29,23 @@ enum oom_scan_t {
 	OOM_SCAN_SELECT,	/* always select this thread first */
 };
 
-extern void compare_swap_oom_score_adj(short old_val, short new_val);
-extern short test_set_oom_score_adj(short new_val);
+/* Thread is the potential origin of an oom condition; kill first on oom */
+#define OOM_FLAG_ORIGIN		((__force oom_flags_t)0x1)
+
+static inline void set_current_oom_origin(void)
+{
+	current->signal->oom_flags |= OOM_FLAG_ORIGIN;
+}
+
+static inline void clear_current_oom_origin(void)
+{
+	current->signal->oom_flags &= ~OOM_FLAG_ORIGIN;
+}
+
+static inline bool oom_task_origin(const struct task_struct *p)
+{
+	return !!(p->signal->oom_flags & OOM_FLAG_ORIGIN);
+}
 
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
diff --git a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -631,6 +631,7 @@ struct signal_struct {
 	struct rw_semaphore group_rwsem;
 #endif
 
+	oom_flags_t oom_flags;
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
diff --git a/include/linux/types.h b/include/linux/types.h
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -156,6 +156,7 @@ typedef u32 dma_addr_t;
 #endif
 typedef unsigned __bitwise__ gfp_t;
 typedef unsigned __bitwise__ fmode_t;
+typedef unsigned __bitwise__ oom_flags_t;
 
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 typedef u64 phys_addr_t;
diff --git a/mm/ksm.c b/mm/ksm.c
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1929,12 +1929,9 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
 	if (ksm_run != flags) {
 		ksm_run = flags;
 		if (flags & KSM_RUN_UNMERGE) {
-			short oom_score_adj;
-
-			oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
+			set_current_oom_origin();
 			err = unmerge_and_remove_all_rmap_items();
-			compare_swap_oom_score_adj(OOM_SCORE_ADJ_MAX,
-								oom_score_adj);
+			clear_current_oom_origin();
 			if (err) {
 				ksm_run = KSM_RUN_STOP;
 				count = err;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -44,48 +44,6 @@ int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 static DEFINE_SPINLOCK(zone_scan_lock);
 
-/*
- * compare_swap_oom_score_adj() - compare and swap current's oom_score_adj
- * @old_val: old oom_score_adj for compare
- * @new_val: new oom_score_adj for swap
- *
- * Sets the oom_score_adj value for current to @new_val iff its present value is
- * @old_val.  Usually used to reinstate a previous value to prevent racing with
- * userspacing tuning the value in the interim.
- */
-void compare_swap_oom_score_adj(short old_val, short new_val)
-{
-	struct sighand_struct *sighand = current->sighand;
-
-	spin_lock_irq(&sighand->siglock);
-	if (current->signal->oom_score_adj == old_val)
-		current->signal->oom_score_adj = new_val;
-	trace_oom_score_adj_update(current);
-	spin_unlock_irq(&sighand->siglock);
-}
-
-/**
- * test_set_oom_score_adj() - set current's oom_score_adj and return old value
- * @new_val: new oom_score_adj value
- *
- * Sets the oom_score_adj value for current to @new_val with proper
- * synchronization and returns the old value.  Usually used to temporarily
- * set a value, save the old value in the caller, and then reinstate it later.
- */
-short test_set_oom_score_adj(short new_val)
-{
-	struct sighand_struct *sighand = current->sighand;
-	int old_val;
-
-	spin_lock_irq(&sighand->siglock);
-	old_val = current->signal->oom_score_adj;
-	current->signal->oom_score_adj = new_val;
-	trace_oom_score_adj_update(current);
-	spin_unlock_irq(&sighand->siglock);
-
-	return old_val;
-}
-
 #ifdef CONFIG_NUMA
 /**
  * has_intersects_mems_allowed() - check task eligiblity for kill
@@ -310,6 +268,13 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 	if (!task->mm)
 		return OOM_SCAN_CONTINUE;
 
+	/*
+	 * If task is allocating a lot of memory and has been marked to be
+	 * killed first if it triggers an oom, then select it.
+	 */
+	if (oom_task_origin(task))
+		return OOM_SCAN_SELECT;
+
 	if (task->flags & PF_EXITING) {
 		/*
 		 * If task is current and is in the process of releasing memory,
diff --git a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1484,7 +1484,6 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	struct address_space *mapping;
 	struct inode *inode;
 	struct filename *pathname;
-	short oom_score_adj;
 	int i, type, prev;
 	int err;
 
@@ -1544,9 +1543,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	p->flags &= ~SWP_WRITEOK;
 	spin_unlock(&swap_lock);
 
-	oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
+	set_current_oom_origin();
 	err = try_to_unuse(type, false, 0); /* force all pages to be unused */
-	compare_swap_oom_score_adj(OOM_SCORE_ADJ_MAX, oom_score_adj);
+	clear_current_oom_origin();
 
 	if (err) {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
