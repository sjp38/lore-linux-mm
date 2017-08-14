Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 949556B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 02:35:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y129so121014179pgy.1
        for <linux-mm@kvack.org>; Sun, 13 Aug 2017 23:35:11 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.123])
        by mx.google.com with ESMTPS id u3si3724752pgo.886.2017.08.13.23.35.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 13 Aug 2017 23:35:10 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH] zsmalloc: zs_page_migrate: schedule free_work if zspage is ZS_EMPTY
Date: Mon, 14 Aug 2017 14:34:46 +0800
Message-ID: <1502692486-27519-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

After commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary
loops but not return -EBUSY if zspage is not inuse") zs_page_migrate
can handle the ZS_EMPTY zspage.

But it will affect the free_work free the zspage.  That will make this
ZS_EMPTY zspage stay in system until another zspage wake up free_work.

Make this patch let zs_page_migrate wake up free_work if need.

Fixes: e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary loops but not return -EBUSY if zspage is not inuse")
Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/zsmalloc.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 62457eb..48ce043 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -2035,8 +2035,14 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	 * Page migration is done so let's putback isolated zspage to
 	 * the list if @page is final isolated subpage in the zspage.
 	 */
-	if (!is_zspage_isolated(zspage))
-		putback_zspage(class, zspage);
+	if (!is_zspage_isolated(zspage)) {
+		/*
+		 * The page and class is locked, we cannot free zspage
+		 * immediately so let's defer.
+		 */
+		if (putback_zspage(class, zspage) == ZS_EMPTY)
+			schedule_work(&pool->free_work);
+	}
 
 	reset_page(page);
 	put_page(page);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
