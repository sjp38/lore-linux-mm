Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 49D6D6B0256
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 09:48:30 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fi3so14060887pac.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 06:48:30 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id uj7si43121151pab.111.2016.03.03.06.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 06:48:29 -0800 (PST)
Received: by mail-pa0-x231.google.com with SMTP id bj10so16036363pad.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 06:48:29 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v3 3/5] mm/zsmalloc: introduce zs_huge_object()
Date: Thu,  3 Mar 2016 23:46:01 +0900
Message-Id: <1457016363-11339-4-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

zsmalloc knows the watermark after which classes are considered
to be ->huge -- every object stored consumes the entire zspage (which
consist of a single order-0 page). On x86_64, PAGE_SHIFT 12 box, the
first non-huge class size is 3264, so starting down from size 3264,
objects share page(-s) and thus minimize memory wastage.

zram, however, has its own statically defined watermark for `bad'
compression "3 * PAGE_SIZE / 4 = 3072", and stores every object
larger than this watermark (3072) as a PAGE_SIZE, object, IOW,
to a ->huge class, this results in increased memory consumption and
memory wastage. (With a small exception: 3264 bytes class. zs_malloc()
adds ZS_HANDLE_SIZE to the object's size, so some objects can pass
3072 bytes and get_size_class_index(size) will return 3264 bytes size
class).

Introduce zs_huge_object() function which tells whether the supplied
object's size belongs to a huge class; so zram now can store objects
to ->huge clases only when those objects have sizes greater than
huge_class_size_watermark.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/zsmalloc.h |  2 ++
 mm/zsmalloc.c            | 13 +++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 34eb160..7184ee1 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -55,4 +55,6 @@ unsigned long zs_get_total_pages(struct zs_pool *pool);
 unsigned long zs_compact(struct zs_pool *pool);
 
 void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats);
+
+bool zs_huge_object(size_t sz);
 #endif
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0bb060f..06a7d87 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -188,6 +188,11 @@ static struct dentry *zs_stat_root;
 static int zs_size_classes;
 
 /*
+ * All classes above this class_size are huge classes
+ */
+static size_t huge_class_size_watermark;
+
+/*
  * We assign a page to ZS_ALMOST_EMPTY fullness group when:
  *	n <= N / f, where
  * n = number of allocated objects
@@ -1244,6 +1249,12 @@ unsigned long zs_get_total_pages(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_get_total_pages);
 
+bool zs_huge_object(size_t sz)
+{
+	return sz > huge_class_size_watermark;
+}
+EXPORT_SYMBOL_GPL(zs_huge_object);
+
 /**
  * zs_map_object - get address of allocated object from handle.
  * @pool: pool from which the object was allocated
@@ -1922,6 +1933,8 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 		pool->size_class[i] = class;
 
 		prev_class = class;
+		if (!class->huge && !huge_class_size_watermark)
+			huge_class_size_watermark = size - ZS_HANDLE_SIZE;
 	}
 
 	pool->flags = flags;
-- 
2.8.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
