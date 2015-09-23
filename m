Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9B76B025A
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:47:44 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so29377829pad.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:47:44 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yq4si7647457pbb.236.2015.09.22.21.47.43
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:47:43 -0700 (PDT)
Subject: [PATCH 09/15] block, pmem: fix null pointer de-reference on shutdown,
 check for queue death
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:42:00 -0400
Message-ID: <20150923044200.36490.54494.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jens Axboe <axboe@kernel.dk>, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

After the driver has been unbound the queue is dead and the private data
pointer is invalid.  Check that the queue is still alive, or otherwise
pin it active before using queuedata.

Fixes crash signatures like the following.

 BUG: unable to handle kernel paging request at ffff880140000000
 [..]
 Call Trace:
  [<ffffffff8145e8bf>] ? copy_user_handle_tail+0x5f/0x70
  [<ffffffffa004e1e0>] pmem_do_bvec.isra.11+0x70/0xf0 [nd_pmem]
  [<ffffffffa004e331>] pmem_make_request+0xd1/0x200 [nd_pmem]
  [<ffffffff811c3162>] ? mempool_alloc+0x72/0x1a0
  [<ffffffff8141f8b6>] generic_make_request+0xd6/0x110
  [<ffffffff8141f966>] submit_bio+0x76/0x170
  [<ffffffff81286dff>] submit_bh_wbc+0x12f/0x160
  [<ffffffff81286e62>] submit_bh+0x12/0x20
  [<ffffffff813395bd>] jbd2_write_superblock+0x8d/0x170
  [<ffffffff8133974d>] jbd2_mark_journal_empty+0x5d/0x90
  [<ffffffff813399cb>] jbd2_journal_destroy+0x24b/0x270
  [<ffffffff810bc4ca>] ? put_pwq_unlocked+0x2a/0x30
  [<ffffffff810bc6f5>] ? destroy_workqueue+0x225/0x250
  [<ffffffff81303494>] ext4_put_super+0x64/0x360
  [<ffffffff8124ab1a>] generic_shutdown_super+0x6a/0xf0

Cc: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 block/blk-core.c      |    2 ++
 drivers/nvdimm/pmem.c |    8 ++++++++
 2 files changed, 10 insertions(+)

diff --git a/block/blk-core.c b/block/blk-core.c
index 13764f8b22e0..0ea7d285b886 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -532,11 +532,13 @@ int blk_dax_get(struct request_queue *q)
 {
 	return blk_qref_enter(&q->dax_ref, GFP_NOWAIT);
 }
+EXPORT_SYMBOL(blk_dax_get);
 
 void blk_dax_put(struct request_queue *q)
 {
 	percpu_ref_put(&q->dax_ref.count);
 }
+EXPORT_SYMBOL(blk_dax_put);
 
 static void blk_dax_freeze(struct request_queue *q)
 {
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index a01611d8f351..3ee02af73ad0 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -73,6 +73,12 @@ static void pmem_make_request(struct request_queue *q, struct bio *bio)
 	struct block_device *bdev = bio->bi_bdev;
 	struct pmem_device *pmem = bdev->bd_disk->private_data;
 
+	if (blk_dax_get(q) != 0) {
+		bio->bi_error = -ENODEV;
+		bio_endio(bio);
+		return;
+	}
+
 	do_acct = nd_iostat_start(bio, &start);
 	bio_for_each_segment(bvec, bio, iter)
 		pmem_do_bvec(pmem, bvec.bv_page, bvec.bv_len, bvec.bv_offset,
@@ -84,6 +90,8 @@ static void pmem_make_request(struct request_queue *q, struct bio *bio)
 		wmb_pmem();
 
 	bio_endio(bio);
+
+	blk_dax_put(q);
 }
 
 static int pmem_rw_page(struct block_device *bdev, sector_t sector,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
