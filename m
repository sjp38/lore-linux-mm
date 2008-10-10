Message-ID: <48EFEC68.6000705@redhat.com>
Date: Fri, 10 Oct 2008 19:59:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
References: <200810081655.06698.nickpiggin@yahoo.com.au>	<20081008185401.D958.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<20081010151701.e9e50bdb.akpm@linux-foundation.org>	<20081010152540.79ed64cb.akpm@linux-foundation.org> <20081010153346.e25b90f7.akpm@linux-foundation.org>
In-Reply-To: <20081010153346.e25b90f7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> OK, that wasn't a particularly good time to drop those patches.
> 
> Here's how shrink_active_list() ended up:

You're close.

> 	while (!list_empty(&l_hold)) {
> 		cond_resched();
> 		page = lru_to_page(&l_hold);
> 		list_del(&page->lru);
> 
> 		if (unlikely(!page_evictable(page, NULL))) {
> 			putback_lru_page(page);
> 			continue;
> 		}

These three lines are needed here:

		/* page_referenced clears PageReferenced */
		if (page_mapping_inuse(page) && page_referenced(page))
			pgmoved++;

> 		list_add(&page->lru, &l_inactive);

That allows us to drop these lines:

> 		if (!page_mapping_inuse(page)) {
> 			/*
> 			 * Bypass use-once, make the next access count. See
> 			 * mark_page_accessed and shrink_page_list.
> 			 */
> 			SetPageReferenced(page);
> 		}

Other than that, it looks good.

> 	}
> 
> 	/*
> 	 * Count the referenced pages as rotated, even when they are moved
> 	 * to the inactive list.  This helps balance scan pressure between
> 	 * file and anonymous pages in get_scan_ratio.
>  	 */
> 	zone->recent_rotated[!!file] += pgmoved;

This now automatically does the right thing.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
