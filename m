Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 65E426B016D
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 05:45:08 -0400 (EDT)
Date: Tue, 9 Aug 2011 11:45:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC] memcg: fix drain_all_stock crash
Message-ID: <20110809094503.GD7463@tiehlicka.suse.cz>
References: <cover.1311338634.git.mhocko@suse.cz>
 <a9244082ba28c4c2e4a6997311d5493bdaa117e9.1311338634.git.mhocko@suse.cz>
 <20110808184738.GA7749@redhat.com>
 <20110808214704.GA4396@tiehlicka.suse.cz>
 <20110808231912.GA29002@redhat.com>
 <20110809072615.GA7463@tiehlicka.suse.cz>
 <20110809093150.GC7463@tiehlicka.suse.cz>
 <20110809183216.97daf2b0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809183216.97daf2b0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue 09-08-11 18:32:16, KAMEZAWA Hiroyuki wrote:
> On Tue, 9 Aug 2011 11:31:50 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > What do you think about the half backed patch bellow? I didn't manage to
> > test it yet but I guess it should help. I hate asymmetry of drain_lock
> > locking (it is acquired somewhere else than it is released which is
> > not). I will think about a nicer way how to do it.
> > Maybe I should also split the rcu part in a separate patch.
> > 
> > What do you think?
> 
> 
> I'd like to revert 8521fc50 first and consider total design change
> rather than ad-hoc fix.

Agreed. Revert should go into 3.0 stable as well. Although the global
mutex is buggy we have that behavior for a long time without any reports.
We should address it but it can wait for 3.2.

> Personally, I don't like to have spin-lock in per-cpu area.

spinlock is not that different from what we already have with the bit
lock.

