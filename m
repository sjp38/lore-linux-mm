Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24A6D6B02FD
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 03:14:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v9so33906002pfk.5
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 00:14:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a22si2693991pfa.431.2017.06.23.00.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 00:14:53 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v2 05/12] block, THP: Make block_device_operations.rw_page support THP
Date: Fri, 23 Jun 2017 15:12:56 +0800
Message-Id: <20170623071303.13469-6-ying.huang@intel.com>
In-Reply-To: <20170623071303.13469-1-ying.huang@intel.com>
References: <20170623071303.13469-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, Jens Axboe <axboe@kernel.dk>

From: Huang Ying <ying.huang@intel.com>

The .rw_page in struct block_device_operations is used by the swap
subsystem to read/write the page contents from/into the corresponding
swap slot in the swap device.  To support the THP (Transparent Huge
Page) swap optimization, the .rw_page is enhanced to support to
read/write THP if possible.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@intel.com> [for brd.c, zram_drv.c, pmem.c]
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Vishal L Verma <vishal.l.verma@intel.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: linux-nvdimm@lists.01.org
---
 drivers/block/brd.c           |  6 +++++-
 drivers/block/zram/zram_drv.c |  2 ++
 drivers/nvdimm/btt.c          |  4 +++-
 drivers/nvdimm/pmem.c         | 41 ++++++++++++++++++++++++++++++-----------
 4 files changed, 40 insertions(+), 13 deletions(-)

diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 57b574f2f66a..4240d2a9dcf9 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -324,7 +324,11 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
 		       struct page *page, bool is_write)
 {
 	struct brd_device *brd = bdev->bd_disk->private_data;
-	int err = brd_do_bvec(brd, page, PAGE_SIZE, 0, is_write, sector);
+	int err;
+
+	if (PageTransHuge(page))
+		return -ENOTSUPP;
+	err = brd_do_bvec(brd, page, PAGE_SIZE, 0, is_write, sector);
 	page_endio(page, is_write, err);
 	return err;
 }
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index d3e3af22a088..9f4973f6ba56 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -927,6 +927,8 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
 	struct zram *zram;
 	struct bio_vec bv;
 
+	if (PageTransHuge(page))
+		return -ENOTSUPP;
 	zram = bdev->bd_disk->private_data;
 
 	if (!valid_io_request(zram, sector, PAGE_SIZE)) {
diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
index 31b2d14e210d..6ec2250b5276 100644
--- a/drivers/nvdimm/btt.c
+++ b/drivers/nvdimm/btt.c
@@ -1248,8 +1248,10 @@ static int btt_rw_page(struct block_device *bdev, sector_t sector,
 		struct page *page, bool is_write)
 {
 	struct btt *btt = bdev->bd_disk->private_data;
+	unsigned int len;
 
-	btt_do_bvec(btt, NULL, page, PAGE_SIZE, 0, is_write, sector);
+	len = hpage_nr_pages(page) * PAGE_SIZE;
+	btt_do_bvec(btt, NULL, page, len, 0, is_write, sector);
 	page_endio(page, is_write, 0);
 	return 0;
 }
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 7bd383aeea14..72e3fbaefee9 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -78,22 +78,40 @@ static blk_status_t pmem_clear_poison(struct pmem_device *pmem,
 static void write_pmem(void *pmem_addr, struct page *page,
 		unsigned int off, unsigned int len)
 {
-	void *mem = kmap_atomic(page);
-
-	memcpy_to_pmem(pmem_addr, mem + off, len);
-	kunmap_atomic(mem);
+	unsigned int chunk;
+	void *mem;
+
+	while (len) {
+		mem = kmap_atomic(page);
+		chunk = min_t(unsigned int, len, PAGE_SIZE);
+		memcpy_to_pmem(pmem_addr, mem + off, chunk);
+		kunmap_atomic(mem);
+		len -= chunk;
+		off = 0;
+		page++;
+		pmem_addr += PAGE_SIZE;
+	}
 }
 
 static blk_status_t read_pmem(struct page *page, unsigned int off,
 		void *pmem_addr, unsigned int len)
 {
+	unsigned int chunk;
 	int rc;
-	void *mem = kmap_atomic(page);
-
-	rc = memcpy_mcsafe(mem + off, pmem_addr, len);
-	kunmap_atomic(mem);
-	if (rc)
-		return BLK_STS_IOERR;
+	void *mem;
+
+	while (len) {
+		mem = kmap_atomic(page);
+		chunk = min_t(unsigned int, len, PAGE_SIZE);
+		rc = memcpy_mcsafe(mem + off, pmem_addr, chunk);
+		kunmap_atomic(mem);
+		if (rc)
+			return BLK_STS_IOERR;
+		len -= chunk;
+		off = 0;
+		page++;
+		pmem_addr += PAGE_SIZE;
+	}
 	return BLK_STS_OK;
 }
 
@@ -186,7 +204,8 @@ static int pmem_rw_page(struct block_device *bdev, sector_t sector,
 	struct pmem_device *pmem = bdev->bd_queue->queuedata;
 	blk_status_t rc;
 
-	rc = pmem_do_bvec(pmem, page, PAGE_SIZE, 0, is_write, sector);
+	rc = pmem_do_bvec(pmem, page, hpage_nr_pages(page) * PAGE_SIZE,
+			  0, is_write, sector);
 
 	/*
 	 * The ->rw_page interface is subtle and tricky.  The core
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
