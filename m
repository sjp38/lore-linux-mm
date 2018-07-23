Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 356536B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 02:44:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d18-v6so5429991edp.0
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 23:44:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k2-v6si1227239eda.433.2018.07.22.23.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jul 2018 23:44:43 -0700 (PDT)
Date: Mon, 23 Jul 2018 08:44:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcg: fix use after free in mem_cgroup_iter()
Message-ID: <20180723064441.GA17905@dhcp22.suse.cz>
References: <1531994807-25639-1-git-send-email-jing.xia@unisoc.com>
 <20180719104345.GV7193@dhcp22.suse.cz>
 <CALvZod55Ku7U3soLtuYY_HL2_mMp5+OT-hngdZkPRGN9xm1a9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod55Ku7U3soLtuYY_HL2_mMp5+OT-hngdZkPRGN9xm1a9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: jing.xia.mail@gmail.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, chunyan.zhang@unisoc.com, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 19-07-18 09:23:10, Shakeel Butt wrote:
> On Thu, Jul 19, 2018 at 3:43 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > [CC Andrew]
> >
> > On Thu 19-07-18 18:06:47, Jing Xia wrote:
> > > It was reported that a kernel crash happened in mem_cgroup_iter(),
> > > which can be triggered if the legacy cgroup-v1 non-hierarchical
> > > mode is used.
> > >
> > > Unable to handle kernel paging request at virtual address 6b6b6b6b6b6b8f
> > > ......
> > > Call trace:
> > >   mem_cgroup_iter+0x2e0/0x6d4
> > >   shrink_zone+0x8c/0x324
> > >   balance_pgdat+0x450/0x640
> > >   kswapd+0x130/0x4b8
> > >   kthread+0xe8/0xfc
> > >   ret_from_fork+0x10/0x20
> > >
> > >   mem_cgroup_iter():
> > >       ......
> > >       if (css_tryget(css))    <-- crash here
> > >           break;
> > >       ......
> > >
> > > The crashing reason is that mem_cgroup_iter() uses the memcg object
> > > whose pointer is stored in iter->position, which has been freed before
> > > and filled with POISON_FREE(0x6b).
> > >
> > > And the root cause of the use-after-free issue is that
> > > invalidate_reclaim_iterators() fails to reset the value of
> > > iter->position to NULL when the css of the memcg is released in non-
> > > hierarchical mode.
> >
> > Well, spotted!
> >
> > I suspect
> > Fixes: 6df38689e0e9 ("mm: memcontrol: fix possible memcg leak due to interrupted reclaim")
> >
> > but maybe it goes further into past. I also suggest
> > Cc: stable
> >
> > even though the non-hierarchical mode is strongly discouraged.
> 
> Why not set root_mem_cgroup's use_hierarchy to true by default on
> init? If someone wants non-hierarchical mode, they can explicitly set
> it to false.

We do not change defaults under users feet usually.
-- 
Michal Hocko
SUSE Labs
