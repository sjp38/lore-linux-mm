Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 912D56B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 08:41:25 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id c80so141951209iod.4
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 05:41:25 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id f5si19287495ioa.4.2017.01.16.05.41.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 05:41:25 -0800 (PST)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: respect pre-allocated storage mapping for memmap
Date: Mon, 16 Jan 2017 21:38:05 +0800
Message-ID: <1484573885-54353-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com, hannes@cmpxchg.org, mhocko@suse.com
Cc: linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

At present, we skip the reservation storage by the driver for
the zone_dvice. but the free pages set aside for the memmap is
ignored. And since the free pages is only used as the memmap,
so we can also skip the corresponding pages.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d604d25..51d8d03 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5047,7 +5047,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	 * memory
 	 */
 	if (altmap && start_pfn == altmap->base_pfn)
-		start_pfn += altmap->reserve;
+		start_pfn += vmem_altmap_offset(altmap);
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
