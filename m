Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19F066B053E
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:41:34 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id j32so14450506iod.15
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:34 -0700 (PDT)
Received: from mail-io0-f194.google.com (mail-io0-f194.google.com. [209.85.223.194])
        by mx.google.com with ESMTPS id 66si1527421itk.4.2017.08.01.05.41.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 05:41:33 -0700 (PDT)
Received: by mail-io0-f194.google.com with SMTP id f1so1452759ioj.2
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:33 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/6] mm, memory_hotplug: cleanup memory offline path
Date: Tue,  1 Aug 2017 14:41:06 +0200
Message-Id: <20170801124111.28881-2-mhocko@kernel.org>
In-Reply-To: <20170801124111.28881-1-mhocko@kernel.org>
References: <20170801124111.28881-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

check_pages_isolated_cb currently accounts the whole pfn range as being
offlined if test_pages_isolated suceeds on the range. This is based on
the assumption that all pages in the range are freed which is currently
the case in most cases but it won't be with later changes. I haven't
double checked but if the range contains invalid pfns we could
theoretically over account and underflow zone's managed pages.

Move the offlined pages counting to offline_isolated_pages_cb and
rely on __offline_isolated_pages to return the correct value.
check_pages_isolated_cb will still do it's primary job and check the pfn
range.

While we are at it remove check_pages_isolated and offline_isolated_pages
and use directly walk_system_ram_range as do in online_pages.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/memory_hotplug.h |  2 +-
 mm/memory_hotplug.c            | 43 ++++++++++--------------------------------
 mm/page_alloc.c                | 11 +++++++++--
 3 files changed, 20 insertions(+), 36 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 5e6e4cc36ff4..f64321b35e88 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -101,7 +101,7 @@ extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
 extern int online_pages(unsigned long, unsigned long, int);
 extern int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long *valid_start, unsigned long *valid_end);
-extern void __offline_isolated_pages(unsigned long, unsigned long);
+extern unsigned long __offline_isolated_pages(unsigned long, unsigned long);
 
 typedef void (*online_page_callback_t)(struct page *page);
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1de2f132bca3..8031cc41bc5c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1444,17 +1444,12 @@ static int
 offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
 			void *data)
 {
-	__offline_isolated_pages(start, start + nr_pages);
+	unsigned long offlined_pages;
+	offlined_pages = __offline_isolated_pages(start, start + nr_pages);
+	*(unsigned long *)data += offlined_pages;
 	return 0;
 }
 
-static void
-offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
-{
-	walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
-				offline_isolated_pages_cb);
-}
-
 /*
  * Check all pages in range, recoreded as memory resource, are isolated.
  */
@@ -1462,26 +1457,7 @@ static int
 check_pages_isolated_cb(unsigned long start_pfn, unsigned long nr_pages,
 			void *data)
 {
-	int ret;
-	long offlined = *(long *)data;
-	ret = test_pages_isolated(start_pfn, start_pfn + nr_pages, true);
-	offlined = nr_pages;
-	if (!ret)
-		*(long *)data += offlined;
-	return ret;
-}
-
-static long
-check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
-{
-	long offlined = 0;
-	int ret;
-
-	ret = walk_system_ram_range(start_pfn, end_pfn - start_pfn, &offlined,
-			check_pages_isolated_cb);
-	if (ret < 0)
-		offlined = (long)ret;
-	return offlined;
+	return test_pages_isolated(start_pfn, start_pfn + nr_pages, true);
 }
 
 static int __init cmdline_parse_movable_node(char *p)
@@ -1590,7 +1566,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		  unsigned long end_pfn, unsigned long timeout)
 {
 	unsigned long pfn, nr_pages, expire;
-	long offlined_pages;
+	unsigned long offlined_pages = 0;
 	int ret, drain, retry_max, node;
 	unsigned long flags;
 	unsigned long valid_start, valid_end;
@@ -1673,15 +1649,16 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	if (ret)
 		goto failed_removal;
 	/* check again */
-	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
-	if (offlined_pages < 0) {
+	if (walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
+			check_pages_isolated_cb)) {
 		ret = -EBUSY;
 		goto failed_removal;
 	}
-	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
-	offline_isolated_pages(start_pfn, end_pfn);
+	walk_system_ram_range(start_pfn, end_pfn - start_pfn, &offlined_pages,
+				offline_isolated_pages_cb);
+	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/* reset pagetype flags and makes migrate type to be MOVABLE */
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 	/* removal success */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index af224632c779..f4e5db85ebfc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7612,7 +7612,7 @@ void zone_pcp_reset(struct zone *zone)
  * All pages in the range must be in a single zone and isolated
  * before calling this.
  */
-void
+unsigned long
 __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 {
 	struct page *page;
@@ -7620,12 +7620,15 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	unsigned int order, i;
 	unsigned long pfn;
 	unsigned long flags;
+	unsigned long offlined_pages = 0;
+
 	/* find the first valid pfn */
 	for (pfn = start_pfn; pfn < end_pfn; pfn++)
 		if (pfn_valid(pfn))
 			break;
 	if (pfn == end_pfn)
-		return;
+		return offlined_pages;
+
 	offline_mem_sections(pfn, end_pfn);
 	zone = page_zone(pfn_to_page(pfn));
 	spin_lock_irqsave(&zone->lock, flags);
@@ -7643,12 +7646,14 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		if (unlikely(!PageBuddy(page) && PageHWPoison(page))) {
 			pfn++;
 			SetPageReserved(page);
+			offlined_pages++;
 			continue;
 		}
 
 		BUG_ON(page_count(page));
 		BUG_ON(!PageBuddy(page));
 		order = page_order(page);
+		offlined_pages += 1 << order;
 #ifdef CONFIG_DEBUG_VM
 		pr_info("remove from free list %lx %d %lx\n",
 			pfn, 1 << order, end_pfn);
@@ -7661,6 +7666,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		pfn += (1 << order);
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
+
+	return offlined_pages;
 }
 #endif
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
