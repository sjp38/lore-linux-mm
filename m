Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C8666B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 19:19:22 -0400 (EDT)
Date: Tue, 9 Aug 2011 01:19:12 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 4/4] memcg: get rid of percpu_charge_mutex lock
Message-ID: <20110808231912.GA29002@redhat.com>
References: <cover.1311338634.git.mhocko@suse.cz>
 <a9244082ba28c4c2e4a6997311d5493bdaa117e9.1311338634.git.mhocko@suse.cz>
 <20110808184738.GA7749@redhat.com>
 <20110808214704.GA4396@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110808214704.GA4396@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, Aug 08, 2011 at 11:47:04PM +0200, Michal Hocko wrote:
> On Mon 08-08-11 20:47:38, Johannes Weiner wrote:
> [...]
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -2071,7 +2071,6 @@ struct memcg_stock_pcp {
> > >  #define FLUSHING_CACHED_CHARGE	(0)
> > >  };
> > >  static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
> > > -static DEFINE_MUTEX(percpu_charge_mutex);
> > >  
> > >  /*
> > >   * Try to consume stocked charge on this cpu. If success, one page is consumed
> > > @@ -2178,7 +2177,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> > >  
> > >  	for_each_online_cpu(cpu) {
> > >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > > -		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > +		if (mem_cgroup_same_or_subtree(root_mem, stock->cached) &&
> > > +				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > >  			flush_work(&stock->work);
> > >  	}
> > >  out:
> > 
> > This hunk triggers a crash for me, as the draining is already done and
> > stock->cached reset to NULL when dereferenced here.  Oops is attached.
> 
> Thanks for catching this. We are racing synchronous drain from
> force_empty and async drain from reclaim, I guess.

It's at the end of a benchmark where several tasks delete the cgroups.
There is no reclaim going on anymore, it must be several sync drains
from force_empty of different memcgs.

> Sync. checked whether it should wait for the work and the cache got
> drained and set to NULL.  First of all we must not dereference the
> cached mem without FLUSHING_CACHED_CHARGE bit test. We have to be
> sure that there is some draining on that cache. stock->cached is set
> to NULL before we clear the bit (I guess we need to add a barrier
> into drain_local_stock). So we should see mem either as NULL or
> still valid (I have to think some more about "still valid" part -
> maybe we will need rcu_read_lock).
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f4ec4e7..626c916 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2197,8 +2197,10 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
>  
>  	for_each_online_cpu(cpu) {
>  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> -		if (mem_cgroup_same_or_subtree(root_mem, stock->cached) &&
> -				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> +		struct mem_cgroup *mem = stock->cached;
> +		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags) &&
> +				 mem && mem_cgroup_same_or_subtree(root_mem, mem)
> +				)
>  			flush_work(&stock->work);
>  	}
>  out:

This ordering makes sure that mem is a sensible pointer, but it still
does not pin the object, *mem, which could go away the femtosecond
after the test_bit succeeds.

> > We have this loop in drain_all_stock():
> > 
> > 	for_each_online_cpu(cpu) {
> > 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > 		struct mem_cgroup *mem;
> > 
> > 		mem = stock->cached;
> > 		if (!mem || !stock->nr_pages)
> > 			continue;
> > 		if (!mem_cgroup_same_or_subtree(root_mem, mem))
> > 			continue;
> > 		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
> > 			if (cpu == curcpu)
> > 				drain_local_stock(&stock->work);
> > 			else
> > 				schedule_work_on(cpu, &stock->work);
> > 		}
> > 	}
> > 
> > The only thing that stabilizes stock->cached is the knowledge that
> > there are still pages accounted to the memcg.
> 
> Yes you are right we have to set FLUSHING_CACHED_CHARGE before nr_pages
> check (and do the appropriate cleanup on the continue paths). This looks
> quite ugly, though.
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f4ec4e7..eca46141 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2179,17 +2179,23 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
>  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
>  		struct mem_cgroup *mem;
>  
> +		/* Try to lock the cache */
> +		if(test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> +			continue;
> +
>  		mem = stock->cached;
>  		if (!mem || !stock->nr_pages)
> -			continue;
> +			goto unlock_cache;
>  		if (!mem_cgroup_same_or_subtree(root_mem, mem))
> -			continue;
> -		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
> -			if (cpu == curcpu)
> -				drain_local_stock(&stock->work);
> -			else
> -				schedule_work_on(cpu, &stock->work);
> -		}
> +			goto unlock_cache;

So one thread locks the cache, recognizes stock->cached is not in the
right hierarchy and unlocks again.  While the cache was locked, a
concurrent drainer with the right hierarchy skipped the stock because
it was locked.  That doesn't sound right.

But yes, we probably need exclusive access to the stock state.

> +
> +		if (cpu == curcpu)
> +			drain_local_stock(&stock->work);
> +		else
> +			schedule_work_on(cpu, &stock->work);
> +		continue;
> +unlock_cache:
> +		clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
> 
>                 ^^^^^
> 		need a barrier?
>  	}
>  
>  	if (!sync)
>  
> > Without the mutex serializing this code, can't there be a concurrent
> > execution that leads to stock->cached being drained, becoming empty
> > and freed by someone else between the stock->nr_pages check and the
> > ancestor check, resulting in use after free?
> > 
> > What makes stock->cached safe to dereference?
> 
> We are using FLUSHING_CACHED_CHARGE as a lock for local draining. I
> guess it should be sufficient.
> 
> mutex which was used previously caused that async draining was exclusive
> so a root_mem that has potentially many relevant caches has to back off
> because other mem wants to clear the cache on the same CPU.

It's now replaced by what is essentially a per-stock bit-spinlock that
is always trylocked.

Would it make sense to promote it to a real spinlock?  Draining a
stock is pretty fast, there should be minimal lock hold times, but we
would still avoid that tiny race window where we would skip otherwise
correct stocks just because they are locked.

> I will think about this tomorrow (with fresh eyes). I think we should be
> able to be without mutex.

The problem is that we have a multi-op atomic section, so we can not
go lockless.  We can read the stock state just fine, and order
accesses to different members so that we get a coherent image.  But
there is still nothing that pins the charge to the memcg, and thus
nothing that stabilizes *stock->cached.

I agree that we can probably do better than a global lock, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
