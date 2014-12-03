Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 507C16B0038
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 07:39:29 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so15747525pab.2
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 04:39:29 -0800 (PST)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id eb1si37920849pbc.240.2014.12.03.04.39.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 04:39:27 -0800 (PST)
Received: by mail-pd0-f172.google.com with SMTP id y13so15356892pdi.31
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 04:39:27 -0800 (PST)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH] zram: use DEVICE_ATTR_[RW|RO|WO] to define zram sys device attribute
Date: Wed,  3 Dec 2014 20:38:52 +0800
Message-Id: <1417610332-11191-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

In current zram, we use DEVICE_ATTR() to define sys device attributes.
SO, we need to set (S_IRUGO | S_IWUSR) permission and other
arguments manually.
Linux kernel has already provided macro DEVICE_ATTR_[RW|RO|WO] to define
sys device attribute. It is simple and readable.

This patch uses kernel defined macro DEVICE_ATTR_[RW|RO|WO] to define
zram device attribute.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
 drivers/block/zram/zram_drv.c |   28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 8eb0d85..53fbd61 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -44,15 +44,14 @@ static const char *default_compressor = "lzo";
 static unsigned int num_devices = 1;
 
 #define ZRAM_ATTR_RO(name)						\
-static ssize_t zram_attr_##name##_show(struct device *d,		\
+static ssize_t name##_show(struct device *d,		\
 				struct device_attribute *attr, char *b)	\
 {									\
 	struct zram *zram = dev_to_zram(d);				\
 	return scnprintf(b, PAGE_SIZE, "%llu\n",			\
 		(u64)atomic64_read(&zram->stats.name));			\
 }									\
-static struct device_attribute dev_attr_##name =			\
-	__ATTR(name, S_IRUGO, zram_attr_##name##_show, NULL);
+static DEVICE_ATTR_RO(name);
 
 static inline int init_done(struct zram *zram)
 {
@@ -994,20 +993,15 @@ static const struct block_device_operations zram_devops = {
 	.owner = THIS_MODULE
 };
 
-static DEVICE_ATTR(disksize, S_IRUGO | S_IWUSR,
-		disksize_show, disksize_store);
-static DEVICE_ATTR(initstate, S_IRUGO, initstate_show, NULL);
-static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
-static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
-static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
-static DEVICE_ATTR(mem_limit, S_IRUGO | S_IWUSR, mem_limit_show,
-		mem_limit_store);
-static DEVICE_ATTR(mem_used_max, S_IRUGO | S_IWUSR, mem_used_max_show,
-		mem_used_max_store);
-static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
-		max_comp_streams_show, max_comp_streams_store);
-static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
-		comp_algorithm_show, comp_algorithm_store);
+static DEVICE_ATTR_RW(disksize);
+static DEVICE_ATTR_RO(initstate);
+static DEVICE_ATTR_WO(reset);
+static DEVICE_ATTR_RO(orig_data_size);
+static DEVICE_ATTR_RO(mem_used_total);
+static DEVICE_ATTR_RW(mem_limit);
+static DEVICE_ATTR_RW(mem_used_max);
+static DEVICE_ATTR_RW(max_comp_streams);
+static DEVICE_ATTR_RW(comp_algorithm);
 
 ZRAM_ATTR_RO(num_reads);
 ZRAM_ATTR_RO(num_writes);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
