Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 87E2D6B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 22:20:09 -0400 (EDT)
Date: Tue, 9 Jun 2009 10:37:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] Properly account for the number of page cache
	pages zone_reclaim() can reclaim
Message-ID: <20090609023731.GA7875@localhost>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1244466090-10711-3-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "linuxram@us.ibm.com" <linuxram@us.ibm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 09:01:29PM +0800, Mel Gorman wrote:
> On NUMA machines, the administrator can configure zone_relcaim_mode that
> is a more targetted form of direct reclaim. On machines with large NUMA
> distances for example, a zone_reclaim_mode defaults to 1 meaning that clean
> unmapped pages will be reclaimed if the zone watermarks are not being met.
> 
> There is a heuristic that determines if the scan is worthwhile but the
> problem is that the heuristic is not being properly applied and is basically
> assuming zone_reclaim_mode is 1 if it is enabled.
> 
> This patch makes zone_reclaim() makes a better attempt at working out how
> many pages it might be able to reclaim given the current reclaim_mode. If it
> cannot clean pages, then NR_FILE_DIRTY number of pages are not candidates. If
> it cannot swap, then NR_FILE_MAPPED are not. This indirectly addresses tmpfs
> as those pages tend to be dirty as they are not cleaned by pdflush or sync.
> 
> The ideal would be that the number of tmpfs pages would also be known
> and account for like NR_FILE_MAPPED as swap is required to discard them.
> A means of working this out quickly was not obvious but a comment is added
> noting the problem.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/vmscan.c |   18 ++++++++++++++++--
>  1 files changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ba211c1..ffe2f32 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2380,6 +2380,21 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  {
>  	int node_id;
>  	int ret;
> +	int pagecache_reclaimable;
> +
> +	/*
> +	 * Work out how many page cache pages we can reclaim in this mode.
> +	 *
> +	 * NOTE: Ideally, tmpfs pages would be accounted as if they were
> +	 *       NR_FILE_MAPPED as swap is required to discard those
> +	 *       pages even when they are clean. However, there is no
> +	 *       way of quickly identifying the number of tmpfs pages
> +	 */
> +	pagecache_reclaimable = zone_page_state(zone, NR_FILE_PAGES);
> +	if (!(zone_reclaim_mode & RECLAIM_WRITE))
> +		pagecache_reclaimable -= zone_page_state(zone, NR_FILE_DIRTY);

> +	if (!(zone_reclaim_mode & RECLAIM_SWAP))
> +		pagecache_reclaimable -= zone_page_state(zone, NR_FILE_MAPPED);

Your patch seems to conflict with KOSAKI's earlier patch "vmscan: change the
number of the unmapped files in zone reclaim", where he offers a better way for
getting rid of the tmpfs pages:

+       nr_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +                                                                    
+                       zone_page_state(zone, NR_ACTIVE_FILE);                                                                       
+       nr_mapped = zone_page_state(zone, NR_FILE_MAPPED);                                                                           
+       if (likely(nr_file_pages >= nr_mapped))                                                                                      
+               nr_unmapped_file_pages = nr_file_pages - nr_mapped;                                                                  
                                                                                                                                     
        if (nr_unmapped_file_pages > zone->min_unmapped_pages) {                                                                     

Thanks,
Fengguang

>  	/*
>  	 * Zone reclaim reclaims unmapped file backed pages and
> @@ -2391,8 +2406,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	 * if less than a specified percentage of the zone is used by
>  	 * unmapped file backed pages.
>  	 */
> -	if (zone_page_state(zone, NR_FILE_PAGES) -
> -	    zone_page_state(zone, NR_FILE_MAPPED) <= zone->min_unmapped_pages
> +	if (pagecache_reclaimable <= zone->min_unmapped_pages
>  	    && zone_page_state(zone, NR_SLAB_RECLAIMABLE)
>  			<= zone->min_slab_pages)
>  		return 0;
> -- 
> 1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
