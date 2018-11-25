Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0329E6B3ECB
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:55:40 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id ay11so19670413plb.20
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 15:55:39 -0800 (PST)
Received: from mxhk.zte.com.cn (mxhk.zte.com.cn. [63.217.80.70])
        by mx.google.com with ESMTPS id k189si2757709pgd.589.2018.11.25.15.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 15:55:38 -0800 (PST)
From: Yang Yang <yang.yang29@zte.com.cn>
Subject: [PATCH] mm: do not consider SWAP to calculate available when not necessary
Date: Mon, 26 Nov 2018 07:58:23 +0800
Message-Id: <1543190303-8121-1-git-send-email-yang.yang29@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn, wang.yi59@zte.com.cn, Yang Yang <yang.yang29@zte.com.cn>

When si_mem_available() calculates 'available', it takes SWAP
into account. But if CONFIG_SWAP is N or SWAP is off(some embedded system
would like to do that), there is no need to consider it.

Signed-off-by: Yang Yang <yang.yang29@zte.com.cn>
---
 mm/page_alloc.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6847177..10e186b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4700,6 +4700,7 @@ static inline void show_node(struct zone *zone)
 
 long si_mem_available(void)
 {
+	struct sysinfo i;
 	long available;
 	unsigned long pagecache;
 	unsigned long wmark_low = 0;
@@ -4708,6 +4709,7 @@ long si_mem_available(void)
 	struct zone *zone;
 	int lru;
 
+	si_swapinfo(&i);
 	for (lru = LRU_BASE; lru < NR_LRU_LISTS; lru++)
 		pages[lru] = global_node_page_state(NR_LRU_BASE + lru);
 
@@ -4724,9 +4726,13 @@ long si_mem_available(void)
 	 * Not all the page cache can be freed, otherwise the system will
 	 * start swapping. Assume at least half of the page cache, or the
 	 * low watermark worth of cache, needs to stay.
+	 * But if CONFIG_SWAP is N or SWAP is off, do not consider it.
 	 */
 	pagecache = pages[LRU_ACTIVE_FILE] + pages[LRU_INACTIVE_FILE];
-	pagecache -= min(pagecache / 2, wmark_low);
+#ifdef CONFIG_SWAP
+	if (i.totalswap > 0)
+		pagecache -= min(pagecache / 2, wmark_low);
+#endif
 	available += pagecache;
 
 	/*
-- 
2.15.2
