Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4A76B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 11:47:16 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so4411303wgh.14
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 08:47:15 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id hl8si8949878wib.60.2014.08.07.08.47.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 08:47:14 -0700 (PDT)
Date: Thu, 7 Aug 2014 11:47:10 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/4] mm: memcontrol: add memory.current and memory.high
 to default hierarchy
Message-ID: <20140807154710.GE14734@cmpxchg.org>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
 <1407186897-21048-3-git-send-email-hannes@cmpxchg.org>
 <20140807133614.GC12730@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140807133614.GC12730@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Aug 07, 2014 at 03:36:14PM +0200, Michal Hocko wrote:
> On Mon 04-08-14 17:14:55, Johannes Weiner wrote:
> [...]
> > @@ -132,6 +137,19 @@ u64 res_counter_uncharge(struct res_counter *counter, unsigned long val);
> >  u64 res_counter_uncharge_until(struct res_counter *counter,
> >  			       struct res_counter *top,
> >  			       unsigned long val);
> > +
> > +static inline unsigned long long res_counter_high(struct res_counter *cnt)
> 
> soft limit used res_counter_soft_limit_excess which has quite a long
> name but at least those two should be consistent.

That name is horrible and a result from "soft_limit" being completely
nondescriptive.  I really see no point in trying to be consistent with
this stuff that we are trying hard to delete.

> > @@ -2621,6 +2621,20 @@ bypass:
> >  done_restock:
> >  	if (batch > nr_pages)
> >  		refill_stock(memcg, batch - nr_pages);
> > +
> > +	res = &memcg->res;
> > +	while (res) {
> > +		unsigned long long high = res_counter_high(res);
> > +
> > +		if (high) {
> > +			unsigned long high_pages = high >> PAGE_SHIFT;
> > +			struct mem_cgroup *memcg;
> > +
> > +			memcg = mem_cgroup_from_res_counter(res, res);
> > +			mem_cgroup_reclaim(memcg, high_pages, gfp_mask, 0);
> > +		}
> > +		res = res->parent;
> > +	}
> >  done:
> >  	return ret;
> >  }
> 
> Why haven't you followed what we do for hard limit here?

I did.

> In my implementation I have the following:
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a37465fcd8ae..6a797c740ea5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2529,6 +2529,21 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
>  	return NOTIFY_OK;
>  }
>  
> +static bool high_limit_excess(struct mem_cgroup *memcg,
> +		struct mem_cgroup **memcg_over_limit)
> +{
> +	struct mem_cgroup *parent = memcg;
> +
> +	do {
> +		if (res_counter_limit_excess(&parent->res, RES_HIGH_LIMIT)) {
> +			*memcg_over_limit = parent;
> +			return true;
> +		}
> +	} while ((parent = parent_mem_cgroup(parent)));
> +
> +	return false;
> +}
> +
>  static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  		      unsigned int nr_pages)
>  {
> @@ -2623,6 +2638,10 @@ bypass:
>  	goto retry;
>  
>  done_restock:
> +	/* Throttle charger a bit if it is above high limit. */
> +	if (high_limit_excess(memcg, &mem_over_limit))
> +		mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);

This is not what the hard limit does.

The hard limit, by its nature, can only be exceeded at one level at a
time, so we try to charge, check the closest limit that was hit,
reclaim, then retry.  This means we are reclaiming up the hierarchy to
enforce the hard limit on each level.

I do the same here: reclaim up the hierarchy to enforce the high limit
on each level.

Your proposal only reclaims the closest offender, leaving higher
hierarchy levels in excess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
