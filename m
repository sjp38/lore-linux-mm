Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 047696B0005
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 23:51:41 -0400 (EDT)
Received: by mail-oi0-f52.google.com with SMTP id d205so45892284oia.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 20:51:41 -0700 (PDT)
Received: from mail-ig0-x244.google.com (mail-ig0-x244.google.com. [2607:f8b0:4001:c05::244])
        by mx.google.com with ESMTPS id u5si2617163obd.73.2016.03.23.20.51.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 20:51:40 -0700 (PDT)
Received: by mail-ig0-x244.google.com with SMTP id ww10so697601igb.2
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 20:51:40 -0700 (PDT)
From: Li Zhang <zhlcindy@gmail.com>
Subject: [PATCH 1/1] mm/page_alloc: Remove useless parameter of __free_pages_boot_core
Date: Thu, 24 Mar 2016 11:51:20 +0800
Message-Id: <1458791480-20324-1-git-send-email-zhlcindy@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@techsingularity.net, vbabka@suse.cz, to=akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

From: Li Zhang <zhlcindy@linux.vnet.ibm.com>

__free_pages_boot_core has parameter pfn which is not used at all.
So this patch is to make it clean.

Signed-off-by: Li Zhang <zhlcindy@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a762be5..8c0affe 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1056,8 +1056,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
-static void __init __free_pages_boot_core(struct page *page,
-					unsigned long pfn, unsigned int order)
+static void __init __free_pages_boot_core(struct page *page, unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
 	struct page *p = page;
@@ -1134,7 +1133,7 @@ void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
 {
 	if (early_page_uninitialised(pfn))
 		return;
-	return __free_pages_boot_core(page, pfn, order);
+	return __free_pages_boot_core(page, order);
 }
 
 /*
@@ -1219,12 +1218,12 @@ static void __init deferred_free_range(struct page *page,
 	if (nr_pages == MAX_ORDER_NR_PAGES &&
 	    (pfn & (MAX_ORDER_NR_PAGES-1)) == 0) {
 		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-		__free_pages_boot_core(page, pfn, MAX_ORDER-1);
+		__free_pages_boot_core(page, MAX_ORDER-1);
 		return;
 	}
 
-	for (i = 0; i < nr_pages; i++, page++, pfn++)
-		__free_pages_boot_core(page, pfn, 0);
+	for (i = 0; i < nr_pages; i++, page++)
+		__free_pages_boot_core(page, 0);
 }
 
 /* Completion tracking for deferred_init_memmap() threads */
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
