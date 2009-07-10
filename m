Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 949176B0098
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 06:32:30 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6AAjVWQ012455
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 06:45:31 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6AAuOXp227450
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 06:56:24 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6AArrRJ001559
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 06:53:53 -0400
Date: Fri, 10 Jul 2009 16:26:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 5/5] Memory controller soft limit reclaim on
	contention (v8)
Message-ID: <20090710105620.GI20129@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop> <20090709171512.8080.8138.sendpatchset@balbir-laptop> <20090710143026.4de7d4b9.kamezawa.hiroyu@jp.fujitsu.com> <20090710065306.GC20129@balbir.in.ibm.com> <20090710163056.a9d552e2.kamezawa.hiroyu@jp.fujitsu.com> <20090710074906.GE20129@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090710074906.GE20129@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2009-07-10 13:19:06]:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-10 16:30:56]:
> 
> > On Fri, 10 Jul 2009 12:23:06 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-10 14:30:26]:
> > > 
> > > > On Thu, 09 Jul 2009 22:45:12 +0530
> > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > Feature: Implement reclaim from groups over their soft limit
> > > > > 
> > > > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > > -	while (loop < 2) {
> > > > > +	while (1) {
> > > > >  		victim = mem_cgroup_select_victim(root_mem);
> > > > > -		if (victim == root_mem)
> > > > > +		if (victim == root_mem) {
> > > > >  			loop++;
> > > > > +			if (loop >= 2) {
> > > > > +				/*
> > > > > +				 * If we have not been able to reclaim
> > > > > +				 * anything, it might because there are
> > > > > +				 * no reclaimable pages under this hierarchy
> > > > > +				 */
> > > > > +				if (!check_soft || !total)
> > > > > +					break;
> > > > > +				/*
> > > > > +				 * We want to do more targetted reclaim.
> > > > > +				 * excess >> 2 is not to excessive so as to
> > > > > +				 * reclaim too much, nor too less that we keep
> > > > > +				 * coming back to reclaim from this cgroup
> > > > > +				 */
> > > > > +				if (total >= (excess >> 2) ||
> > > > > +					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
> > > > > +					break;
> > > > > +			}
> > > > > +		}
> > > > 
> > > > Hmm..this logic is very unclear for me. Why just exit back as usual reclaim ?
> > > >
> > > 
> > > Basically what this check does is, it checks to see if the loops > 2,
> > > then as in the previous case (when soft limits were not supported)
> > > exit or if the total reclaimed is 0, exit (because we are running with
> > > swap turned off, may be?). Otherwise, check if we have reclaimed a
> > > certain portion of the total amount we exceed the soft limit by or if
> > > the loops are too large and exit. I hope this clarifies
> > >  
> > +#define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(10000)
> > +#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
> > +
> > .....too big. 
> > 
> 
> Agreed, will cut it short
> 
> > IMO,
> > > > > +				if (total >= (excess >> 2) ||
> > > > > +					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
> > > > > +					break;
> > is unnecessary. Do you want to block kswapd here for such a long time ?
> > loops > 2 is definitely enough, I believe.
> > If you find out loops>2 is not enough later, just retrying soft limit is enough.
> > 
> 
> 
> Yes, worth experimenting with, I'll redo with the special code
> removed.


OK, so I experimented with it, I found the following behaviour

1. We try to reclaim, priority is high, scanned pages are low and
   hence memory cgroup zone reclaim returns 0 (no pages could be
   reclaimed).
2. Now regular reclaim from balance_pgdat() is called, it is able
   to shrink from global LRU and hence some other mem cgroup, thus
   breaking soft limit semantics.


> > > > > +			res_counter_soft_limit_excess(&mz->mem->res);
> > > > > +		__mem_cgroup_remove_exceeded(mz->mem, mz, stz);
> > > > > +		if (mz->usage_in_excess)
> > > > > +			__mem_cgroup_insert_exceeded(mz->mem, mz, stz);
> > > > 
> > > > plz don't push back "mz" if !reclaimd.
> > > >
> > > 
> > > We need to do that, what is someone does a swapoff -a and swapon -a in
> > > between, we still need to give mz a chance. No?
> > >  
> > kswapd's original behavior will work well in such special case, No ?
> > 
> > In !reclaimed case, loss to push it back is larger than benefit, I think.
> >
> 
> OK, I'll try it out. 
>

I tried, it did not work out well, please see above. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
