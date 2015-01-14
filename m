Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id E94586B006E
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 10:34:28 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id k11so9447504wes.6
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 07:34:28 -0800 (PST)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id i2si3631609wiy.102.2015.01.14.07.34.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 07:34:28 -0800 (PST)
Received: by mail-wg0-f48.google.com with SMTP id l2so9609494wgh.7
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 07:34:28 -0800 (PST)
Date: Wed, 14 Jan 2015 16:34:25 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm: memcontrol: default hierarchy interface for
 memory
Message-ID: <20150114153425.GF4706@dhcp22.suse.cz>
References: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org>
 <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 08-01-15 23:15:04, Johannes Weiner wrote:
[...]
> @@ -2353,6 +2353,22 @@ done_restock:
>  	css_get_many(&memcg->css, batch);
>  	if (batch > nr_pages)
>  		refill_stock(memcg, batch - nr_pages);
> +	/*
> +	 * If the hierarchy is above the normal consumption range,
> +	 * make the charging task trim the excess.
> +	 */
> +	do {
> +		unsigned long nr_pages = page_counter_read(&memcg->memory);
> +		unsigned long high = ACCESS_ONCE(memcg->high);
> +
> +		if (nr_pages > high) {
> +			mem_cgroup_events(memcg, MEMCG_HIGH, 1);
> +
> +			try_to_free_mem_cgroup_pages(memcg, nr_pages - high,
> +						     gfp_mask, true);
> +		}

As I've said before I am not happy about this. Heavy parallel load
hitting on the limit can generate really high reclaim targets causing
over reclaim and long stalls. Moreover portions of the excess would be
reclaimed multiple times which is not necessary.

I am not entirely happy about reclaiming nr_pages for THP_PAGES already
and this might be much worse, more probable and less predictable.

I believe the target should be capped somehow. nr_pages sounds like a
compromise. It would still throttle the charger and scale much better.

> +
> +	} while ((memcg = parent_mem_cgroup(memcg)));
>  done:
>  	return ret;
>  }
[...]
> +static int memory_events_show(struct seq_file *m, void *v)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> +
> +	seq_printf(m, "low %lu\n", mem_cgroup_read_events(memcg, MEMCG_LOW));
> +	seq_printf(m, "high %lu\n", mem_cgroup_read_events(memcg, MEMCG_HIGH));
> +	seq_printf(m, "max %lu\n", mem_cgroup_read_events(memcg, MEMCG_MAX));
> +	seq_printf(m, "oom %lu\n", mem_cgroup_read_events(memcg, MEMCG_OOM));
> +
> +	return 0;
> +}

OK, but I really think we need a way of OOM notification for user space
OOM handling as well - including blocking the OOM killer as we have
now.  This is not directly related to this patch so it doesn't have to
happen right now, we should just think about the proper interface if
oom_control is consider not suitable.

[...]
> @@ -2322,6 +2325,12 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			struct lruvec *lruvec;
>  			int swappiness;
>  
> +			if (mem_cgroup_low(root, memcg)) {
> +				if (!sc->may_thrash)
> +					continue;
> +				mem_cgroup_events(memcg, MEMCG_LOW, 1);
> +			}
> +
>  			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  			swappiness = mem_cgroup_swappiness(memcg);
>  
> @@ -2343,8 +2352,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  				mem_cgroup_iter_break(root, memcg);
>  				break;
>  			}
> -			memcg = mem_cgroup_iter(root, memcg, &reclaim);
> -		} while (memcg);
> +		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));

I had a similar code but then I could trigger quick priority drop downs
during parallel reclaim with multiple low limited groups. I've tried to
address that by retrying shrink_zone if it hasn't called shrink_lruvec
at all. Still not ideal because it can livelock theoretically, but I
haven't seen that in my testing.

The following is a quick rebase (not tested yet). I can send it as a
separate patch with a full changelog if you prefer that over merging it
into yours but I think we need it in some form:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index cd4cbc045b79..6cf7d4293976 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2306,6 +2306,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 {
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
+	int scanned_memcgs = 0;
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2331,6 +2332,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 				mem_cgroup_events(memcg, MEMCG_LOW, 1);
 			}
 
+			scanned_memcgs++;
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 			swappiness = mem_cgroup_swappiness(memcg);
 
@@ -2355,6 +2357,14 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
 		/*
+		 * reclaimers are racing and only saw low limited memcgs
+		 * so we have to retry the memcg walk.
+		 */
+		if (!scanned_memcgs && (global_reclaim(sc) ||
+					!mem_cgroup_low(root, root)))
+			continue;
+
+		/*
 		 * Shrink the slab caches in the same proportion that
 		 * the eligible LRU pages were scanned.
 		 */
@@ -2380,8 +2390,11 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		if (sc->nr_reclaimed - nr_reclaimed)
 			reclaimable = true;
 
-	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
-					 sc->nr_scanned - nr_scanned, sc));
+		if (!should_continue_reclaim(zone,
+					sc->nr_reclaimed - nr_reclaimed,
+					sc->nr_scanned - nr_scanned, sc))
+			break;
+	} while (true);
 
 	return reclaimable;
 }

[...]

Other than that the patch looks OK and I am happy this has moved
forward finally.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
