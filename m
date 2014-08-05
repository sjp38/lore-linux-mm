Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 280A26B0038
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 04:01:40 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so939955pad.35
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 01:01:39 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ar5si1070697pbd.27.2014.08.05.01.01.36
        for <linux-mm@kvack.org>;
        Tue, 05 Aug 2014 01:01:38 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 2/3] zsmalloc/zram: add zs_get_max_size_bytes and use it in zram
Date: Tue,  5 Aug 2014 17:02:02 +0900
Message-Id: <1407225723-23754-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1407225723-23754-1-git-send-email-minchan@kernel.org>
References: <1407225723-23754-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>

Normally, zram user can get maximum memory zsmalloc consumed via
polling mem_used_total with sysfs in userspace.

But it has a critical problem because user can miss peak memory
usage during update interval so that gap between them could be
huge when memory pressure is really heavy.

This patch adds new API zs_get_max_size_bytes in zsmalloc so
user(ex, zram) doesn't need to poll in short interval to get
exact value.

User can just see max memory usage once his test workload is
done. It's pretty handy and accurate.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/blockdev/zram.txt |  1 +
 drivers/block/zram/zram_drv.c   | 17 +++++++++++++++++
 include/linux/zsmalloc.h        |  1 +
 mm/zsmalloc.c                   | 20 ++++++++++++++++++++
 4 files changed, 39 insertions(+)

diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
index 0595c3f56ccf..d24534bee763 100644
--- a/Documentation/blockdev/zram.txt
+++ b/Documentation/blockdev/zram.txt
@@ -95,6 +95,7 @@ size of the disk when not in use so a huge zram is wasteful.
 		orig_data_size
 		compr_data_size
 		mem_used_total
+		mem_used_max
 
 7) Deactivate:
 	swapoff /dev/zram0
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 36e54be402df..a4d637b4db7d 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -109,6 +109,21 @@ static ssize_t mem_used_total_show(struct device *dev,
 	return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
 }
 
+static ssize_t mem_used_max_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	u64 val = 0;
+	struct zram *zram = dev_to_zram(dev);
+	struct zram_meta *meta = zram->meta;
+
+	down_read(&zram->init_lock);
+	if (init_done(zram))
+		val = zs_get_max_size_bytes(meta->mem_pool);
+	up_read(&zram->init_lock);
+
+	return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
+}
+
 static ssize_t max_comp_streams_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
@@ -838,6 +853,7 @@ static DEVICE_ATTR(initstate, S_IRUGO, initstate_show, NULL);
 static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
 static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
 static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
+static DEVICE_ATTR(mem_used_max, S_IRUGO, mem_used_max_show, NULL);
 static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
 		max_comp_streams_show, max_comp_streams_store);
 static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
@@ -866,6 +882,7 @@ static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_orig_data_size.attr,
 	&dev_attr_compr_data_size.attr,
 	&dev_attr_mem_used_total.attr,
+	&dev_attr_mem_used_max.attr,
 	&dev_attr_max_comp_streams.attr,
 	&dev_attr_comp_algorithm.attr,
 	NULL,
diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index e44d634e7fb7..fb087ca06a88 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -47,5 +47,6 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 
 u64 zs_get_total_size_bytes(struct zs_pool *pool);
+u64 zs_get_max_size_bytes(struct zs_pool *pool);
 
 #endif
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index a6089bd26621..3b5be076268a 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -219,6 +219,7 @@ struct zs_pool {
 
 	gfp_t flags;	/* allocation flags used when growing pool */
 	unsigned long pages_allocated;
+	unsigned long max_pages_allocated;
 };
 
 /*
@@ -946,6 +947,8 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
 		spin_lock(&pool->stat_lock);
 		pool->pages_allocated += class->pages_per_zspage;
+		if (pool->max_pages_allocated < pool->pages_allocated)
+			pool->max_pages_allocated = pool->pages_allocated;
 		spin_unlock(&pool->stat_lock);
 		spin_lock(&class->lock);
 	}
@@ -1101,6 +1104,9 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
+/*
+ * Reports current memory usage consumed by zs_malloc
+ */
 u64 zs_get_total_size_bytes(struct zs_pool *pool)
 {
 	u64 npages;
@@ -1112,6 +1118,20 @@ u64 zs_get_total_size_bytes(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_get_total_size_bytes);
 
+/*
+ * Reports maximum memory usage zs_malloc have consumed
+ */
+u64 zs_get_max_size_bytes(struct zs_pool *pool)
+{
+	u64 npages;
+
+	spin_lock(&pool->stat_lock);
+	npages = pool->max_pages_allocated;
+	spin_unlock(&pool->stat_lock);
+	return npages << PAGE_SHIFT;
+}
+EXPORT_SYMBOL_GPL(zs_get_max_size_bytes);
+
 module_init(zs_init);
 module_exit(zs_exit);
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
