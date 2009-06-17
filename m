Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 97B986B005A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 02:35:59 -0400 (EDT)
Date: Wed, 17 Jun 2009 14:37:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH] HWPOISON: only early kill processes who installed
	SIGBUS handler
Message-ID: <20090617063702.GA20922@localhost>
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost> <20090615064447.GA18390@wotan.suse.de> <20090615070914.GC31969@one.firstfloor.org> <20090615071907.GA8665@wotan.suse.de> <20090615121001.GA10944@localhost> <20090615122528.GA13256@wotan.suse.de> <20090615142225.GA11167@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615142225.GA11167@localhost>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 10:22:25PM +0800, Wu Fengguang wrote:
> On Mon, Jun 15, 2009 at 08:25:28PM +0800, Nick Piggin wrote:
> > On Mon, Jun 15, 2009 at 08:10:01PM +0800, Wu Fengguang wrote:
> > > On Mon, Jun 15, 2009 at 03:19:07PM +0800, Nick Piggin wrote:
> > > > > For KVM you need early kill, for the others it remains to be seen.
> > > > 
> > > > Right. It's almost like you need to do a per-process thing, and
> > > > those that can handle things (such as the new SIGBUS or the new
> > > > EIO) could get those, and others could be killed.
> > > 
> > > To send early SIGBUS kills to processes who has called
> > > sigaction(SIGBUS, ...)?  KVM will sure do that. For other apps we
> > > don't mind they can understand that signal at all.
> > 
> > For apps that hook into SIGBUS for some other means and
> 
> Yes I was referring to the sigaction(SIGBUS) apps, others will
> be late killed anyway.
> 
> > do not understand the new type of SIGBUS signal? What about
> > those?
> 
> We introduced two new SIGBUS codes:
>         BUS_MCEERR_AO=5         for early kill
>         BUS_MCEERR_AR=4         for late  kill
> I'd assume a legacy application will handle them in the same way (both
> are unexpected code to the application).
> 
> We don't care whether the application can be killed by BUS_MCEERR_AO
> or BUS_MCEERR_AR depending on its SIGBUS handler implementation.
> But (in the rare case) if the handler
> - refused to die on BUS_MCEERR_AR, it may create a busy loop and
>   flooding of SIGBUS signals, which is a bug of the application.
>   BUS_MCEERR_AO is one time and won't lead to busy loops.
> - does something that hurts itself (ie. data safety) on BUS_MCEERR_AO,
>   it may well hurt the same way on BUS_MCEERR_AR. The latter one is
>   unavoidable, so the application must be fixed anyway.

This patch materializes the automatically early kill idea.
It aims to remove the vm.memory_failure_ealy_kill sysctl parameter.

This is mainly a policy change, please comment.

Thanks,
Fengguang

---
HWPOISON: only early kill processes who installed SIGBUS handler

We want to send SIGBUS.BUS_MCEERR_AO signals to KVM ASAP, so that
it is able to take actions to isolate the corrupted page. In fact,
any applications that does extensive internal caching (KVM, Oracle,
etc.) is advised to install a SIGBUS handler to get early notifications
of corrupted memory, so that it has good possibility to find and remove
the page from its cache. If don't do so, they will later receive the
SIGBUS.BUS_MCEERR_AR signal on accessing the corrupted memory, which
can be deadly (too hard to rescue).

For applications that don't care the signal, let them continue to run
until they try to consume the corrupted data.

For applications that used to catch the SIGBUS handler but don't understand
the new BUS_MCEERR_AO/BUS_MCEERR_AR codes, they may
- refused to die on BUS_MCEERR_AR, creating a busy loop and
  flooding of SIGBUS signals, which is a bug of the application.
  BUS_MCEERR_AO is an one shot event and won't lead to busy loops.
- does something that hurts itself (ie. data safety) on BUS_MCEERR_AO,
  it may well hurt the same way on BUS_MCEERR_AR. The latter one is
  unavoidable, so the application must be fixed anyway.


CC: Nick Piggin <npiggin@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -205,6 +205,20 @@ static void kill_procs_ao(struct list_he
 	}
 }
 
+static bool task_early_kill_elegible(struct task_struct *tsk)
+{
+	__sighandler_t handler;
+
+	if (!tsk->mm)
+		return false;
+
+	handler = tsk->sighand->action[SIGBUS-1].sa.sa_handler;
+	if (handler == SIG_DFL || handler == SIG_IGN)
+		return false;
+
+	return true;
+}
+
 /*
  * Collect processes when the error hit an anonymous page.
  */
@@ -222,7 +236,7 @@ static void collect_procs_anon(struct pa
 		goto out;
 
 	for_each_process (tsk) {
-		if (!tsk->mm)
+		if (!task_early_kill_elegible(tsk))
 			continue;
 		list_for_each_entry (vma, &av->head, anon_vma_node) {
 			if (!page_mapped_in_vma(page, vma))
@@ -262,7 +276,7 @@ static void collect_procs_file(struct pa
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
