Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 43B806B0260
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 03:26:12 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a8so95779346pfg.0
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 00:26:12 -0800 (PST)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id h8si15057729pli.261.2016.11.25.00.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 00:26:11 -0800 (PST)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 2/2] ZRAM: add sysfs switch swap_cache_not_keep
Date: Fri, 25 Nov 2016 16:25:13 +0800
Message-ID: <1480062313-7361-3-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1480062313-7361-1-git-send-email-zhuhui@xiaomi.com>
References: <1480062313-7361-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, dan.j.williams@intel.com, jthumshirn@suse.de, akpm@linux-foundation.org, zhuhui@xiaomi.com, re.emese@gmail.com, andriy.shevchenko@linux.intel.com, vishal.l.verma@intel.com, hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net, vbabka@suse.cz, vdavydov.dev@gmail.com, kirill.shutemov@linux.intel.com, ying.huang@intel.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, willy@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, jmarchan@redhat.com, lstoakes@gmail.com, geliangtang@163.com, viro@zeniv.linux.org.uk, hughd@google.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com

This patch add a sysfs interface swap_cache_not_keep to control the swap
cache rule for a ZRAM disk.
Swap will not keep the swap cache anytime if it set to 1.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 drivers/block/zram/zram_drv.c | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 04365b1..bda9bbf 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -30,6 +30,8 @@
 #include <linux/err.h>
 #include <linux/idr.h>
 #include <linux/sysfs.h>
+#include <linux/swap.h>
+#include <asm/barrier.h>
 
 #include "zram_drv.h"
 
@@ -1158,6 +1160,32 @@ static ssize_t reset_store(struct device *dev,
 	return len;
 }
 
+#ifdef CONFIG_SWAP_CACHE_RULE
+static ssize_t swap_cache_not_keep_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return scnprintf(buf, PAGE_SIZE, "%d\n",
+			 zram->disk->swap_cache_not_keep);
+}
+
+static ssize_t swap_cache_not_keep_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	struct zram *zram = dev_to_zram(dev);
+	bool rule;
+
+	if (strtobool(buf, &rule) < 0)
+		return -EINVAL;
+	WRITE_ONCE(zram->disk->swap_cache_not_keep, rule);
+
+	swap_cache_rule_update();
+
+	return len;
+}
+#endif
+
 static int zram_open(struct block_device *bdev, fmode_t mode)
 {
 	int ret = 0;
@@ -1190,6 +1218,9 @@ static int zram_open(struct block_device *bdev, fmode_t mode)
 static DEVICE_ATTR_RW(mem_used_max);
 static DEVICE_ATTR_RW(max_comp_streams);
 static DEVICE_ATTR_RW(comp_algorithm);
+#ifdef CONFIG_SWAP_CACHE_RULE
+static DEVICE_ATTR_RW(swap_cache_not_keep);
+#endif
 
 static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_disksize.attr,
@@ -1213,6 +1244,9 @@ static int zram_open(struct block_device *bdev, fmode_t mode)
 	&dev_attr_io_stat.attr,
 	&dev_attr_mm_stat.attr,
 	&dev_attr_debug_stat.attr,
+#ifdef CONFIG_SWAP_CACHE_RULE
+	&dev_attr_swap_cache_not_keep.attr,
+#endif
 	NULL,
 };
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
