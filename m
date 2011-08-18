Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A483C900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 04:41:06 -0400 (EDT)
Date: Thu, 18 Aug 2011 10:41:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5 4/6]  memg: calculate numa weight for vmscan
Message-ID: <20110818084103.GE23056@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
 <20110809191100.6c4c3285.kamezawa.hiroyu@jp.fujitsu.com>
 <20110817143418.GC7482@tiehlicka.suse.cz>
 <20110818091750.79eea4f5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110818091750.79eea4f5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu 18-08-11 09:17:50, KAMEZAWA Hiroyuki wrote:
> On Wed, 17 Aug 2011 16:34:18 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Sorry it took so long but I was quite busy recently.
> > 
> > On Tue 09-08-11 19:11:00, KAMEZAWA Hiroyuki wrote:
[...]
> > > Index: mmotm-Aug3/mm/memcontrol.c
> > > ===================================================================
> > > --- mmotm-Aug3.orig/mm/memcontrol.c
> > > +++ mmotm-Aug3/mm/memcontrol.c
[...]
> > > +
> > > +	/* 'scanned - rotated/scanned' means ratio of finding not active. */
> > > +	anon = anon * (scanned[0] - rotated[0]) / (scanned[0] + 1);
> > > +	file = file * (scanned[1] - rotated[1]) / (scanned[1] + 1);
> > 
> > OK, makes sense. We should not reclaim from nodes that are known to be
> > hard to reclaim from. We, however, have to be careful to not exclude the
> > node from reclaiming completely.
> > 
> > > +
> > > +	weight = (anon * anon_prio + file * file_prio) / 200;
> > 
> > Shouldn't we rather normalize the weight to the node size? This way we
> > are punishing bigger nodes, aren't we.
> > 
> 
> Here, the routine is for reclaiming memory in a memcg in smooth way.
> And not for balancing zone. It will be kswapd+memcg(softlimit) work.
> The size of node in this memcg is represented by file + anon.

I am not sure I understand what you mean by that but consider two nodes.
swappiness = 0
anon_prio = 1
file_prio = 200
A 1000 pages, 100 anon, 300 file: weight 300, node is 40% full
B 15000 pages 2500 anon, 3500 file: weight ~3500, node is 40% full

I think that both nodes should be equal.

> > > +	return weight;
> > > +}
> > > +
> > > +/*
> > > + * Calculate each NUMA node's scan weight. scan weight is determined by
> > > + * amount of pages and recent scan ratio, swappiness.
> > > + */
> > > +static unsigned long
> > > +mem_cgroup_calc_numascan_weight(struct mem_cgroup *memcg)
> > > +{
> > > +	unsigned long weight, total_weight;
> > > +	u64 anon_prio, file_prio, nr_anon, nr_file;
> > > +	int lru_mask;
> > > +	int nid;
> > > +
> > > +	anon_prio = mem_cgroup_swappiness(memcg) + 1;
> > > +	file_prio = 200 - anon_prio + 1;
> > 
> > What is +1 good for. I do not see that anon_prio would be used as a
> > denominator.
> > 
> 
> weight = (anon * anon_prio + file * file_prio) / 200;
> 
> Just for avoiding the influence of anon never be 0 (by wrong value
> set to swappiness by user.)

OK, so you want to prevent from situation where we have swappiness 0
and there are no file pages so the node would have 0 weight?
Why do you consider 0 swappiness a wrong value?

[...]
> > > +	nr_file = mem_cgroup_nr_lru_pages(memcg, LRU_ALL_FILE);
> > > +	nr_anon = mem_cgroup_nr_lru_pages(memcg, LRU_ALL_ANON);
> > > +
> > > +	/* If file cache is small w.r.t swappiness, check anon page's weight */
> > > +	if (nr_file * file_prio >= nr_anon * anon_prio)
> > > +		lru_mask |= BIT(LRU_INACTIVE_ANON);
> > 
> > Why we do not care about active anon (e.g. if inactive anon is low)?
> > 
> This condition is wrong...
> 
> 	if (nr_file * file_prio <= nr_anon * anon_prio)
> 		lru_mask |= BIT(LRU_INACTIVE_ANON);

True. Haven't noticed it before...

> 
> I was worried about LRU_ACTIVE_ANON. I considered
>   - We can't handle ACTIVE_ANON and INACTIVE_ANON in the same weight.
>     But I don't want to add more magic numbers.

Yes I agree, weight shouldn't involve active pages because we do not
want to reclaim nodes according to their active working set.

>   - vmscan.c:shrink_zone() scans ACTIVE_ANON whenever/only when
>     inactive_anon_is_low()==true. SWAP_CLUSTER_MAX per priority.
>     It's specially handled.
> 
> So, I thought involing the number of ACTIVE_ANON to the weight is difficult
> and ignored ACTIVE_ANON, here. Do you have idea ?

I am not sure whether nr_anon should include also active pages, though.
We are comparing all file to all anon pages which looks consistent, on
the other hand we are not including active pages into weight. This way
we make bigger pressure on nodes with a big anon working set.
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
