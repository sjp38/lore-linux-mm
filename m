Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2E76B6B0035
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 00:24:59 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id x13so4093274ief.9
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 21:24:59 -0700 (PDT)
Received: from psmtp.com ([74.125.245.173])
        by mx.google.com with SMTP id je4si1388704icb.100.2013.10.30.21.24.57
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 21:24:58 -0700 (PDT)
Received: by mail-ea0-f180.google.com with SMTP id l9so915066eaj.11
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 21:24:55 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH] mm: __rmqueue_fallback() should respect pageblock type
Date: Thu, 31 Oct 2013 00:24:49 -0400
Message-Id: <1383193489-27331-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

When __rmqueue_fallback() don't find out a free block with the same size
of required, it splits a larger page and puts back rest peiece of the page
to free list.

But it has one serious mistake. When putting back, __rmqueue_fallback()
always use start_migratetype if type is not CMA. However, __rmqueue_fallback()
is only called when all of start_migratetype queue are empty. That said,
__rmqueue_fallback always put back memory to wrong queue except
try_to_steal_freepages() changed pageblock type (i.e. requested size is
smaller than half of page block). Finally, antifragmentation framework
increase fragmenation instead of decrease.

Mel's original anti fragmentation do the right thing. But commit 47118af076
(mm: mmzone: MIGRATE_CMA migration type added) broke it.

This patch restores sane and old behavior.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd886fa..ea7bb9a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1101,7 +1101,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			 */
 			expand(zone, page, order, current_order, area,
 			       is_migrate_cma(migratetype)
-			     ? migratetype : start_migratetype);
+			     ? migratetype : new_type);
 
 			trace_mm_page_alloc_extfrag(page, order,
 				current_order, start_migratetype, migratetype,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
