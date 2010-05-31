Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1906B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 14:33:30 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [patch 3/5] vmscan: remove all_unreclaimable scan control
References: <20100430222009.379195565@cmpxchg.org>
	<20100430222009.379195565@cmpxchg.org>
	<20100430224316.056084208@cmpxchg.org>
Date: Mon, 31 May 2010 11:32:51 -0700
In-Reply-To: <20100430224316.056084208@cmpxchg.org> (Johannes Weiner's message
	of "Sat, 1 May 2010 01:05:31 +0200")
Message-ID: <xr93sk57yl9o.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> writes:
> This scan control is abused to communicate a return value from
> shrink_zones().  Write this idiomatically and remove the knob.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c |   14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -70,8 +70,6 @@ struct scan_control {
>  
>  	int swappiness;
>  
> -	int all_unreclaimable;
> -
>  	int order;
>  
>  	int lumpy_reclaim;
> @@ -1701,14 +1699,14 @@ static void shrink_zone(int priority, st
>   * If a zone is deemed to be full of pinned pages then just give it a light
>   * scan then give up on it.
>   */
> -static void shrink_zones(int priority, struct zonelist *zonelist,
> +static int shrink_zones(int priority, struct zonelist *zonelist,
>  					struct scan_control *sc)
>  {
>  	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
>  	struct zoneref *z;
>  	struct zone *zone;
> +	int progress = 0;
>  
> -	sc->all_unreclaimable = 1;
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
>  					sc->nodemask) {
>  		if (!populated_zone(zone))
> @@ -1724,19 +1722,19 @@ static void shrink_zones(int priority, s
>  
>  			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
>  				continue;	/* Let kswapd poll it */
> -			sc->all_unreclaimable = 0;
>  		} else {
>  			/*
>  			 * Ignore cpuset limitation here. We just want to reduce
>  			 * # of used pages by us regardless of memory shortage.
>  			 */
> -			sc->all_unreclaimable = 0;
>  			mem_cgroup_note_reclaim_priority(sc->mem_cgroup,
>  							priority);
>  		}
>  
>  		shrink_zone(priority, zone, sc);
> +		progress = 1;
>  	}
> +	return progress;
>  }
>  
>  /*
> @@ -1789,7 +1787,7 @@ static unsigned long do_try_to_free_page
>  		sc->nr_scanned = 0;
>  		if (!priority)
>  			disable_swap_token();
> -		shrink_zones(priority, zonelist, sc);
> +		ret = shrink_zones(priority, zonelist, sc);
>  		/*
>  		 * Don't shrink slabs when reclaiming memory from
>  		 * over limit cgroups
> @@ -1826,7 +1824,7 @@ static unsigned long do_try_to_free_page
>  			congestion_wait(BLK_RW_ASYNC, HZ/10);
>  	}
>  	/* top priority shrink_zones still had more to do? don't OOM, then */
> -	if (!sc->all_unreclaimable && scanning_global_lru(sc))
> +	if (ret && scanning_global_lru(sc))
>  		ret = sc->nr_reclaimed;
>  out:
>  	/*

I agree with the direction of this patch, but I am seeing a hang when
testing with mmotm-2010-05-21-16-05.  The following test hangs, unless I
remove this patch from mmotm:
  mount -t cgroup none /cgroups -o memory
  mkdir /cgroups/cg1
  echo $$ > /cgroups/cg1/tasks
  dd bs=1024 count=1024 if=/dev/null of=/data/foo
  echo $$ > /cgroups/tasks
  echo 1 > /cgroups/cg1/memory.force_empty

I think the hang is caused by the following portion of
mem_cgroup_force_empty():
	while (nr_retries && mem->res.usage > 0) {
		int progress;

		if (signal_pending(current)) {
			ret = -EINTR;
			goto out;
		}
		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
						false, get_swappiness(mem));
		if (!progress) {
			nr_retries--;
			/* maybe some writeback is necessary */
			congestion_wait(BLK_RW_ASYNC, HZ/10);
		}

	}

With this patch applied, it is possible that when do_try_to_free_pages()
calls shrink_zones() for priority 0 that shrink_zones() may return 1
indicating progress, even though no pages may have been reclaimed.
Because this is a cgroup operation, scanning_global_lru() is false and
the following portion of do_try_to_free_pages() fails to set ret=0.
> 	if (ret && scanning_global_lru(sc))
>  		ret = sc->nr_reclaimed;
This leaves ret=1 indicating that do_try_to_free_pages() reclaimed 1
page even though it did not reclaim any pages.  Therefore
mem_cgroup_force_empty() erroneously believes that
try_to_free_mem_cgroup_pages() is making progress (one page at a time),
so there is an endless loop.

If I apply the following fix, then your patch does not hang and the
system appears to operate correctly.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 915dceb..772913c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1850,7 +1850,7 @@ static unsigned long do_try_to_free_pages(struct
zonelist *zonelist,
                        congestion_wait(BLK_RW_ASYNC, HZ/10);
        }
        /* top priority shrink_zones still had more to do? don't OOM,
        then */
-       if (ret && scanning_global_lru(sc))
+       if (ret)
                ret = sc->nr_reclaimed;
 out:
        /*

I have not done thorough testing, so this may introduce other problems.
Is there a reason not return nr_reclaimed when operating on a cgroup?
This may affect mem_cgroup_hierarchical_reclaim().

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
