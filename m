Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 7AE4A6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 05:57:57 -0400 (EDT)
Received: by yenm8 with SMTP id m8so3244209yen.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 02:57:56 -0700 (PDT)
Date: Fri, 23 Mar 2012 02:57:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix testorder interaction between two kswapd patches
Message-ID: <alpine.LSU.2.00.1203230254110.31362@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

Adjusting cc715d99e529 "mm: vmscan: forcibly scan highmem if there are
too many buffer_heads pinning highmem" for -stable reveals that it was
slightly wrong once on top of fe2c2a106663 "vmscan: reclaim at order 0
when compaction is enabled", which specifically adds testorder for the
zone_watermark_ok_safe() test.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux.git/mm/vmscan.c	2012-03-22 15:03:14.132010081 -0700
+++ linux/mm/vmscan.c	2012-03-23 02:25:04.012090838 -0700
@@ -2817,7 +2817,7 @@ loop_again:
 				testorder = 0;
 
 			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
-				    !zone_watermark_ok_safe(zone, order,
+				    !zone_watermark_ok_safe(zone, testorder,
 					high_wmark_pages(zone) + balance_gap,
 					end_zone, 0)) {
 				shrink_zone(priority, zone, &sc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
