Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2F0336B0055
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 05:27:37 -0400 (EDT)
Date: Mon, 22 Jun 2009 17:27:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 12/15] HWPOISON: per process early kill option
	prctl(PR_MEMORY_FAILURE_EARLY_KILL)
Message-ID: <20090622092754.GC8110@localhost>
References: <20090620031608.624240019@intel.com> <20090620031626.237671605@intel.com> <20090621085212.GC8218@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090621085212.GC8218@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 21, 2009 at 04:52:12PM +0800, Andi Kleen wrote:
> On Sat, Jun 20, 2009 at 11:16:20AM +0800, Wu Fengguang wrote:
> > The default option is late kill, ie. only kill the process when it actually
> > tries to access the corrupted data. But an admin can still request a legacy
> > application to be early killed by writing a wrapper tool which calls prctl()
> > and exec the application:
> > 
> > 	# this_app_shall_be_early_killed  legacy_app
> > 
> > KVM needs the early kill signal. At early kill time it has good opportunity
> > to isolate the corruption in guest kernel pages. It will be too late to do
> > anything useful on late kill.
> > 
> > Proposed by Nick Pidgin.
> 
> If anything you would need two flags per process: one to signify
> that the application set the flag and another what the actual
> value is.

OK.

> Also you broke the existing qemu implementation now which obviously
> doesn't know about this new flag.

Yes, it is.

> I don't think we need this patch right now.

There must be a policy and maybe a parameter.
Till now there are three schemes:

A) default to early kill; export vm.memory_failure_early_kill
B) default to late kill; export prctl() parameters
C) early kill if SIGBUS handler is installed, otherwise late kill;
   no parameters is exported.

If we don't do this patch, what would be your preferred policy?

> > +static bool task_early_kill_elegible(struct task_struct *tsk)
> > +{
> > +	if (!tsk->mm)
> > +		return false;
> 
> I don't think this can happen.

It's for skipping kernel threads, you wrote that code :)

> > +
> > +	return tsk->flags & PF_EARLY_KILL;
> 
> This type mixing is also dangerous, if someone create e.g. a char bool
> it would be always false.

That's right. Here is the updated patch.

---
HWPOISON: per process early kill option prctl(PR_SET_MEMORY_FAILURE_EARLY_KILL)

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
 include/linux/prctl.h |    7 +++++++
 include/linux/sched.h |    1 +
 kernel/sys.c          |    9 +++++++++
 mm/memory-failure.c   |   12 ++++++++++--
 4 files changed, 27 insertions(+), 2 deletions(-)

--- sound-2.6.orig/include/linux/prctl.h
+++ sound-2.6/include/linux/prctl.h
@@ -88,4 +88,11 @@
 #define PR_TASK_PERF_COUNTERS_DISABLE		31
 #define PR_TASK_PERF_COUNTERS_ENABLE		32
 
+/*
+ * Send early SIGBUS.BUS_MCEERR_AO notification on memory corruption?
+ * Useful for KVM and mission critical apps.
+ */
+#define PR_SET_MEMORY_FAILURE_EARLY_KILL	33
+#define PR_GET_MEMORY_FAILURE_EARLY_KILL	34
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
@@ -1545,6 +1545,15 @@ SYSCALL_DEFINE5(prctl, int, option, unsi
 				current->timer_slack_ns = arg2;
 			error = 0;
 			break;
+		case PR_GET_MEMORY_FAILURE_EARLY_KILL:
+			error = !!(me->flags & PF_EARLY_KILL);
+			break;
+		case PR_SET_MEMORY_FAILURE_EARLY_KILL:
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
+	return !!(tsk->flags & PF_EARLY_KILL);
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
