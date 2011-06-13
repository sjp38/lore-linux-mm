Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36EAD6B004A
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 21:42:25 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p5D1gLZb003928
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 18:42:21 -0700
Received: from pxj1 (pxj1.prod.google.com [10.243.27.65])
	by wpaz1.hot.corp.google.com with ESMTP id p5D1gF1n013434
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 18:42:19 -0700
Received: by pxj1 with SMTP id 1so2803553pxj.37
        for <linux-mm@kvack.org>; Sun, 12 Jun 2011 18:42:14 -0700 (PDT)
Date: Sun, 12 Jun 2011 18:41:58 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
In-Reply-To: <20110611175136.GA31154@cmpxchg.org>
Message-ID: <alpine.LSU.2.00.1106121828220.31463@sister.anvils>
References: <BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com> <BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com> <20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LSU.2.00.1106091812030.4904@sister.anvils>
 <20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com> <20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com> <20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com> <20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LSU.2.00.1106101425400.28334@sister.anvils>
 <20110610235442.GA21413@cmpxchg.org> <20110611175136.GA31154@cmpxchg.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-140283987-1307929327=:31463"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-140283987-1307929327=:31463
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 11 Jun 2011, Johannes Weiner wrote:
> On Sat, Jun 11, 2011 at 01:54:42AM +0200, Johannes Weiner wrote:
> > On Fri, Jun 10, 2011 at 02:49:35PM -0700, Hugh Dickins wrote:
> > > On Fri, 10 Jun 2011, KAMEZAWA Hiroyuki wrote:
> > > >=20
> > > > I think this can be a fix.=20
> > >=20
> > > Sorry, I think not: I've not digested your rationale,
> > > but three things stand out:
> > >=20
> > > 1. Why has this only just started happening?  I may not have run that
> > >    test on 3.0-rc1, but surely I ran it for hours with 2.6.39;
> > >    maybe not with khugepaged, but certainly with ksmd.
> > >=20
> > > 2. Your hunk below:
> > > > -=09if (!mm_need_new_owner(mm, p))
> > > > +=09if (!mm_need_new_owner(mm, p)) {
> > > > +=09=09rcu_assign_pointer(mm->owner, NULL);
> > >    is now setting mm->owner to NULL at times when we were sure it did=
 not
> > >    need updating before (task is not the owner): you're damaging mm->=
owner.
>=20
> This is a problem with the patch, but I think Kame's analysis and
> approach to fix it are still correct.

Yes, I was looking at his patch, when I should have spent more time
reading his comments: you're right, the analysis is fine, and I too
dislike stale pointers.

>=20
> mm_update_next_owner() does not set mm->owner to NULL when the last
> possible owner goes away, but leaves it pointing to a possibly stale
> task struct.
>=20
> Noone cared before khugepaged, and up to Andrea's patch khugepaged
> prevented the last possible owner from exiting until the call into the
> memory controller had finished.
>=20
> Here is a revised version of Kame's fix.

It seems to be strangely difficult to get right!
I have no idea what your
=09if (atomic_read(&mm->mm_users <=3D 1)) {
actually ends up doing, I'm surprised it only gives compiler warnings
rather than an error.

The version I've signed off and am actually testing is below;
but I've not had enough time to spare on the machine which reproduced
it before, and another I thought I'd delegate it to last night,
failed to reproduce without the patch.  Try again tonight.

Thought I'd better respond despite inadequate testing, given the flaw
in the posted patch.  Hope the one below is flawless.

Hugh

>=20
> ---

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] [BUGFIX] mm: clear mm->owner when last possible owner leav=
es

The following crash was reported:

> Call Trace:
> =A0[<ffffffff81139792>] mem_cgroup_from_task+0x15/0x17
> =A0[<ffffffff8113a75a>] __mem_cgroup_try_charge+0x148/0x4b4
> =A0[<ffffffff810493f3>] ? need_resched+0x23/0x2d
> =A0[<ffffffff814cbf43>] ? preempt_schedule+0x46/0x4f
> =A0[<ffffffff8113afe8>] mem_cgroup_charge_common+0x9a/0xce
> =A0[<ffffffff8113b6d1>] mem_cgroup_newpage_charge+0x5d/0x5f
> =A0[<ffffffff81134024>] khugepaged+0x5da/0xfaf
> =A0[<ffffffff81078ea0>] ? __init_waitqueue_head+0x4b/0x4b
> =A0[<ffffffff81133a4a>] ? add_mm_counter.constprop.5+0x13/0x13
> =A0[<ffffffff81078625>] kthread+0xa8/0xb0
> =A0[<ffffffff814d13e8>] ? sub_preempt_count+0xa1/0xb4
> =A0[<ffffffff814d5664>] kernel_thread_helper+0x4/0x10
> =A0[<ffffffff814ce858>] ? retint_restore_args+0x13/0x13
> =A0[<ffffffff8107857d>] ? __init_kthread_worker+0x5a/0x5a

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
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
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
-=09/*
-=09 * If there are other users of the mm and the owner (us) is exiting
-=09 * we need to find a new owner to take on the responsibility.
-=09 */
-=09if (atomic_read(&mm->mm_users) <=3D 1)
-=09=09return 0;
-=09if (mm->owner !=3D p)
-=09=09return 0;
-=09return 1;
-}
-
 void mm_update_next_owner(struct mm_struct *mm)
 {
 =09struct task_struct *c, *g, *p =3D current;
=20
 retry:
-=09if (!mm_need_new_owner(mm, p))
+=09/*
+=09 * If the exiting or execing task is not the owner, it's
+=09 * someone else's problem.
+=09 */
+=09if (mm->owner !=3D p)
+=09=09return;
+
+=09/*
+=09 * The current owner is exiting/execing and there are no other
+=09 * candidates.  Do not leave the mm pointing to a possibly
+=09 * freed task structure.
+=09 */
+=09if (atomic_read(&mm->mm_users) <=3D 1) {
+=09=09mm->owner =3D NULL;
 =09=09return;
+=09}
=20
 =09read_lock(&tasklist_lock);
 =09/*
--8323584-140283987-1307929327=:31463--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
