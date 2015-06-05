Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7DFEB900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 07:12:06 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so13657742pdj.0
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 04:12:06 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id o1si10467122pdd.111.2015.06.05.04.12.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 04:12:05 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so51482783pdb.1
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 04:12:05 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] zsmalloc: fix a null pointer dereference in destroy_handle_cache()
Date: Fri,  5 Jun 2015 20:11:30 +0900
Message-Id: <1433502690-2524-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

zs_destroy_pool()->destroy_handle_cache() invoked from
zs_create_pool() can pass a NULL ->handle_cachep pointer
to kmem_cache_destroy(), which will dereference it.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 33d5126..c766240 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -285,7 +285,8 @@ static int create_handle_cache(struct zs_pool *pool)
 
 static void destroy_handle_cache(struct zs_pool *pool)
 {
-	kmem_cache_destroy(pool->handle_cachep);
+	if (pool->handle_cachep)
+		kmem_cache_destroy(pool->handle_cachep);
 }
 
 static unsigned long alloc_handle(struct zs_pool *pool)
-- 
2.4.2.387.gf86f31a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
