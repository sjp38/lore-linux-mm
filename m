Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9ECA06B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 18:03:21 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so1200703pdj.23
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 15:03:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tk5si1366676pbc.338.2014.04.23.15.03.20
        for <linux-mm@kvack.org>;
        Wed, 23 Apr 2014 15:03:20 -0700 (PDT)
Date: Wed, 23 Apr 2014 15:03:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] MM: avoid throttling reclaim for loop-back nfsd
 threads.
Message-Id: <20140423150318.d4bcf234faa5bea7fcb57b9b@linux-foundation.org>
In-Reply-To: <20140423024058.4725.71995.stgit@notabene.brown>
References: <20140423022441.4725.89693.stgit@notabene.brown>
	<20140423024058.4725.71995.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Mel Gorman <mgorman@suse.com>, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 23 Apr 2014 12:40:58 +1000 NeilBrown <neilb@suse.de> wrote:

> When a loop-back NFS mount is active and the backing device for the
> NFS mount becomes congested, that can impose throttling delays on the
> nfsd threads.
> 
> These delays significantly reduce throughput and so the NFS mount
> remains congested.
> 
> This results in a live lock and the reduced throughput persists.
> 
> This live lock has been found in testing with the 'wait_iff_congested'
> call, and could possibly be caused by the 'congestion_wait' call.
> 
> This livelock is similar to the deadlock which justified the
> introduction of PF_LESS_THROTTLE, and the same flag can be used to
> remove this livelock.
> 
> To minimise the impact of the change, we still throttle nfsd when the
> filesystem it is writing to is congested, but not when some separate
> filesystem (e.g. the NFS filesystem) is congested.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  mm/vmscan.c |   18 ++++++++++++++++--
>  1 file changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a9c74b409681..e011a646de95 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1424,6 +1424,18 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
>  	list_splice(&pages_to_free, page_list);
>  }
>  
> +/* If a kernel thread (such as nfsd for loop-back mounts) services

/*
 * If ...

please

> + * a backing device by writing to the page cache it sets PF_LESS_THROTTLE.
> + * In that case we should only throttle if the backing device it is
> + * writing to is congested.  In other cases it is safe to throttle.
> + */
> +static int current_may_throttle(void)
> +{
> +	return !(current->flags & PF_LESS_THROTTLE) ||
> +		current->backing_dev_info == NULL ||
> +		bdi_write_congested(current->backing_dev_info);
> +}
> +
>  /*
>   * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
>   * of reclaimed pages
> @@ -1552,7 +1564,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  		 * implies that pages are cycling through the LRU faster than
>  		 * they are written so also forcibly stall.
>  		 */
> -		if (nr_unqueued_dirty == nr_taken || nr_immediate)
> +		if ((nr_unqueued_dirty == nr_taken || nr_immediate)
> +		    && current_may_throttle())

	foo &&
	bar

please.  As you did in in current_may_throttle().

>  			congestion_wait(BLK_RW_ASYNC, HZ/10);
>  	}
>  
> @@ -1561,7 +1574,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	 * is congested. Allow kswapd to continue until it starts encountering
>  	 * unqueued dirty pages or cycling through the LRU too quickly.
>  	 */
> -	if (!sc->hibernation_mode && !current_is_kswapd())
> +	if (!sc->hibernation_mode && !current_is_kswapd()
> +	    && current_may_throttle())

ditto

>  		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
>  
>  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
