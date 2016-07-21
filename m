Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 557A86B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 01:16:30 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id q2so120943958pap.1
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 22:16:30 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id wy7si7534269pab.3.2016.07.20.22.16.28
        for <linux-mm@kvack.org>;
        Wed, 20 Jul 2016 22:16:29 -0700 (PDT)
Date: Thu, 21 Jul 2016 14:16:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/5] mm, vmscan: Do not account skipped pages as scanned
Message-ID: <20160721051648.GA31865@bbox>
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

The comment should explain why.

/* Pages skipped do not contribute to scan to prevent premature OOM */


> +		scan++;
> +


The one of my concern about node-lru is to add more lru lock contetion
in multiple zone system so such unbounded skip scanning under the lock
should have a limit to prevent latency spike and serialization of
current reclaim work.

Another concern is big mismatch between the number of pages from list and
LRU stat count because lruvec_lru_size call sites don't take the stat
under the lock while isolate_lru_pages moves many pages from lru list
to temporal skipped list.


>  		switch (__isolate_lru_page(page, mode)) {
>  		case 0:
>  			nr_pages = hpage_nr_pages(page);
> -- 
> 2.6.4
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
