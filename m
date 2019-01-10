Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA8948E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 00:36:28 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id u197so8295168qka.8
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 21:36:28 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u56sor65552156qvc.58.2019.01.09.21.36.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 21:36:27 -0800 (PST)
MIME-Version: 1.0
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com> <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
 <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com> <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
 <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com>
In-Reply-To: <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com>
From: Yang Shi <shy828301@gmail.com>
Date: Wed, 9 Jan 2019 21:36:15 -0800
Message-ID: <CAHbLzkrE887hR_2o_1zJkBcReDt-KzezUE4Jug8zULdV7g17-w@mail.gmail.com>
Subject: Re: memory cgroup pagecache and inode problem
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fam Zheng <zhengfeiran@bytedance.com>
Cc: cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?UTF-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com

On Sun, Jan 6, 2019 at 9:10 PM Fam Zheng <zhengfeiran@bytedance.com> wrote:
>
>
>
> > On Jan 5, 2019, at 03:36, Yang Shi <shy828301@gmail.com> wrote:
> >
> >
> > drop_caches would drop all page caches globally. You may not want to
> > drop the page caches used by other memcgs.
>
> We=E2=80=99ve tried your async force_empty patch (with a modification to =
default it to true to make it transparently enabled for the sake of testing=
), and for the past few days the stale mem cgroups still accumulate, up to =
40k.
>
> We=E2=80=99ve double checked that the force_empty routines are invoked wh=
en a mem cgroup is offlined. But this doesn=E2=80=99t look very effective s=
o far. Because, once we do `echo 1 > /proc/sys/vm/drop_caches`, all the gro=
ups immediately go away.
>
> This is a bit unexpected.
>
> Yang, could you hint what are missing in the force_empty operation, compa=
red to a blanket drop cache?

Drop caches does invalidate pages inode by inode. But, memcg
force_empty does call memcg direct reclaim.

Offlined memcgs will not go away if there is still page charged. Maybe
relate to per cpu memcg stock. I recall there are some commits which
do solve the per cpu page counter cache problem.

591edfb10a94 mm: drain memcg stocks on css offlining
d12c60f64cf8 mm: memcontrol: drain memcg stock on force_empty
bb4a7ea2b144 mm: memcontrol: drain stocks on resize limit

Not sure if they would help out.

Yang

>
> Fam
