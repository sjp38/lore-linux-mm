Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7885F6B0253
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 10:25:38 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so13519162lfw.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 07:25:38 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id k201si16292679lfe.369.2016.07.19.07.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 07:25:36 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 2841F1C1D78
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:25:36 +0100 (IST)
Date: Tue, 19 Jul 2016 15:25:34 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node
 basis
Message-ID: <20160719142534.GD10438@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-5-git-send-email-mgorman@techsingularity.net>
 <20160707011211.GA27987@js1304-P5Q-DELUXE>
 <20160707094808.GP11498@techsingularity.net>
 <20160708022852.GA2370@js1304-P5Q-DELUXE>
 <20160708100532.GC11498@techsingularity.net>
 <20160714062836.GB29676@js1304-P5Q-DELUXE>
 <20160718121122.GQ9806@techsingularity.net>
 <20160718142714.GA10438@techsingularity.net>
 <20160719083031.GD17479@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160719083031.GD17479@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 19, 2016 at 05:30:31PM +0900, Joonsoo Kim wrote:
> On Mon, Jul 18, 2016 at 03:27:14PM +0100, Mel Gorman wrote:
> > On Mon, Jul 18, 2016 at 01:11:22PM +0100, Mel Gorman wrote:
> > > The all_unreclaimable logic is related to the number of pages scanned
> > > but currently pages skipped contributes to pages scanned. That is one
> > > possibility. The other is that if all pages scanned are skipped then the
> > > OOM killer can believe there is zero progress.
> > > 
> > > Try this to start with;
> > > 
> > 
> > And if that fails, try this heavier handed version that will scan the full
> > LRU potentially to isolate at least a single page if it's available for
> > zone-constrained allocations. It's compile-tested only
> 
> I tested both patches but they don't work for me. Notable difference
> is that all_unreclaimable is now "no".
> 

Ok, that's good to know at least. It at least indicates that skips
accounted as scans are a contributory factor.

> Just attach the oops log from heavier version.
> 

Apparently, isolating at least one page is not enough. Please try the
following. If it fails, please post the test script you're using. I can
simulate what you describe (mapped reads combined with lots of forks)
but no guarantee I'll get it exactly right. I think it's ok to not
account skips as scans because the skips are already accounted for.

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
-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
