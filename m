Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DEB16B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:05:53 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id w107so157951833ota.6
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 07:05:53 -0800 (PST)
Received: from smtpbgau2.qq.com (smtpbgau2.qq.com. [54.206.34.216])
        by mx.google.com with ESMTPS id e48si9042685ote.335.2017.01.25.07.05.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 07:05:52 -0800 (PST)
From: ysxie@foxmail.com
Subject: [PATCH v4 2/2] HWPOISON: soft offlining for non-lru movable page
Date: Wed, 25 Jan 2017 23:05:38 +0800
Message-Id: <1485356738-4831-3-git-send-email-ysxie@foxmail.com>
In-Reply-To: <1485356738-4831-1-git-send-email-ysxie@foxmail.com>
References: <1485356738-4831-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

From: Yisheng Xie <xieyisheng1@huawei.com>

This patch is to extends soft offlining framework to support
non-lru page, which already support migration after
commit bda807d44454 ("mm: migrate: support non-lru movable page
migration")

When memory corrected errors occur on a non-lru movable page,
we can choose to stop using it by migrating data onto another
page and disable the original (maybe half-broken) one.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Suggested-by: Minchan Kim <minchan@kernel.org>
Reviewed-by: Minchan Kim <minchan@kernel.org>
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
CC: Vlastimil Babka <vbabka@suse.cz>
---
 mm/memory-failure.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index f283c7e..56e39f8 100644
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
+	else if (!isolate_movable_page(page, ISOLATE_UNEVICTABLE))
+		ret = -EBUSY;
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
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
