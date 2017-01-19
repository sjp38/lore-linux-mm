Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81A696B02AA
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 09:59:13 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id c7so9045528wjb.7
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 06:59:13 -0800 (PST)
Received: from smtpbguseast2.qq.com (smtpbguseast2.qq.com. [54.204.34.130])
        by mx.google.com with ESMTPS id m89si23852360wmh.34.2017.01.19.06.59.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 06:59:12 -0800 (PST)
From: ysxie@foxmail.com
Subject: [RFC v2] HWPOISON: soft offlining for non-lru movable page
Date: Thu, 19 Jan 2017 22:59:03 +0800
Message-Id: <1484837943-21745-1-git-send-email-ysxie@foxmail.com>
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
---
v2:
 delete function soft_offline_movable_page() and hanle non-lru movable
 page in __soft_offline_page() as Michal Hocko suggested.

Any comment is more than welcome.

 mm/memory-failure.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index f283c7e..74be9e1 100644
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
@@ -1609,7 +1610,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 
 static int __soft_offline_page(struct page *page, int flags)
 {
-	int ret;
+	int ret = -1;
 	unsigned long pfn = page_to_pfn(page);
 
 	/*
@@ -1619,7 +1620,8 @@ static int __soft_offline_page(struct page *page, int flags)
 	 * so there's no race between soft_offline_page() and memory_failure().
 	 */
 	lock_page(page);
-	wait_on_page_writeback(page);
+	if (PageLRU(page))
+		wait_on_page_writeback(page);
 	if (PageHWPoison(page)) {
 		unlock_page(page);
 		put_hwpoison_page(page);
@@ -1630,7 +1632,8 @@ static int __soft_offline_page(struct page *page, int flags)
 	 * Try to invalidate first. This should work for
 	 * non dirty unmapped page cache pages.
 	 */
-	ret = invalidate_inode_page(page);
+	if (PageLRU(page))
+		ret = invalidate_inode_page(page);
 	unlock_page(page);
 	/*
 	 * RED-PEN would be better to keep it isolated here, but we
@@ -1649,7 +1652,10 @@ static int __soft_offline_page(struct page *page, int flags)
 	 * Try to migrate to a new page instead. migrate.c
 	 * handles a large number of cases for us.
 	 */
-	ret = isolate_lru_page(page);
+	if (PageLRU(page))
+		ret = isolate_lru_page(page);
+	else
+		ret = !isolate_movable_page(page, ISOLATE_UNEVICTABLE);
 	/*
 	 * Drop page reference which is came from get_any_page()
 	 * successful isolate_lru_page() already took another one.
@@ -1657,18 +1663,15 @@ static int __soft_offline_page(struct page *page, int flags)
 	put_hwpoison_page(page);
 	if (!ret) {
 		LIST_HEAD(pagelist);
-		inc_node_page_state(page, NR_ISOLATED_ANON +
+		if (PageLRU(page))
+			inc_node_page_state(page, NR_ISOLATED_ANON +
 					page_is_file_cache(page));
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
