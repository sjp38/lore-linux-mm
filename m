Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CAB26B0038
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 18:35:22 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 204so541277946pfx.1
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 15:35:22 -0800 (PST)
Received: from smtpbg.qq.com (SMTPBG353.QQ.COM. [183.57.50.164])
        by mx.google.com with SMTP id u84si12613457pgb.258.2017.01.31.15.35.20
        for <linux-mm@kvack.org>;
        Tue, 31 Jan 2017 15:35:21 -0800 (PST)
From: ysxie@foxmail.com
Subject: [PATCH v5 4/4] mm/hotplug: enable memory hotplug for non-lru movable pages
Date: Wed,  1 Feb 2017 07:28:43 +0800
Message-Id: <1485905323-2615-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, arbab@linux.vnet.ibm.com, vkuznets@redhat.com, ak@linux.intel.com, guohanjun@huawei.com, qiuxishi@huawei.com

From: Yisheng Xie <xieyisheng1@huawei.com>

We had considered all of the non-lru pages as unmovable before
commit bda807d44454 ("mm: migrate: support non-lru movable page
migration"). But now some of non-lru pages like zsmalloc,
virtio-balloon pages also become movable. So we can offline such
blocks by using non-lru page migration.

This patch straightforwardly add non-lru migration code, which
means adding non-lru related code to the functions which scan
over pfn and collect pages to be migrated and isolate them before
migration.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
CC: Vlastimil Babka <vbabka@suse.cz>
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
