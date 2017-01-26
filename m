Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C06CC6B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 15:48:56 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id o185so52592419itb.6
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 12:48:56 -0800 (PST)
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com. [15.233.44.26])
        by mx.google.com with ESMTPS id c17si2870679ioa.167.2017.01.26.12.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 12:48:56 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 2/2] base/memory, hotplug: fix a kernel oops in show_valid_zones()
Date: Thu, 26 Jan 2017 14:44:15 -0700
Message-Id: <20170126214415.4509-3-toshi.kani@hpe.com>
In-Reply-To: <20170126214415.4509-1-toshi.kani@hpe.com>
References: <20170126214415.4509-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org
Cc: linux-mm@kvack.org, zhenzhang.zhang@huawei.com, arbab@linux.vnet.ibm.com, dan.j.williams@intel.com, abanman@sgi.com, rientjes@google.com, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

Reading a sysfs memoryN/valid_zones file leads to the following
oops when the first page of a range is not backed by struct page.
show_valid_zones() assumes that 'start_pfn' is always valid for
page_zone().

 BUG: unable to handle kernel paging request at ffffea017a000000
 IP: show_valid_zones+0x6f/0x160

Since test_pages_in_a_zone() already checks holes, extend this
function to return 'valid_start' and 'valid_end' for a given range.
show_valid_zones() then proceeds with the valid range.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 drivers/base/memory.c          |   12 ++++++------
 include/linux/memory_hotplug.h |    3 ++-
 mm/memory_hotplug.c            |   20 +++++++++++++++-----
 3 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 8ab8ea1..2c9aad9 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -389,33 +389,33 @@ static ssize_t show_valid_zones(struct device *dev,
 {
 	struct memory_block *mem = to_memory_block(dev);
 	unsigned long start_pfn, end_pfn;
+	unsigned long valid_start, valid_end, valid_pages;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
-	struct page *first_page;
 	struct zone *zone;
 	int zone_shift = 0;
 
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	end_pfn = start_pfn + nr_pages;
-	first_page = pfn_to_page(start_pfn);
 
 	/* The block contains more than one zone can not be offlined. */
-	if (!test_pages_in_a_zone(start_pfn, end_pfn))
+	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start, &valid_end))
 		return sprintf(buf, "none\n");
 
-	zone = page_zone(first_page);
+	zone = page_zone(pfn_to_page(valid_start));
+	valid_pages = valid_end - valid_start;
 
 	/* MMOP_ONLINE_KEEP */
 	sprintf(buf, "%s", zone->name);
 
 	/* MMOP_ONLINE_KERNEL */
-	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_NORMAL);
+	zone_shift = zone_can_shift(valid_start, valid_pages, ZONE_NORMAL);
 	if (zone_shift) {
 		strcat(buf, " ");
 		strcat(buf, (zone + zone_shift)->name);
 	}
 
 	/* MMOP_ONLINE_MOVABLE */
-	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_MOVABLE);
+	zone_shift = zone_can_shift(valid_start, valid_pages, ZONE_MOVABLE);
 	if (zone_shift) {
 		strcat(buf, " ");
 		strcat(buf, (zone + zone_shift)->name);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 01033fa..b6aa972 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -85,7 +85,8 @@ extern int zone_grow_waitqueues(struct zone *zone, unsigned long nr_pages);
 extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
 /* VM interface that may be used by firmware interface */
 extern int online_pages(unsigned long, unsigned long, int);
-extern int test_pages_in_a_zone(unsigned long, unsigned long);
+extern int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
+	unsigned long *valid_start, unsigned long *valid_end);
 extern void __offline_isolated_pages(unsigned long, unsigned long);
 
 typedef void (*online_page_callback_t)(struct page *page);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7836606..9de2f83 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1478,10 +1478,13 @@ bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 
 /*
  * Confirm all pages in a range [start, end) belong to the same zone.
+ * When true, return its valid [start, end).
  */
-int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
+int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
+			 unsigned long *valid_start, unsigned long *valid_end)
 {
 	unsigned long pfn, sec_end_pfn;
+	unsigned long start, end;
 	struct zone *zone = NULL;
 	struct page *page;
 	int i;
@@ -1503,14 +1506,20 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
 			page = pfn_to_page(pfn + i);
 			if (zone && page_zone(page) != zone)
 				return 0;
+			if (!zone)
+				start = pfn + i;
 			zone = page_zone(page);
+			end = pfn + MAX_ORDER_NR_PAGES;
 		}
 	}
 
-	if (zone)
+	if (zone) {
+		*valid_start = start;
+		*valid_end = end;
 		return 1;
-	else
+	} else {
 		return 0;
+	}
 }
 
 /*
@@ -1837,6 +1846,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	long offlined_pages;
 	int ret, drain, retry_max, node;
 	unsigned long flags;
+	unsigned long valid_start, valid_end;
 	struct zone *zone;
 	struct memory_notify arg;
 
@@ -1847,10 +1857,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		return -EINVAL;
 	/* This makes hotplug much easier...and readable.
 	   we assume this for now. .*/
-	if (!test_pages_in_a_zone(start_pfn, end_pfn))
+	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start, &valid_end))
 		return -EINVAL;
 
-	zone = page_zone(pfn_to_page(start_pfn));
+	zone = page_zone(pfn_to_page(valid_start));
 	node = zone_to_nid(zone);
 	nr_pages = end_pfn - start_pfn;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
