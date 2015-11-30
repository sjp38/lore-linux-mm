Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 62D2D6B0258
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 12:08:49 -0500 (EST)
Received: by lffu14 with SMTP id u14so206311712lff.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 09:08:48 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 6si29478687lfi.118.2015.11.30.09.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 09:08:47 -0800 (PST)
Date: Mon, 30 Nov 2015 20:08:31 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 12/13] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Message-ID: <20151130170831.GE24704@esperanza>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
 <20151124215844.GA1373@cmpxchg.org>
 <20151130105421.GA24704@esperanza>
 <20151130152638.GA30243@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151130152638.GA30243@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Nov 30, 2015 at 10:26:38AM -0500, Johannes Weiner wrote:
> On Mon, Nov 30, 2015 at 01:54:21PM +0300, Vladimir Davydov wrote:
> > On Tue, Nov 24, 2015 at 04:58:44PM -0500, Johannes Weiner wrote:
> > ...
> > > @@ -5520,15 +5557,30 @@ void sock_release_memcg(struct sock *sk)
> > >   */
> > >  bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> > >  {
> > > -	struct page_counter *counter;
> > > +	gfp_t gfp_mask = GFP_KERNEL;
> > >  
> > > -	if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
> > > -				    nr_pages, &counter)) {
> > > -		memcg->tcp_mem.memory_pressure = 0;
> > > -		return true;
> > > +#ifdef CONFIG_MEMCG_KMEM
> > > +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
> > > +		struct page_counter *counter;
> > > +
> > > +		if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
> > > +					    nr_pages, &counter)) {
> > > +			memcg->tcp_mem.memory_pressure = 0;
> > > +			return true;
> > > +		}
> > > +		page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
> > > +		memcg->tcp_mem.memory_pressure = 1;
> > > +		return false;
> > >  	}
> > > -	page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
> > > -	memcg->tcp_mem.memory_pressure = 1;
> > > +#endif
> > > +	/* Don't block in the packet receive path */
> > > +	if (in_softirq())
> > > +		gfp_mask = GFP_NOWAIT;
> > > +
> > > +	if (try_charge(memcg, gfp_mask, nr_pages) == 0)
> > > +		return true;
> > > +
> > > +	try_charge(memcg, gfp_mask|__GFP_NOFAIL, nr_pages);
> > 
> > We won't trigger high reclaim if we get here, because try_charge does
> > not check high threshold if failing or forcing charge. I think this
> > should be fixed regardless of this patch. The fix is attached below.
> 
> We kind of assume that max is either set above high, or not at
> all. That means when max is hit the high limit has already failed and
> it's of limited use to schedule background reclaim.

Yeah, you're right. No point scheduling the work here - it must be
already running.

> 
> > Also, I don't like calling try_charge twice: the second time will go
> > through all the try_charge steps for nothing. What about checking
> > page_counter value after calling try_charge instead:
> > 
> > 	try_charge(memcg, gfp_mask|__GFP_NOFAIL, nr_pages);
> > 	return page_counter_read(&memcg->memory) <= memcg->memory.limit;
> > 
> > or adding an out parameter to try_charge that would inform us if charge
> > was forced?
> 
> That's a complete cold path where we are going to drop the packet in
> all but a few cases. It's not worth the trouble.

Right

> 
> > > @@ -5539,10 +5591,32 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> > >   */
> > >  void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> > >  {
> > > -	page_counter_uncharge(&memcg->tcp_mem.memory_allocated, nr_pages);
> > > +#ifdef CONFIG_MEMCG_KMEM
> > > +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
> > > +		page_counter_uncharge(&memcg->tcp_mem.memory_allocated,
> > > +				      nr_pages);
> > > +		return;
> > > +	}
> > > +#endif
> > > +	page_counter_uncharge(&memcg->memory, nr_pages);
> > > +	css_put_many(&memcg->css, nr_pages);
> > 
> > cancel_charge(memcg, nr_pages);
> 
> It does the same, but it's a weird name for regular uncharging.

Right

> 
> > From: Vladimir Davydov <vdavydov@virtuozzo.com>
> > Subject: [PATCH] memcg: check high threshold if forcing allocation
> > 
> > try_charge() does not result in checking high threshold if it forces
> > charge. This is incorrect, because we could have failed to reclaim
> > memory due to the current context, so we do need to check high threshold
> > and try to compensate for the excess once we are in the safe context.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 79a29d564bff..e922965b572b 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2112,13 +2112,14 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >  		page_counter_charge(&memcg->memsw, nr_pages);
> >  	css_get_many(&memcg->css, nr_pages);
> >  
> > -	return 0;
> > +	goto check_high;
> >  
> >  done_restock:
> >  	css_get_many(&memcg->css, batch);
> >  	if (batch > nr_pages)
> >  		refill_stock(memcg, batch - nr_pages);
> >  
> > +check_high:
> >  	/*
> >  	 * If the hierarchy is above the normal consumption range, schedule
> >  	 * reclaim on returning to userland.  We can perform reclaim here
> 
> One problem is that OOM victims force their charges so they can exit
> quickly. It'd be contradictory to then task them with high reclaim.
> 

Yeah, scratch that patch. It isn't necessary anyway, because, as you
pointed out, we don't really need to schedule high reclaim when we fail
hard in mem_cgroup_charge_skmem.

No more questions left,

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
