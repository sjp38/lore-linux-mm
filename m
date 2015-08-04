Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id C64B46B0253
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 09:52:59 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so167493184wib.0
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 06:52:59 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id ld9si2402052wjc.86.2015.08.04.06.52.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Aug 2015 06:52:58 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so24924047wib.0
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 06:52:58 -0700 (PDT)
Date: Tue, 4 Aug 2015 15:52:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: vmscan: never isolate more pages than necessary
Message-ID: <20150804135255.GG28571@dhcp22.suse.cz>
References: <1438614147-30419-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438614147-30419-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 03-08-15 18:02:27, Vladimir Davydov wrote:
> If transparent huge pages are enabled, we can isolate many more pages
> than we actually need to scan, because we count both single and huge
> pages equally in isolate_lru_pages().
> 
> Since commit 5bc7b8aca942d ("mm: thp: add split tail pages to shrink
> page list in page reclaim"), we scan all the tail pages immediately
> after a huge page split (see shrink_page_list()). As a result, we can
> reclaim up to SWAP_CLUSTER_MAX * HPAGE_PMD_NR (512 MB) in one run!

512MB is really unexpected. But yeah, you are right. Mel has increased
SWAP_CLUSTER_MAX to 256 recently (mm: increase SWAP_CLUSTER_MAX to
batch TLB flushes) which I have missed. That has made the situation
potentially much worse. I guess this is worth mentioning in the
changelog because the original SWAP_CLUSTER_MAX (32) hasn't looked that
scary.
 
> This is easy to catch on memcg reclaim with zswap enabled. The latter
> makes swapout instant so that if we happen to scan an unreferenced huge
> page we will evict both its head and tail pages immediately, which is
> likely to result in excessive reclaim.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/vmscan.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5221e19e98f4..94092fd3b96b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1387,7 +1387,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	unsigned long nr_taken = 0;
>  	unsigned long scan;
>  
> -	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
> +	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
> +					!list_empty(src); scan++) {
>  		struct page *page;
>  		int nr_pages;
>  
> -- 
> 2.1.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
