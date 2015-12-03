Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3826B0255
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 23:11:50 -0500 (EST)
Received: by padhx2 with SMTP id hx2so59516759pad.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 20:11:50 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id g73si9139519pfd.168.2015.12.02.20.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 20:11:49 -0800 (PST)
Received: by padhx2 with SMTP id hx2so59516607pad.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 20:11:49 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] mm/compaction: restore COMPACT_CLUSTER_MAX to 32
Date: Thu,  3 Dec 2015 13:11:40 +0900
Message-Id: <1449115900-20112-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Until now, COMPACT_CLUSTER_MAX is defined as SWAP_CLUSTER_MAX.
Commit ("mm: increase SWAP_CLUSTER_MAX to batch TLB flushes")
changes SWAP_CLUSTER_MAX from 32 to 256 to improve tlb flush performance
so COMPACT_CLUSTER_MAX is also changed to 256. But, it has
no justification on compaction-side and I think that loss is more than
benefit.

One example is that migration scanner would isolates and migrates
too many pages unnecessarily with 256 COMPACT_CLUSTER_MAX. It may be
enough to migrate 4 pages in order to make order-2 page, but, now,
compaction will migrate 256 pages.

To reduce this unneeded overhead, this patch restores
COMPACT_CLUSTER_MAX to 32.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/swap.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d08feef..31eb343 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -155,7 +155,7 @@ enum {
 };
 
 #define SWAP_CLUSTER_MAX 256UL
-#define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
+#define COMPACT_CLUSTER_MAX 32UL
 
 /*
  * Ratio between zone->managed_pages and the "gap" that above the per-zone
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
