Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 981F68E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 06:15:09 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id g79so19451807vsd.6
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 03:15:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y79sor26612528vkd.59.2019.01.03.03.15.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 03:15:08 -0800 (PST)
MIME-Version: 1.0
References: <000000000000c06550057e4cac7c@google.com> <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
 <CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com>
In-Reply-To: <CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 3 Jan 2019 12:14:54 +0100
Message-ID: <CAG_fn=Wmjqo8yWesAfF+E2QTT1pqoODaUMA56ufsrDOE_R4snQ@mail.gmail.com>
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Yisheng Xie <xieyisheng1@huawei.com>, zhong jiang <zhongjiang@huawei.com>

On Thu, Jan 3, 2019 at 9:42 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>
> On Thu, Jan 3, 2019 at 9:36 AM Vlastimil Babka <vbabka@suse.cz> wrote:
> >
> >
> > On 12/31/18 8:51 AM, syzbot wrote:
> > > Hello,
> > >
> > > syzbot found the following crash on:
> > >
> > > HEAD commit:    79fc24ff6184 kmsan: highmem: use kmsan_clear_page() i=
n cop..
> > > git tree:       kmsan
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=3D13c48b674=
00000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=3D901dd030b=
2cc57e7
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=3Db19c2dc2c99=
0ea657a71
> > > compiler:       clang version 8.0.0 (trunk 349734)
> > >
> > > Unfortunately, I don't have any reproducer for this crash yet.
> > >
> > > IMPORTANT: if you fix the bug, please add the following tag to the co=
mmit:
> > > Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
> > >
> > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [in=
line]
> > > BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c=
:384
> >
> > The report doesn't seem to indicate where the uninit value resides in
> > the mempolicy object.
>
> Yes, it doesn't and it's not trivial to do. The tool reports uses of
> unint _values_. Values don't necessary reside in memory. It can be a
> register, that come from another register that was calculated as a sum
> of two other values, which may come from a function argument, etc.
>
> > I'll have to guess. mm/mempolicy.c:353 contains:
> >
> >         if (!mpol_store_user_nodemask(pol) &&
> >             nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
> >
> > "mpol_store_user_nodemask(pol)" is testing pol->flags, which I couldn't
> > see being uninitialized after leaving mpol_new(). So I'll guess it's
> > actually about accessing pol->w.cpuset_mems_allowed on line 354.
> >
> > For w.cpuset_mems_allowed to be not initialized and the nodes_equal()
> > reachable for a mempolicy where mpol_set_nodemask() is called in
> > do_mbind(), it seems the only possibility is a MPOL_PREFERRED policy
> > with empty set of nodes, i.e. MPOL_LOCAL equivalent. Let's see if the
> > patch below helps. This code is a maze to me. Note the uninit access
> > should be benign, rebinding this kind of policy is always a no-op.
If I'm reading mempolicy.c right, `pol->flags & MPOL_F_LOCAL` doesn't
imply `pol->mode =3D=3D MPOL_PREFERRED`, shouldn't we check for both here?

> > ----8<----
> > From ff0ca29da6bc2572d7b267daa77ced6083e3f02d Mon Sep 17 00:00:00 2001
> > From: Vlastimil Babka <vbabka@suse.cz>
> > Date: Thu, 3 Jan 2019 09:31:59 +0100
> > Subject: [PATCH] mm, mempolicy: fix uninit memory access
> >
> > ---
> >  mm/mempolicy.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index d4496d9d34f5..a0b7487b9112 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -350,7 +350,7 @@ static void mpol_rebind_policy(struct mempolicy *po=
l, const nodemask_t *newmask)
> >  {
> >         if (!pol)
> >                 return;
> > -       if (!mpol_store_user_nodemask(pol) &&
> > +       if (!mpol_store_user_nodemask(pol) && !(pol->flags & MPOL_F_LOC=
AL) &&
> >             nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
> >                 return;
> >
> > --
> > 2.19.2
> >
> > --
> > You received this message because you are subscribed to the Google Grou=
ps "syzkaller-bugs" group.
> > To unsubscribe from this group and stop receiving emails from it, send =
an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> > To view this discussion on the web visit https://groups.google.com/d/ms=
gid/syzkaller-bugs/a71997c3-e8ae-a787-d5ce-3db05768b27c%40suse.cz.
> > For more options, visit https://groups.google.com/d/optout.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
