Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 285688E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 05:37:46 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so9296773ede.19
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 02:37:46 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id f10-v6si3340651eja.11.2019.01.22.02.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 02:37:44 -0800 (PST)
From: Oscar Salvador <osalvador@suse.de>
Subject: [RFC PATCH v2 1/4] mm, memory_hotplug: cleanup memory offline path
Date: Tue, 22 Jan 2019 11:37:05 +0100
Message-Id: <20190122103708.11043-2-osalvador@suse.de>
In-Reply-To: <20190122103708.11043-1-osalvador@suse.de>
References: <20190122103708.11043-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, david@redhat.com, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Oscar Salvador <osalvador@suse.de>

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
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/memory_hotplug.h |  2 +-
 mm/memory_hotplug.c            | 45 +++++++++++-------------------------------
 mm/page_alloc.c                | 11 +++++++++--
 3 files changed, 22 insertions(+), 36 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index d56bfbacf7d6..1a230dde6027 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -85,7 +85,7 @@ extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
 extern int online_pages(unsigned long, unsigned long, int);
 extern int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long *valid_start, unsigned long *valid_end);
-extern void __offline_isolated_pages(unsigned long, unsigned long);
+extern unsigned long __offline_isolated_pages(unsigned long, unsigned long);
 
 typedef int (*online_page_callback_t)(struct page *page, unsigned int order);
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ec22c86d9f89..6efa44087b37 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1451,17 +1451,12 @@ static int
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
@@ -1469,26 +1464,7 @@ static int
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
@@ -1573,7 +1549,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		  unsigned long end_pfn)
 {
 	unsigned long pfn, nr_pages;
-	long offlined_pages;
+	unsigned long offlined_pages = 0;
 	int ret, node;
 	unsigned long flags;
 	unsigned long valid_start, valid_end;
@@ -1650,13 +1626,16 @@ static int __ref __offline_pages(unsigned long start_pfn,
 			goto failed_removal_isolated;
 		}
 		/* check again */
-		offlined_pages = check_pages_isolated(start_pfn, end_pfn);
-	} while (offlined_pages < 0);
+		ret = walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
+							check_pages_isolated_cb);
+	} while (ret);
 
-	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
-	offline_isolated_pages(start_pfn, end_pfn);
+	walk_system_ram_range(start_pfn, end_pfn - start_pfn, &offlined_pages,
+						offline_isolated_pages_cb);
+
+	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/* reset pagetype flags and makes migrate type to be MOVABLE */
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 	/* removal success */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d7a521971a05..cad7468a0f20 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8479,7 +8479,7 @@ void zone_pcp_reset(struct zone *zone)
  * All pages in the range must be in a single zone and isolated
  * before calling this.
  */
-void
+unsigned long
 __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 {
 	struct page *page;
@@ -8487,12 +8487,15 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
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
@@ -8510,12 +8513,14 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
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
@@ -8528,6 +8533,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		pfn += (1 << order);
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
+
+	return offlined_pages;
 }
 #endif
 
-- 
2.13.7
