Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9156B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 23:20:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f23so36820253pgn.15
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 20:20:09 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.123])
        by mx.google.com with ESMTPS id i7si6978909plk.84.2017.08.15.20.20.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 20:20:07 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH v3] zsmalloc: zs_page_migrate: schedule free_work if zspage is ZS_EMPTY
Date: Wed, 16 Aug 2017 11:19:41 +0800
Message-ID: <1502853581-21218-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

After commit [1] zs_page_migrate can handle the ZS_EMPTY zspage.

But I got some false in zs_page_isolate:
	if (get_zspage_inuse(zspage) == 0) {
		spin_unlock(&class->lock);
		return false;
	}
The page of this zspage was migrated in before.

The reason is commit [1] just handle the "page" but not "newpage"
then it keep the "newpage" with a empty zspage inside system.
Root cause is zs_page_isolate remove it from ZS_EMPTY list but not
call zs_page_putback "schedule_work(&pool->free_work);".  Because
zs_page_migrate done the job without "schedule_work(&pool->free_work);"

Make this patch let zs_page_migrate wake up free_work if need.

[1] zsmalloc-zs_page_migrate-skip-unnecessary-loops-but-not-return-ebusy-if-zspage-is-not-inuse-fix.patch

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/zsmalloc.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 62457eb..fb99953 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -2035,8 +2035,15 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	 * Page migration is done so let's putback isolated zspage to
 	 * the list if @page is final isolated subpage in the zspage.
 	 */
-	if (!is_zspage_isolated(zspage))
-		putback_zspage(class, zspage);
+	if (!is_zspage_isolated(zspage)) {
+		/*
+		 * Since we allow empty zspage migration, putback of zspage
+		 * should free empty zspage. Otherwise, it could make a leak
+		 * until upcoming free_work is done, which isn't guaranteed.
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
