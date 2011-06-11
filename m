Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB396B0012
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 13:51:53 -0400 (EDT)
Date: Sat, 11 Jun 2011 19:51:36 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
Message-ID: <20110611175136.GA31154@cmpxchg.org>
References: <BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com>
 <BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
 <20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1106091812030.4904@sister.anvils>
 <20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1106101425400.28334@sister.anvils>
 <20110610235442.GA21413@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110610235442.GA21413@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Sat, Jun 11, 2011 at 01:54:42AM +0200, Johannes Weiner wrote:
> On Fri, Jun 10, 2011 at 02:49:35PM -0700, Hugh Dickins wrote:
> > On Fri, 10 Jun 2011, KAMEZAWA Hiroyuki wrote:
> > > 
> > > I think this can be a fix. 
> > 
> > Sorry, I think not: I've not digested your rationale,
> > but three things stand out:
> > 
> > 1. Why has this only just started happening?  I may not have run that
> >    test on 3.0-rc1, but surely I ran it for hours with 2.6.39;
> >    maybe not with khugepaged, but certainly with ksmd.
> > 
> > 2. Your hunk below:
> > > -	if (!mm_need_new_owner(mm, p))
> > > +	if (!mm_need_new_owner(mm, p)) {
> > > +		rcu_assign_pointer(mm->owner, NULL);
> >    is now setting mm->owner to NULL at times when we were sure it did not
> >    need updating before (task is not the owner): you're damaging mm->owner.

This is a problem with the patch, but I think Kame's analysis and
approach to fix it are still correct.

mm_update_next_owner() does not set mm->owner to NULL when the last
possible owner goes away, but leaves it pointing to a possibly stale
task struct.

Noone cared before khugepaged, and up to Andrea's patch khugepaged
prevented the last possible owner from exiting until the call into the
memory controller had finished.

Here is a revised version of Kame's fix.

---
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] [BUGFIX] mm: clear mm->owner when last possible owner leaves

The following crash was reported:

> Call Trace:
>  [<ffffffff81139792>] mem_cgroup_from_task+0x15/0x17
>  [<ffffffff8113a75a>] __mem_cgroup_try_charge+0x148/0x4b4
>  [<ffffffff810493f3>] ? need_resched+0x23/0x2d
>  [<ffffffff814cbf43>] ? preempt_schedule+0x46/0x4f
>  [<ffffffff8113afe8>] mem_cgroup_charge_common+0x9a/0xce
>  [<ffffffff8113b6d1>] mem_cgroup_newpage_charge+0x5d/0x5f
>  [<ffffffff81134024>] khugepaged+0x5da/0xfaf
>  [<ffffffff81078ea0>] ? __init_waitqueue_head+0x4b/0x4b
>  [<ffffffff81133a4a>] ? add_mm_counter.constprop.5+0x13/0x13
>  [<ffffffff81078625>] kthread+0xa8/0xb0
>  [<ffffffff814d13e8>] ? sub_preempt_count+0xa1/0xb4
>  [<ffffffff814d5664>] kernel_thread_helper+0x4/0x10
>  [<ffffffff814ce858>] ? retint_restore_args+0x13/0x13
>  [<ffffffff8107857d>] ? __init_kthread_worker+0x5a/0x5a

What happens is that khugepaged tries to charge a huge page against an
mm whose last possible owner has already exited, and the memory
controller crashes when the stale mm->owner is used to look up the
cgroup to charge.

mm->owner has never been set to NULL with the last owner going away,
but nobody cared until khugepaged came along.

Even then it wasn't a problem because the final mmput() on an mm was
forced to acquire and release mmap_sem in write-mode, preventing an
exiting owner to go away while the mmap_sem was held, and until
"692e0b3 mm: thp: optimize memcg charge in khugepaged", the memory
cgroup charge was protected by mmap_sem in read-mode.

Instead of going back to relying on the mmap_sem to enforce lifetime
of a task, this patch ensures that mm->owner is properly set to NULL
when the last possible owner is exiting, which the memory controller
can handle just fine.

Reported-by: Hugh Dickins <hughd@google.com>
Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/kernel/exit.c b/kernel/exit.c
index 20a4064..ef8ff79 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -563,27 +563,27 @@ void exit_files(struct task_struct *tsk)
 /*
  * Task p is exiting and it owned mm, lets find a new owner for it
  */
-static inline int
-mm_need_new_owner(struct mm_struct *mm, struct task_struct *p)
-{
-	/*
-	 * If there are other users of the mm and the owner (us) is exiting
-	 * we need to find a new owner to take on the responsibility.
-	 */
-	if (atomic_read(&mm->mm_users) <= 1)
-		return 0;
-	if (mm->owner != p)
-		return 0;
-	return 1;
-}
-
 void mm_update_next_owner(struct mm_struct *mm)
 {
 	struct task_struct *c, *g, *p = current;
 
 retry:
-	if (!mm_need_new_owner(mm, p))
+	/*
+	 * If the exiting or execing task is not the owner, it's
+	 * someone else's problem.
+	 */
+	if (mm->owner != p)
+		return;
+
+	/*
+	 * The current owner is exiting/execing and there are no other
+	 * candidates.  Do not leave the mm pointing to a possibly
+	 * freed task structure.
+	 */
+	if (atomic_read(&mm->mm_users <= 1)) {
+		mm->owner = NULL;
 		return;
+	}
 
 	read_lock(&tasklist_lock);
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
