Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4246B0261
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 05:19:33 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so714730lbb.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:19:32 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id z10si28893448wjj.209.2016.06.07.02.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 02:19:31 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id m124so21382060wme.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:19:31 -0700 (PDT)
Date: Tue, 7 Jun 2016 11:19:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 04/10] mm: fix LRU balancing effect of new transparent
 huge pages
Message-ID: <20160607091930.GF12305@dhcp22.suse.cz>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-5-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606194836.3624-5-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon 06-06-16 15:48:30, Johannes Weiner wrote:
> Currently, THP are counted as single pages until they are split right
> before being swapped out. However, at that point the VM is already in
> the middle of reclaim, and adjusting the LRU balance then is useless.
> 
> Always account THP by the number of basepages, and remove the fixup
> from the splitting path.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/swap.c | 18 ++++++++----------
>  1 file changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index d2786a6308dd..c6936507abb5 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -249,13 +249,14 @@ void rotate_reclaimable_page(struct page *page)
>  }
>  
>  static void update_page_reclaim_stat(struct lruvec *lruvec,
> -				     int file, int rotated)
> +				     int file, int rotated,
> +				     unsigned int nr_pages)
>  {
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>  
> -	reclaim_stat->recent_scanned[file]++;
> +	reclaim_stat->recent_scanned[file] += nr_pages;
>  	if (rotated)
> -		reclaim_stat->recent_rotated[file]++;
> +		reclaim_stat->recent_rotated[file] += nr_pages;
>  }
>  
>  static void __activate_page(struct page *page, struct lruvec *lruvec,
> @@ -272,7 +273,7 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
>  		trace_mm_lru_activate(page);
>  
>  		__count_vm_event(PGACTIVATE);
> -		update_page_reclaim_stat(lruvec, file, 1);
> +		update_page_reclaim_stat(lruvec, file, 1, hpage_nr_pages(page));
>  	}
>  }
>  
> @@ -532,7 +533,7 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
>  
>  	if (active)
>  		__count_vm_event(PGDEACTIVATE);
> -	update_page_reclaim_stat(lruvec, file, 0);
> +	update_page_reclaim_stat(lruvec, file, 0, hpage_nr_pages(page));
>  }
>  
>  
> @@ -549,7 +550,7 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
>  		add_page_to_lru_list(page, lruvec, lru);
>  
>  		__count_vm_event(PGDEACTIVATE);
> -		update_page_reclaim_stat(lruvec, file, 0);
> +		update_page_reclaim_stat(lruvec, file, 0, hpage_nr_pages(page));
>  	}
>  }
>  
> @@ -809,9 +810,6 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
>  		list_head = page_tail->lru.prev;
>  		list_move_tail(&page_tail->lru, list_head);
>  	}
> -
> -	if (!PageUnevictable(page))
> -		update_page_reclaim_stat(lruvec, file, PageActive(page_tail));
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
> @@ -826,7 +824,7 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
>  
>  	SetPageLRU(page);
>  	add_page_to_lru_list(page, lruvec, lru);
> -	update_page_reclaim_stat(lruvec, file, active);
> +	update_page_reclaim_stat(lruvec, file, active, hpage_nr_pages(page));
>  	trace_mm_lru_insertion(page, lru);
>  }
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
