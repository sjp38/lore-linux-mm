Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id CEC9D6B004D
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 07:14:00 -0400 (EDT)
Date: Wed, 14 Mar 2012 12:13:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: hugetlb: defer freeing pages when gathering surplus
 pages
Message-ID: <20120314111357.GD4434@tiehlicka.suse.cz>
References: <CAJd=RBATj97k5UESDFx82bzt0K4OquhBoDkfjPBPacdmdfJE8g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBATj97k5UESDFx82bzt0K4OquhBoDkfjPBPacdmdfJE8g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

[Sorry for the late reply but I was away from email for quite sometime]

On Tue 14-02-12 20:53:51, Hillf Danton wrote:
> When gathering surplus pages, the number of needed pages is recomputed after
> reacquiring hugetlb lock to catch changes in resv_huge_pages and
> free_huge_pages. Plus it is recomputed with the number of newly allocated
> pages involved.
> 
> Thus freeing pages could be deferred a bit to see if the final page request is
> satisfied, though pages could be allocated less than needed.

The patch looks OK but I am missing a word why we need it. I guess
your primary motivation is that we want to reduce false positives when
we fail to allocate surplus pages while somebody freed some in the
background.
What is the workload that you observed such a behavior? Or is this just
from the code review?

> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/hugetlb.c	Tue Feb 14 20:10:46 2012
> +++ b/mm/hugetlb.c	Tue Feb 14 20:19:42 2012
> @@ -852,6 +852,7 @@ static int gather_surplus_pages(struct h
>  	struct page *page, *tmp;
>  	int ret, i;
>  	int needed, allocated;
> +	bool alloc_ok = true;
> 
>  	needed = (h->resv_huge_pages + delta) - h->free_huge_pages;
>  	if (needed <= 0) {
> @@ -867,17 +868,13 @@ retry:
>  	spin_unlock(&hugetlb_lock);
>  	for (i = 0; i < needed; i++) {
>  		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> -		if (!page)
> -			/*
> -			 * We were not able to allocate enough pages to
> -			 * satisfy the entire reservation so we free what
> -			 * we've allocated so far.
> -			 */
> -			goto free;
> -
> +		if (!page) {
> +			alloc_ok = false;
> +			break;
> +		}
>  		list_add(&page->lru, &surplus_list);
>  	}
> -	allocated += needed;
> +	allocated += i;
> 
>  	/*
>  	 * After retaking hugetlb_lock, we need to recalculate 'needed'
> @@ -886,9 +883,16 @@ retry:
>  	spin_lock(&hugetlb_lock);
>  	needed = (h->resv_huge_pages + delta) -
>  			(h->free_huge_pages + allocated);
> -	if (needed > 0)
> -		goto retry;
> -
> +	if (needed > 0) {
> +		if (alloc_ok)
> +			goto retry;
> +		/*
> +		 * We were not able to allocate enough pages to
> +		 * satisfy the entire reservation so we free what
> +		 * we've allocated so far.
> +		 */
> +		goto free;
> +	}
>  	/*
>  	 * The surplus_list now contains _at_least_ the number of extra pages
>  	 * needed to accommodate the reservation.  Add the appropriate number
> @@ -914,10 +918,10 @@ retry:
>  		VM_BUG_ON(page_count(page));
>  		enqueue_huge_page(h, page);
>  	}
> +free:
>  	spin_unlock(&hugetlb_lock);
> 
>  	/* Free unnecessary surplus pages to the buddy allocator */
> -free:
>  	if (!list_empty(&surplus_list)) {
>  		list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
>  			list_del(&page->lru);
> --
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
