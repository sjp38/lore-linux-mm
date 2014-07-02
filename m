Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3D26B0038
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 17:46:08 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id l13so782768iga.9
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 14:46:08 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id ib4si15310689icc.72.2014.07.02.14.46.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 14:46:07 -0700 (PDT)
Received: by mail-ie0-f171.google.com with SMTP id x19so10041455ier.30
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 14:46:06 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv3 3/4] mm/zpool: zbud/zsmalloc implement zpool
Date: Wed,  2 Jul 2014 17:45:35 -0400
Message-Id: <1404337536-11037-4-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1404337536-11037-1-git-send-email-ddstreet@ieee.org>
References: <1401747586-11861-1-git-send-email-ddstreet@ieee.org>
 <1404337536-11037-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Update zbud and zsmalloc to implement the zpool api.

[Fengguang Wu <fengguang.wu@intel.com>: make functions static]
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Weijie Yang <weijie.yang@samsung.com>
---

Note to Seth: We talked about removing the retries parameter from
zbud_reclaim_page(), but I did not include that in this patch.
I'll send a separate patch for that.

Changes since v2 : https://lkml.org/lkml/2014/6/2/801
  -make functions static per suggestion from Fengguang Wu
  -move module owner initialization from later patch
  -update to use gfp params for create and malloc

Changes since v1 : https://lkml.org/lkml/2014/5/24/136
  -Update zbud_zpool_shrink() to call zbud_reclaim_page()
   in a loop until number of pages requested has been
   reclaimed, or error
  -Update zbud_zpool_shrink() to update passed *reclaimed
   param with # pages actually reclaimed
  -Update zs_pool_shrink() with new param, although function
   is not implemented yet

 mm/zbud.c     | 94 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/zsmalloc.c | 85 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 179 insertions(+)

diff --git a/mm/zbud.c b/mm/zbud.c
index d012261..a05790b 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -51,6 +51,7 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/zbud.h>
+#include <linux/zpool.h>
 
 /*****************
  * Structures
@@ -113,6 +114,90 @@ struct zbud_header {
 };
 
 /*****************
+ * zpool
+ ****************/
+
+#ifdef CONFIG_ZPOOL
+
+static int zbud_zpool_evict(struct zbud_pool *pool, unsigned long handle)
+{
+	return zpool_evict(pool, handle);
+}
+
+static struct zbud_ops zbud_zpool_ops = {
+	.evict =	zbud_zpool_evict
+};
+
+static void *zbud_zpool_create(gfp_t gfp, struct zpool_ops *zpool_ops)
+{
+	return zbud_create_pool(gfp, &zbud_zpool_ops);
+}
+
+static void zbud_zpool_destroy(void *pool)
+{
+	zbud_destroy_pool(pool);
+}
+
+static int zbud_zpool_malloc(void *pool, size_t size, gfp_t gfp,
+			unsigned long *handle)
+{
+	return zbud_alloc(pool, size, gfp, handle);
+}
+static void zbud_zpool_free(void *pool, unsigned long handle)
+{
+	zbud_free(pool, handle);
+}
+
+static int zbud_zpool_shrink(void *pool, unsigned int pages,
+			unsigned int *reclaimed)
+{
+	unsigned int total = 0;
+	int ret = -EINVAL;
+
+	while (total < pages) {
+		ret = zbud_reclaim_page(pool, 8);
+		if (ret < 0)
+			break;
+		total++;
+	}
+
+	if (reclaimed)
+		*reclaimed = total;
+
+	return ret;
+}
+
+static void *zbud_zpool_map(void *pool, unsigned long handle,
+			enum zpool_mapmode mm)
+{
+	return zbud_map(pool, handle);
+}
+static void zbud_zpool_unmap(void *pool, unsigned long handle)
+{
+	zbud_unmap(pool, handle);
+}
+
+static u64 zbud_zpool_total_size(void *pool)
+{
+	return zbud_get_pool_size(pool) * PAGE_SIZE;
+}
+
+static struct zpool_driver zbud_zpool_driver = {
+	.type =		"zbud",
+	.owner =	THIS_MODULE,
+	.create =	zbud_zpool_create,
+	.destroy =	zbud_zpool_destroy,
+	.malloc =	zbud_zpool_malloc,
+	.free =		zbud_zpool_free,
+	.shrink =	zbud_zpool_shrink,
+	.map =		zbud_zpool_map,
+	.unmap =	zbud_zpool_unmap,
+	.total_size =	zbud_zpool_total_size,
+};
+
+#endif /* CONFIG_ZPOOL */
+
+/*****************
  * Helpers
 *****************/
 /* Just to make the code easier to read */
