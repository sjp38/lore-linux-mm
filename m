Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ABA506B0047
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 17:11:05 -0500 (EST)
From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Subject: [PATCH RFC] bootmem: micro optimize freeing pages in bulks
Date: Thu,  1 Dec 2011 23:10:55 +0100
Message-Id: <1322777455-32315-1-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Johannes Weiner <hannes@saeurebad.de>, Andrew Morton <akpm@linux-foundation.org>

The first entry of bdata->node_bootmem_map holds the data for
bdata->node_min_pfn up to bdata->node_min_pfn + BITS_PER_LONG - 1. So
the test for freeing all pages of a single map entry can be slightly
relaxed.

Moreover use DIV_ROUND_UP in another place instead of open coding it.

Cc: Johannes Weiner <hannes@saeurebad.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
---
Hello,

I'm not sure the current code is correct (and my patch doesn't fix it):

If

	aligned && vec == ~0UL

evalutates to true, but

	start + BITS_PER_LONG <= end

does not (or "< end" resp.) the else branch still frees all BITS_PER_LONG
pages. Is this intended? If yes, the last check can better be omitted
resulting in the pages being freed in a bulk.
If not, the loop in the else branch should only do something like:

	while (vec && off < min(BITS_PER_LONG, end - start)) {
		...

Having said that please note that I just started today to look into mm/
so please take my analysis with a grain of salt.

Best regards
Uwe

 mm/bootmem.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index fc22150..1e7d791 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -56,7 +56,7 @@ early_param("bootmem_debug", bootmem_debug_setup);
 
 static unsigned long __init bootmap_bytes(unsigned long pages)
 {
-	unsigned long bytes = (pages + 7) / 8;
+	unsigned long bytes = DIV_ROUND_UP(pages, 8);
 
 	return ALIGN(bytes, sizeof(long));
 }
@@ -197,7 +197,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 		idx = start - bdata->node_min_pfn;
 		vec = ~map[idx / BITS_PER_LONG];
 
-		if (aligned && vec == ~0UL && start + BITS_PER_LONG < end) {
+		if (aligned && vec == ~0UL && start + BITS_PER_LONG <= end) {
 			int order = ilog2(BITS_PER_LONG);
 
 			__free_pages_bootmem(pfn_to_page(start), order);
-- 
1.7.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
