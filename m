Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 068906B0038
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 04:50:02 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so20582893pdj.3
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 01:50:01 -0700 (PDT)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-251.mail.alibaba.com. [205.204.113.251])
        by mx.google.com with ESMTP id km1si282371pab.155.2015.06.12.01.49.59
        for <linux-mm@kvack.org>;
        Fri, 12 Jun 2015 01:50:01 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH 19/25] mm, vmscan: Account in vmstat for pages skipped during reclaim
Date: Fri, 12 Jun 2015 16:49:44 +0800
Message-ID: <00f801d0a4ec$bb61a480$3224ed80$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1326,6 +1326,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> 
>  	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
>  		struct page *page;
> +		struct zone *zone;
>  		int nr_pages;
> 
>  		page = lru_to_page(src);
> @@ -1333,8 +1334,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> 
>  		VM_BUG_ON_PAGE(!PageLRU(page), page);
> 
> -		if (page_zone_id(page) > sc->reclaim_idx)
> +		zone = page_zone(page);
> +		if (page_zone_id(page) > sc->reclaim_idx) {
>  			list_move(&page->lru, &pages_skipped);
> +			__count_zone_vm_events(PGSCAN_SKIP, page_zone(page), 1);
> +		}
The newly added zone is not used.
> 
>  		switch (__isolate_lru_page(page, mode)) {
>  		case 0:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
