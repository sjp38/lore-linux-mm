Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4AB6B007B
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 02:36:04 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 676143EE0BD
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 15:35:59 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D15345DEA3
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 15:35:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 33F5545DE83
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 15:35:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EF4F1DB802C
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 15:35:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CAD6C1DB803C
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 15:35:58 +0900 (JST)
Date: Wed, 8 Jun 2011 15:29:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix behavior of per cpu charge cache
 draining.
Message-Id: <20110608152901.f16b3e59.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110608144934.b5944a64.nishimura@mxp.nes.nec.co.jp>
References: <20110608140518.0cd9f791.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608144934.b5944a64.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>

On Wed, 8 Jun 2011 14:49:34 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> I have a few minor comments.
> 
> On Wed, 8 Jun 2011 14:05:18 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > This patch is made against mainline git tree.
> > ==
> > From d1372da4d3c6f8051b5b1cf7b5e8b45a8094b388 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Wed, 8 Jun 2011 13:51:11 +0900
> > Subject: [BUGFIX][PATCH] memcg: fix behavior of per cpu charge cache draining.
> > 
> > For performance, memory cgroup caches some "charge" from res_counter
> > into per cpu cache. This works well but because it's cache,
> > it needs to be flushed in some cases. Typical cases are
> > 	1. when someone hit limit.
> > 	2. when rmdir() is called and need to charges to be 0.
> > 
> > But "1" has problem.
> > 
> > Recently, with large SMP machines, we see many kworker/%d:%d when
> > memcg hit limit. It is because of flushing memcg's percpu cache. 
> > Bad things in implementation are
> > 
> > a) it's called before calling try_to_free_mem_cgroup_pages()
> >    so, it's called immidiately when a task hit limit.
> >    (I thought it was better to avoid to run into memory reclaim.
> >     But it was wrong decision.)
> > 
> > b) Even if a cpu contains a cache for memcg not related to
> >    a memcg which hits limit, drain code is called.
> > 
> > This patch fixes a) and b) by
> > 
> > A) delay calling of flushing until one run of try_to_free...
> >    Then, the number of calling is much decreased.
> > B) check percpu cache contains a useful data or not.
> > plus
> > C) check asynchronous percpu draining doesn't run on the cpu.
> > 
> > Reported-by: Ying Han <yinghan@google.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   44 ++++++++++++++++++++++++++++----------------
> >  1 files changed, 28 insertions(+), 16 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index bd9052a..c22c0eb 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -359,7 +359,7 @@ enum charge_type {
> >  static void mem_cgroup_get(struct mem_cgroup *mem);
> >  static void mem_cgroup_put(struct mem_cgroup *mem);
> >  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> > -static void drain_all_stock_async(void);
> > +static void drain_all_stock_async(struct mem_cgroup *mem);
> >  
> >  static struct mem_cgroup_per_zone *
> >  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> > @@ -1670,8 +1670,6 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  		victim = mem_cgroup_select_victim(root_mem);
> >  		if (victim == root_mem) {
> >  			loop++;
> > -			if (loop >= 1)
> > -				drain_all_stock_async();
> >  			if (loop >= 2) {
> >  				/*
> >  				 * If we have not been able to reclaim
> > @@ -1723,6 +1721,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  				return total;
> >  		} else if (mem_cgroup_margin(root_mem))
> >  			return total;
> > +		drain_all_stock_async(root_mem);
> >  	}
> >  	return total;
> >  }
> > @@ -1934,9 +1933,11 @@ struct memcg_stock_pcp {
> >  	struct mem_cgroup *cached; /* this never be root cgroup */
> >  	unsigned int nr_pages;
> >  	struct work_struct work;
> > +	unsigned long flags;
> > +#define ASYNC_FLUSHING	(0)
> >  };
> >  static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
> > -static atomic_t memcg_drain_count;
> > +static atomic_t memcg_drain_count; /* Indicates there is synchronous flusher */
> >  
> >  /*
> >   * Try to consume stocked charge on this cpu. If success, one page is consumed
> > @@ -1984,6 +1985,7 @@ static void drain_local_stock(struct work_struct *dummy)
> >  {
> >  	struct memcg_stock_pcp *stock = &__get_cpu_var(memcg_stock);
> >  	drain_stock(stock);
> > +	clear_bit(ASYNC_FLUSHING, &stock->flags);
> >  }
> >  
> >  /*
> > @@ -2006,28 +2008,38 @@ static void refill_stock(struct mem_cgroup *mem, unsigned int nr_pages)
> >   * Tries to drain stocked charges in other cpus. This function is asynchronous
> >   * and just put a work per cpu for draining localy on each cpu. Caller can
> >   * expects some charges will be back to res_counter later but cannot wait for
> > - * it.
> > + * it. This runs only when per-cpu stock contains information of memcg which
> > + * is under specified root_mem and no other flush runs.
> >   */
> > -static void drain_all_stock_async(void)
> > +static void drain_all_stock_async(struct mem_cgroup *root_mem)
> >  {
> >  	int cpu;
> > -	/* This function is for scheduling "drain" in asynchronous way.
> > -	 * The result of "drain" is not directly handled by callers. Then,
> > -	 * if someone is calling drain, we don't have to call drain more.
> > -	 * Anyway, WORK_STRUCT_PENDING check in queue_work_on() will catch if
> > -	 * there is a race. We just do loose check here.
> > +
> > +	/*
> > +	 * If synchronous flushing (which flushes all cpus's cache) runs,
> > +	 * do nothing.
> >  	 */
> > -	if (atomic_read(&memcg_drain_count))
> > +	if (unlikely(atomic_read(&memcg_drain_count)))
> >  		return;
> > -	/* Notify other cpus that system-wide "drain" is running */
> > -	atomic_inc(&memcg_drain_count);
> >  	get_online_cpus();
> >  	for_each_online_cpu(cpu) {
> >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > -		schedule_work_on(cpu, &stock->work);
> > +		struct mem_cgroup *mem;
> > +		bool do_flush;
> > +
> > +		rcu_read_lock();
> 
> Should this rcu_read_lock() be placed here ? IIUC, it's necessary only for css_is_ancestor().
> 

I thought rcu_read_lock() is required before getting a pointer to be acceseed.

But hmm...at second thought..
 1. stock->cached is flushed before memcg is destroyed..
 2. force_empty()(before destroy memcg) and this function can
    do mutual execution by some lock.

Then, it's safe to access stock->cached. Ok. I'll move this (with some comment)

> > +		mem = stock->cached;
> > +		if (!mem) {
> > +			rcu_read_unlock();
> > +			continue;
> > +		}
> > +		do_flush = ((mem == root_mem) ||
> > +		     	css_is_ancestor(&mem->css, &root_mem->css));
> 
> Adding "root_mem->use_hierarchy" is better to avoid flusing the cache as long as possible.
> 

ok. here is v2.

==
