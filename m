Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 99F76900002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:03 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part3 PATCH v2 2/4] mem-hotplug: Skip LOCAL_NODE_DATA pages in memory offline procedure.
Date: Thu, 13 Jun 2013 21:03:54 +0800
Message-Id: <1371128636-9027-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

In memory offline procedure, skip pages marked as LOCAL_NODE_DATA.
For now, this kind of pages are used to store local node pagetables.

The minimum unit of memory online/offline is a memory block. In a
block, the movable pages will be offlined as usual (unmapped and
isolated), and the pagetable pages will be skipped. After the iteration
of all page, the block will be set as offline, but the kernel can
still access the pagetable pages. This is user transparent.

v1 -> v2: As suggested by Wu Jianguo <wujianguo@huawei.com>, define a
	  macro to check if a page contains local node data.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/memory_hotplug.h |    7 ++++++-
 mm/page_alloc.c                |   15 +++++++++++++--
 mm/page_isolation.c            |    5 +++++
 3 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index c0c4107..05de193 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -5,8 +5,8 @@
 #include <linux/spinlock.h>
 #include <linux/notifier.h>
 #include <linux/bug.h>
+#include <linux/mm_types.h>
 
-struct page;
 struct zone;
 struct pglist_data;
 struct mem_section;
@@ -31,6 +31,11 @@ enum {
 	MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE = LOCAL_NODE_DATA,
 };
 
+static inline bool is_local_node_data(struct page *page)
+{
+	return (unsigned long)page->lru.next == LOCAL_NODE_DATA;
+}
+
 /* Types for control the zone type of onlined memory */
 enum {
 	ONLINE_KEEP,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a5325b2..7cd8f13 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5772,6 +5772,11 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 			continue;
 
 		page = pfn_to_page(check);
+
+		/* Skip pages storing local node kernel data. */
+		if (is_local_node_data(page))
+			continue;
+
 		/*
 		 * We can't use page_count without pin a page
 		 * because another CPU can free compound page.
@@ -6095,8 +6100,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	struct page *page;
 	struct zone *zone;
 	int order, i;
-	unsigned long pfn;
-	unsigned long flags;
+	unsigned long pfn, flags;
 	/* find the first valid pfn */
 	for (pfn = start_pfn; pfn < end_pfn; pfn++)
 		if (pfn_valid(pfn))
@@ -6112,6 +6116,13 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			continue;
 		}
 		page = pfn_to_page(pfn);
+
+		/* Skip pages storing local node kernel data. */
+		if (is_local_node_data(page)) {
+			pfn++;
+			continue;
+		}
+
 		/*
 		 * The HWPoisoned page may be not in buddy system, and
 		 * page_count() is not 0.
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 383bdbb..4cb0ccb 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -6,6 +6,7 @@
 #include <linux/page-isolation.h>
 #include <linux/pageblock-flags.h>
 #include <linux/memory.h>
+#include <linux/memory_hotplug.h>
 #include "internal.h"
 
 int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
@@ -181,6 +182,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			continue;
 		}
 		page = pfn_to_page(pfn);
+
 		if (PageBuddy(page)) {
 			/*
 			 * If race between isolatation and allocation happens,
@@ -208,6 +210,9 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			 */
 			pfn++;
 			continue;
+		} else if (is_local_node_data(page)) {
+			pfn++;
+			continue;
 		}
 		else
 			break;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
