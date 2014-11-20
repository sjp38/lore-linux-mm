Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id CFB1B6B0069
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 08:08:51 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id w10so3070589pde.10
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:08:51 -0800 (PST)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id kv12si2819229pab.232.2014.11.20.05.08.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 05:08:50 -0800 (PST)
Received: by mail-pd0-f175.google.com with SMTP id y10so3040081pdj.6
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:08:49 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/zsmalloc: avoid duplicate assignment of prev_class
Date: Thu, 20 Nov 2014 21:08:33 +0800
Message-Id: <1416488913-9691-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, iamjoonsoo.kim@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

In zs_create_pool(), prev_class is assigned (ZS_SIZE_CLASSES - 1)
times. And the prev_class only references to the previous alloc
size_class. So we do not need unnecessary assignement.

This patch modifies *prev_class* to *prev_alloc_class*. And the
*prev_alloc_class* will only be assigned when a new size_class
structure is allocated.

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
---
 mm/zsmalloc.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b3b57ef..ac2b396 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -970,7 +970,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 		int size;
 		int pages_per_zspage;
 		struct size_class *class;
-		struct size_class *prev_class;
+		struct size_class *uninitialized_var(prev_alloc_class);
 
 		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
 		if (size > ZS_MAX_ALLOC_SIZE)
@@ -987,9 +987,8 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 		 * previous size_class if possible.
 		 */
 		if (i < ZS_SIZE_CLASSES - 1) {
-			prev_class = pool->size_class[i + 1];
-			if (can_merge(prev_class, size, pages_per_zspage)) {
-				pool->size_class[i] = prev_class;
+			if (can_merge(prev_alloc_class, size, pages_per_zspage)) {
+				pool->size_class[i] = prev_alloc_class;
 				continue;
 			}
 		}
@@ -1003,6 +1002,8 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 		class->pages_per_zspage = pages_per_zspage;
 		spin_lock_init(&class->lock);
 		pool->size_class[i] = class;
+
+		prev_alloc_class = class;
 	}
 
 	pool->flags = flags;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
