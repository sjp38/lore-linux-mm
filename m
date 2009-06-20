From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 12/15] HWPOISON: per process early kill option prctl(PR_MEMORY_FAILURE_EARLY_KILL)
Date: Sat, 20 Jun 2009 11:16:20 +0800
Message-ID: <20090620031626.237671605@intel.com>
References: <20090620031608.624240019@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756124AbZFTDUP@vger.kernel.org>
Content-Disposition: inline; filename=hwpoison-prctl-early-kill.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

This allows an application to request for early SIGBUS.BUS_MCEERR_AO
notification as soon as memory corruption in its virtual address space is
detected.

The default option is late kill, ie. only kill the process when it actually
tries to access the corrupted data. But an admin can still request a legacy
application to be early killed by writing a wrapper tool which calls prctl()
and exec the application:

	# this_app_shall_be_early_killed  legacy_app

KVM needs the early kill signal. At early kill time it has good opportunity
to isolate the corruption in guest kernel pages. It will be too late to do
anything useful on late kill.

Proposed by Nick Pidgin.

Cc: Nick Piggin <npiggin@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/prctl.h |    6 ++++++
 include/linux/sched.h |    1 +
 kernel/sys.c          |    6 ++++++
 mm/memory-failure.c   |   12 ++++++++++--
 4 files changed, 23 insertions(+), 2 deletions(-)

--- sound-2.6.orig/include/linux/prctl.h
+++ sound-2.6/include/linux/prctl.h
@@ -88,4 +88,10 @@
 #define PR_TASK_PERF_COUNTERS_DISABLE		31
 #define PR_TASK_PERF_COUNTERS_ENABLE		32
 
+/*
+ * Send early SIGBUS.BUS_MCEERR_AO notification on memory corruption?
+ * Useful for KVM and mission critical apps.
+ */
+#define PR_MEMORY_FAILURE_EARLY_KILL		33
+
 #endif /* _LINUX_PRCTL_H */
--- sound-2.6.orig/include/linux/sched.h
+++ sound-2.6/include/linux/sched.h
@@ -1666,6 +1666,7 @@ extern cputime_t task_gtime(struct task_
 #define PF_MEMALLOC	0x00000800	/* Allocating memory */
 #define PF_FLUSHER	0x00001000	/* responsible for disk writeback */
 #define PF_USED_MATH	0x00002000	/* if unset the fpu must be initialized before use */
+#define PF_EARLY_KILL	0x00004000	/* kill me early on memory failure */
 #define PF_NOFREEZE	0x00008000	/* this thread should not be frozen */
 #define PF_FROZEN	0x00010000	/* frozen for system suspend */
 #define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
--- sound-2.6.orig/kernel/sys.c
+++ sound-2.6/kernel/sys.c
@@ -1545,6 +1545,12 @@ SYSCALL_DEFINE5(prctl, int, option, unsi
 				current->timer_slack_ns = arg2;
 			error = 0;
 			break;
+		case PR_MEMORY_FAILURE_EARLY_KILL:
+			if (arg2)
+				me->flags |= PF_EARLY_KILL;
+			else
+				me->flags &= ~PF_EARLY_KILL;
+			break;
 		default:
 			error = -EINVAL;
 			break;
--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -214,6 +214,14 @@ static void kill_procs_ao(struct list_he
 	}
 }
 
+static bool task_early_kill_elegible(struct task_struct *tsk)
+{
+	if (!tsk->mm)
+		return false;
+
+	return tsk->flags & PF_EARLY_KILL;
+}
+
 /*
  * Collect processes when the error hit an anonymous page.
  */
@@ -231,7 +239,7 @@ static void collect_procs_anon(struct pa
 		goto out;
 
 	for_each_process (tsk) {
-		if (!tsk->mm)
+		if (!task_early_kill_elegible(tsk))
 			continue;
 		list_for_each_entry (vma, &av->head, anon_vma_node) {
 			if (!page_mapped_in_vma(page, vma))
@@ -271,7 +279,7 @@ static void collect_procs_file(struct pa
 	for_each_process(tsk) {
 		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 
-		if (!tsk->mm)
+		if (!task_early_kill_elegible(tsk))
 			continue;
 
 		vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff,

-- 
