Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACBB8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 05:27:21 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s11-v6so788253pgv.9
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 02:27:21 -0700 (PDT)
Received: from alexa-out-blr-01.qualcomm.com (alexa-out-blr-01.qualcomm.com. [103.229.18.197])
        by mx.google.com with ESMTPS id k4-v6si469773pfc.328.2018.09.12.02.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 02:27:19 -0700 (PDT)
From: Arun KS <arunks@codeaurora.org>
Subject: [RFC] memory_hotplug: Free pages as pageblock_order
Date: Wed, 12 Sep 2018 14:56:45 +0530
Message-Id: <1536744405-16752-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, iamjoonsoo.kim@lge.com, osalvador@suse.de, arunks@codeaurora.org, malat@debian.org, gregkh@linuxfoundation.org, yasu.isimatu@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: arunks.linux@gmail.com, vinmenon@codeaurora.org

When free pages are done with pageblock_order, time spend on
coalescing pages by buddy allocator can be reduced. With
section size of 256MB, hot add latency of a single section
shows improvement from 50-60 ms to less than 1 ms, hence
improving the hot add latency by 60%.

If this looks okey, I'll modify users of set_online_page_callback
and resend clean patch.

Signed-off-by: Arun KS <arunks@codeaurora.org>
---
 include/linux/memory_hotplug.h |  1 +
 mm/memory_hotplug.c            | 52 ++++++++++++++++++++++++++++++++++++------
 2 files changed, 46 insertions(+), 7 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 34a2822..447047d 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -88,6 +88,7 @@ extern int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 extern void __offline_isolated_pages(unsigned long, unsigned long);
 
 typedef void (*online_page_callback_t)(struct page *page);
+typedef int (*online_pages_callback_t)(struct page *page, unsigned int order);
 
 extern int set_online_page_callback(online_page_callback_t callback);
 extern int restore_online_page_callback(online_page_callback_t callback);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 38d94b7..853104d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -662,19 +662,57 @@ static void generic_online_page(struct page *page)
 	__online_page_free(page);
 }
 
+static int generic_online_pages(struct page *page, unsigned int order);
+static online_pages_callback_t online_pages_callback = generic_online_pages;
+
+static int generic_online_pages(struct page *page, unsigned int order)
+{
+	unsigned long nr_pages = 1 << order;
+	struct page *p = page;
+	unsigned int loop;
+
+	for (loop = 0 ; loop < nr_pages ; loop++, p++) {
+		__ClearPageReserved(p);
+		set_page_count(p, 0);
+	}
+	adjust_managed_page_count(page, nr_pages);
+	init_page_count(page);
+	__free_pages(page, order);
+
+	return 0;
+}
+
+static int online_pages_blocks(unsigned long start_pfn, unsigned long nr_pages)
+{
+	unsigned long pages_per_block = (1 << pageblock_order);
+	unsigned long nr_pageblocks = nr_pages / pages_per_block;
+//	unsigned long rem_pages = nr_pages % pages_per_block;
+	int i, ret, onlined_pages = 0;
+	struct page *page;
+
+	for (i = 0 ; i < nr_pageblocks ; i++) {
+		page = pfn_to_page(start_pfn + (i * pages_per_block));
+		ret = (*online_pages_callback)(page, pageblock_order);
+		if (!ret)
+			onlined_pages += pages_per_block;
+		else if (ret > 0)
+			onlined_pages += ret;
+	}
+/*
+	if (rem_pages)
+		onlined_pages += online_page_single(start_pfn + i, rem_pages);
+*/
+
+	return onlined_pages;
+}
+
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 			void *arg)
 {
-	unsigned long i;
 	unsigned long onlined_pages = *(unsigned long *)arg;
-	struct page *page;
 
 	if (PageReserved(pfn_to_page(start_pfn)))
-		for (i = 0; i < nr_pages; i++) {
-			page = pfn_to_page(start_pfn + i);
-			(*online_page_callback)(page);
-			onlined_pages++;
-		}
+		onlined_pages = online_pages_blocks(start_pfn, nr_pages);
 
 	online_mem_sections(start_pfn, start_pfn + nr_pages);
 
-- 
1.9.1
