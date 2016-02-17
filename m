Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id DFC7C6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 20:56:55 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id z135so15183696iof.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 17:56:55 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id p7si21511891oif.106.2016.02.16.17.56.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 17:56:55 -0800 (PST)
From: YiPing Xu <xuyiping@huawei.com>
Subject: [PATCH] zsmalloc: drop unused member 'mapping_area->huge'
Date: Wed, 17 Feb 2016 09:56:39 +0800
Message-ID: <1455674199-6227-1-git-send-email-xuyiping@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xuyiping@huawei.com, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: suzhuangluan@hisilicon.com, puck.chen@hisilicon.com, dan.zhao@hisilicon.com

When unmapping a huge class page in zs_unmap_object, the page will
be unmapped by kmap_atomic. the "!area->huge" branch in
__zs_unmap_object is alway true, and no code set "area->huge" now,
so we can drop it.

Signed-off-by: YiPing Xu <xuyiping@huawei.com>
---
 mm/zsmalloc.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 2d7c4c1..43e4cbc 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -281,7 +281,6 @@ struct mapping_area {
 #endif
 	char *vm_addr; /* address of kmap_atomic()'ed pages */
 	enum zs_mapmode vm_mm; /* mapping mode */
-	bool huge;
 };
 
 static int create_handle_cache(struct zs_pool *pool)
@@ -1127,11 +1126,9 @@ static void __zs_unmap_object(struct mapping_area *area,
 		goto out;
 
 	buf = area->vm_buf;
-	if (!area->huge) {
-		buf = buf + ZS_HANDLE_SIZE;
-		size -= ZS_HANDLE_SIZE;
-		off += ZS_HANDLE_SIZE;
-	}
+	buf = buf + ZS_HANDLE_SIZE;
+	size -= ZS_HANDLE_SIZE;
+	off += ZS_HANDLE_SIZE;
 
 	sizes[0] = PAGE_SIZE - off;
 	sizes[1] = size - sizes[0];
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
