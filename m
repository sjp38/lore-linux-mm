Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E58606B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 08:57:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so5961057wme.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 05:57:30 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id m8si1368468wjw.73.2016.06.08.05.57.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 05:57:29 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r5so2818264wmr.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 05:57:29 -0700 (PDT)
Date: Wed, 8 Jun 2016 14:57:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/10] mm: deactivations shouldn't bias the LRU balance
Message-ID: <20160608125727.GI22570@dhcp22.suse.cz>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-9-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606194836.3624-9-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon 06-06-16 15:48:34, Johannes Weiner wrote:
> Operations like MADV_FREE, FADV_DONTNEED etc. currently move any
> affected active pages to the inactive list to accelerate their reclaim
> (good) but also steer page reclaim toward that LRU type, or away from
> the other (bad).
> 
> The reason why this is undesirable is that such operations are not
> part of the regular page aging cycle, and rather a fluke that doesn't
> say much about the remaining pages on that list. They might all be in
> heavy use. But once the chunk of easy victims has been purged, the VM
> continues to apply elevated pressure on the remaining hot pages. The
> other LRU, meanwhile, might have easily reclaimable pages, and there
> was never a need to steer away from it in the first place.
> 
> As the previous patch outlined, we should focus on recording actually
> observed cost to steer the balance rather than speculating about the
> potential value of one LRU list over the other. In that spirit, leave
> explicitely deactivated pages to the LRU algorithm to pick up, and let
> rotations decide which list is the easiest to reclaim.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/swap.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 645d21242324..ae07b469ddca 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -538,7 +538,6 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
>  
>  	if (active)
>  		__count_vm_event(PGDEACTIVATE);
> -	lru_note_cost(lruvec, !file, hpage_nr_pages(page));
>  }
>  
>  
> @@ -546,7 +545,6 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
>  			    void *arg)
>  {
>  	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
> -		int file = page_is_file_cache(page);
>  		int lru = page_lru_base_type(page);
>  
>  		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
> @@ -555,7 +553,6 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
>  		add_page_to_lru_list(page, lruvec, lru);
>  
>  		__count_vm_event(PGDEACTIVATE);
> -		lru_note_cost(lruvec, !file, hpage_nr_pages(page));
>  	}
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
