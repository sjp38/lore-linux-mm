Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 849B16B005A
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 05:55:04 -0400 (EDT)
Date: Thu, 18 Jun 2009 17:56:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] HWPOISON: only early kill processes who installed
	SIGBUS handler
Message-ID: <20090618095644.GA1422@localhost>
References: <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost> <20090615064447.GA18390@wotan.suse.de> <20090615070914.GC31969@one.firstfloor.org> <20090615071907.GA8665@wotan.suse.de> <20090615121001.GA10944@localhost> <20090615122528.GA13256@wotan.suse.de> <20090615142225.GA11167@localhost> <20090617063702.GA20922@localhost> <20090617080404.GB31192@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090617080404.GB31192@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 17, 2009 at 04:04:04PM +0800, Nick Piggin wrote:
> On Wed, Jun 17, 2009 at 02:37:02PM +0800, Wu Fengguang wrote:
> > On Mon, Jun 15, 2009 at 10:22:25PM +0800, Wu Fengguang wrote:
> > > On Mon, Jun 15, 2009 at 08:25:28PM +0800, Nick Piggin wrote:
> > > > On Mon, Jun 15, 2009 at 08:10:01PM +0800, Wu Fengguang wrote:
> > > > > On Mon, Jun 15, 2009 at 03:19:07PM +0800, Nick Piggin wrote:
> > > > > > > For KVM you need early kill, for the others it remains to be seen.
> > > > > > 
> > > > > > Right. It's almost like you need to do a per-process thing, and
> > > > > > those that can handle things (such as the new SIGBUS or the new
> > > > > > EIO) could get those, and others could be killed.
> > > > > 
> > > > > To send early SIGBUS kills to processes who has called
> > > > > sigaction(SIGBUS, ...)?  KVM will sure do that. For other apps we
> > > > > don't mind they can understand that signal at all.
> > > > 
> > > > For apps that hook into SIGBUS for some other means and
> > > 
> > > Yes I was referring to the sigaction(SIGBUS) apps, others will
> > > be late killed anyway.
> > > 
> > > > do not understand the new type of SIGBUS signal? What about
> > > > those?
> > > 
> > > We introduced two new SIGBUS codes:
> > >         BUS_MCEERR_AO=5         for early kill
> > >         BUS_MCEERR_AR=4         for late  kill
> > > I'd assume a legacy application will handle them in the same way (both
> > > are unexpected code to the application).
> > > 
> > > We don't care whether the application can be killed by BUS_MCEERR_AO
> > > or BUS_MCEERR_AR depending on its SIGBUS handler implementation.
> > > But (in the rare case) if the handler
> > > - refused to die on BUS_MCEERR_AR, it may create a busy loop and
> > >   flooding of SIGBUS signals, which is a bug of the application.
> > >   BUS_MCEERR_AO is one time and won't lead to busy loops.
> > > - does something that hurts itself (ie. data safety) on BUS_MCEERR_AO,
> > >   it may well hurt the same way on BUS_MCEERR_AR. The latter one is
> > >   unavoidable, so the application must be fixed anyway.
> > 
> > This patch materializes the automatically early kill idea.
> > It aims to remove the vm.memory_failure_ealy_kill sysctl parameter.
> > 
> > This is mainly a policy change, please comment.
> 
> Well then you can still early-kill random apps that did not
> want it, and you may still cause problems if its sigbus
> handler does something nontrivial.
> 
> Can you use a prctl or something so it can expclitly
> register interest in this?

OK, this patch allows one to request early kill by calling
prctl(PR_MEMORY_FAILURE_EARLY_KILL, 1, ...).

Now either app or admin can choose to enable/disable early kill on
a per-process basis. But still, an admin won't be able to change the
behavior of an application who calls prctl() to set the option by itself.

Thanks,
Fengguang

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
+#define PF_EARLY_KILL	0x00004000	/* early kill me on memory failure */
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
@@ -205,6 +205,14 @@ static void kill_procs_ao(struct list_he
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
@@ -222,7 +230,7 @@ static void collect_procs_anon(struct pa
 		goto out;
 
 	for_each_process (tsk) {
-		if (!tsk->mm)
+		if (!task_early_kill_elegible(tsk))
 			continue;
 		list_for_each_entry (vma, &av->head, anon_vma_node) {
 			if (!page_mapped_in_vma(page, vma))
@@ -262,7 +270,7 @@ static void collect_procs_file(struct pa
 	for_each_process(tsk) {
 		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 
-		if (!tsk->mm)
+		if (!task_early_kill_elegible(tsk))
 			continue;
 
 		vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
