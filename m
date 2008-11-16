Date: Sat, 15 Nov 2008 21:00:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: evict streaming IO cache first
Message-Id: <20081115210039.537f59f5.akpm@linux-foundation.org>
In-Reply-To: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sat, 15 Nov 2008 18:38:59 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi Andrew,
> 
> I think we need this patch at 2.6.28.
> Can this thinking get acception?
> 
> 
> --------------------------------------------------
> From: Rik van Riel <riel@redhat.com>
> 
> Gene Heskett reported 2.6.28-rc3 often make unnecessary swap-out
> on his system(4GB mem, 2GB swap).
> and He has had to do a "swapoff -a; swapon -a" daily to clear the swap.
> 
> 
> Actually, When there is a lot of streaming IO (or lite memory pressure workload)
> going on, we do not want to scan or evict pages from the working set.  
> The old VM used to skip any mapped page, but still evict indirect blocks and
> other data that is useful to cache.

Well yes, that was to stop precisely this problem from happening.

> This patch adds logic to skip scanning the anon lists and
> the active file list if most of the file pages are on the
> inactive file list (where streaming IO pages live), while
> at the lowest scanning priority.
> 
> If the system is not doing a lot of streaming IO, eg. the
> system is running a database workload, then more often used
> file pages will be on the active file list and this logic
> is automatically disabled.
> 
> 
> IOW, Large server apparently doesn't need this patch. but
> desktop or small server need it.
> 
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Ackted-by: Gene Heskett <gene.heskett@gmail.com>
> Tested-by: Gene Heskett <gene.heskett@gmail.com>
> ---
>  include/linux/mmzone.h |    1 +
>  mm/vmscan.c            |   18 ++++++++++++++++--
>  2 files changed, 17 insertions(+), 2 deletions(-)
> 
> Index: b/include/linux/mmzone.h
> ===================================================================
> --- a/include/linux/mmzone.h	2008-11-10 16:10:34.000000000 +0900
> +++ b/include/linux/mmzone.h	2008-11-10 16:12:20.000000000 +0900
> @@ -453,6 +453,7 @@ static inline int zone_is_oom_locked(con
>   * queues ("queue_length >> 12") during an aging round.
>   */
>  #define DEF_PRIORITY 12
> +#define PRIO_CACHE_ONLY (DEF_PRIORITY+1)
>  
>  /* Maximum number of zones on a zonelist */
>  #define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c	2008-11-10 16:10:34.000000000 +0900
> +++ b/mm/vmscan.c	2008-11-10 16:11:30.000000000 +0900
> @@ -1443,6 +1443,20 @@ static unsigned long shrink_zone(int pri
>  		}
>  	}
>  
> +	/*
> +	 * If there is a lot of sequential IO going on, most of the
> +	 * file pages will be on the inactive file list.  We start
> +	 * out by reclaiming those pages, without putting pressure on
> +	 * the working set.  We only do this if the bulk of the file pages
> +	 * are not in the working set (on the active file list).
> +	 */
> +	if (priority == PRIO_CACHE_ONLY &&
> +			(nr[LRU_INACTIVE_FILE] > nr[LRU_ACTIVE_FILE]))
> +		for_each_evictable_lru(l)
> +			/* Scan only the inactive_file list. */
> +			if (l != LRU_INACTIVE_FILE)
> +				nr[l] = 0;
> +
>  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
>  					nr[LRU_INACTIVE_FILE]) {
>  		for_each_evictable_lru(l) {
> @@ -1573,7 +1587,7 @@ static unsigned long do_try_to_free_page
>  		}
>  	}
>  
> -	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> +	for (priority = PRIO_CACHE_ONLY; priority >= 0; priority--) {
>  		sc->nr_scanned = 0;
>  		if (!priority)
>  			disable_swap_token();
> @@ -1735,7 +1749,7 @@ loop_again:
>  	for (i = 0; i < pgdat->nr_zones; i++)
>  		temp_priority[i] = DEF_PRIORITY;
>  
> -	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> +	for (priority = PRIO_CACHE_ONLY; priority >= 0; priority--) {
>  		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
>  		unsigned long lru_pages = 0;

This is a twiddle, and not a terribly good one, IMO.

See, the old reclaim_mapped logic tried to work by *observing* the
behaviour of page reclaim.  The above tweak tries to predict a-priori
what will happen, and hence has far less information.  This is a key
difference!

The guesses which the above code makes can and will go wrong, I expect.

For a start, it has a sudden transition point at (nr[LRU_INACTIVE_FILE]
== nr[LRU_ACTIVE_FILE).  That is a completely arbitrary wet finger in
the air, and when it is crossed, there will be large changes in
behaviour.  This cannot be right!

Secondly, the above code is dependent upon the size of the zone.  We
scan 1/8192th of the zone's pages in "only reclaim file pages" mode,
then we flip into "scan anon pages as well" mode.

If the size of the zone is less than (SWAP_CLUSTER_MAX * 8192) (1GB
with 4k pages) then this code will _always_ fail to reclaim
SWAP_CLUSTER_MAX pages on that initial pass, and hence will always
decrement `priority' and will always fall into "scan anon pages as
well" mode.

So I suspect this code didn't fix the problem for small zones much at
all.


Really, I think that the old approach of observing the scanner
behaviour (rather than trying to predict it) was better.  It has more
information.  I see that bits of it are still left there - afaict
zone->prev_priority doesn't do anything any more?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
