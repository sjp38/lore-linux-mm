Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 83A8E6B0088
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 03:09:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6A7Wfvg027763
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Jul 2009 16:32:41 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D862145DE51
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:32:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D71B45DE55
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:32:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C8681DB8041
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:32:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D73BB1DB803B
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:32:39 +0900 (JST)
Date: Fri, 10 Jul 2009 16:30:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/5] Memory controller soft limit reclaim on
 contention (v8)
Message-Id: <20090710163056.a9d552e2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090710065306.GC20129@balbir.in.ibm.com>
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
	<20090709171512.8080.8138.sendpatchset@balbir-laptop>
	<20090710143026.4de7d4b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090710065306.GC20129@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Jul 2009 12:23:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-10 14:30:26]:
> 
> > On Thu, 09 Jul 2009 22:45:12 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > Feature: Implement reclaim from groups over their soft limit
> > > 
> > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > -	while (loop < 2) {
> > > +	while (1) {
> > >  		victim = mem_cgroup_select_victim(root_mem);
> > > -		if (victim == root_mem)
> > > +		if (victim == root_mem) {
> > >  			loop++;
> > > +			if (loop >= 2) {
> > > +				/*
> > > +				 * If we have not been able to reclaim
> > > +				 * anything, it might because there are
> > > +				 * no reclaimable pages under this hierarchy
> > > +				 */
> > > +				if (!check_soft || !total)
> > > +					break;
> > > +				/*
> > > +				 * We want to do more targetted reclaim.
> > > +				 * excess >> 2 is not to excessive so as to
> > > +				 * reclaim too much, nor too less that we keep
> > > +				 * coming back to reclaim from this cgroup
> > > +				 */
> > > +				if (total >= (excess >> 2) ||
> > > +					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
> > > +					break;
> > > +			}
> > > +		}
> > 
> > Hmm..this logic is very unclear for me. Why just exit back as usual reclaim ?
> >
> 
> Basically what this check does is, it checks to see if the loops > 2,
> then as in the previous case (when soft limits were not supported)
> exit or if the total reclaimed is 0, exit (because we are running with
> swap turned off, may be?). Otherwise, check if we have reclaimed a
> certain portion of the total amount we exceed the soft limit by or if
> the loops are too large and exit. I hope this clarifies
>  
+#define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(10000)
+#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
+
.....too big. 

IMO,
> > > +				if (total >= (excess >> 2) ||
> > > +					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
> > > +					break;
is unnecessary. Do you want to block kswapd here for such a long time ?
loops > 2 is definitely enough, I believe.
If you find out loops>2 is not enough later, just retrying soft limit is enough.



> > 
> > 
> > >  		if (!mem_cgroup_local_usage(&victim->stat)) {
> > >  			/* this cgroup's local usage == 0 */
> > >  			css_put(&victim->css);
> > >  			continue;
> > >  		}
> > >  		/* we use swappiness of local cgroup */
> > > -		ret = try_to_free_mem_cgroup_pages(victim, gfp_mask, noswap,
> > > -						   get_swappiness(victim));
> > > +		if (check_soft)
> > > +			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> > > +				noswap, get_swappiness(victim), zone,
> > > +				zone->zone_pgdat->node_id, priority);
> > > +		else
> > > +			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> > > +						noswap, get_swappiness(victim));
> > 
> > Do we need 2 functions ?
> >
> 
> Yes, one does zonelist based reclaim, the other one does shrinking of
> a particular zone in a particular node - as identified by
> balance_pgdat.
>  
> > >  		css_put(&victim->css);
> > >  		/*
> > >  		 * At shrinking usage, we can't check we should stop here or
> > > @@ -1072,7 +1182,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > >  		if (shrink)
> > >  			return ret;
> > >  		total += ret;
> > > -		if (mem_cgroup_check_under_limit(root_mem))
> > > +		if (check_soft) {
> > > +			if (res_counter_check_under_soft_limit(&root_mem->res))
> > > +				return total;
> > > +		} else if (mem_cgroup_check_under_limit(root_mem))
> > >  			return 1 + total;
> > >  	}
> > >  	return total;
> > > @@ -1207,8 +1320,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > >  		if (!(gfp_mask & __GFP_WAIT))
> > >  			goto nomem;
> > >  
> > > -		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
> > > -							flags);
> > > +		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> > > +							gfp_mask, flags, -1);
> > >  		if (ret)
> > >  			continue;
> > >  
> > > @@ -2002,8 +2115,9 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> > >  		if (!ret)
> > >  			break;
> > >  
> > > -		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
> > > -						   MEM_CGROUP_RECLAIM_SHRINK);
> > > +		progress = mem_cgroup_hierarchical_reclaim(memcg, NULL,
> > > +						GFP_KERNEL,
> > > +						MEM_CGROUP_RECLAIM_SHRINK, -1);
> > 
> > What this -1 means ?
> >
> 
> -1 means don't care, I should clarify that via comments.
>  

Hmm, rather than comment,
#define DONT_CARE_PRIRITY	(-1)
or some is self explaining.


> > >  		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
> > >  		/* Usage is reduced ? */
> > >    		if (curusage >= oldusage)
> > > @@ -2055,9 +2169,9 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> > >  		if (!ret)
> > >  			break;
> > >  
> > > -		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
> > > +		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
> > >  						MEM_CGROUP_RECLAIM_NOSWAP |
> > > -						MEM_CGROUP_RECLAIM_SHRINK);
> > > +						MEM_CGROUP_RECLAIM_SHRINK, -1);
> > again.
> > 
> > >  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
> > >  		/* Usage is reduced ? */
> > >  		if (curusage >= oldusage)
> > > @@ -2068,6 +2182,82 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> > >  	return ret;
> > >  }
> > >  
> > > +unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> > > +						gfp_t gfp_mask, int nid,
> > > +						int zid, int priority)
> > > +{
> > > +	unsigned long nr_reclaimed = 0;
> > > +	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
> > > +	unsigned long flags;
> > > +	unsigned long reclaimed;
> > > +	int loop = 0;
> > > +	struct mem_cgroup_soft_limit_tree_per_zone *stz;
> > > +
> > > +	if (order > 0)
> > > +		return 0;
> > > +
> > > +	stz = soft_limit_tree_node_zone(nid, zid);
> > > +	/*
> > > +	 * This loop can run a while, specially if mem_cgroup's continuously
> > > +	 * keep exceeding their soft limit and putting the system under
> > > +	 * pressure
> > > +	 */
> > > +	do {
> > > +		if (next_mz)
> > > +			mz = next_mz;
> > > +		else
> > > +			mz = mem_cgroup_largest_soft_limit_node(stz);
> > > +		if (!mz)
> > > +			break;
> > > +
> > > +		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
> > > +						gfp_mask,
> > > +						MEM_CGROUP_RECLAIM_SOFT,
> > > +						priority);
> > > +		nr_reclaimed += reclaimed;
> > > +		spin_lock_irqsave(&stz->lock, flags);
> > > +
> > > +		/*
> > > +		 * If we failed to reclaim anything from this memory cgroup
> > > +		 * it is time to move on to the next cgroup
> > > +		 */
> > > +		next_mz = NULL;
> > > +		if (!reclaimed) {
> > > +			do {
> > > +				/*
> > > +				 * By the time we get the soft_limit lock
> > > +				 * again, someone might have aded the
> > > +				 * group back on the RB tree. Iterate to
> > > +				 * make sure we get a different mem.
> > > +				 * mem_cgroup_largest_soft_limit_node returns
> > > +				 * NULL if no other cgroup is present on
> > > +				 * the tree
> > > +				 */
> > > +				next_mz =
> > > +				__mem_cgroup_largest_soft_limit_node(stz);
> > > +			} while (next_mz == mz);
> > > +		}
> > > +		mz->usage_in_excess =
> > > +			res_counter_soft_limit_excess(&mz->mem->res);
> > > +		__mem_cgroup_remove_exceeded(mz->mem, mz, stz);
> > > +		if (mz->usage_in_excess)
> > > +			__mem_cgroup_insert_exceeded(mz->mem, mz, stz);
> > 
> > plz don't push back "mz" if !reclaimd.
> >
> 
> We need to do that, what is someone does a swapoff -a and swapon -a in
> between, we still need to give mz a chance. No?
>  
kswapd's original behavior will work well in such special case, No ?

In !reclaimed case, loss to push it back is larger than benefit, I think.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
