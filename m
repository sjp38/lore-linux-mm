Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCB2D6B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 22:36:45 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 101so5116882iom.7
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 19:36:45 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id b194si18587955iob.139.2017.01.24.19.36.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 19:36:44 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [RFC PATCH] mm/hotplug: enable memory hotplug for non-lru movable pages
Date: Wed, 25 Jan 2017 11:25:14 +0800
Message-ID: <1485314714-38251-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, arbab@linux.vnet.ibm.com, vkuznets@redhat.com, ak@linux.intel.com, n-horiguchi@ah.jp.nec.com, minchan@kernel.org, liwanp@linux.vnet.ibm.com, qiuxishi@huawei.com, guohanjun@huawei.com

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
---
 mm/memory_hotplug.c | 32 +++++++++++++++++++++-----------
 mm/page_alloc.c     |  8 ++++++--
 2 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e43142c1..fbdbffc 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1510,15 +1510,16 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
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
 	unsigned long pfn;
 	struct page *page;
+	bool movable;
 	for (pfn = start; pfn < end; pfn++) {
 		if (pfn_valid(pfn)) {
 			page = pfn_to_page(pfn);
@@ -1531,6 +1532,11 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 					pfn = round_up(pfn + 1,
 						1 << compound_order(page)) - 1;
 			}
+			lock_page(page);
+			movable = __PageMovable(page);
+			unlock_page(page);
+			if (movable)
+				return pfn;
 		}
 	}
 	return 0;
@@ -1600,21 +1606,25 @@ static struct page *new_node_page(struct page *page, unsigned long private,
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
+			ret = !isolate_movable_page(page, ISOLATE_UNEVICTABLE);
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
index d604d25..52d3067 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7055,8 +7055,9 @@ void *__init alloc_large_system_hash(const char *tablename,
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
@@ -7112,6 +7113,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
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
