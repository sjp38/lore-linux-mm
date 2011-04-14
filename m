Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 53897900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 20:41:28 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3E0fP0O007056
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:41:25 -0700
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by hpaq1.eem.corp.google.com with ESMTP id p3E0fM3e027148
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:41:23 -0700
Received: by pxi19 with SMTP id 19so500072pxi.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:41:21 -0700 (PDT)
Date: Wed, 13 Apr 2011 17:41:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] oom: replace PF_OOM_ORIGIN with toggling oom_score_adj
In-Reply-To: <20110414090310.07FF.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104131740280.16515@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104131132240.5563@chino.kir.corp.google.com> <20110414090310.07FF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

There's a kernel-wide shortage of per-process flags, so it's always 
helpful to trim one when possible without incurring a significant 
penalty.  It's even more important when you're planning on adding a per-
process flag yourself, which I plan to do shortly for transparent 
hugepages.

PF_OOM_ORIGIN is used by ksm and swapoff to prefer current since it has a 
tendency to allocate large amounts of memory and should be preferred for 
killing over other tasks.  We'd rather immediately kill the task making 
the errant syscall rather than penalizing an innocent task.

This patch removes PF_OOM_ORIGIN since its behavior is equivalent to 
setting the process's oom_score_adj to OOM_SCORE_ADJ_MAX.

The process's old oom_score_adj is stored and then set to 
OOM_SCORE_ADJ_MAX during the time it used to have PF_OOM_ORIGIN.  The old 
value is then reinstated when the process should no longer be considered 
a high priority for oom killing.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: s/OOM_SCORE_ADJ_MIN/OOM_SCORE_ADJ_MAX/ as pointed out by
     KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

 include/linux/oom.h   |    2 ++
 include/linux/sched.h |    1 -
 mm/ksm.c              |    7 +++++--
 mm/oom_kill.c         |   28 +++++++++++++++++++---------
 mm/swapfile.c         |    6 ++++--
 5 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -40,6 +40,8 @@ enum oom_constraint {
 	CONSTRAINT_MEMCG,
 };
 
+extern int test_set_oom_score_adj(int new_val);
+
 extern unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 			const nodemask_t *nodemask, unsigned long totalpages);
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
diff --git a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1738,7 +1738,6 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
 #define PF_FROZEN	0x00010000	/* frozen for system suspend */
 #define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
 #define PF_KSWAPD	0x00040000	/* I am kswapd */
-#define PF_OOM_ORIGIN	0x00080000	/* Allocating much memory to others */
 #define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
 #define PF_KTHREAD	0x00200000	/* I am a kernel thread */
 #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
diff --git a/mm/ksm.c b/mm/ksm.c
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -35,6 +35,7 @@
 #include <linux/ksm.h>
 #include <linux/hash.h>
 #include <linux/freezer.h>
+#include <linux/oom.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -1894,9 +1895,11 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
 	if (ksm_run != flags) {
 		ksm_run = flags;
 		if (flags & KSM_RUN_UNMERGE) {
-			current->flags |= PF_OOM_ORIGIN;
+			int oom_score_adj;
+
+			oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
 			err = unmerge_and_remove_all_rmap_items();
-			current->flags &= ~PF_OOM_ORIGIN;
+			test_set_oom_score_adj(oom_score_adj);
 			if (err) {
 				ksm_run = KSM_RUN_STOP;
 				count = err;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -38,6 +38,25 @@ int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 static DEFINE_SPINLOCK(zone_scan_lock);
 
+int test_set_oom_score_adj(int new_val)
+{
+	struct sighand_struct *sighand = current->sighand;
+	int old_val;
+
+	spin_lock(&sighand->siglock);
+	old_val = current->signal->oom_score_adj;
+	if (new_val != old_val) {
+		if (new_val == OOM_SCORE_ADJ_MIN)
+			atomic_inc(&current->mm->oom_disable_count);
+		else if (old_val == OOM_SCORE_ADJ_MIN)
+			atomic_dec(&current->mm->oom_disable_count);
+		current->signal->oom_score_adj = new_val;
+	}
+	spin_unlock(&sighand->siglock);
+
+	return old_val;
+}
+
 #ifdef CONFIG_NUMA
 /**
  * has_intersects_mems_allowed() - check task eligiblity for kill
@@ -173,15 +192,6 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	}
 
 	/*
-	 * When the PF_OOM_ORIGIN bit is set, it indicates the task should have
-	 * priority for oom killing.
-	 */
-	if (p->flags & PF_OOM_ORIGIN) {
-		task_unlock(p);
-		return 1000;
-	}
-
-	/*
 	 * The memory controller may have a limit of 0 bytes, so avoid a divide
 	 * by zero, if necessary.
 	 */
diff --git a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -31,6 +31,7 @@
 #include <linux/syscalls.h>
 #include <linux/memcontrol.h>
 #include <linux/poll.h>
+#include <linux/oom.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -1555,6 +1556,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	struct address_space *mapping;
 	struct inode *inode;
 	char *pathname;
+	int oom_score_adj;
 	int i, type, prev;
 	int err;
 
@@ -1613,9 +1615,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	p->flags &= ~SWP_WRITEOK;
 	spin_unlock(&swap_lock);
 
-	current->flags |= PF_OOM_ORIGIN;
+	oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
 	err = try_to_unuse(type);
-	current->flags &= ~PF_OOM_ORIGIN;
+	test_set_oom_score_adj(oom_score_adj);
 
 	if (err) {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
