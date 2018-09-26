Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0068E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:25:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b21-v6so840745edt.18
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 01:25:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9-v6si600723edj.444.2018.09.26.01.25.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 01:25:00 -0700 (PDT)
Date: Wed, 26 Sep 2018 10:24:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RESEND] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Message-ID: <20180926082458.GI6278@dhcp22.suse.cz>
References: <20180917230846.31027-1-guro@fb.com>
 <20180925185845.GX18685@dhcp22.suse.cz>
 <20180926081337.GA23355@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180926081337.GA23355@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed 26-09-18 09:13:43, Roman Gushchin wrote:
> On Tue, Sep 25, 2018 at 08:58:45PM +0200, Michal Hocko wrote:
> > On Mon 17-09-18 23:10:59, Roman Gushchin wrote:
> > > The memcg OOM killer is never invoked due to a failed high-order
> > > allocation, however the MEMCG_OOM event can be raised.
> > > 
> > > As shown below, it can happen under conditions, which are very
> > > far from a real OOM: e.g. there is plenty of clean pagecache
> > > and low memory pressure.
> > > 
> > > There is no sense in raising an OOM event in such a case,
> > > as it might confuse a user and lead to wrong and excessive actions.
> > > 
> > > Let's look at the charging path in try_caharge(). If the memory usage
> > > is about memory.max, which is absolutely natural for most memory cgroups,
> > > we try to reclaim some pages. Even if we were able to reclaim
> > > enough memory for the allocation, the following check can fail due to
> > > a race with another concurrent allocation:
> > > 
> > >     if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
> > >         goto retry;
> > > 
> > > For regular pages the following condition will save us from triggering
> > > the OOM:
> > > 
> > >    if (nr_reclaimed && nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER))
> > >        goto retry;
> > > 
> > > But for high-order allocation this condition will intentionally fail.
> > > The reason behind is that we'll likely fall to regular pages anyway,
> > > so it's ok and even preferred to return ENOMEM.
> > > 
> > > In this case the idea of raising MEMCG_OOM looks dubious.
> > 
> > I would really appreciate an example of application that would get
> > confused by consuming this event and an explanation why. I do agree that
> > the event itself is kinda weird because it doesn't give you any context
> > for what kind of requests the memcg is OOM. Costly orders are a little
> > different story than others and users shouldn't care about this because
> > this is a mere implementation detail.
> 
> Our container management system (called Tupperware) used the OOM event
> as a signal that a workload might be affected by the OOM killer, so
> it restarted the corresponding container.
> 
> I started looking at this problem, when I was reported, that it sometimes
> happens when there is a plenty of inactive page cache, and also there were
> no signs that the OOM killer has been invoking at all.
> The proposed patch resolves this problem.

Thanks! This is exactly the kind of information that should be in the
changelog. With the changelog updated and an explicit note in the
documentation that the event is triggered only when the memcg is _going_
to consider the oom killer as the only option you can add

Acked-by: Michal Hocko <mhocko@suse.com>

> > In other words, do we have any users to actually care about this half
> > baked event at all? Shouldn't we simply stop emiting it (or make it an
> > alias of OOM_KILL) rather than making it slightly better but yet kinda
> > incomplete?
> 
> The only problem with OOM_KILL I see is that OOM_KILL might not be raised
> at all, if the OOM killer is not able to find an appropriate victim.
> For instance, if all tasks are oom protected (oom_score_adj set to -1000).

This is a very good point.
-- 
Michal Hocko
SUSE Labs
