Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E34D6B025F
	for <linux-mm@kvack.org>; Sat, 23 Apr 2016 15:14:03 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so205883729pab.2
        for <linux-mm@kvack.org>; Sat, 23 Apr 2016 12:14:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id k74si14814729pfb.30.2016.04.23.12.14.02
        for <linux-mm@kvack.org>;
        Sat, 23 Apr 2016 12:14:02 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v3 3/7] dax: enable dax in the presence of known media errors (badblocks)
Date: Sat, 23 Apr 2016 13:13:38 -0600
Message-Id: <1461438822-3592-4-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1461438822-3592-1-git-send-email-vishal.l.verma@intel.com>
References: <1461438822-3592-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dan Williams <dan.j.williams@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: Dan Williams <dan.j.williams@intel.com>

1/ If a mapping overlaps a bad sector fail the request.

2/ Do not opportunistically report more dax-capable capacity than is
   requested when errors present.

[vishal: fix a conflict with system RAM collision patches]
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 block/ioctl.c         | 9 ---------
 drivers/nvdimm/pmem.c | 8 ++++++++
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/block/ioctl.c b/block/ioctl.c
index 4ff1f92..bf80bfd 100644
--- a/block/ioctl.c
+++ b/block/ioctl.c
@@ -423,15 +423,6 @@ bool blkdev_dax_capable(struct block_device *bdev)
 			|| (bdev->bd_part->nr_sects % (PAGE_SIZE / 512)))
 		return false;
 
-	/*
-	 * If the device has known bad blocks, force all I/O through the
-	 * driver / page cache.
-	 *
-	 * TODO: support finer grained dax error handling
-	 */
-	if (disk->bb && disk->bb->count)
-		return false;
-
 	return true;
 }
 #endif
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index f72733c..4567d9a 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -188,9 +188,17 @@ static long pmem_direct_access(struct block_device *bdev,
 	struct pmem_device *pmem = bdev->bd_disk->private_data;
 	resource_size_t offset = sector * 512 + pmem->data_offset;
 
+	if (unlikely(is_bad_pmem(&pmem->bb, sector, dax->size)))
+		return -EIO;
 	dax->addr = pmem->virt_addr + offset;
 	dax->pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
 
+	/*
+	 * If badblocks are present, limit known good range to the
+	 * requested range.
+	 */
+	if (unlikely(pmem->bb.count))
+		return dax->size;
 	return pmem->size - pmem->pfn_pad - offset;
 }
 
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
