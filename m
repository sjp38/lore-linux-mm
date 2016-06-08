Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC636B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 09:18:39 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id j12so3817550lbo.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 06:18:39 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id f66si2152761wma.11.2016.06.08.06.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 06:18:33 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id m124so2923703wme.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 06:18:33 -0700 (PDT)
Date: Wed, 8 Jun 2016 15:18:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] mm: only count actual rotations as LRU reclaim cost
Message-ID: <20160608131831.GJ22570@dhcp22.suse.cz>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-10-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606194836.3624-10-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon 06-06-16 15:48:35, Johannes Weiner wrote:
> Noting a reference on an active file page but still deactivating it
> represents a smaller cost of reclaim than noting a referenced
> anonymous page and actually physically rotating it back to the head.
> The file page *might* refault later on, but it's definite progress
> toward freeing pages, whereas rotating the anonymous page costs us
> real time without making progress toward the reclaim goal.
> 
> Don't treat both events as equal. The following patch will hook up LRU
> balancing to cache and swap refaults, which are a much more concrete
> cost signal for reclaiming one list over the other. Remove the
> maybe-IO cost bias from page references, and only note the CPU cost
> for actual rotations that prevent the pages from getting reclaimed.

The changelog was quite hard to digest for me but I guess I got your
point. The change itself makes sense to me because noting the LRU
cost for pages which we intentionally keep on the active list because
they are really precious is reasonable. Which is not the case for
referenced pages in general because we only find out whether they are
really needed when we encounter them on the inactive list.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 06e381e1004c..acbd212eab6e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1821,7 +1821,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  
>  		if (page_referenced(page, 0, sc->target_mem_cgroup,
>  				    &vm_flags)) {
> -			nr_rotated += hpage_nr_pages(page);
>  			/*
>  			 * Identify referenced, file-backed active pages and
>  			 * give them one more trip around the active list. So
> @@ -1832,6 +1831,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  			 * so we ignore them here.
>  			 */
>  			if ((vm_flags & VM_EXEC) && page_is_file_cache(page)) {
> +				nr_rotated += hpage_nr_pages(page);
>  				list_add(&page->lru, &l_active);
>  				continue;
>  			}
> @@ -1846,10 +1846,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	 */
>  	spin_lock_irq(&zone->lru_lock);
>  	/*
> -	 * Count referenced pages from currently used mappings as rotated,
> -	 * even though only some of them are actually re-activated.  This
> -	 * helps balance scan pressure between file and anonymous pages in
> -	 * get_scan_count.
> +	 * Rotating pages costs CPU without actually
> +	 * progressing toward the reclaim goal.
>  	 */
>  	lru_note_cost(lruvec, file, nr_rotated);
>  
> -- 
> 2.8.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
