Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B273C6B008A
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 02:11:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5A6BMgQ029898
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 10 Jun 2009 15:11:22 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 656F945DE69
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:11:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 32F2745DE62
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:11:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1246D1DB8049
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:11:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0A571DB8043
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:11:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] lumpy reclaim: clean up and write lumpy reclaim
In-Reply-To: <20090610142443.9370aff8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090610142443.9370aff8.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090610151027.DDBA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Jun 2009 15:11:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, apw@canonical.com, riel@redhat.com, minchan.kim@gmail.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

> I think lumpy reclaim should be updated to meet to current split-lru.
> This patch includes bugfix and cleanup. How do you think ?
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> In lumpty reclaim, "cursor_page" is found just by pfn. Then, we don't know
> where "cursor" page came from. Then, putback it to "src" list is BUG.
> And as pointed out, current lumpy reclaim doens't seem to
> work as originally designed and a bit complicated. This patch adds a
> function try_lumpy_reclaim() and rewrite the logic.
> 
> The major changes from current lumpy reclaim is
>   - check migratetype before aggressive retry at failure.
>   - check PG_unevictable at failure.
>   - scan is done in buddy system order. This is a help for creating
>     a lump around targeted page. We'll create a continuous pages for buddy
>     allocator as far as we can _around_ reclaim target page.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/vmscan.c |  120 +++++++++++++++++++++++++++++++++++-------------------------
>  1 file changed, 71 insertions(+), 49 deletions(-)
> 
> Index: mmotm-2.6.30-Jun10/mm/vmscan.c
> ===================================================================
> --- mmotm-2.6.30-Jun10.orig/mm/vmscan.c
> +++ mmotm-2.6.30-Jun10/mm/vmscan.c
> @@ -850,6 +850,69 @@ int __isolate_lru_page(struct page *page
>  	return ret;
>  }
>  
> +static int
> +try_lumpy_reclaim(struct page *page, struct list_head *dst, int request_order)
> +{
> +	unsigned long buddy_base, buddy_idx, buddy_start_pfn, buddy_end_pfn;
> +	unsigned long pfn, page_pfn, page_idx;
> +	int zone_id, order, type;
> +	int do_aggressive = 0;
> +	int nr = 0;
> +	/*
> +	 * Lumpy reqraim. Try to take near pages in requested order to
> +	 * create free continous pages. This algorithm tries to start
> +	 * from order 0 and scan buddy pages up to request_order.
> +	 * If you are unsure about buddy position calclation, please see
> +	 * mm/page_alloc.c
> +	 */
> +	zone_id = page_zone_id(page);
> +	page_pfn = page_to_pfn(page);
> +	buddy_base = page_pfn & ~((1 << MAX_ORDER) - 1);
> +
> +	/* Can we expect succesful reclaim ? */
> +	type = get_pageblock_migratetype(page);
> +	if ((type == MIGRATE_MOVABLE) || (type == MIGRATE_RECLAIMABLE))
> +		do_aggressive = 1;
> +
> +	for (order = 0; order < request_order; ++order) {
> +		/* offset in this buddy region */
> +		page_idx = page_pfn & ~buddy_base;
> +		/* offset of buddy can be calculated by xor */
> +		buddy_idx = page_idx ^ (1 << order);
> +		buddy_start_pfn = buddy_base + buddy_idx;
> +		buddy_end_pfn = buddy_start_pfn + (1 << order);
> +
> +		/* scan range [buddy_start_pfn...buddy_end_pfn) */
> +		for (pfn = buddy_start_pfn; pfn < buddy_end_pfn; ++pfn) {
> +			/* Avoid holes within the zone. */
> +			if (unlikely(!pfn_valid_within(pfn)))
> +				break;
> +			page = pfn_to_page(pfn);
> +			/*
> +			 * Check that we have not crossed a zone boundary.
> +			 * Some arch have zones not aligned to MAX_ORDER.
> +			 */
> +			if (unlikely(page_zone_id(page) != zone_id))
> +				break;
> +
> +			/* we are always under ISOLATE_BOTH */
> +			if (__isolate_lru_page(page, ISOLATE_BOTH, 0) == 0) {
> +				list_move(&page->lru, dst);
> +				nr++;
> +			} else if (do_aggressive && !PageUnevictable(page))

Could you explain this branch intention more?



> +					continue;
> +			else
> +				break;
> +		}
> +		/* we can't refill this order */
> +		if (pfn != buddy_end_pfn)
> +			break;
> +		if (buddy_start_pfn < page_pfn)
> +			page_pfn = buddy_start_pfn;
> +	}
> +	return nr;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
