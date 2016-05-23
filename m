Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 22CBC6B0005
	for <linux-mm@kvack.org>; Sun, 22 May 2016 23:29:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b124so1919413pfb.1
        for <linux-mm@kvack.org>; Sun, 22 May 2016 20:29:22 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id n5si48352023pfn.212.2016.05.22.20.29.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 May 2016 20:29:21 -0700 (PDT)
From: Chen Feng <puck.chen@hisilicon.com>
Subject: [PATCH] mm: compact: remove watermark check at compact suitable
Date: Mon, 23 May 2016 11:20:17 +0800
Message-ID: <1463973617-10599-1-git-send-email-puck.chen@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: puck.chen@hisilicon.com, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mina86@mina86.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: xuyiping@hisilicon.com, suzhuangluan@hisilicon.com, dan.zhao@hisilicon.com, qijiwen@hisilicon.com, oliver.fu@hisilicon.com, puck.chen@foxmail.com

There are two paths calling this function.
For direct compact, there is no need to check the zone watermark here.
For kswapd wakeup kcompactd, since there is a reclaim before this.
It makes sense to do compact even the watermark is ok at this time.

Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
---
 mm/compaction.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 8fa2540..cb322df 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1260,13 +1260,6 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
 		return COMPACT_CONTINUE;
 
 	watermark = low_wmark_pages(zone);
-	/*
-	 * If watermarks for high-order allocation are already met, there
-	 * should be no need for compaction at all.
-	 */
-	if (zone_watermark_ok(zone, order, watermark, classzone_idx,
-								alloc_flags))
-		return COMPACT_PARTIAL;
 
 	/*
 	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
