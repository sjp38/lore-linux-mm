Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2497C6B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 10:27:22 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so116386396lfi.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 07:27:22 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id p2si1419608wjv.234.2016.07.18.07.27.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 07:27:20 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id C43771C1858
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 15:27:19 +0100 (IST)
Date: Mon, 18 Jul 2016 15:27:14 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node
 basis
Message-ID: <20160718142714.GA10438@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-5-git-send-email-mgorman@techsingularity.net>
 <20160707011211.GA27987@js1304-P5Q-DELUXE>
 <20160707094808.GP11498@techsingularity.net>
 <20160708022852.GA2370@js1304-P5Q-DELUXE>
 <20160708100532.GC11498@techsingularity.net>
 <20160714062836.GB29676@js1304-P5Q-DELUXE>
 <20160718121122.GQ9806@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160718121122.GQ9806@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 18, 2016 at 01:11:22PM +0100, Mel Gorman wrote:
> The all_unreclaimable logic is related to the number of pages scanned
> but currently pages skipped contributes to pages scanned. That is one
> possibility. The other is that if all pages scanned are skipped then the
> OOM killer can believe there is zero progress.
> 
> Try this to start with;
> 

And if that fails, try this heavier handed version that will scan the full
LRU potentially to isolate at least a single page if it's available for
zone-constrained allocations. It's compile-tested only

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a6f31617a08c..6a35691c8b94 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1408,14 +1408,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		isolate_mode_t mode, enum lru_list lru)
 {
 	struct list_head *src = &lruvec->lists[lru];
-	unsigned long nr_taken = 0;
+	unsigned long nr_taken = 0, total_skipped = 0;
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
 	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
 	unsigned long scan, nr_pages;
 	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
-					!list_empty(src); scan++) {
+			!list_empty(src) && scan == total_skipped; scan++) {
 		struct page *page;
 
 		page = lru_to_page(src);
@@ -1426,6 +1426,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		if (page_zonenum(page) > sc->reclaim_idx) {
 			list_move(&page->lru, &pages_skipped);
 			nr_skipped[page_zonenum(page)]++;
+			total_skipped++;
 			continue;
 		}
 
@@ -1465,7 +1466,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			__count_zid_vm_events(PGSCAN_SKIP, zid, nr_skipped[zid]);
 		}
 	}
-	*nr_scanned = scan;
+	*nr_scanned = scan - total_skipped;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
 				    nr_taken, mode, is_file_lru(lru));
 	update_lru_sizes(lruvec, lru, nr_zone_taken, nr_taken);

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
