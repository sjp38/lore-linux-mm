Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 277BE6B0068
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 22:50:49 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/3 v3] mm: bug fix free page check in zone_watermark_ok
Date: Thu, 12 Jul 2012 11:50:48 +0900
Message-Id: <1342061449-29590-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1342061449-29590-1-git-send-email-minchan@kernel.org>
References: <1342061449-29590-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar@ap.sony.com>, Minchan Kim <minchan@kernel.org>

In __zone_watermark_ok, free and min are signed long type
while z->lowmem_reserve[classzone_idx] is unsigned long type.
So comparision of them could be wrong due to type conversion
to unsigned although free_pages is minus value.

It could return true instead of false in case of order-0 check
so that kswapd could sleep forever. It means livelock because
direct reclaimer loops forever until kswapd set
zone->all_unreclaimable.

Aaditya reported this problem when he test my hotplug patch.

Reported-off-by: Aaditya Kumar <aaditya.kumar@ap.sony.com>
Tested-by: Aaditya Kumar <aaditya.kumar@ap.sony.com>
Signed-off-by: Aaditya Kumar <aaditya.kumar@ap.sony.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
This patch isn't dependent with this series.
It seems to be candidate for -stable but I'm not sure because of this part.
So, pass the decision to akpm.

" - It must fix a real bug that bothers people (not a, "This could be a
   problem..." type thing)."

 mm/page_alloc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f17e6e4..627653c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1594,6 +1594,7 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 {
 	/* free_pages my go negative - that's OK */
 	long min = mark;
+	long lowmem_reserve = z->lowmem_reserve[classzone_idx];
 	int o;
 
 	free_pages -= (1 << order) - 1;
@@ -1602,7 +1603,7 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
 
-	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
+	if (free_pages <= min + lowmem_reserve)
 		return false;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
