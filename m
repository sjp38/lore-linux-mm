From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [RFC][PATCH -mm] vmscan: fix swapout on sequential IO
References: <20080723144115.72803eb8@bree.surriel.com>
Date: Wed, 23 Jul 2008 20:48:10 +0200
In-Reply-To: <20080723144115.72803eb8@bree.surriel.com> (Rik van Riel's
	message of "Wed, 23 Jul 2008 14:41:15 -0400")
Message-ID: <87zlo8mo7p.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rik,

Rik van Riel <riel@surriel.com> writes:

> From: Rik van Riel <riel@redhat.com>
>
> Only force the scanning of every LRU list if we could not easily
> find a page to evict.  This preserves the balancing done by
> get_scan_ratio(), while ensuring the VM will make progress
> when there is serious memory pressure.
>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> This should fix the "dd if=/dev/sda of=/dev/null causes swapout"
> problem that has been seen with the new split LRU VM.
>
>  mm/vmscan.c |   17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
>
> Index: linux-2.6.26-rc8-mm1/mm/vmscan.c
> ===================================================================
> --- linux-2.6.26-rc8-mm1.orig/mm/vmscan.c	2008-07-23 14:19:09.000000000 -0400
> +++ linux-2.6.26-rc8-mm1/mm/vmscan.c	2008-07-23 14:36:26.000000000 -0400
> @@ -1447,24 +1447,27 @@ static unsigned long shrink_zone(int pri
>  	unsigned long nr_to_scan;
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long percent[2];	/* anon @ 0; file @ 1 */
> +	unsigned int force_scan = 0;
>  	enum lru_list l;
>  
> +	/*
> +         * If we do not immediately find pages to evict, put some
> +         * pressure on every LRU list to guarantee progress.
> +         */
> +	if (priority < DEF_PRIORITY - 2)
> +		force_scan = 1;
> +
>  	get_scan_ratio(zone, sc, percent);
>  
>  	for_each_evictable_lru(l) {
>  		if (scan_global_lru(sc)) {
>  			int file = is_file_lru(l);
> -			int scan;
> -			/*
> -			 * Add one to nr_to_scan just to make sure that the
> -			 * kernel will slowly sift through each list.
> -			 */
> -			scan = zone_page_state(zone, NR_LRU_BASE + l);
> +			int scan = zone_page_state(zone, NR_LRU_BASE + l);
>  			if (priority) {
>  				scan >>= priority;
>  				scan = (scan * percent[file]) / 100;
>  			}
> -			zone->lru[l].nr_scan += scan + 1;
> +			zone->lru[l].nr_scan += scan + force_scan;

The accumulation aspect is not gone, though.  If the system has reached
the force-scan priority swap_cluster_max times, the next scan, even if
long after the last scan, will scan bogus lists.

>  			nr[l] = zone->lru[l].nr_scan;
>  			if (nr[l] >= sc->swap_cluster_max)
>  				zone->lru[l].nr_scan = 0;

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
