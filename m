Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93E956B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 04:04:24 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so318606153pab.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 01:04:24 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id uc6si32371586pab.83.2016.07.25.01.04.22
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 01:04:23 -0700 (PDT)
Date: Mon, 25 Jul 2016 17:04:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/5] mm, vmscan: Do not account skipped pages as scanned
Message-ID: <20160725080456.GB1660@bbox>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <1469028111-1622-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469028111-1622-2-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 20, 2016 at 04:21:47PM +0100, Mel Gorman wrote:
> Page reclaim determines whether a pgdat is unreclaimable by examining how
> many pages have been scanned since a page was freed and comparing that
> to the LRU sizes. Skipped pages are not considered reclaim candidates but
> contribute to scanned. This can prematurely mark a pgdat as unreclaimable
> and trigger an OOM kill.
> 
> While this does not fix an OOM kill message reported by Joonsoo Kim,
> it did stop pgdat being marked unreclaimable.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/vmscan.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 22aec2bcfeec..b16d578ce556 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1415,7 +1415,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	LIST_HEAD(pages_skipped);
>  
>  	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
> -					!list_empty(src); scan++) {
> +					!list_empty(src);) {
>  		struct page *page;
>  
>  		page = lru_to_page(src);
> @@ -1429,6 +1429,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  			continue;
>  		}
>  
> +		/* Pages skipped do not contribute to scan */
> +		scan++;
> +

As I mentioned in previous version, under irq-disabled-spin-lock, such
unbounded operation would make the latency spike worse if there are
lot of pages we should skip.

Don't we take care it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
