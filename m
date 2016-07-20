Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 813D46B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 20:16:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p64so67808001pfb.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 17:16:10 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id q72si11860812pfj.148.2016.07.19.17.16.08
        for <linux-mm@kvack.org>;
        Tue, 19 Jul 2016 17:16:09 -0700 (PDT)
Date: Wed, 20 Jul 2016 09:16:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: add per-zone lru list stat
Message-ID: <20160720001624.GA25472@bbox>
References: <1468943433-24805-1-git-send-email-minchan@kernel.org>
 <20160719164857.GT11400@suse.de>
MIME-Version: 1.0
In-Reply-To: <20160719164857.GT11400@suse.de>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 19, 2016 at 05:48:57PM +0100, Mel Gorman wrote:
> On Wed, Jul 20, 2016 at 12:50:32AM +0900, Minchan Kim wrote:
> > While I did stress test with hackbench, I got OOM message frequently
> > which didn't ever happen in zone-lru.
> > 
> 
> This one also showed pgdat going unreclaimable early. Have you tried any
> of the three oom-related patches I sent to Joonsoo to see what impact,
> if any, it had?

Before the result, I want to say goal of this patch, again.
Without per-zone lru stat, it's really hard to debug OOM problem in
multiple zones system so regardless of solving the problem, we should add
per-zone lru stat for debuggability of OOM which has been never perfect
solution, ever.

You sent 3 patches in that thread and first one was same I had applied
when I found this problem firstly. It didn't solve the problem.

So I tested last one

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a6f31617a08c..0dc443b52228 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1415,7 +1415,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
-					!list_empty(src); scan++) {
+					!list_empty(src);) {
 		struct page *page;
 
 		page = lru_to_page(src);
@@ -1428,6 +1428,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			nr_skipped[page_zonenum(page)]++;
 			continue;
 		}
+`
+		/* Pages skipped do not contribute to scan */
+		scan++;
 
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:

The result is not OOM but hackbench stalls forever.
When I parse vmstat for every 2sec, I found pgskip_high velocity is too
high(i.e., 100000000 pages per 2 sec) while pgscan_direct and pgdeactiation is
really low(i.e., 30 pages per 2 sec).
The reason why it doesn't trigger OOM is a small amout of pages(i.e. 20 pages
per sec) are freed so NR_PAGES_SCANNED is always reset to zero.

> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
