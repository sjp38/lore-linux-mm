Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD378E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 19:50:30 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s14so3881305qkl.16
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 16:50:30 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 130sor17806222qkl.33.2019.01.15.16.50.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 16:50:29 -0800 (PST)
MIME-Version: 1.0
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com> <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
 <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com> <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
 <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com> <CAHbLzkrE887hR_2o_1zJkBcReDt-KzezUE4Jug8zULdV7g17-w@mail.gmail.com>
 <9B56B884-8FDD-4BB5-A6CA-AD7F84397039@bytedance.com>
In-Reply-To: <9B56B884-8FDD-4BB5-A6CA-AD7F84397039@bytedance.com>
From: Yang Shi <shy828301@gmail.com>
Date: Tue, 15 Jan 2019 16:50:18 -0800
Message-ID: <CAHbLzkpHst6bA=eVjoHRFuCuOfo8kKnCPE7Tg4voaJ_kwruVqw@mail.gmail.com>
Subject: Re: memory cgroup pagecache and inode problem
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fam Zheng <zhengfeiran@bytedance.com>
Cc: cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?UTF-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com

On Thu, Jan 10, 2019 at 12:30 AM Fam Zheng <zhengfeiran@bytedance.com> wrot=
e:
>
>
>
> > On Jan 10, 2019, at 13:36, Yang Shi <shy828301@gmail.com> wrote:
> >
> > On Sun, Jan 6, 2019 at 9:10 PM Fam Zheng <zhengfeiran@bytedance.com> wr=
ote:
> >>
> >>
> >>
> >>> On Jan 5, 2019, at 03:36, Yang Shi <shy828301@gmail.com> wrote:
> >>>
> >>>
> >>> drop_caches would drop all page caches globally. You may not want to
> >>> drop the page caches used by other memcgs.
> >>
> >> We=E2=80=99ve tried your async force_empty patch (with a modification =
to default it to true to make it transparently enabled for the sake of test=
ing), and for the past few days the stale mem cgroups still accumulate, up =
to 40k.
> >>
> >> We=E2=80=99ve double checked that the force_empty routines are invoked=
 when a mem cgroup is offlined. But this doesn=E2=80=99t look very effectiv=
e so far. Because, once we do `echo 1 > /proc/sys/vm/drop_caches`, all the =
groups immediately go away.
> >>
> >> This is a bit unexpected.
> >>
> >> Yang, could you hint what are missing in the force_empty operation, co=
mpared to a blanket drop cache?
> >
> > Drop caches does invalidate pages inode by inode. But, memcg
> > force_empty does call memcg direct reclaim.
>
> But force_empty touches things that drop_caches doesn=E2=80=99t? If so th=
en maybe combining both approaches is more reliable. Since like you said,

AFAICS, force_empty may unmap pages, but drop_caches doesn't.

> dropping _all_ pages is usually too much thus not desired, we may want to=
 somehow limit the dropped caches to those that are in the memory cgroup in=
 question. What do you think?

This is what force_empty is supposed to do.  But, as your test shows
some page cache may still remain after force_empty, then cause offline
memcgs accumulated.  I haven't figured out what happened.  You may try
what Michal suggested.

Yang

>
>
> >
> > Offlined memcgs will not go away if there is still page charged. Maybe
> > relate to per cpu memcg stock. I recall there are some commits which
> > do solve the per cpu page counter cache problem.
> >
> > 591edfb10a94 mm: drain memcg stocks on css offlining
> > d12c60f64cf8 mm: memcontrol: drain memcg stock on force_empty
> > bb4a7ea2b144 mm: memcontrol: drain stocks on resize limit
> >
> > Not sure if they would help out.
>
> These are all in 4.20, which is tested but not helpful.
>
> Fam
>
