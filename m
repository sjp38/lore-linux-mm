Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A14F66B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 23:04:34 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o138so5092234ito.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 20:04:34 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id u188si532573itd.92.2017.01.17.20.04.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 20:04:33 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [RFC] HWPOISON: soft offlining for non-lru movable page
Date: Wed, 18 Jan 2017 12:00:54 +0800
Message-ID: <1484712054-7997-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

This patch is to extends soft offlining framework to support
non-lru page, which already support migration after
commit bda807d44454 ("mm: migrate: support non-lru movable page
migration")

When memory corrected errors occur on a non-lru movable page,
we can choose to stop using it by migrating data onto another
page and disable the original (maybe half-broken) one.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/memory-failure.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 53 insertions(+), 2 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index f283c7e..10043a4 100644
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
@@ -1549,6 +1550,54 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
 	return ret;
 }
 
+static int soft_offline_movable_page(struct page *page, int flags)
+{
+	int ret;
+	unsigned long pfn = page_to_pfn(page);
+	LIST_HEAD(pagelist);
+
+	/*
+	 * This double-check of PageHWPoison is to avoid the race with
+	 * memory_failure(). See also comment in __soft_offline_page().
+	 */
+	lock_page(page);
+	if (PageHWPoison(page)) {
+		unlock_page(page);
+		put_hwpoison_page(page);
+		pr_info("soft offline: %#lx movable page already poisoned\n",
+			pfn);
+		return -EBUSY;
+	}
+	unlock_page(page);
+
+	ret = isolate_movable_page(page, ISOLATE_UNEVICTABLE);
+	/*
+	 * get_any_page() and isolate_movable_page() takes a refcount each,
+	 * so need to drop one here.
+	 */
+	put_hwpoison_page(page);
+	if (!ret) {
+		pr_info("soft offline: %#lx movable page failed to isolate\n",
+			pfn);
+		return -EBUSY;
+	}
+
+	list_add(&page->lru, &pagelist);
+	ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
+			    MIGRATE_SYNC, MR_MEMORY_FAILURE);
+	if (ret) {
+		if (!list_empty(&pagelist))
+			putback_movable_pages(&pagelist);
+
+		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
+			pfn, ret, page->flags);
+		if (ret > 0)
+			ret = -EIO;
+	}
+
+	return ret;
+}
+
 static int soft_offline_huge_page(struct page *page, int flags)
 {
 	int ret;
@@ -1705,8 +1754,10 @@ static int soft_offline_in_use_page(struct page *page, int flags)
 
 	if (PageHuge(page))
 		ret = soft_offline_huge_page(page, flags);
-	else
+	else if (PageLRU(page))
 		ret = __soft_offline_page(page, flags);
+	else
+		ret = soft_offline_movable_page(page, flags);
 
 	return ret;
 }
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
