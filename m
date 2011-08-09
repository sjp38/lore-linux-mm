Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D7E98900137
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 03:26:20 -0400 (EDT)
Date: Tue, 9 Aug 2011 09:26:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] memcg: get rid of percpu_charge_mutex lock
Message-ID: <20110809072615.GA7463@tiehlicka.suse.cz>
References: <cover.1311338634.git.mhocko@suse.cz>
 <a9244082ba28c4c2e4a6997311d5493bdaa117e9.1311338634.git.mhocko@suse.cz>
 <20110808184738.GA7749@redhat.com>
 <20110808214704.GA4396@tiehlicka.suse.cz>
 <20110808231912.GA29002@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110808231912.GA29002@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue 09-08-11 01:19:12, Johannes Weiner wrote:
> On Mon, Aug 08, 2011 at 11:47:04PM +0200, Michal Hocko wrote:
> > On Mon 08-08-11 20:47:38, Johannes Weiner wrote:
> > [...]
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -2071,7 +2071,6 @@ struct memcg_stock_pcp {
> > > >  #define FLUSHING_CACHED_CHARGE	(0)
> > > >  };
> > > >  static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
> > > > -static DEFINE_MUTEX(percpu_charge_mutex);
> > > >  
> > > >  /*
> > > >   * Try to consume stocked charge on this cpu. If success, one page is consumed
> > > > @@ -2178,7 +2177,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> > > >  
> > > >  	for_each_online_cpu(cpu) {
> > > >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > > > -		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > > +		if (mem_cgroup_same_or_subtree(root_mem, stock->cached) &&
> > > > +				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > >  			flush_work(&stock->work);
> > > >  	}
> > > >  out:
> > > 
> > > This hunk triggers a crash for me, as the draining is already done and
> > > stock->cached reset to NULL when dereferenced here.  Oops is attached.
> > 
> > Thanks for catching this. We are racing synchronous drain from
> > force_empty and async drain from reclaim, I guess.
> 
> It's at the end of a benchmark where several tasks delete the cgroups.
> There is no reclaim going on anymore, it must be several sync drains
> from force_empty of different memcgs.

I am afraid it is worse than that. Sync. drainer can kick itself really
trivial just by doing local draining. Then stock->cached is guaranteed
to be NULL when we reach this...

[...]
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index f4ec4e7..626c916 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2197,8 +2197,10 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> >  
> >  	for_each_online_cpu(cpu) {
> >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > -		if (mem_cgroup_same_or_subtree(root_mem, stock->cached) &&
> > -				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > +		struct mem_cgroup *mem = stock->cached;
> > +		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags) &&
> > +				 mem && mem_cgroup_same_or_subtree(root_mem, mem)
> > +				)
> >  			flush_work(&stock->work);
> >  	}
> >  out:
> 
> This ordering makes sure that mem is a sensible pointer, but it still
> does not pin the object, *mem, which could go away the femtosecond
> after the test_bit succeeds.

Yes there are possible races
	CPU0			CPU1				CPU2
mem = stock->cached
			stock->cached = NULL
			clear_bit
							    test_and_set_bit
test_bit()
<preempted>		...
			mem_cgroup_destroy
use after free

The race is not very probable because we are doing quite a bunch of work
before we can deallocate mem. mem_cgroup_destroy is called after
synchronize_rcu so we can close the race by rcu_read_lock, right?


[...]
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index f4ec4e7..eca46141 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2179,17 +2179,23 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> >  		struct mem_cgroup *mem;
> >  
> > +		/* Try to lock the cache */
> > +		if(test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > +			continue;
> > +
> >  		mem = stock->cached;
> >  		if (!mem || !stock->nr_pages)
> > -			continue;
> > +			goto unlock_cache;
> >  		if (!mem_cgroup_same_or_subtree(root_mem, mem))
> > -			continue;
> > -		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
> > -			if (cpu == curcpu)
> > -				drain_local_stock(&stock->work);
> > -			else
> > -				schedule_work_on(cpu, &stock->work);
> > -		}
> > +			goto unlock_cache;
> 
> So one thread locks the cache, recognizes stock->cached is not in the
> right hierarchy and unlocks again.  While the cache was locked, a
> concurrent drainer with the right hierarchy skipped the stock because
> it was locked.  That doesn't sound right.

You are right. We have to make it less parallel.

> 
> But yes, we probably need exclusive access to the stock state.
> 
> > +
> > +		if (cpu == curcpu)
> > +			drain_local_stock(&stock->work);
> > +		else
> > +			schedule_work_on(cpu, &stock->work);
> > +		continue;
> > +unlock_cache:
> > +		clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
> > 
> >                 ^^^^^
> > 		need a barrier?
> >  	}
> >  
> >  	if (!sync)
> >  
> > > Without the mutex serializing this code, can't there be a concurrent
> > > execution that leads to stock->cached being drained, becoming empty
> > > and freed by someone else between the stock->nr_pages check and the
> > > ancestor check, resulting in use after free?
> > > 
> > > What makes stock->cached safe to dereference?
> > 
> > We are using FLUSHING_CACHED_CHARGE as a lock for local draining. I
> > guess it should be sufficient.
> > 
> > mutex which was used previously caused that async draining was exclusive
> > so a root_mem that has potentially many relevant caches has to back off
> > because other mem wants to clear the cache on the same CPU.
> 
> It's now replaced by what is essentially a per-stock bit-spinlock that
> is always trylocked.

Yes.

> 
> Would it make sense to promote it to a real spinlock?  Draining a
> stock is pretty fast, there should be minimal lock hold times, but we
> would still avoid that tiny race window where we would skip otherwise
> correct stocks just because they are locked.

Yes, per-stock spinlock will be easiest way because if tried other games
with atomics we would endup with a more complicated refill_stock which
can race with draining as well.

> > I will think about this tomorrow (with fresh eyes). I think we should be
> > able to be without mutex.
> 
> The problem is that we have a multi-op atomic section, so we can not
> go lockless.  We can read the stock state just fine, and order
> accesses to different members so that we get a coherent image.  But
> there is still nothing that pins the charge to the memcg, and thus
> nothing that stabilizes *stock->cached.
> 
> I agree that we can probably do better than a global lock, though.

Fully agreed. I will send a patch after I give it some testing.

Thanks!
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
