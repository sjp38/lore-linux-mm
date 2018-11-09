Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C73D6B0688
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 21:28:07 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id q6so282492otk.4
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 18:28:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q24sor3608389otc.160.2018.11.08.18.28.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 18:28:06 -0800 (PST)
From: "Darryl T. Agostinelli" <dagostinelli@gmail.com>
Subject: [PATCH] Suppress the sparse warning ./include/linux/slab.h:332:43: warning: dubious: x & !y
Date: Thu,  8 Nov 2018 20:28:01 -0600
Message-Id: <20181109022801.29979-1-dagostinelli@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cl@linux.com, bvanassche@acm.org, akpm@linux-foundation.org, penberg@kernel.org, vbabka@suse.cz, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, "Darryl T. Agostinelli" <dagostinelli@gmail.com>

Signed-off-by: Darryl T. Agostinelli <dagostinelli@gmail.com>
---
 include/linux/slab.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 918f374e7156..883b7f56bf35 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -317,6 +317,7 @@ static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
 	int is_dma = 0;
 	int type_dma = 0;
 	int is_reclaimable;
+	int y;
 
 #ifdef CONFIG_ZONE_DMA
 	is_dma = !!(flags & __GFP_DMA);
@@ -329,7 +330,10 @@ static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
 	 * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
 	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
 	 */
-	return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
+
+	y = (is_reclaimable & (is_dma == 0 ? 1 : 0));
+
+	return type_dma + y * KMALLOC_RECLAIM;
 }
 
 /*
-- 
2.17.1
