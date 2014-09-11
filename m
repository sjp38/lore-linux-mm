Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1D78B6B0062
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 16:55:12 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id h18so3530291igc.15
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:55:11 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id q10si2521906icg.8.2014.09.11.13.55.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 13:55:11 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so5863874iec.19
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:55:11 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 09/10] zsmalloc: add zs_shrink()
Date: Thu, 11 Sep 2014 16:54:00 -0400
Message-Id: <1410468841-320-10-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

Add function zs_shrink() to implement zs_pool shrinking.  This allows
the pool owner to reduce the size of the zs_pool by one zspage, which
contains one or more struct pages.  Once the zs_pool is shrunk, the
freed pages are available for system use.

This is used by zswap to limit its total system memory usage to a
user-defined amount, while attempting to keep the most recently stored
pages compressed in memory, and the oldest (or older) pages are evicted
from the zsmalloc zs_pool and written out to swap disk.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 include/linux/zsmalloc.h |  1 +
 mm/zsmalloc.c            | 35 +++++++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 2c341d4..07fe84d 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -45,6 +45,7 @@ void zs_destroy_pool(struct zs_pool *pool);
 
 unsigned long zs_malloc(struct zs_pool *pool, size_t size);
 void zs_free(struct zs_pool *pool, unsigned long obj);
+int zs_shrink(struct zs_pool *pool);
 
 void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 			enum zs_mapmode mm);
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 60fd23e..f769c21 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1296,6 +1296,41 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
 EXPORT_SYMBOL_GPL(zs_free);
 
 /**
+ * zs_shrink - Shrink the pool
+ * @pool: pool to shrink
+ *
+ * The pool will be shrunk by one zspage, which is some
+ * number of pages in size.  On success, the number of freed
+ * pages is returned.  On failure, the error is returned.
+ */
+int zs_shrink(struct zs_pool *pool)
+{
+	struct size_class *class;
+	enum fullness_group fullness;
+	struct page *page;
+	int class_idx, ret;
+
+	if (!pool->ops || !pool->ops->evict)
+		return -EINVAL;
+
+	/* if a page is found, the class is locked */
+	page = find_lru_zspage(pool);
+	if (!page)
+		return -ENOENT;
+
+	get_zspage_mapping(page, &class_idx, &fullness);
+	class = &pool->size_class[class_idx];
+
+	/* reclaim_zspage unlocks the class lock */
+	ret = reclaim_zspage(pool, page);
+	if (ret)
+		return ret;
+
+	return class->pages_per_zspage;
+}
+EXPORT_SYMBOL_GPL(zs_shrink);
+
+/**
  * zs_map_object - get address of allocated object from handle.
  * @pool: pool from which the object was allocated
  * @handle: handle returned from zs_malloc
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