> 
> 
> Thanks,
> -Kame
> 
> > ---
> > From 26c2cdc55aa14ec4a54e9c8e2c8b9072c7cb8e28 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Tue, 9 Aug 2011 10:53:28 +0200
> > Subject: [PATCH] memcg: fix drain_all_stock crash
> > 
> > 8521fc50 (memcg: get rid of percpu_charge_mutex lock) introduced a crash
> > in sync mode when we are about to check whether we have to wait for the
> > work because we are calling mem_cgroup_same_or_subtree without checking
> > FLUSHING_CACHED_CHARGE before so we can dereference already cleaned
> > cache (the simplest case would be when we drain the local cache).
> > 
> > BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
> > IP: [<ffffffff81083b70>] css_is_ancestor+0x20/0x70
> > PGD 4ae7a067 PUD 4adc4067 PMD 0
> > Oops: 0000 [#1] PREEMPT SMP
> > CPU 0
> > Pid: 19677, comm: rmdir Tainted: G        W   3.0.0-mm1-00188-gf38d32b #35 ECS MCP61M-M3/MCP61M-M3
> > RIP: 0010:[<ffffffff81083b70>]  [<ffffffff81083b70>] css_is_ancestor+0x20/0x70
> > RSP: 0018:ffff880077b09c88  EFLAGS: 00010202
> > RAX: ffff8800781bb310 RBX: 0000000000000000 RCX: 000000000000003e
> > RDX: 0000000000000000 RSI: ffff8800779f7c00 RDI: 0000000000000000
> > RBP: ffff880077b09c98 R08: ffffffff818a4e88 R09: 0000000000000000
> > R10: 0000000000000000 R11: dead000000100100 R12: ffff8800779f7c00
> > R13: ffff8800779f7c00 R14: 0000000000000000 R15: ffff88007bc0eb80
> > FS:  00007f5d689ec720(0000) GS:ffff88007bc00000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 0000000000000018 CR3: 000000004ad57000 CR4: 00000000000006f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process rmdir (pid: 19677, threadinfo ffff880077b08000, task ffff8800781bb310)
> > Stack:
> >  ffffffff818a4e88 000000000000eb80 ffff880077b09ca8 ffffffff810feba3
> >  ffff880077b09d08 ffffffff810feccf ffff880077b09cf8 0000000000000001
> >  ffff88007bd0eb80 0000000000000001 ffff880077af2000 0000000000000000
> > Call Trace:
> >  [<ffffffff810feba3>] mem_cgroup_same_or_subtree+0x33/0x40
> >  [<ffffffff810feccf>] drain_all_stock+0x11f/0x170
> >  [<ffffffff81103211>] mem_cgroup_force_empty+0x231/0x6d0
> >  [<ffffffff81111872>] ? path_put+0x22/0x30
> >  [<ffffffff8111c925>] ? __d_lookup+0xb5/0x170
> >  [<ffffffff811036c4>] mem_cgroup_pre_destroy+0x14/0x20
> >  [<ffffffff81080559>] cgroup_rmdir+0xb9/0x500
> >  [<ffffffff81063990>] ? abort_exclusive_wait+0xb0/0xb0
> >  [<ffffffff81114d26>] vfs_rmdir+0x86/0xe0
> >  [<ffffffff811233d3>] ? mnt_want_write+0x43/0x80
> >  [<ffffffff81114e7b>] do_rmdir+0xfb/0x110
> >  [<ffffffff81114ea6>] sys_rmdir+0x16/0x20
> >  [<ffffffff8154d76b>] system_call_fastpath+0x16/0x1b
> > 
> > Testing FLUSHING_CACHED_CHARGE before dereferencing is still not enough
> > because then we still might see mem == NULL so we have to check it
> > before dereferencing.
> > We have to do all stock checking under FLUSHING_CACHED_CHARGE bit lock
> > so it is much easier to use a spin_lock instead. Let's also add a flag
> > (under_drain) that draining in progress so that concurrent callers do
> > not have to wait on the lock pointlessly.
> > 
> > Finally we do not make sure that the mem still exists. It could have
> > been removed in the meantime:
> > 	CPU0			CPU1			     CPU2
> > mem=stock->cached
> > stock->cached=NULL
> > 			      clear_bit
> > 							test_and_set_bit
> > test_bit()		      ...
> > <preempted>		mem_cgroup_destroy
> > use after free
> > 
> > `...' is actually quite a bunch of work to do so the race is not very
> > probable. The important thing, though, is that cgroup_subsys->destroy
> > (mem_cgroup_destroy) is called after synchronize_rcu so we can protect
> > by calling rcu_read_lock when dereferencing cached mem.
> > 
> > TODO:
> > - check if under_drain needs some memory barriers
> > - check the hotplug path (can we wait on spinlock?)
> > - better changelog
> > - do some testing
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > Reported-by: Johannes Weiner <jweiner@redhat.com>
> > ---
> >  mm/memcontrol.c |   67 +++++++++++++++++++++++++++++++++++++++++-------------
> >  1 files changed, 51 insertions(+), 16 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index f4ec4e7..e34f9fd 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2087,8 +2087,8 @@ struct memcg_stock_pcp {
> >  	struct mem_cgroup *cached; /* this never be root cgroup */
> >  	unsigned int nr_pages;
> >  	struct work_struct work;
> > -	unsigned long flags;
> > -#define FLUSHING_CACHED_CHARGE	(0)
> > +	spinlock_t drain_lock; /* protects from parallel draining */
> > +	bool under_drain;
> >  };
> >  static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
> >  
> > @@ -2114,6 +2114,7 @@ static bool consume_stock(struct mem_cgroup *mem)
> >  
> >  /*
> >   * Returns stocks cached in percpu to res_counter and reset cached information.
> > + * Do not call this directly - use drain_local_stock instead.
> >   */
> >  static void drain_stock(struct memcg_stock_pcp *stock)
> >  {
> > @@ -2133,12 +2134,16 @@ static void drain_stock(struct memcg_stock_pcp *stock)
> >  /*
> >   * This must be called under preempt disabled or must be called by
> >   * a thread which is pinned to local cpu.
> > + * Parameter is not used.
> > + * Assumes stock->drain_lock held.
> >   */
> >  static void drain_local_stock(struct work_struct *dummy)
> >  {
> >  	struct memcg_stock_pcp *stock = &__get_cpu_var(memcg_stock);
> >  	drain_stock(stock);
> > -	clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
> > +
> > +	stock->under_drain = false;
> > +	spin_unlock(&stock->drain_lock);
> >  }
> >  
> >  /*
> > @@ -2150,7 +2155,9 @@ static void refill_stock(struct mem_cgroup *mem, unsigned int nr_pages)
> >  	struct memcg_stock_pcp *stock = &get_cpu_var(memcg_stock);
> >  
> >  	if (stock->cached != mem) { /* reset if necessary */
> > -		drain_stock(stock);
> > +		spin_lock(&stock->drain_lock);
> > +		stock->under_drain = true;
> > +		drain_local_stock(NULL);
> >  		stock->cached = mem;
> >  	}
> >  	stock->nr_pages += nr_pages;
> > @@ -2179,17 +2186,27 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> >  		struct mem_cgroup *mem;
> >  
> > +		/*
> > +		 * make sure we are not waiting when somebody already drains
> > +		 * the cache.
> > +		 */
> > +		if (!spin_trylock(&stock->drain_lock)) {
> > +			if (stock->under_drain)
> > +				continue;
> > +			spin_lock(&stock->drain_lock);
> > +		}
> >  		mem = stock->cached;
> > -		if (!mem || !stock->nr_pages)
> > +		if (!mem || !stock->nr_pages ||
> > +				!mem_cgroup_same_or_subtree(root_mem, mem)) {
> > +			spin_unlock(&stock->drain_lock);
> >  			continue;
> > -		if (!mem_cgroup_same_or_subtree(root_mem, mem))
> > -			continue;
> > -		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
> > -			if (cpu == curcpu)
> > -				drain_local_stock(&stock->work);
> > -			else
> > -				schedule_work_on(cpu, &stock->work);
> >  		}
> > +
> > +		stock->under_drain = true;
> > +		if (cpu == curcpu)
> > +			drain_local_stock(&stock->work);
> > +		else
> > +			schedule_work_on(cpu, &stock->work);
> >  	}
> >  
> >  	if (!sync)
> > @@ -2197,8 +2214,20 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> >  
> >  	for_each_online_cpu(cpu) {
> >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > -		if (mem_cgroup_same_or_subtree(root_mem, stock->cached) &&
> > -				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > +		struct mem_cgroup *mem;
> > +		bool wait_for_drain = false;
> > +
> > +		/*
> > +		 * we have to be careful about parallel group destroying
> > +		 * (mem_cgroup_destroy) which is derefered after sychronize_rcu
> > +		 */
> > +		rcu_read_lock();
> > +		mem = stock->cached;
> > +		wait_for_drain = stock->under_drain &&
> > +			mem && mem_cgroup_same_or_subtree(root_mem, mem);
> > +		rcu_read_unlock();
> > +
> > +		if (wait_for_drain)
> >  			flush_work(&stock->work);
> >  	}
> >  out:
> > @@ -2278,8 +2307,12 @@ static int __cpuinit memcg_cpu_hotplug_callback(struct notifier_block *nb,
> >  	for_each_mem_cgroup_all(iter)
> >  		mem_cgroup_drain_pcp_counter(iter, cpu);
> >  
> > -	stock = &per_cpu(memcg_stock, cpu);
> > -	drain_stock(stock);
> > +	if (!spin_trylock(&stock->drain_lock)) {
> > +		if (stock->under_drain)
> > +			return NOTIFY_OK;
> > +		spin_lock(&stock->drain_lock);
> > +	}
> > +	drain_local_stock(NULL);
> >  	return NOTIFY_OK;
> >  }
> >  
> > @@ -5068,6 +5101,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  			struct memcg_stock_pcp *stock =
> >  						&per_cpu(memcg_stock, cpu);
> >  			INIT_WORK(&stock->work, drain_local_stock);
> > +			stock->under_drain = false;
> > +			spin_lock_init(&stock->drain_lock);
> >  		}
> >  		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
> >  	} else {
> > -- 
> > 1.7.5.4
> > 
> > 
> > -- 
> > Michal Hocko
> > SUSE Labs
> > SUSE LINUX s.r.o.
> > Lihovarska 1060/12
> > 190 00 Praha 9    
> > Czech Republic
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
