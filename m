Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B84518E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 11:27:50 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p14-v6so32228167oip.0
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 08:27:50 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u62-v6si13090475oig.363.2018.09.11.08.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 08:27:49 -0700 (PDT)
Date: Tue, 11 Sep 2018 08:27:30 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH RFC] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Message-ID: <20180911152725.GA28828@tower.DHCP.thefacebook.com>
References: <20180910215622.4428-1-guro@fb.com>
 <20180911121141.GS10951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180911121141.GS10951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue, Sep 11, 2018 at 02:11:41PM +0200, Michal Hocko wrote:
> On Mon 10-09-18 14:56:22, Roman Gushchin wrote:
> > The memcg OOM killer is never invoked due to a failed high-order
> > allocation, however the MEMCG_OOM event can be easily raised.
> > 
> > Under some memory pressure it can happen easily because of a
> > concurrent allocation. Let's look at try_charge(). Even if we were
> > able to reclaim enough memory, this check can fail due to a race
> > with another allocation:
> > 
> >     if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
> >         goto retry;
> > 
> > For regular pages the following condition will save us from triggering
> > the OOM:
> > 
> >    if (nr_reclaimed && nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER))
> >        goto retry;
> > 
> > But for high-order allocation this condition will intentionally fail.
> > The reason behind is that we'll likely fall to regular pages anyway,
> > so it's ok and even preferred to return ENOMEM.
> > 
> > In this case the idea of raising the MEMCG_OOM event looks dubious.
> 
> Why is this a problem though? IIRC this event was deliberately placed
> outside of the oom path because we wanted to count allocation failures
> and this is also documented that way
> 
>           oom
>                 The number of time the cgroup's memory usage was
>                 reached the limit and allocation was about to fail.
> 
>                 Depending on context result could be invocation of OOM
>                 killer and retrying allocation or failing a
> 
> One could argue that we do not apply the same logic to GFP_NOWAIT
> requests but in general I would like to see a good reason to change
> the behavior and if it is really the right thing to do then we need to
> update the documentation as well.

Right, the current behavior matches the documentation, because the description
of the event is broad enough. My point is that the current behavior is not
useful in my corner case.

Let me explain my case in details: I've got a report about sporadic memcg oom
kills on some hosts with plenty of pagecache and low memory pressure.
You'll probably agree, that raising OOM signal in this case looks strange.

It's natural for cgroup memory usage to be around memory.max border, and
I've explained in the commit message how an attempt to charge a high-order
allocation can fail in this case, even if there no real memory pressure
in the cgroup.

Thanks!
