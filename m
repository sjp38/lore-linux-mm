Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BECFC49ED6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 03:22:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D768521479
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 03:22:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D768521479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 785F96B0003; Wed, 11 Sep 2019 23:22:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A6976B0005; Wed, 11 Sep 2019 23:22:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 563736B0006; Wed, 11 Sep 2019 23:22:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0220.hostedemail.com [216.40.44.220])
	by kanga.kvack.org (Postfix) with ESMTP id 2E30E6B0003
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 23:22:01 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id D366F8E4A
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:22:00 +0000 (UTC)
X-FDA: 75924819600.23.boat59_4b9f2c024ae07
X-HE-Tag: boat59_4b9f2c024ae07
X-Filterd-Recvd-Size: 10074
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com [115.124.30.130])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:21:59 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R241e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=teawaterz@linux.alibaba.com;NM=1;PH=DS;RN=26;SR=0;TI=SMTPD_---0Tc71FcL_1568258502;
Received: from localhost(mailfrom:teawaterz@linux.alibaba.com fp:SMTPD_---0Tc71FcL_1568258502)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 12 Sep 2019 11:21:52 +0800
From: Hui Zhu <teawaterz@linux.alibaba.com>
To: sjenning@redhat.com,
	ddstreet@ieee.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	willy@infradead.org,
	chris@chris-wilson.co.uk,
	hannes@cmpxchg.org,
	ziqian.lzq@antfin.com,
	osandov@fb.com,
	ying.huang@intel.com,
	aryabinin@virtuozzo.com,
	vovoy@chromium.org,
	richard.weiyang@gmail.com,
	jgg@ziepe.ca,
	dan.j.williams@intel.com,
	rppt@linux.ibm.com,
	jglisse@redhat.com,
	b.zolnierkie@samsung.com,
	axboe@kernel.dk,
	dennis@kernel.org,
	josef@toxicpanda.com,
	tj@kernel.org,
	oleg@redhat.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Cc: Hui Zhu <teawaterz@linux.alibaba.com>
Subject: [PATCH] zswap: Add CONFIG_ZSWAP_IO_SWITCH
Date: Thu, 12 Sep 2019 11:21:30 +0800
Message-Id: <1568258490-25359-1-git-send-email-teawaterz@linux.alibaba.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I use zswap to handle the swap IO issue in a VM that uses a swap file.
This VM has 4G memory and 2 CPUs.  And I set up 4G swap in /swapfile.
This is test script:
cat 1.sh
./usemem --sleep 3600 -M -a -n 1 $((3 * 1024 * 1024 * 1024)) &
sleep 10
echo 1 > /proc/sys/vm/drop_caches
./usemem -S -f /test2 $((2 * 1024 * 1024 * 1024)) &
while [ True ]; do ./usemem -a -n 1 $((1 * 1024 * 1024 * 1024)); done

Without ZSWAP:
echo 100 > /proc/sys/vm/swappiness
swapon /swapfile
sh 1.sh
...
...
1207959552 bytes / 2076479 usecs = 568100 KB/s
61088 usecs to free memory
1207959552 bytes / 2035439 usecs = 579554 KB/s
55073 usecs to free memory
2415919104 bytes / 24054408 usecs = 98081 KB/s
3741 usecs to free memory
1207959552 bytes / 1954371 usecs = 603594 KB/s
53161 usecs to free memory
...
...

With ZSWAP:
echo 100 > /proc/sys/vm/swappiness
swapon /swapfile
echo lz4 > /sys/module/zswap/parameters/compressor
echo zsmalloc > /sys/module/zswap/parameters/zpool
echo 0 > /sys/module/zswap/parameters/same_filled_pages_enabled
echo 20 > /sys/module/zswap/parameters/max_pool_percent
echo 1 > /sys/module/zswap/parameters/enabled
sh 1.sh
1207959552 bytes / 3619283 usecs = 325934 KB/s
194825 usecs to free memory
1207959552 bytes / 3439563 usecs = 342964 KB/s
218419 usecs to free memory
2415919104 bytes / 19508762 usecs = 120935 KB/s
5632 usecs to free memory
1207959552 bytes / 3329369 usecs = 354315 KB/s
179764 usecs to free memory

