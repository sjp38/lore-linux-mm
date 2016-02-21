Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 761386B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 08:30:01 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id e127so77713374pfe.3
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 05:30:01 -0800 (PST)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id p83si32199167pfj.121.2016.02.21.05.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 05:30:00 -0800 (PST)
Received: by mail-pf0-x233.google.com with SMTP id e127so77713277pfe.3
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 05:30:00 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v2 1/3] mm/zsmalloc: introduce zs_get_huge_class_size_watermark()
Date: Sun, 21 Feb 2016 22:27:52 +0900
Message-Id: <1456061274-20059-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

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

Introduce a zs_get_huge_class_size_watermark() function which tells
the size of a first non-huge class; so zram now can store objects
to ->huge clases only when those objects have sizes greater than
huge_class_size_watermark.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/zsmalloc.h |  2 ++
 mm/zsmalloc.c            | 14 ++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 34eb160..45dcb51 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -55,4 +55,6 @@ unsigned long zs_get_total_pages(struct zs_pool *pool);
 unsigned long zs_compact(struct zs_pool *pool);
 
 void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats);
+
+int zs_get_huge_class_size_watermark(void);
 #endif
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 43e4cbc..e7f10bd 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -188,6 +188,11 @@ static struct dentry *zs_stat_root;
 static int zs_size_classes;
 
 /*
+ * All classes above this class_size are huge classes
+ */
+static int huge_class_size_watermark;
+
+/*
  * We assign a page to ZS_ALMOST_EMPTY fullness group when:
  *	n <= N / f, where
  * n = number of allocated objects
@@ -1241,6 +1246,12 @@ unsigned long zs_get_total_pages(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_get_total_pages);
 
+int zs_get_huge_class_size_watermark(void)
+{
+	return huge_class_size_watermark;
+}
+EXPORT_SYMBOL_GPL(zs_get_huge_class_size_watermark);
+
 /**
  * zs_map_object - get address of allocated object from handle.
  * @pool: pool from which the object was allocated
@@ -1942,10 +1953,13 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 		if (pages_per_zspage == 1 &&
 			get_maxobj_per_zspage(size, pages_per_zspage) == 1)
 			class->huge = true;
+
 		spin_lock_init(&class->lock);
 		pool->size_class[i] = class;
 
 		prev_class = class;
+		if (!class->huge && !huge_class_size_watermark)
+			huge_class_size_watermark = size - ZS_HANDLE_SIZE;
 	}
 
 	pool->flags = flags;
-- 
2.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
