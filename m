Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0629A6B0261
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 03:04:14 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id c7so2744025wjb.7
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 00:04:13 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id 77si1373585wmj.34.2017.02.03.00.04.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 00:04:12 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v6 3/4] HWPOISON: soft offlining for non-lru movable page
Date: Fri, 3 Feb 2017 15:59:29 +0800
Message-ID: <1486108770-630-4-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1486108770-630-1-git-send-email-xieyisheng1@huawei.com>
References: <1486108770-630-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: mhocko@kernel.org, minchan@kernel.org, ak@linux.intel.com, guohanjun@huawei.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, arbab@linux.vnet.ibm.com, izumi.taku@jp.fujitsu.com, vkuznets@redhat.com, vbabka@suse.cz, qiuxishi@huawei.com

Extend soft offlining framework to support non-lru page, which already
support migration after commit bda807d44454 ("mm: migrate: support non-lru
movable page migration")

When memory corrected errors occur on a non-lru movable page, we can
choose to stop using it by migrating data onto another page and disable
the original (maybe half-broken) one.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Suggested-by: Minchan Kim <minchan@kernel.org>
Reviewed-by: Minchan Kim <minchan@kernel.org>
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
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
 mm/memory-failure.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index f283c7e..3d0f2fd 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1527,7 +1527,8 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
 {
 	int ret = __get_any_page(page, pfn, flags);
 
-	if (ret == 1 && !PageHuge(page) && !PageLRU(page)) {
+	if (ret == 1 && !PageHuge(page) &&
+	    !PageLRU(page) && !__PageMovable(page)) {
 		/*
 		 * Try to free it.
 		 */
@@ -1649,7 +1650,10 @@ static int __soft_offline_page(struct page *page, int flags)
 	 * Try to migrate to a new page instead. migrate.c
 	 * handles a large number of cases for us.
 	 */
-	ret = isolate_lru_page(page);
+	if (PageLRU(page))
+		ret = isolate_lru_page(page);
+	else
+		ret = isolate_movable_page(page, ISOLATE_UNEVICTABLE);
 	/*
 	 * Drop page reference which is came from get_any_page()
 	 * successful isolate_lru_page() already took another one.
@@ -1657,18 +1661,20 @@ static int __soft_offline_page(struct page *page, int flags)
 	put_hwpoison_page(page);
 	if (!ret) {
 		LIST_HEAD(pagelist);
-		inc_node_page_state(page, NR_ISOLATED_ANON +
-					page_is_file_cache(page));
+		/*
+		 * After isolated lru page, the PageLRU will be cleared,
+		 * so use !__PageMovable instead for LRU page's mapping
+		 * cannot have PAGE_MAPPING_MOVABLE.
+		 */
+		if (!__PageMovable(page))
+			inc_node_page_state(page, NR_ISOLATED_ANON +
+						page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (ret) {
-			if (!list_empty(&pagelist)) {
-				list_del(&page->lru);
-				dec_node_page_state(page, NR_ISOLATED_ANON +
-						page_is_file_cache(page));
-				putback_lru_page(page);
-			}
+			if (!list_empty(&pagelist))
+				putback_movable_pages(&pagelist);
 
 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
 				pfn, ret, page->flags);
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
