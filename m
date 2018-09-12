Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9248E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:35:41 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n4-v6so988991plk.7
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 05:35:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d3-v6si937321pla.37.2018.09.12.05.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 05:35:39 -0700 (PDT)
Date: Wed, 12 Sep 2018 14:35:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Message-ID: <20180912123534.GG10951@dhcp22.suse.cz>
References: <20180910215622.4428-1-guro@fb.com>
 <20180911121141.GS10951@dhcp22.suse.cz>
 <20180911152725.GA28828@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180911152725.GA28828@tower.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue 11-09-18 08:27:30, Roman Gushchin wrote:
> On Tue, Sep 11, 2018 at 02:11:41PM +0200, Michal Hocko wrote:
> > On Mon 10-09-18 14:56:22, Roman Gushchin wrote:
> > > The memcg OOM killer is never invoked due to a failed high-order
> > > allocation, however the MEMCG_OOM event can be easily raised.
> > > 
> > > Under some memory pressure it can happen easily because of a
> > > concurrent allocation. Let's look at try_charge(). Even if we were
> > > able to reclaim enough memory, this check can fail due to a race
> > > with another allocation:
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
> > > In this case the idea of raising the MEMCG_OOM event looks dubious.
> > 
> > Why is this a problem though? IIRC this event was deliberately placed
> > outside of the oom path because we wanted to count allocation failures
> > and this is also documented that way
> > 
> >           oom
> >                 The number of time the cgroup's memory usage was
> >                 reached the limit and allocation was about to fail.
> > 
> >                 Depending on context result could be invocation of OOM
> >                 killer and retrying allocation or failing a
> > 
> > One could argue that we do not apply the same logic to GFP_NOWAIT
> > requests but in general I would like to see a good reason to change
> > the behavior and if it is really the right thing to do then we need to
> > update the documentation as well.
> 
> Right, the current behavior matches the documentation, because the description
> of the event is broad enough. My point is that the current behavior is not
> useful in my corner case.
> 
> Let me explain my case in details: I've got a report about sporadic memcg oom
> kills on some hosts with plenty of pagecache and low memory pressure.
> You'll probably agree, that raising OOM signal in this case looks strange.

I am not sure I follow. So you see both OOM_KILL and OOM events and the
user misinterprets OOM ones?

My understanding was that OOM event should tell admin that the limit
should be increased in order to allow more charges. Without OOM_KILL
events it means that those failed charges have some sort of fallback
so it is not critical condition for the workload yet. Something to watch
for though in case of perf. degradation or potential misbehavior.

Whether this is how the event is used, I dunno. Anyway, if you want to
just move the event and make it closer to OOM_KILL then I strongly
suspect the event is losing its relevance.
-- 
Michal Hocko
SUSE Labs
