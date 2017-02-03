Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8C06B0268
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 03:04:59 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r141so2012432wmg.4
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 00:04:59 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id 91si31672461wrj.85.2017.02.03.00.04.56
        for <linux-mm@kvack.org>;
        Fri, 03 Feb 2017 00:04:58 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v6 4/4] mm/hotplug: enable memory hotplug for non-lru movable pages
Date: Fri, 3 Feb 2017 15:59:30 +0800
Message-ID: <1486108770-630-5-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1486108770-630-1-git-send-email-xieyisheng1@huawei.com>
References: <1486108770-630-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: mhocko@kernel.org, minchan@kernel.org, ak@linux.intel.com, guohanjun@huawei.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, arbab@linux.vnet.ibm.com, izumi.taku@jp.fujitsu.com, vkuznets@redhat.com, vbabka@suse.cz, qiuxishi@huawei.com

We had considered all of the non-lru pages as unmovable before commit
bda807d44454 ("mm: migrate: support non-lru movable page migration").  But
now some of non-lru pages like zsmalloc, virtio-balloon pages also become
movable.  So we can offline such blocks by using non-lru page migration.

This patch straightforwardly adds non-lru migration code, which means
adding non-lru related code to the functions which scan over pfn and
collect pages to be migrated and isolate them before migration.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Hanjun Guo <guohanjun@huawei.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c | 28 +++++++++++++++++-----------
 mm/page_alloc.c     |  8 ++++++--
 2 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ca2723d..ea1be08 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1516,10 +1516,10 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
 }
 
 /*
- * Scan pfn range [start,end) to find movable/migratable pages (LRU pages
- * and hugepages). We scan pfn because it's much easier than scanning over
- * linked list. This function returns the pfn of the first found movable
- * page if it's found, otherwise 0.
+ * Scan pfn range [start,end) to find movable/migratable pages (LRU pages,
+ * non-lru movable pages and hugepages). We scan pfn because it's much
+ * easier than scanning over linked list. This function returns the pfn
+ * of the first found movable page if it's found, otherwise 0.
  */
 static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 {
@@ -1530,6 +1530,8 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 			page = pfn_to_page(pfn);
 			if (PageLRU(page))
 				return pfn;
+			if (__PageMovable(page))
+				return pfn;
 			if (PageHuge(page)) {
 				if (page_huge_active(page))
 					return pfn;
@@ -1606,21 +1608,25 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 		if (!get_page_unless_zero(page))
 			continue;
 		/*
-		 * We can skip free pages. And we can only deal with pages on
-		 * LRU.
+		 * We can skip free pages. And we can deal with pages on
+		 * LRU and non-lru movable pages.
 		 */
-		ret = isolate_lru_page(page);
+		if (PageLRU(page))
+			ret = isolate_lru_page(page);
+		else
+			ret = isolate_movable_page(page, ISOLATE_UNEVICTABLE);
 		if (!ret) { /* Success */
 			put_page(page);
 			list_add_tail(&page->lru, &source);
 			move_pages--;
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
+			if (!__PageMovable(page))
+				inc_node_page_state(page, NR_ISOLATED_ANON +
+						    page_is_file_cache(page));
 
 		} else {
 #ifdef CONFIG_DEBUG_VM
-			pr_alert("removing pfn %lx from LRU failed\n", pfn);
-			dump_page(page, "failed to remove from LRU");
+			pr_alert("failed to isolate pfn %lx\n", pfn);
+			dump_page(page, "isolation failed");
 #endif
 			put_page(page);
 			/* Because we don't have big zone->lock. we should
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f3e0c69..9c4e229 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7081,8 +7081,9 @@ void *__init alloc_large_system_hash(const char *tablename,
  * If @count is not zero, it is okay to include less @count unmovable pages
  *
  * PageLRU check without isolation or lru_lock could race so that
- * MIGRATE_MOVABLE block might include unmovable pages. It means you can't
- * expect this function should be exact.
+ * MIGRATE_MOVABLE block might include unmovable pages. And __PageMovable
+ * check without lock_page also may miss some movable non-lru pages at
+ * race condition. So you can't expect this function should be exact.
  */
 bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 			 bool skip_hwpoisoned_pages)
@@ -7138,6 +7139,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		if (skip_hwpoisoned_pages && PageHWPoison(page))
 			continue;
 
+		if (__PageMovable(page))
+			continue;
+
 		if (!PageLRU(page))
 			found++;
 		/*
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
