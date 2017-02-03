Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C61506B0260
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 03:04:08 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id jz4so2756183wjb.5
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 00:04:08 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id 4si31644590wro.182.2017.02.03.00.04.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 00:04:06 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v6 1/4] mm/migration: make isolate_movable_page() return int type
Date: Fri, 3 Feb 2017 15:59:27 +0800
Message-ID: <1486108770-630-2-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1486108770-630-1-git-send-email-xieyisheng1@huawei.com>
References: <1486108770-630-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: mhocko@kernel.org, minchan@kernel.org, ak@linux.intel.com, guohanjun@huawei.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, arbab@linux.vnet.ibm.com, izumi.taku@jp.fujitsu.com, vkuznets@redhat.com, vbabka@suse.cz, qiuxishi@huawei.com

Change the return type of isolate_movable_page() from bool to int.  It
will return 0 when isolate movable page successfully, and return -EBUSY
when it isolates failed.

There is no functional change within this patch but prepare for later
patch.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Suggested-by: Minchan Kim <minchan@kernel.org>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Hanjun Guo <guohanjun@huawei.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/migrate.h | 2 +-
 mm/compaction.c         | 2 +-
 mm/migrate.c            | 6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

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
index 87f4d0f..6807174 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -74,7 +74,7 @@ int migrate_prep_local(void)
 	return 0;
 }
 
-bool isolate_movable_page(struct page *page, isolate_mode_t mode)
+int isolate_movable_page(struct page *page, isolate_mode_t mode)
 {
 	struct address_space *mapping;
 
@@ -125,14 +125,14 @@ bool isolate_movable_page(struct page *page, isolate_mode_t mode)
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
+	return -EBUSY;
 }
 
 /* It should be called on page which is PG_movable */
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
