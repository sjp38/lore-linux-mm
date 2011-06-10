Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 17E586B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:49:53 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p5ALnleA009616
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:49:50 -0700
Received: from pva4 (pva4.prod.google.com [10.241.209.4])
	by wpaz1.hot.corp.google.com with ESMTP id p5ALnGqi006652
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:49:45 -0700
Received: by pva4 with SMTP id 4so1563883pva.30
        for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:49:43 -0700 (PDT)
Date: Fri, 10 Jun 2011 14:49:35 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
In-Reply-To: <20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1106101425400.28334@sister.anvils>
References: <20110609212956.GA2319@redhat.com> <BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com> <BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com> <20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1106091812030.4904@sister.anvils> <20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com> <20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com> <20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1162693246-1307742583=:28334"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1162693246-1307742583=:28334
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 10 Jun 2011, KAMEZAWA Hiroyuki wrote:
>=20
> I think this can be a fix.=20

Sorry, I think not: I've not digested your rationale,
but three things stand out:

1. Why has this only just started happening?  I may not have run that
   test on 3.0-rc1, but surely I ran it for hours with 2.6.39;
   maybe not with khugepaged, but certainly with ksmd.

2. Your hunk below:
> -=09if (!mm_need_new_owner(mm, p))
> +=09if (!mm_need_new_owner(mm, p)) {
> +=09=09rcu_assign_pointer(mm->owner, NULL);
   is now setting mm->owner to NULL at times when we were sure it did not
   need updating before (task is not the owner): you're damaging mm->owner.

3. There's a patch from Andrea in 3.0-rc1 which looks very likely to be
   relevant, 692e0b35427a "mm: thp: optimize memcg charge in khugepaged".
   I'll try reproducing without that tonight (I crashed in 20 minutes
   this morning, so it's not too hard).

Hugh

> maybe good to CC Oleg.
> =3D=3D
> From dff52fb35af0cf36486965d19ee79e04b59f1dc4 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 10 Jun 2011 13:15:14 +0900
> Subject: [PATCH] [BUGFIX] update mm->owner even if no next owner.
>=20
> A panic is reported.
>=20
> > Call Trace:
> > =C2=A0[<ffffffff81139792>] mem_cgroup_from_task+0x15/0x17
> > =C2=A0[<ffffffff8113a75a>] __mem_cgroup_try_charge+0x148/0x4b4
> > =C2=A0[<ffffffff810493f3>] ? need_resched+0x23/0x2d
> > =C2=A0[<ffffffff814cbf43>] ? preempt_schedule+0x46/0x4f
> > =C2=A0[<ffffffff8113afe8>] mem_cgroup_charge_common+0x9a/0xce
> > =C2=A0[<ffffffff8113b6d1>] mem_cgroup_newpage_charge+0x5d/0x5f
> > =C2=A0[<ffffffff81134024>] khugepaged+0x5da/0xfaf
> > =C2=A0[<ffffffff81078ea0>] ? __init_waitqueue_head+0x4b/0x4b
> > =C2=A0[<ffffffff81133a4a>] ? add_mm_counter.constprop.5+0x13/0x13
> > =C2=A0[<ffffffff81078625>] kthread+0xa8/0xb0
> > =C2=A0[<ffffffff814d13e8>] ? sub_preempt_count+0xa1/0xb4
> > =C2=A0[<ffffffff814d5664>] kernel_thread_helper+0x4/0x10
> > =C2=A0[<ffffffff814ce858>] ? retint_restore_args+0x13/0x13
> > =C2=A0[<ffffffff8107857d>] ? __init_kthread_worker+0x5a/0x5a
>=20
> The code is.
> >         return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
> >                                 struct mem_cgroup, css);
>=20
>=20
> What happens here is accssing a freed task struct "p" from mm->owner.
> So, it's doubtful that mm->owner points to freed task struct.
>=20
> At thread exit, we need to handle mm->owner. If exitting-thread =3D=3D mm=
->owner,
> we modify mm->owner to points to other exisiting task. But, we do not upd=
ate
> mm->owner when there are no more threads. But if a kernel thread, like kh=
ugepaged,
> picks up a mm_struct without updating mm->users, there is a trouble.
>=20
> When mm_users shows that the task is the last task belongs to mm.
> mm->owner is not updated and remained to point to the task. So, in this c=
ase,
> mm->owner points to a not exisiting task.  This was good because if there
> are no thread, no charge happens in old days. But now, we have ksm and
> khugepaged.
>=20
> rcu_read_lock() used in memcg is of no use because mm->owner can be
> freed before we take rcu_read_lock.
> Then, mm->owner should be cleared if there are no next owner.
>=20
> Reported-by: Hugh Dickins <hughd@google.com>
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  kernel/exit.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/kernel/exit.c b/kernel/exit.c
> index 20a4064..dbc3736 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -582,8 +582,10 @@ void mm_update_next_owner(struct mm_struct *mm)
>  =09struct task_struct *c, *g, *p =3D current;
> =20
>  retry:
> -=09if (!mm_need_new_owner(mm, p))
> +=09if (!mm_need_new_owner(mm, p)) {
> +=09=09rcu_assign_pointer(mm->owner, NULL);
>  =09=09return;
> +=09}
> =20
>  =09read_lock(&tasklist_lock);
>  =09/*
> @@ -617,7 +619,7 @@ retry:
>  =09 * most likely racing with swapoff (try_to_unuse()) or /proc or
>  =09 * ptrace or page migration (get_task_mm()).  Mark owner as NULL.
>  =09 */
> -=09mm->owner =3D NULL;
> +=09rcu_assign_pointer(mm->owner, NULL);
>  =09return;
> =20
>  assign_new_owner:
> --=20
> 1.7.4.1
--8323584-1162693246-1307742583=:28334--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
