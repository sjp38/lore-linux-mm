Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2C58E0005
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 08:11:48 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d1-v6so12860251pfo.16
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 05:11:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m21-v6si21393022pgd.48.2018.09.11.05.11.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 05:11:44 -0700 (PDT)
Date: Tue, 11 Sep 2018 14:11:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Message-ID: <20180911121141.GS10951@dhcp22.suse.cz>
References: <20180910215622.4428-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180910215622.4428-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon 10-09-18 14:56:22, Roman Gushchin wrote:
> The memcg OOM killer is never invoked due to a failed high-order
> allocation, however the MEMCG_OOM event can be easily raised.
> 
> Under some memory pressure it can happen easily because of a
> concurrent allocation. Let's look at try_charge(). Even if we were
> able to reclaim enough memory, this check can fail due to a race
> with another allocation:
> 
>     if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
>         goto retry;
> 
> For regular pages the following condition will save us from triggering
> the OOM:
> 
>    if (nr_reclaimed && nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER))
>        goto retry;
> 
> But for high-order allocation this condition will intentionally fail.
> The reason behind is that we'll likely fall to regular pages anyway,
> so it's ok and even preferred to return ENOMEM.
> 
> In this case the idea of raising the MEMCG_OOM event looks dubious.

Why is this a problem though? IIRC this event was deliberately placed
outside of the oom path because we wanted to count allocation failures
and this is also documented that way

          oom
                The number of time the cgroup's memory usage was
                reached the limit and allocation was about to fail.

                Depending on context result could be invocation of OOM
                killer and retrying allocation or failing a

One could argue that we do not apply the same logic to GFP_NOWAIT
requests but in general I would like to see a good reason to change
the behavior and if it is really the right thing to do then we need to
update the documentation as well.

> Fix this by moving MEMCG_OOM raising to  mem_cgroup_oom() after
> allocation order check, so that the event won't be raised for high
> order allocations.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> ---
>  mm/memcontrol.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fcec9b39e2a3..103ca3c31c04 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1669,6 +1669,8 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
>  	if (order > PAGE_ALLOC_COSTLY_ORDER)
>  		return OOM_SKIPPED;
>  
> +	memcg_memory_event(memcg, MEMCG_OOM);
> +
>  	/*
>  	 * We are in the middle of the charge context here, so we
>  	 * don't want to block when potentially sitting on a callstack
> @@ -2250,8 +2252,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	if (fatal_signal_pending(current))
>  		goto force;
>  
> -	memcg_memory_event(mem_over_limit, MEMCG_OOM);
> -
>  	/*
>  	 * keep retrying as long as the memcg oom killer is able to make
>  	 * a forward progress or bypass the charge if the oom killer
> -- 
> 2.17.1

-- 
Michal Hocko
SUSE Labs
