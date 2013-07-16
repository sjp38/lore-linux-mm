Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 66A506B003C
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 09:42:07 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 09/10] mm: zone_reclaim: after a successful zone_reclaim check the min watermark
Date: Tue, 16 Jul 2013 15:41:53 +0200
Message-Id: <1373982114-19774-10-git-send-email-aarcange@redhat.com>
In-Reply-To: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
References: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Hush Bensen <hush.bensen@gmail.com>

If we're in the fast path and we succeeded zone_reclaim(), it means we
freed enough memory and we can use the min watermark to have some
margin against concurrent allocations from other CPUs or interrupts.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/page_alloc.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0519181..3690c2e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1961,8 +1961,26 @@ zonelist_scan:
 			case ZONE_RECLAIM_FULL:
 				/* scanned but unreclaimable */
 				continue;
+			case ZONE_RECLAIM_SUCCESS:
+				/*
+				 * If we successfully reclaimed
+				 * enough, allow allocations up to the
+				 * min watermark (instead of stopping
+				 * at "mark"). This provides some more
+				 * margin against parallel
+				 * allocations. Using the min
+				 * watermark doesn't alter when we
+				 * wakeup kswapd. It also doesn't
+				 * alter the synchronous direct
+				 * reclaim behavior of zone_reclaim()
+				 * that will still be invoked at the
+				 * next pass if we're still below the
+				 * low watermark (even if kswapd isn't
+				 * woken).
+				 */
+				mark = min_wmark_pages(zone);
+				/* Fall through */
 			default:
-				/* did we reclaim enough */
 				if (zone_watermark_ok(zone, order, mark,
 						classzone_idx, alloc_flags))
 					goto try_this_zone;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
