Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9E1D6B0253
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 08:23:15 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id c80so177142403iod.4
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 05:23:15 -0800 (PST)
Received: from smtpbg123.qq.com (smtpbg123.qq.com. [183.60.2.34])
        by mx.google.com with SMTP id 30si15950775pla.317.2017.01.31.05.23.14
        for <linux-mm@kvack.org>;
        Tue, 31 Jan 2017 05:23:15 -0800 (PST)
From: ysxie@foxmail.com
Subject: [PATCH v5 1/4] mm/migration: make isolate_movable_page() return int type
Date: Tue, 31 Jan 2017 21:06:18 +0800
Message-Id: <1485867981-16037-2-git-send-email-ysxie@foxmail.com>
In-Reply-To: <1485867981-16037-1-git-send-email-ysxie@foxmail.com>
References: <1485867981-16037-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, arbab@linux.vnet.ibm.com, vkuznets@redhat.com, ak@linux.intel.com, guohanjun@huawei.com, qiuxishi@huawei.com

From: Yisheng Xie <xieyisheng1@huawei.com>

This patch changes the return type of isolate_movable_page()
from bool to int. It will return 0 when isolate movable page
successfully, return -EINVAL when the page is not a non-lru movable
page, and for other cases it will return -EBUSY.

There is no functional change within this patch but prepare
for later patch.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
CC: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/migrate.h |  2 +-
 mm/compaction.c         |  2 +-
 mm/migrate.c            | 11 +++++++----
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ae8d475..43d5deb 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -37,7 +37,7 @@ extern int migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
 		unsigned long private, enum migrate_mode mode, int reason);
-extern bool isolate_movable_page(struct page *page, isolate_mode_t mode);
+extern int isolate_movable_page(struct page *page, isolate_mode_t mode);
 extern void putback_movable_page(struct page *page);
 
 extern int migrate_prep(void);
diff --git a/mm/compaction.c b/mm/compaction.c
index 949198d..1d89147 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -802,7 +802,7 @@ static bool too_many_isolated(struct zone *zone)
 					locked = false;
 				}
 
-				if (isolate_movable_page(page, isolate_mode))
+				if (!isolate_movable_page(page, isolate_mode))
 					goto isolate_success;
 			}
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 87f4d0f..bbbd170 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -74,8 +74,9 @@ int migrate_prep_local(void)
 	return 0;
 }
 
-bool isolate_movable_page(struct page *page, isolate_mode_t mode)
+int isolate_movable_page(struct page *page, isolate_mode_t mode)
 {
+	int ret = -EBUSY;
 	struct address_space *mapping;
 
 	/*
@@ -95,8 +96,10 @@ bool isolate_movable_page(struct page *page, isolate_mode_t mode)
 	 * assumes anybody doesn't touch PG_lock of newly allocated page
 	 * so unconditionally grapping the lock ruins page's owner side.
 	 */
-	if (unlikely(!__PageMovable(page)))
+	if (unlikely(!__PageMovable(page))) {
+		ret = -EINVAL;
 		goto out_putpage;
+	}
 	/*
 	 * As movable pages are not isolated from LRU lists, concurrent
 	 * compaction threads can race against page migration functions
@@ -125,14 +128,14 @@ bool isolate_movable_page(struct page *page, isolate_mode_t mode)
 	__SetPageIsolated(page);
 	unlock_page(page);
 
-	return true;
+	return 0;
 
 out_no_isolated:
 	unlock_page(page);
 out_putpage:
 	put_page(page);
 out:
-	return false;
+	return ret;
 }
 
 /* It should be called on page which is PG_movable */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
