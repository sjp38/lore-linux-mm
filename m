Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 644BB6B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 04:06:03 -0400 (EDT)
Received: by lacdq2 with SMTP id dq2so63925713lac.1
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 01:06:02 -0700 (PDT)
Received: from mail-la0-x22a.google.com (mail-la0-x22a.google.com. [2a00:1450:4010:c03::22a])
        by mx.google.com with ESMTPS id th8si3325998lbb.153.2015.09.26.01.06.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 01:06:01 -0700 (PDT)
Received: by laclj5 with SMTP id lj5so23956124lac.3
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 01:06:01 -0700 (PDT)
Date: Sat, 26 Sep 2015 10:05:51 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCHv2 1/3] zpool: add compaction api
Message-Id: <20150926100551.6c16d0ea3bb7758849150a0a@gmail.com>
In-Reply-To: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
References: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ddstreet@ieee.org, akpm@linux-foundation.org, Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

This patch adds two functions to the zpool API: zpool_compact()
and zpool_get_num_compacted(). The former triggers compaction for
the underlying allocator and the latter retrieves the number of
pages migrated due to compaction for the whole time of this pool's
existence.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

---
 include/linux/zpool.h |  9 +++++++++
 mm/zpool.c            | 23 +++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index 42f8ec9..be1ed58 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -58,6 +58,10 @@ void *zpool_map_handle(struct zpool *pool, unsigned long handle,
 
 void zpool_unmap_handle(struct zpool *pool, unsigned long handle);
 
+unsigned long zpool_compact(struct zpool *pool);
+
+unsigned long zpool_get_num_compacted(struct zpool *pool);
+
 u64 zpool_get_total_size(struct zpool *pool);
 
 
@@ -72,6 +76,8 @@ u64 zpool_get_total_size(struct zpool *pool);
  * @shrink:	shrink the pool.
  * @map:	map a handle.
  * @unmap:	unmap a handle.
+ * @compact:	try to run compaction over a pool
+ * @get_num_compacted:	get amount of compacted pages for a pool
  * @total_size:	get total size of a pool.
  *
  * This is created by a zpool implementation and registered
@@ -98,6 +104,9 @@ struct zpool_driver {
 				enum zpool_mapmode mm);
 	void (*unmap)(void *pool, unsigned long handle);
 
+	unsigned long (*compact)(void *pool);
+	unsigned long (*get_num_compacted)(void *pool);
+
 	u64 (*total_size)(void *pool);
 };
 
diff --git a/mm/zpool.c b/mm/zpool.c
index 8f670d3..e469a66 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -340,6 +340,29 @@ void zpool_unmap_handle(struct zpool *zpool, unsigned long handle)
 	zpool->driver->unmap(zpool->pool, handle);
 }
 
+ /**
+ * zpool_compact() - try to run compaction over zpool
+ * @pool       The zpool to compact
+ *
+ * Returns: the number of migrated pages
+ */
+unsigned long zpool_compact(struct zpool *zpool)
+{
+	return zpool->driver->compact(zpool->pool);
+}
+
+
+/**
+ * zpool_get_num_compacted() - get the number of migrated/compacted pages
+ * @stats	stats to fill in
+ *
+ * Returns: the total number of migrated pages for the pool
+ */
+unsigned long zpool_get_num_compacted(struct zpool *zpool)
+{
+	zpool->driver->get_num_compacted(zpool->pool);
+}
+
 /**
  * zpool_get_total_size() - The total size of the pool
  * @pool	The zpool to check
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
