Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B13F6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 05:56:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r133so126855766pgr.6
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 02:56:48 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.125])
        by mx.google.com with ESMTPS id g6si4386131plj.244.2017.08.14.02.56.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 02:56:47 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH v2] zsmalloc: zs_page_migrate: schedule free_work if zspage is ZS_EMPTY
Date: Mon, 14 Aug 2017 17:56:30 +0800
Message-ID: <1502704590-3129-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

After commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary
loops but not return -EBUSY if zspage is not inuse") zs_page_migrate
can handle the ZS_EMPTY zspage.

But I got some false in zs_page_isolate:
	if (get_zspage_inuse(zspage) == 0) {
		spin_unlock(&class->lock);
		return false;
	}
The page of this zspage was migrated in before.

The reason is commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip
unnecessary loops but not return -EBUSY if zspage is not inuse") just
handle the "page" but not "newpage" then it keep the "newpage" with
a empty zspage inside system.
Root cause is zs_page_isolate remove it from ZS_EMPTY list but not
call zs_page_putback "schedule_work(&pool->free_work);".  Because
zs_page_migrate done the job without "schedule_work(&pool->free_work);"

Make this patch let zs_page_migrate wake up free_work if need.

Fixes: e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary loops but not return -EBUSY if zspage is not inuse")
Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/zsmalloc.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 62457eb..c6cc77c 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -2035,8 +2035,17 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	 * Page migration is done so let's putback isolated zspage to
 	 * the list if @page is final isolated subpage in the zspage.
 	 */
-	if (!is_zspage_isolated(zspage))
-		putback_zspage(class, zspage);
+	if (!is_zspage_isolated(zspage)) {
+		/*
+		 * Page will be freed in following part. But newpage and
+		 * zspage will stay in system if zspage is in ZS_EMPTY
+		 * list.  So call free_work to free it.
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
