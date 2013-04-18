Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 408006B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 11:02:11 -0400 (EDT)
Date: Thu, 18 Apr 2013 08:01:05 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 02/10] mm: vmscan: Obey proportional scanning
 requirements for kswapd
Message-ID: <20130418150105.GD2018@cmpxchg.org>
References: <1365710278-6807-1-git-send-email-mgorman@suse.de>
 <1365710278-6807-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365710278-6807-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 11, 2013 at 08:57:50PM +0100, Mel Gorman wrote:
> @@ -1841,17 +1848,58 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  							    lruvec, sc);
>  			}
>  		}
> +
> +		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> +			continue;
> +
>  		/*
> -		 * On large memory systems, scan >> priority can become
> -		 * really large. This is fine for the starting priority;
> -		 * we want to put equal scanning pressure on each zone.
> -		 * However, if the VM has a harder time of freeing pages,
> -		 * with multiple processes reclaiming pages, the total
> -		 * freeing target can get unreasonably large.
> +		 * For global direct reclaim, reclaim only the number of pages
> +		 * requested. Less care is taken to scan proportionally as it
> +		 * is more important to minimise direct reclaim stall latency
> +		 * than it is to properly age the LRU lists.
>  		 */
> -		if (nr_reclaimed >= nr_to_reclaim &&
> -		    sc->priority < DEF_PRIORITY)
> +		if (global_reclaim(sc) && !current_is_kswapd())
>  			break;
> +
> +		/*
> +		 * For kswapd and memcg, reclaim at least the number of pages
> +		 * requested. Ensure that the anon and file LRUs shrink
> +		 * proportionally what was requested by get_scan_count(). We
> +		 * stop reclaiming one LRU and reduce the amount scanning
> +		 * proportional to the original scan target.
> +		 */
> +		nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
> +		nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];
> +
> +		if (nr_file > nr_anon) {
> +			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
> +						targets[LRU_ACTIVE_ANON] + 1;
> +			lru = LRU_BASE;
> +			percentage = nr_anon * 100 / scan_target;
> +		} else {
> +			unsigned long scan_target = targets[LRU_INACTIVE_FILE] +
> +						targets[LRU_ACTIVE_FILE] + 1;
> +			lru = LRU_FILE;
> +			percentage = nr_file * 100 / scan_target;
> +		}
> +
> +		/* Stop scanning the smaller of the LRU */
> +		nr[lru] = 0;
> +		nr[lru + LRU_ACTIVE] = 0;
> +
> +		/*
> +		 * Recalculate the other LRU scan count based on its original
> +		 * scan target and the percentage scanning already complete
> +		 */
> +		lru = (lru == LRU_FILE) ? LRU_BASE : LRU_FILE;
> +		nr[lru] = targets[lru] * (100 - percentage) / 100;
> +		nr[lru] -= min(nr[lru], (targets[lru] - nr[lru]));

This doesn't seem right.  Say percentage is 60, then

    nr[lru] = targets[lru] * (100 - percentage) / 100;

sets nr[lru] to 40% of targets[lru], and so in

    nr[lru] -= min(nr[lru], (targets[lru] - nr[lru]));

targets[lru] - nr[lru] is 60% of targets[lru], making it bigger than
nr[lru], which is in turn subtracted from itself, i.e. it leaves the
remaining type at 0 if >= 50% of the other type were scanned, and at
half of the inverted scan percentage if less than 50% were scanned.

Would this be more sensible?

    already_scanned = targets[lru] - nr[lru];
    nr[lru] = targets[lru] * percentage / 100; /* adjusted original target */
    nr[lru] -= min(nr[lru], already_scanned);  /* minus work already done */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
