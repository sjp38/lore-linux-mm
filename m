Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id mB3Dqp1H022033
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 19:22:51 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB3DqqjF4227212
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 19:22:52 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id mB3DqpCe015410
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 19:22:51 +0530
Date: Wed, 3 Dec 2008 19:22:49 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 06/11] memcg: make inactive_anon_is_low()
Message-ID: <20081203135249.GE17701@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081201211457.1CDC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081201211457.1CDC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2008-12-01 21:15:46]:

> Changelog:
>  v1 -> v2:
>    - add detail patch description
>    - fix coding style in mem_cgroup_set_inactive_ratio()
>    - add comment to mem_cgroup_set_inactive_ratio
>    - remove extra newline
>    - memcg::inactiveratio change type to unsigned int
>

[snip]
 
> +/*
> + * The inactive anon list should be small enough that the VM never has to
> + * do too much work, but large enough that each inactive page has a chance
> + * to be referenced again before it is swapped out.
> + *
> + * this calculation is straightforward porting from
> + * page_alloc.c::setup_per_zone_inactive_ratio().
> + * it describe more detail.
> + */
> +static void mem_cgroup_set_inactive_ratio(struct mem_cgroup *memcg)
> +{
> +	unsigned int gb, ratio;
> +
> +	gb = res_counter_read_u64(&memcg->res, RES_LIMIT) >> 30;
> +	if (gb)
> +		ratio = int_sqrt(10 * gb);

I don't understand where the magic number 10 comes from?

> +	else
> +		ratio = 1;
> +
> +	memcg->inactive_ratio = ratio;
> +
> +}
> +
>  static DEFINE_MUTEX(set_limit_mutex);
> 
>  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> @@ -1384,6 +1424,10 @@ static int mem_cgroup_resize_limit(struc
>  				GFP_HIGHUSER_MOVABLE, false);
>    		if (!progress)			retry_count--;
>  	}
> +
> +	if (!ret)
> +		mem_cgroup_set_inactive_ratio(memcg);
> +
>  	return ret;
>  }
> 
> @@ -1968,7 +2012,7 @@ mem_cgroup_create(struct cgroup_subsys *
>  		res_counter_init(&mem->res, NULL);
>  		res_counter_init(&mem->memsw, NULL);
>  	}
> -
> +	mem_cgroup_set_inactive_ratio(mem);
>  	mem->last_scanned_child = NULL;
> 
>  	return &mem->css;
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1369,14 +1369,7 @@ static void shrink_active_list(unsigned 
>  	pagevec_release(&pvec);
>  }
> 
> -/**
> - * inactive_anon_is_low - check if anonymous pages need to be deactivated
> - * @zone: zone to check
> - *
> - * Returns true if the zone does not have enough inactive anon pages,
> - * meaning some active anon pages need to be deactivated.
> - */
> -static int inactive_anon_is_low(struct zone *zone)
> +static int inactive_anon_is_low_global(struct zone *zone)
>  {
>  	unsigned long active, inactive;
> 
> @@ -1389,6 +1382,25 @@ static int inactive_anon_is_low(struct z
>  	return 0;
>  }
> 
> +/**
> + * inactive_anon_is_low - check if anonymous pages need to be deactivated
> + * @zone: zone to check
> + * @sc:   scan control of this context
> + *
> + * Returns true if the zone does not have enough inactive anon pages,
> + * meaning some active anon pages need to be deactivated.
> + */
> +static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
> +{
> +	int low;
> +
> +	if (scan_global_lru(sc))
> +		low = inactive_anon_is_low_global(zone);
> +	else
> +		low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup, zone);
> +	return low;
> +}
> +
>  static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>  	struct zone *zone, struct scan_control *sc, int priority)
>  {
> @@ -1400,7 +1412,7 @@ static unsigned long shrink_list(enum lr
>  	}
> 
>  	if (lru == LRU_ACTIVE_ANON &&
> -	    (!scan_global_lru(sc) || inactive_anon_is_low(zone))) {
> +	    inactive_anon_is_low(zone, sc)) {

Can't we merge the line with the "if" statement

>  		shrink_active_list(nr_to_scan, zone, sc, priority, file);
>  		return 0;
>  	}
> @@ -1565,9 +1577,7 @@ static void shrink_zone(int priority, st
>  	 * Even if we did not try to evict anon pages at all, we want to
>  	 * rebalance the anon lru active/inactive ratio.
>  	 */
> -	if (!scan_global_lru(sc) || inactive_anon_is_low(zone))
> -		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> -	else if (!scan_global_lru(sc))
> +	if (inactive_anon_is_low(zone, sc))
>  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> 
>  	throttle_vm_writeout(sc->gfp_mask);
> @@ -1863,7 +1873,7 @@ loop_again:
>  			 * Do some background aging of the anon list, to give
>  			 * pages a chance to be referenced before reclaiming.
>  			 */
> -			if (inactive_anon_is_low(zone))
> +			if (inactive_anon_is_low(zone, &sc))
>  				shrink_active_list(SWAP_CLUSTER_MAX, zone,
>  							&sc, priority, 0);
> 
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