The normal io speed is increased from 98081 KB/s to 120935 KB/s.
But I found 2 issues of zswap in this machine:
1. Because the disk of VM has the file cache in the host layer,
   so normal swap speed is higher than with zswap.
2. Because zswap need allocates memory to store the compressed pages,
   it will make memory capacity worse.
For example:
Command "./usemem -a -n 1 $((7 * 1024 * 1024 * 1024))" request 7G memory
from this machine.
It will work OK without zswap but got OOM when zswap is opened.

This commit adds CONFIG_ZSWAP_IO_SWITCH that try to handle the issues
and let zswap keep save IO.
It add two parameters read_in_flight_limit and write_in_flight_limit to
zswap.
In zswap_frontswap_store, pages will be stored to zswap only when
the IO in flight number of swap device is bigger than
zswap_read_in_flight_limit or zswap_write_in_flight_limit
when zswap is enabled.
Then the zswap just work when the IO in flight number of swap device
is low.

This is the test result:
echo 100 > /proc/sys/vm/swappiness
swapon /swapfile
echo lz4 > /sys/module/zswap/parameters/compressor
echo zsmalloc > /sys/module/zswap/parameters/zpool
echo 0 > /sys/module/zswap/parameters/same_filled_pages_enabled
echo 20 > /sys/module/zswap/parameters/max_pool_percent
echo 1 > /sys/module/zswap/parameters/enabled
echo 3 > /sys/module/zswap/parameters/read_in_flight_limit
echo 50 > /sys/module/zswap/parameters/write_in_flight_limit
sh 1.sh
...
1207959552 bytes / 2320861 usecs = 508280 KB/s
106164 usecs to free memory
1207959552 bytes / 2343916 usecs = 503280 KB/s
79386 usecs to free memory
2415919104 bytes / 20136015 usecs = 117167 KB/s
4411 usecs to free memory
1207959552 bytes / 1833403 usecs = 643419 KB/s
70452 usecs to free memory
...
killall usemem
./usemem -a -n 1 $((7 * 1024 * 1024 * 1024))
8455716864 bytes / 14457505 usecs = 571159 KB/s
365961 usecs to free memory

Signed-off-by: Hui Zhu <teawaterz@linux.alibaba.com>
---
 include/linux/swap.h |  3 +++
 mm/Kconfig           | 11 +++++++++++
 mm/page_io.c         | 16 +++++++++++++++
 mm/zswap.c           | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 85 insertions(+)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index de2c67a..82b621f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -389,6 +389,9 @@ extern void end_swap_bio_write(struct bio *bio);
 extern int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	bio_end_io_t end_write_func);
 extern int swap_set_page_dirty(struct page *page);
+#ifdef CONFIG_ZSWAP_IO_SWITCH
+extern void swap_io_in_flight(struct page *page, unsigned int inflight[2]);
+#endif
 
 int add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
 		unsigned long nr_pages, sector_t start_block);
diff --git a/mm/Kconfig b/mm/Kconfig
index 56cec63..d077e51 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -546,6 +546,17 @@ config ZSWAP
 	  they have not be fully explored on the large set of potential
 	  configurations and workloads that exist.
 
+config ZSWAP_IO_SWITCH
+	bool "Compressed cache for swap pages according to the IO status"
+	depends on ZSWAP
+	def_bool n
+	help
+	  Add two parameters read_in_flight_limit and write_in_flight_limit to
+	  ZSWAP.  When ZSWAP is enabled, pages will be stored to zswap only
+	  when the IO in flight number of swap device is bigger than
+	  zswap_read_in_flight_limit or zswap_write_in_flight_limit.
+	  If unsure, say "n".
+
 config ZPOOL
 	tristate "Common API for compressed memory storage"
 	help
diff --git a/mm/page_io.c b/mm/page_io.c
index 24ee600..e66b050 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -434,3 +434,19 @@ int swap_set_page_dirty(struct page *page)
 		return __set_page_dirty_no_writeback(page);
 	}
 }
