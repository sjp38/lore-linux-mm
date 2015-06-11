Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id DAFD46B006C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 03:58:31 -0400 (EDT)
Received: by padev16 with SMTP id ev16so49070202pad.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 00:58:31 -0700 (PDT)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-248.mail.alibaba.com. [205.204.113.248])
        by mx.google.com with ESMTP id gs10si17967643pac.124.2015.06.11.00.58.29
        for <linux-mm@kvack.org>;
        Thu, 11 Jun 2015 00:58:30 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH 04/25] mm, vmscan: Begin reclaiming pages on a per-node basis
Date: Thu, 11 Jun 2015 15:58:14 +0800
Message-ID: <00fe01d0a41c$5f242bf0$1d6c83d0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

> @@ -1319,6 +1322,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	struct list_head *src = &lruvec->lists[lru];
>  	unsigned long nr_taken = 0;
>  	unsigned long scan;
> +	LIST_HEAD(pages_skipped);
> 
>  	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
>  		struct page *page;
> @@ -1329,6 +1333,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> 
>  		VM_BUG_ON_PAGE(!PageLRU(page), page);
> 
> +		if (page_zone_id(page) > sc->reclaim_idx)
> +			list_move(&page->lru, &pages_skipped);
> +
>  		switch (__isolate_lru_page(page, mode)) {
>  		case 0:
>  			nr_pages = hpage_nr_pages(page);
> @@ -1347,6 +1354,15 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  		}
>  	}
> 
> +	/*
> +	 * Splice any skipped pages to the start of the LRU list. Note that
> +	 * this disrupts the LRU order when reclaiming for lower zones but
> +	 * we cannot splice to the tail. If we did then the SWAP_CLUSTER_MAX
> +	 * scanning would soon rescan the same pages to skip and put the
> +	 * system at risk of premature OOM.
> +	 */
> +	if (!list_empty(&pages_skipped))
> +		list_splice(&pages_skipped, src);
>  	*nr_scanned = scan;
>  	trace_mm_vmscan_lru_isolate(sc->order, nr_to_scan, scan,
>  				    nr_taken, mode, is_file_lru(lru));

Can we avoid splicing pages by skipping pages with scan not incremented?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