@@ -511,11 +596,20 @@ static int __init init_zbud(void)
 	/* Make sure the zbud header will fit in one chunk */
 	BUILD_BUG_ON(sizeof(struct zbud_header) > ZHDR_SIZE_ALIGNED);
 	pr_info("loaded\n");
+
+#ifdef CONFIG_ZPOOL
+	zpool_register_driver(&zbud_zpool_driver);
+#endif
+
 	return 0;
 }
 
 static void __exit exit_zbud(void)
 {
+#ifdef CONFIG_ZPOOL
+	zpool_unregister_driver(&zbud_zpool_driver);
+#endif
+
 	pr_info("unloaded\n");
 }
 
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 4cd5479..6c1e2a4 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -92,6 +92,7 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/zsmalloc.h>
+#include <linux/zpool.h>
 
 /*
  * This must be power of 2 and greater than of equal to sizeof(link_free).
@@ -240,6 +241,82 @@ struct mapping_area {
 	enum zs_mapmode vm_mm; /* mapping mode */
 };
 
+/* zpool driver */
+
+#ifdef CONFIG_ZPOOL
+
+static void *zs_zpool_create(gfp_t gfp, struct zpool_ops *zpool_ops)
+{
+	return zs_create_pool(gfp);
+}
+
+static void zs_zpool_destroy(void *pool)
+{
+	zs_destroy_pool(pool);
+}
+
+static int zs_zpool_malloc(void *pool, size_t size, gfp_t gfp,
+			unsigned long *handle)
+{
+	*handle = zs_malloc(pool, size);
+	return *handle ? 0 : -1;
+}
+static void zs_zpool_free(void *pool, unsigned long handle)
+{
+	zs_free(pool, handle);
+}
+
+static int zs_zpool_shrink(void *pool, unsigned int pages,
+			unsigned int *reclaimed)
+{
+	return -EINVAL;
+}
+
+static void *zs_zpool_map(void *pool, unsigned long handle,
+			enum zpool_mapmode mm)
+{
+	enum zs_mapmode zs_mm;
+
+	switch (mm) {
+	case ZPOOL_MM_RO:
+		zs_mm = ZS_MM_RO;
+		break;
+	case ZPOOL_MM_WO:
+		zs_mm = ZS_MM_WO;
+		break;
+	case ZPOOL_MM_RW: /* fallthru */
+	default:
+		zs_mm = ZS_MM_RW;
+		break;
+	}
+
+	return zs_map_object(pool, handle, zs_mm);
+}
+static void zs_zpool_unmap(void *pool, unsigned long handle)
+{
+	zs_unmap_object(pool, handle);
+}
+
+static u64 zs_zpool_total_size(void *pool)
+{
+	return zs_get_total_size_bytes(pool);
+}
+
+static struct zpool_driver zs_zpool_driver = {
+	.type =		"zsmalloc",
+	.owner =	THIS_MODULE,
+	.create =	zs_zpool_create,
+	.destroy =	zs_zpool_destroy,
+	.malloc =	zs_zpool_malloc,
+	.free =		zs_zpool_free,
+	.shrink =	zs_zpool_shrink,
+	.map =		zs_zpool_map,
+	.unmap =	zs_zpool_unmap,
+	.total_size =	zs_zpool_total_size,
+};
+
+#endif /* CONFIG_ZPOOL */
+
 /* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
 static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
 
@@ -813,6 +890,10 @@ static void zs_exit(void)
 {
 	int cpu;
 
+#ifdef CONFIG_ZPOOL
+	zpool_unregister_driver(&zs_zpool_driver);
+#endif
+
 	cpu_notifier_register_begin();
 
 	for_each_online_cpu(cpu)
@@ -839,6 +920,10 @@ static int zs_init(void)
 
 	cpu_notifier_register_done();
 
+#ifdef CONFIG_ZPOOL
+	zpool_register_driver(&zs_zpool_driver);
+#endif
+
 	return 0;
 fail:
 	zs_exit();
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
