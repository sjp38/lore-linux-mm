Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 22E536B0261
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:27:59 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id e70so304725105ioi.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 01:27:59 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id p191si18479497iod.221.2016.08.22.01.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 01:27:58 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 3/4] ZRAM: do not swap the page that compressed size bigger than non_swap
Date: Mon, 22 Aug 2016 16:25:08 +0800
Message-ID: <1471854309-30414-4-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
References: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, hughd@google.com, rostedt@goodmis.org, mingo@redhat.com, peterz@infradead.org, acme@kernel.org, alexander.shishkin@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, zhuhui@xiaomi.com, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, tglx@linutronix.de, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, joe@perches.com, namit@vmware.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com

New option ZRAM_NON_SWAP add a interface "non_swap" to zram.
User can set a unsigned int value to zram.
If a page that compressed size is bigger than limit, mark it as
non-swap.  Then this page will add to unevictable lru list.

This patch doesn't handle the shmem file pages.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 drivers/block/zram/Kconfig    | 11 +++++++++++
 drivers/block/zram/zram_drv.c | 39 +++++++++++++++++++++++++++++++++++++++
 drivers/block/zram/zram_drv.h |  4 ++++
 3 files changed, 54 insertions(+)

diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
index b8ecba6..525caaa 100644
--- a/drivers/block/zram/Kconfig
+++ b/drivers/block/zram/Kconfig
@@ -13,3 +13,14 @@ config ZRAM
 	  disks and maybe many more.
 
 	  See zram.txt for more information.
+
+config ZRAM_NON_SWAP
+	bool "Enable zram non-swap support"
+	depends on ZRAM
+	select NON_SWAP
+	default n
+	help
+	  This option add a interface "non_swap" to zram.  User can set
+	  a unsigned int value to zram.
+	  If a page that compressed size is bigger than limit, mark it as
+	  non-swap.  Then this page will add to unevictable lru list.
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 04365b1..8f7f1ec 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -714,6 +714,14 @@ compress_again:
 		goto out;
 	}
 
+#ifdef CONFIG_ZRAM_NON_SWAP
+	if (!is_partial_io(bvec) && PageAnon(page) &&
+	    zram->non_swap && clen > zram->non_swap) {
+		ret = 0;
+		SetPageNonSwap(page);
+		goto out;
+	}
+#endif
 	src = zstrm->buffer;
 	if (unlikely(clen > max_zpage_size)) {
 		clen = PAGE_SIZE;
@@ -1180,6 +1188,31 @@ static const struct block_device_operations zram_devops = {
 	.owner = THIS_MODULE
 };
 
+#ifdef CONFIG_ZRAM_NON_SWAP
+static ssize_t non_swap_show(struct device *dev,
+			     struct device_attribute *attr, char *buf)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	return scnprintf(buf, PAGE_SIZE, "%u\n", zram->non_swap);
+}
+
+static ssize_t non_swap_store(struct device *dev,
+			      struct device_attribute *attr, const char *buf,
+			      size_t len)
+{
+	struct zram *zram = dev_to_zram(dev);
+
+	zram->non_swap = (unsigned int)memparse(buf, NULL);
+
+	if (zram->non_swap > max_zpage_size)
+		pr_warn("Nonswap should small than max_zpage_size %zu\n",
+			max_zpage_size);
+
+	return len;
+}
+#endif
+
 static DEVICE_ATTR_WO(compact);
 static DEVICE_ATTR_RW(disksize);
 static DEVICE_ATTR_RO(initstate);
@@ -1190,6 +1223,9 @@ static DEVICE_ATTR_RW(mem_limit);
 static DEVICE_ATTR_RW(mem_used_max);
 static DEVICE_ATTR_RW(max_comp_streams);
 static DEVICE_ATTR_RW(comp_algorithm);
+#ifdef CONFIG_ZRAM_NON_SWAP
+static DEVICE_ATTR_RW(non_swap);
+#endif
 
 static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_disksize.attr,
@@ -1210,6 +1246,9 @@ static struct attribute *zram_disk_attrs[] = {
 	&dev_attr_mem_used_max.attr,
 	&dev_attr_max_comp_streams.attr,
 	&dev_attr_comp_algorithm.attr,
+#ifdef CONFIG_ZRAM_NON_SWAP
+	&dev_attr_non_swap.attr,
+#endif
 	&dev_attr_io_stat.attr,
 	&dev_attr_mm_stat.attr,
 	&dev_attr_debug_stat.attr,
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 74fcf10..bd5f38a 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -119,5 +119,9 @@ struct zram {
 	 * zram is claimed so open request will be failed
 	 */
 	bool claim; /* Protected by bdev->bd_mutex */
+
+#ifdef CONFIG_ZRAM_NON_SWAP
+	unsigned int non_swap;
+#endif
 };
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
