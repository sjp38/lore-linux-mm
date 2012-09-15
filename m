Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D7AFF6B005D
	for <linux-mm@kvack.org>; Sat, 15 Sep 2012 06:56:42 -0400 (EDT)
Received: by lahd3 with SMTP id d3so3942452lah.14
        for <linux-mm@kvack.org>; Sat, 15 Sep 2012 03:56:40 -0700 (PDT)
Message-ID: <50545EE4.5050004@openvz.org>
Date: Sat, 15 Sep 2012 14:56:36 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] memory cgroup: update root memory cgroup when node is
 onlined
References: <505187D4.7070404@cn.fujitsu.com> <20120913205935.GK1560@cmpxchg.org> <alpine.LSU.2.00.1209131816070.1908@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1209131816070.1908@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Wen Congyang <wency@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiang Liu <liuj97@gmail.com>, "mhocko@suse.cz" <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>

Hugh Dickins wrote:
> On Thu, 13 Sep 2012, Johannes Weiner wrote:
>> On Thu, Sep 13, 2012 at 03:14:28PM +0800, Wen Congyang wrote:
>>> root_mem_cgroup->info.nodeinfo is initialized when the system boots.
>>> But NODE_DATA(nid) is null if the node is not onlined, so
>>> root_mem_cgroup->info.nodeinfo[nid]->zoneinfo[zone].lruvec.zone contains
>>> an invalid pointer. If we use numactl to bind a program to the node
>>> after onlining the node and its memory, it will cause the kernel
>>> panicked:
>>
>> Is there any chance we could get rid of the zone backpointer in lruvec
>> again instead?
>
> It could be done, but it would make me sad :(

Me too

>
>> Adding new nodes is a rare event and so updating every
>> single memcg in the system might be just borderline crazy.
>
> Not horribly crazy, but rather ugly, yes.
>
>> But can't
>> we just go back to passing the zone along with the lruvec down
>> vmscan.c paths?  I agree it's ugly to pass both, given their
>> relationship.  But I don't think the backpointer is any cleaner but in
>> addition less robust.
>
> It's like how we use vma->mm: we could change everywhere to pass mm with
> vma, but it looks cleaner and cuts down on long arglists to have mm in vma.
>  From past experience, one of the things I worried about was adding extra
> args to the reclaim stack.
>
>>
>> That being said, the crashing code in particular makes me wonder:
>>
>> static __always_inline void add_page_to_lru_list(struct page *page,
>> 				struct lruvec *lruvec, enum lru_list lru)
>> {
>> 	int nr_pages = hpage_nr_pages(page);
>> 	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
>> 	list_add(&page->lru,&lruvec->lists[lru]);
>> 	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
>> }
>>
>> Why did we ever pass zone in here and then felt the need to replace it
>> with lruvec->zone in fa9add6 "mm/memcg: apply add/del_page to lruvec"?
>> A page does not roam between zones, its zone is a static property that
>> can be retrieved with page_zone().
>
> Just as in vmscan.c, we have the lruvec to hand, and that's what we
> mainly want to operate upon, but there is also some need for zone.
>
> (Both Konstantin and I were looking towards the day when we move the
> lru_lock into the lruvec, removing more dependence on "zone".  Pretty
> much the only reason that hasn't happened yet, is that we have not found
> time to make a performance case convincingly - but that's another topic.)
>
> Yes, page_zone(page) is a static property of the page, but it's not
> necessarily cheap to evaluate: depends on how complex the memory model
> and the spare page flags space, doesn't it?  We both preferred to
> derive zone from lruvec where convenient.
>
> How do you feel about this patch, and does it work for you guys?
>
> You'd be right if you guessed that I started out without the
> mem_cgroup_zone_lruvec part of it, but oops in get_scan_count
> told me that's needed too.
>
> Description to be filled in later: would it be needed for -stable,
> or is onlining already broken in other ways that you're now fixing up?
>
> Reported-by: Tang Chen<tangchen@cn.fujitsu.com>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> ---
>
>   include/linux/mmzone.h |    2 -
>   mm/memcontrol.c        |   40 ++++++++++++++++++++++++++++++++-------
>   mm/mmzone.c            |    6 -----
>   mm/page_alloc.c        |    2 -
>   4 files changed, 36 insertions(+), 14 deletions(-)
>
> --- 3.6-rc5/include/linux/mmzone.h	2012-08-03 08:31:26.892842267 -0700
> +++ linux/include/linux/mmzone.h	2012-09-13 17:07:51.893772372 -0700
> @@ -744,7 +744,7 @@ extern int init_currently_empty_zone(str
>   				     unsigned long size,
>   				     enum memmap_context context);
>
> -extern void lruvec_init(struct lruvec *lruvec, struct zone *zone);
> +extern void lruvec_init(struct lruvec *lruvec);
>
>   static inline struct zone *lruvec_zone(struct lruvec *lruvec)
>   {
> --- 3.6-rc5/mm/memcontrol.c	2012-08-03 08:31:27.060842270 -0700
> +++ linux/mm/memcontrol.c	2012-09-13 17:46:36.870804625 -0700
> @@ -1061,12 +1061,25 @@ struct lruvec *mem_cgroup_zone_lruvec(st
>   				      struct mem_cgroup *memcg)
>   {
>   	struct mem_cgroup_per_zone *mz;
> +	struct lruvec *lruvec;
>
> -	if (mem_cgroup_disabled())
> -		return&zone->lruvec;
> +	if (mem_cgroup_disabled()) {
> +		lruvec =&zone->lruvec;
> +		goto out;
> +	}
>
>   	mz = mem_cgroup_zoneinfo(memcg, zone_to_nid(zone), zone_idx(zone));
> -	return&mz->lruvec;
> +	lruvec =&mz->lruvec;
> +out:
> +	/*
> +	 * Since a node can be onlined after the mem_cgroup was created,
> +	 * we have to be prepared to initialize lruvec->zone here.
> +	 */
> +	if (unlikely(lruvec->zone != zone)) {
> +		VM_BUG_ON(lruvec->zone);
> +		lruvec->zone = zone;
> +	}
> +	return lruvec;
>   }

Whoaaa, this makes me dizzy. I prefer hook in register_one_node().
BTW It would be nice to add notifier-chains into memory-hotplug.

>
>   /*
> @@ -1093,9 +1106,12 @@ struct lruvec *mem_cgroup_page_lruvec(st
>   	struct mem_cgroup_per_zone *mz;
>   	struct mem_cgroup *memcg;
>   	struct page_cgroup *pc;
> +	struct lruvec *lruvec;
>
> -	if (mem_cgroup_disabled())
> -		return&zone->lruvec;
> +	if (mem_cgroup_disabled()) {
> +		lruvec =&zone->lruvec;
> +		goto out;
> +	}
>
>   	pc = lookup_page_cgroup(page);
>   	memcg = pc->mem_cgroup;
> @@ -1113,7 +1129,17 @@ struct lruvec *mem_cgroup_page_lruvec(st
>   		pc->mem_cgroup = memcg = root_mem_cgroup;
>
>   	mz = page_cgroup_zoneinfo(memcg, page);
> -	return&mz->lruvec;
> +	lruvec =&mz->lruvec;
> +out:
> +	/*
> +	 * Since a node can be onlined after the mem_cgroup was created,
> +	 * we have to be prepared to initialize lruvec->zone here.
> +	 */
> +	if (unlikely(lruvec->zone != zone)) {
> +		VM_BUG_ON(lruvec->zone);
> +		lruvec->zone = zone;
> +	}
> +	return lruvec;
>   }
>
>   /**
> @@ -4742,7 +4768,7 @@ static int alloc_mem_cgroup_per_zone_inf
>
>   	for (zone = 0; zone<  MAX_NR_ZONES; zone++) {
>   		mz =&pn->zoneinfo[zone];
> -		lruvec_init(&mz->lruvec,&NODE_DATA(node)->node_zones[zone]);
> +		lruvec_init(&mz->lruvec);
>   		mz->usage_in_excess = 0;
>   		mz->on_tree = false;
>   		mz->memcg = memcg;
> --- 3.6-rc5/mm/mmzone.c	2012-08-03 08:31:27.064842271 -0700
> +++ linux/mm/mmzone.c	2012-09-13 17:06:28.921766001 -0700
> @@ -87,7 +87,7 @@ int memmap_valid_within(unsigned long pf
>   }
>   #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
>
> -void lruvec_init(struct lruvec *lruvec, struct zone *zone)
> +void lruvec_init(struct lruvec *lruvec)
>   {
>   	enum lru_list lru;
>
> @@ -95,8 +95,4 @@ void lruvec_init(struct lruvec *lruvec,
>
>   	for_each_lru(lru)
>   		INIT_LIST_HEAD(&lruvec->lists[lru]);
> -
> -#ifdef CONFIG_MEMCG
> -	lruvec->zone = zone;
> -#endif
>   }
> --- 3.6-rc5/mm/page_alloc.c	2012-08-22 14:25:39.508279046 -0700
> +++ linux/mm/page_alloc.c	2012-09-13 17:06:08.265763526 -0700
> @@ -4456,7 +4456,7 @@ static void __paginginit free_area_init_
>   		zone->zone_pgdat = pgdat;
>
>   		zone_pcp_init(zone);
> -		lruvec_init(&zone->lruvec, zone);
> +		lruvec_init(&zone->lruvec);
>   		if (!size)
>   			continue;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
