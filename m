Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AE0C36B005A
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 01:13:03 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8U5ElML005613
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Sep 2009 14:14:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 95C2545DE4F
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 14:14:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E49A45DE50
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 14:14:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B80EE08003
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 14:14:47 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF454EF800A
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 14:14:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: RFC [Patch] few useful page reclaim mm tracepoints
In-Reply-To: <1254154166.3219.3.camel@dhcp-100-19-198.bos.redhat.com>
References: <1254154166.3219.3.camel@dhcp-100-19-198.bos.redhat.com>
Message-Id: <20090930134322.5EEC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 30 Sep 2009 14:14:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> 
> Here a few mm page reclaim tracepoints that really show what is being
> reclaimed and from where.  mm_get_scanratio reports the number anonymous
> and pagecache pages as well as the percent that will be reclaimed from
> each.  mm_pagereclaim_shrinkactive reports whether it is shrinking
> anonymous or pagecache pages, the number scanned and the number actually
> moved(deactivated).  mm_pagereclaim_shrinkinactive reports whether it is
> shrinking anonymous or pagecache pages, the number scanned and the
> number actually reclaimed.  These three simple mm tracepoints capture
> much of the page reclaim activity.
> 
> ------------------------------------------------------------------------
> 
> # tracer: mm 
> #
> #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> #              | |       |          |         |
>          kswapd1-549   [004]   149.524509: mm_get_scanratio: 2043329
> anonymous pages, reclaiming 1% - 1312 pagecache pages, reclaiming 99%
>          kswapd1-549   [004]   149.524709: mm_pagereclaim_shrinkactive:
> anonymous, scanned 32, moved 32, priority 12
>          kswapd1-549   [004]   149.524542:
> mm_pagereclaim_shrinkinactive: anonymous, scanned 32, reclaimed 32,
> priority 7

Looks good generally. and I have few comment.




> @@ -1168,6 +1170,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
>  done:
>  	local_irq_enable();
>  	pagevec_release(&pvec);
> +	trace_mm_pagereclaim_shrinkinactive(nr_scanned, nr_reclaimed,
> +						file, priority);
>  	return nr_reclaimed;
>  }

In shrink_inactive list, the pages will become 
 (1) moved to active list
 (2) moved to inactive list again
 (3) moved to unevictable list
 (4) freed

your tracepoint only watch freed pages.
maybe, other moving should be watched too. each moving indicate each different pressure.

Plus, I like more shorter tracepoint name personally.


>  
> @@ -1325,6 +1329,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  						LRU_BASE   + file * LRU_FILE);
>  
>  	spin_unlock_irq(&zone->lru_lock);
> +	trace_mm_pagereclaim_shrinkactive(pgscanned, pgmoved, file, priority);
>  }

pgmoved don't point meaningful data.
pgmoved mean how much pages isolate from active list. but it doesn't mean
how much pages move to inactive-list although we really need it.


>  static int inactive_anon_is_low_global(struct zone *zone)
> @@ -1491,6 +1496,7 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
>  	/* Normalize to percentages */
>  	percent[0] = 100 * ap / (ap + fp + 1);
>  	percent[1] = 100 - percent[0];
> +	trace_mm_get_scanratio(anon, file, percent[0], percent[1]);
>  }

Maybe bad place.
shrink_zone() have following code.

        if (!sc->may_swap || (nr_swap_pages <= 0)) {
                noswap = 1;
                percent[0] = 0;
                percent[1] = 100;
        } else
                get_scan_ratio(zone, sc, percent);

        (snip)

        for_each_evictable_lru(l) {
                int file = is_file_lru(l);
                unsigned long scan;

                scan = zone_nr_pages(zone, sc, l);
                if (priority || noswap) {
                        scan >>= priority;
                        scan = (scan * percent[file]) / 100;
                }

(1) shrink_zone() often don't call get_scan_ratio().
(2) for some reason, "scan" calculation igure percent[file].

Maybe we should log scan variable or nr[l] variable.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
