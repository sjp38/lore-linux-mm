Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 318196B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 05:01:19 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so192294876pab.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 02:01:18 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id c1si18220365pap.77.2015.11.23.02.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 02:01:18 -0800 (PST)
Date: Mon, 23 Nov 2015 13:00:59 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 13/14] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Message-ID: <20151123100059.GB29014@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
 <20151120131033.GF31308@esperanza>
 <20151120192506.GD5623@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151120192506.GD5623@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Nov 20, 2015 at 02:25:06PM -0500, Johannes Weiner wrote:
> On Fri, Nov 20, 2015 at 04:10:33PM +0300, Vladimir Davydov wrote:
> > On Thu, Nov 12, 2015 at 06:41:32PM -0500, Johannes Weiner wrote:
> > ...
> > > @@ -5514,16 +5550,43 @@ void sock_release_memcg(struct sock *sk)
> > >   */
> > >  bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> > >  {
> > > +	unsigned int batch = max(CHARGE_BATCH, nr_pages);
> > >  	struct page_counter *counter;
> > > +	bool force = false;
> > >  
> > > -	if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
> > > -				    nr_pages, &counter)) {
> > > -		memcg->tcp_mem.memory_pressure = 0;
> > > +#ifdef CONFIG_MEMCG_KMEM
> > > +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
> > > +		if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
> > > +					    nr_pages, &counter)) {
> > > +			memcg->tcp_mem.memory_pressure = 0;
> > > +			return true;
> > > +		}
> > > +		page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
> > > +		memcg->tcp_mem.memory_pressure = 1;
> > > +		return false;
> > > +	}
> > > +#endif
> > > +	if (consume_stock(memcg, nr_pages))
> > >  		return true;
> > > +retry:
> > > +	if (page_counter_try_charge(&memcg->memory, batch, &counter))
> > > +		goto done;
> > > +
> > > +	if (batch > nr_pages) {
> > > +		batch = nr_pages;
> > > +		goto retry;
> > >  	}
> > > -	page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
> > > -	memcg->tcp_mem.memory_pressure = 1;
> > > -	return false;
> > > +
> > > +	page_counter_charge(&memcg->memory, batch);
> > > +	force = true;
> > > +done:
> > 
> > > +	css_get_many(&memcg->css, batch);
> > 
> > Is there any point to get css reference per each charged page? For kmem
> > it is absolutely necessary, because dangling slabs must block
> > destruction of memcg's kmem caches, which are destroyed on css_free. But
> > for sockets there's no such problem: memcg will be destroyed only after
> > all sockets are destroyed and therefore uncharged (since
> > sock_update_memcg pins css).
> 
> I'm afraid we have to when we want to share 'stock' with cache and
> anon pages, which hold individual references. drain_stock() always
> assumes one reference per cached page.

Missed that, you're right.

> 
> > > +	if (batch > nr_pages)
> > > +		refill_stock(memcg, batch - nr_pages);
> > > +
> > > +	schedule_work(&memcg->socket_work);
> > 
> > I think it's suboptimal to schedule the work even if we are below the
> > high threshold.
> 
> Hm, it seemed unnecessary to duplicate the hierarchy check since this
> is in the batch-exhausted slowpath anyway.

Dunno, may be you're right.

I've another question regarding this socket_work: its reclaim target
always equals CHARGE_BATCH. Can't it result in a workload exceeding
memory.high in case there are a lot of allocations coming from different
cpus? In this case the work might not manage to complete before another
allocation happens. May be, we should accumulate the number of pages to
be reclaimed by the work, as we do in try_charge?

> 
> > BTW why do we need this work at all? Why is reclaim_high called from
> > task_work not enough?
> 
> The problem lies in the memcg association: the random task that gets
> interrupted by an arriving packet might not be in the same memcg as
> the one owning receiving socket. And multiple interrupts could happen
> while we're in the kernel already charging pages. We'd basically have
> to maintain a list of memcgs that need to run reclaim_high associated
> with current.
> 

Right, I think this is worth placing in a comment to memcg->socket_work.
I wonder if we could use it *instead* of task_work for handling every
allocation, not only socket-related. Would it make any sense? May be, it
could reduce the latency experienced by tasks in memory cgroups.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
