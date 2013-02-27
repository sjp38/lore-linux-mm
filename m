Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 6B2926B0005
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 04:41:00 -0500 (EST)
Date: Wed, 27 Feb 2013 10:40:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: implement low limits
Message-ID: <20130227094054.GC16719@dhcp22.suse.cz>
References: <8121361952156@webcorp1g.yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8121361952156@webcorp1g.yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: Johannes Weiner-Arquette <hannes@cmpxchg.org>, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Ying Han <yinghan@google.com>

On Wed 27-02-13 12:02:36, Roman Gushchin wrote:
> Hi, all!
> 
> I've implemented low limits for memory cgroups. The primary goal was
> to add an ability to protect some memory from reclaiming without using
> mlock(). A kind of "soft mlock()".

Let me restate what I have already mentioned in the private
communication.

We already have soft limit which can be implemented to achieve the
same/similar functionality and in fact this is a long term objective (at
least for me). I hope I will be able to post my code soon. The last post
by Ying Hand (cc-ing her) was here:
http://comments.gmane.org/gmane.linux.kernel.mm/83499

To be honest I do not like introduction of a new limit because we have
two already and the situation would get over complicated.

More comments on the code bellow.

[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 53b8201..d8e6ee6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1743,6 +1743,53 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  			 NULL, "Memory cgroup out of memory");
>  }
>  
> +/*
> + * If a cgroup is under low limit or enough close to it,
> + * decrease speed of page scanning.
> + *
> + * mem_cgroup_low_limit_scale() returns a number
> + * from range [0, DEF_PRIORITY - 2], which is used
> + * in the reclaim code as a scanning priority modifier.
> + *
> + * If the low limit is not set, it returns 0;
> + *
> + * usage - low_limit > usage / 8  => 0
> + * usage - low_limit > usage / 16 => 1
> + * usage - low_limit > usage / 32 => 2
> + * ...
> + * usage - low_limit > usage / (2 ^ DEF_PRIORITY - 3) => DEF_PRIORITY - 3
> + * usage < low_limit => DEF_PRIORITY - 2

Could you clarify why you have used this calculation. The comment
exlaims _what_ is done but not _why_ it is done.

It is also strange (and unexplained) that the low limit will work
differently depending on the memcg memory usage - bigger groups have a
bigger chance to be reclaimed even if they are under the limit.

> + *
> + */
> +unsigned int mem_cgroup_low_limit_scale(struct lruvec *lruvec)
> +{
> +	struct mem_cgroup_per_zone *mz;
> +	struct mem_cgroup *memcg;
> +	unsigned long long low_limit;
> +	unsigned long long usage;
> +	unsigned int i;
> +
> +	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
> +	memcg = mz->memcg;
> +	if (!memcg)
> +		return 0;
> +
> +	low_limit = res_counter_read_u64(&memcg->res, RES_LOW_LIMIT);
> +	if (!low_limit)
> +		return 0;
> +
> +	usage = res_counter_read_u64(&memcg->res, RES_USAGE);
> +
> +	if (usage < low_limit)
> +		return DEF_PRIORITY - 2;
> +
> +	for (i = 0; i < DEF_PRIORITY - 2; i++)
> +		if (usage - low_limit > (usage >> (i + 3)))
> +			break;

why this doesn't depend in the current reclaim priority?

> +
> +	return i;
> +}
> +
>  static unsigned long mem_cgroup_reclaim(struct mem_cgroup *memcg,
>  					gfp_t gfp_mask,
>  					unsigned long flags)
[...]
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 88c5fed..9c1c702 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1660,6 +1660,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  	bool force_scan = false;
>  	unsigned long ap, fp;
>  	enum lru_list lru;
> +	unsigned int low_limit_scale = 0;
>  
>  	/*
>  	 * If the zone or memcg is small, nr[l] can be 0.  This
> @@ -1779,6 +1780,9 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  	fraction[1] = fp;
>  	denominator = ap + fp + 1;
>  out:
> +	if (global_reclaim(sc))
> +		low_limit_scale = mem_cgroup_low_limit_scale(lruvec);

What if the group is reclaimed as a result from parent hitting its
limit?

> +
>  	for_each_evictable_lru(lru) {
>  		int file = is_file_lru(lru);
>  		unsigned long size;
> @@ -1786,6 +1790,7 @@ out:
>  
>  		size = get_lru_size(lruvec, lru);
>  		scan = size >> sc->priority;
> +		scan >>= low_limit_scale;
>  
>  		if (!scan && force_scan)
>  			scan = min(size, SWAP_CLUSTER_MAX);

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
