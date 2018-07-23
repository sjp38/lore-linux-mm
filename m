Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4EE46B0008
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 12:17:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h18-v6so636297wmb.8
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 09:17:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16-v6sor3595631wrr.24.2018.07.23.09.17.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 09:17:42 -0700 (PDT)
MIME-Version: 1.0
References: <1531994807-25639-1-git-send-email-jing.xia@unisoc.com>
 <20180719104345.GV7193@dhcp22.suse.cz> <CALvZod55Ku7U3soLtuYY_HL2_mMp5+OT-hngdZkPRGN9xm1a9Q@mail.gmail.com>
 <20180723064441.GA17905@dhcp22.suse.cz>
In-Reply-To: <20180723064441.GA17905@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 23 Jul 2018 09:17:28 -0700
Message-ID: <CALvZod5UwJp8cM3OcjCDadkjKgAnGHj8XVcgjFk5Thcst02MAQ@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: fix use after free in mem_cgroup_iter()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: jing.xia.mail@gmail.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, chunyan.zhang@unisoc.com, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Jul 22, 2018 at 11:44 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 19-07-18 09:23:10, Shakeel Butt wrote:
> > On Thu, Jul 19, 2018 at 3:43 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > [CC Andrew]
> > >
> > > On Thu 19-07-18 18:06:47, Jing Xia wrote:
> > > > It was reported that a kernel crash happened in mem_cgroup_iter(),
> > > > which can be triggered if the legacy cgroup-v1 non-hierarchical
> > > > mode is used.
> > > >
> > > > Unable to handle kernel paging request at virtual address 6b6b6b6b6b6b8f
> > > > ......
> > > > Call trace:
> > > >   mem_cgroup_iter+0x2e0/0x6d4
> > > >   shrink_zone+0x8c/0x324
> > > >   balance_pgdat+0x450/0x640
> > > >   kswapd+0x130/0x4b8
> > > >   kthread+0xe8/0xfc
> > > >   ret_from_fork+0x10/0x20
> > > >
> > > >   mem_cgroup_iter():
> > > >       ......
> > > >       if (css_tryget(css))    <-- crash here
> > > >           break;
> > > >       ......
> > > >
> > > > The crashing reason is that mem_cgroup_iter() uses the memcg object
> > > > whose pointer is stored in iter->position, which has been freed before
> > > > and filled with POISON_FREE(0x6b).
> > > >
> > > > And the root cause of the use-after-free issue is that
> > > > invalidate_reclaim_iterators() fails to reset the value of
> > > > iter->position to NULL when the css of the memcg is released in non-
> > > > hierarchical mode.
> > >
> > > Well, spotted!
> > >
> > > I suspect
> > > Fixes: 6df38689e0e9 ("mm: memcontrol: fix possible memcg leak due to interrupted reclaim")
> > >
> > > but maybe it goes further into past. I also suggest
> > > Cc: stable
> > >
> > > even though the non-hierarchical mode is strongly discouraged.
> >
> > Why not set root_mem_cgroup's use_hierarchy to true by default on
> > init? If someone wants non-hierarchical mode, they can explicitly set
> > it to false.
>
> We do not change defaults under users feet usually.

Then how non-hierarchical mode is being discouraged currently? I don't
see any comments in the docs.

Shakeel
