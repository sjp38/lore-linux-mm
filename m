Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id CFACC828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 19:36:30 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id q21so471315394iod.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 16:36:30 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id k2si371185igx.32.2016.01.14.16.36.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 16:36:30 -0800 (PST)
From: Junil Lee <junil0814.lee@lge.com>
Subject: [PATCH] zsmalloc: fix migrate_zspage-zs_free race condition
Date: Fri, 15 Jan 2016 09:36:24 +0900
Message-ID: <1452818184-2994-1-git-send-email-junil0814.lee@lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org
Cc: sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Junil Lee <junil0814.lee@lge.com>

To prevent unlock at the not correct situation, tagging the new obj to
assure lock in migrate_zspage() before right unlock path.

Two functions are in race condition by tag which set 1 on last bit of
obj, however unlock succrently when update new obj to handle before call
unpin_tag() which is right unlock path.

summarize this problem by call flow as below:

		CPU0								CPU1
migrate_zspage
find_alloced_obj()
	trypin_tag() -- obj |= HANDLE_PIN_BIT
obj_malloc() -- new obj is not set			zs_free
record_obj() -- unlock and break sync		pin_tag() -- get lock
unpin_tag()

Signed-off-by: Junil Lee <junil0814.lee@lge.com>
---
 mm/zsmalloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e7414ce..bb459ef 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1635,6 +1635,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		free_obj = obj_malloc(d_page, class, handle);
 		zs_object_copy(free_obj, used_obj, class);
 		index++;
+		free_obj |= BIT(HANDLE_PIN_BIT);
 		record_obj(handle, free_obj);
 		unpin_tag(handle);
 		obj_free(pool, class, used_obj);
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
