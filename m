Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AAFB1900240
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 10:45:04 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] mm: vmscan: Evaluate the watermarks against the correct classzone
Date: Fri, 24 Jun 2011 15:44:56 +0100
Message-Id: <1308926697-22475-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1308926697-22475-1-git-send-email-mgorman@suse.de>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?P=C3=A1draig=20Brady?= <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

When deciding if kswapd is sleeping prematurely, the classzone is
taken into account but this is different to what balance_pgdat() and
the allocator are doing. Specifically, the DMA zone will be checked
based on the classzone used when waking kswapd which could be for a
GFP_KERNEL or GFP_HIGHMEM request. The lowmem reserve limit kicks in,
the watermark is not met and kswapd thinks its sleeping prematurely
keeping kswapd awake in error.

Reported-and-tested-by: PA!draig Brady <P@draigBrady.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9cebed1..a76b6cc2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2341,7 +2341,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 		}
 
 		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
-							classzone_idx, 0))
+							i, 0))
 			all_zones_ok = false;
 		else
 			balanced += zone->present_pages;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
