Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A242D6B000C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 12:23:23 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v24-v6so2551472wmh.5
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:23:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2-v6sor1476852wmf.6.2018.07.19.09.23.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 09:23:22 -0700 (PDT)
MIME-Version: 1.0
References: <1531994807-25639-1-git-send-email-jing.xia@unisoc.com> <20180719104345.GV7193@dhcp22.suse.cz>
In-Reply-To: <20180719104345.GV7193@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 19 Jul 2018 09:23:10 -0700
Message-ID: <CALvZod55Ku7U3soLtuYY_HL2_mMp5+OT-hngdZkPRGN9xm1a9Q@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: fix use after free in mem_cgroup_iter()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: jing.xia.mail@gmail.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, chunyan.zhang@unisoc.com, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jul 19, 2018 at 3:43 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> [CC Andrew]
>
> On Thu 19-07-18 18:06:47, Jing Xia wrote:
> > It was reported that a kernel crash happened in mem_cgroup_iter(),
> > which can be triggered if the legacy cgroup-v1 non-hierarchical
> > mode is used.
> >
> > Unable to handle kernel paging request at virtual address 6b6b6b6b6b6b8f
> > ......
> > Call trace:
> >   mem_cgroup_iter+0x2e0/0x6d4
> >   shrink_zone+0x8c/0x324
> >   balance_pgdat+0x450/0x640
> >   kswapd+0x130/0x4b8
> >   kthread+0xe8/0xfc
> >   ret_from_fork+0x10/0x20
> >
> >   mem_cgroup_iter():
> >       ......
> >       if (css_tryget(css))    <-- crash here
> >           break;
> >       ......
> >
> > The crashing reason is that mem_cgroup_iter() uses the memcg object
> > whose pointer is stored in iter->position, which has been freed before
> > and filled with POISON_FREE(0x6b).
> >
> > And the root cause of the use-after-free issue is that
> > invalidate_reclaim_iterators() fails to reset the value of
> > iter->position to NULL when the css of the memcg is released in non-
> > hierarchical mode.
>
> Well, spotted!
>
> I suspect
> Fixes: 6df38689e0e9 ("mm: memcontrol: fix possible memcg leak due to interrupted reclaim")
>
> but maybe it goes further into past. I also suggest
> Cc: stable
>
> even though the non-hierarchical mode is strongly discouraged.

Why not set root_mem_cgroup's use_hierarchy to true by default on
init? If someone wants non-hierarchical mode, they can explicitly set
it to false.

> A lack of
> reports for 3 years is encouraging that not many people really use this
> mode.
>
> > Signed-off-by: Jing Xia <jing.xia.mail@gmail.com>
>
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> Thanks!
> > ---
> >  mm/memcontrol.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index e6f0d5e..8c0280b 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -850,7 +850,7 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
> >       int nid;
> >       int i;
> >
> > -     while ((memcg = parent_mem_cgroup(memcg))) {
> > +     for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> >               for_each_node(nid) {
> >                       mz = mem_cgroup_nodeinfo(memcg, nid);
> >                       for (i = 0; i <= DEF_PRIORITY; i++) {
> > --
> > 1.9.1
>
> --
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
