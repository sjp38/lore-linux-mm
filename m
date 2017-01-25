Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 572E06B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:40:25 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d123so16456439pfd.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 02:40:25 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id 207si22987234pgh.10.2017.01.25.02.40.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 02:40:24 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH] mm/migration: make isolate_movable_page always defined
Date: Wed, 25 Jan 2017 18:36:03 +0800
Message-ID: <1485340563-60785-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

Define isolate_movable_page as a static inline function when
CONFIG_MIGRATION is not enable. It should return false
here which means failed to isolate movable pages.

This patch do not have any functional change but to resolve compile
error caused by former commit "HWPOISON: soft offlining for non-lru
movable page" with CONFIG_MIGRATION disabled.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 include/linux/migrate.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ae8d475..631a8c8 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -56,6 +56,8 @@ static inline int migrate_pages(struct list_head *l, new_page_t new,
 		free_page_t free, unsigned long private, enum migrate_mode mode,
 		int reason)
 	{ return -ENOSYS; }
+static inline bool isolate_movable_page(struct page *page, isolate_mode_t mode)
+	{ return false; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