+
+#ifdef CONFIG_ZSWAP_IO_SWITCH
+void swap_io_in_flight(struct page *page, unsigned int inflight[2])
+{
+	struct swap_info_struct *sis = page_swap_info(page);
+
+	if (!sis->bdev) {
+		inflight[0] = 0;
+		inflight[1] = 0;
+		return;
+	}
+
+	part_in_flight_rw(bdev_get_queue(sis->bdev), sis->bdev->bd_part,
+					  inflight);
+}
+#endif
diff --git a/mm/zswap.c b/mm/zswap.c
index 0e22744..1255645 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -62,6 +62,13 @@ static u64 zswap_reject_compress_poor;
 static u64 zswap_reject_alloc_fail;
 /* Store failed because the entry metadata could not be allocated (rare) */
 static u64 zswap_reject_kmemcache_fail;
+#ifdef CONFIG_ZSWAP_IO_SWITCH
+/* Store failed because zswap_read_in_flight_limit or
+ * zswap_write_in_flight_limit is bigger than IO in flight number of
+ * swap device
+ */
+static u64 zswap_reject_io;
+#endif
 /* Duplicate store was encountered (rare) */
 static u64 zswap_duplicate_entry;
 
@@ -114,6 +121,22 @@ static bool zswap_same_filled_pages_enabled = true;
 module_param_named(same_filled_pages_enabled, zswap_same_filled_pages_enabled,
 		   bool, 0644);
 
+#ifdef CONFIG_ZSWAP_IO_SWITCH
+/* zswap will not try to store the page if zswap_read_in_flight_limit is
+ * bigger than IO read in flight number of swap device
+ */
+static unsigned int zswap_read_in_flight_limit;
+module_param_named(read_in_flight_limit, zswap_read_in_flight_limit,
+		   uint, 0644);
+
+/* zswap will not try to store the page if zswap_write_in_flight_limit is
+ * bigger than IO write in flight number of swap device
+ */
+static unsigned int zswap_write_in_flight_limit;
+module_param_named(write_in_flight_limit, zswap_write_in_flight_limit,
+		   uint, 0644);
+#endif
+
 /*********************************
 * data structures
 **********************************/
@@ -1009,6 +1032,34 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 		goto reject;
 	}
 
+#ifdef CONFIG_ZSWAP_IO_SWITCH
+	if (zswap_read_in_flight_limit || zswap_write_in_flight_limit) {
+		unsigned int inflight[2];
+		bool should_swap = false;
+
+		swap_io_in_flight(page, inflight);
+
+		if (zswap_write_in_flight_limit &&
+			inflight[1] < zswap_write_in_flight_limit)
+			should_swap = true;
+
+		if (zswap_read_in_flight_limit &&
+			(should_swap ||
+			 (!should_swap && !zswap_write_in_flight_limit))) {
+			if (inflight[0] < zswap_read_in_flight_limit)
+				should_swap = true;
+			else
+				should_swap = false;
+		}
+
+		if (should_swap) {
+			zswap_reject_io++;
+			ret = -EIO;
+			goto reject;
+		}
+	}
+#endif
+
 	/* reclaim space if needed */
 	if (zswap_is_full()) {
 		zswap_pool_limit_hit++;
@@ -1264,6 +1315,10 @@ static int __init zswap_debugfs_init(void)
 			   zswap_debugfs_root, &zswap_reject_kmemcache_fail);
 	debugfs_create_u64("reject_compress_poor", 0444,
 			   zswap_debugfs_root, &zswap_reject_compress_poor);
+#ifdef CONFIG_ZSWAP_IO_SWITCH
+	debugfs_create_u64("reject_io", 0444,
+			   zswap_debugfs_root, &zswap_reject_io);
+#endif
 	debugfs_create_u64("written_back_pages", 0444,
 			   zswap_debugfs_root, &zswap_written_back_pages);
 	debugfs_create_u64("duplicate_entry", 0444,
-- 
2.7.4


