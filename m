Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 524E282F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 16:12:36 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so50031378pad.1
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 13:12:36 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id yw10si4839560pac.86.2015.10.29.13.12.31
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 13:12:31 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC 03/11] pmem: enable REQ_FLUSH handling
Date: Thu, 29 Oct 2015 14:12:07 -0600
Message-Id: <1446149535-16200-4-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

Currently the PMEM driver doesn't accept REQ_FLUSH bios.  These are sent
down via blkdev_issue_flush() in response to a fsync() or msync().

When we get an msync() or fsync() it is the responsibility of the DAX code
to flush all dirty pages to media.  The PMEM driver then just has issue a
wmb_pmem() in response to the REQ_FLUSH to ensure that before we return all
the flushed data has been durably stored on the media.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 drivers/nvdimm/pmem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 0ba6a97..e1e222e 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -80,7 +80,7 @@ static void pmem_make_request(struct request_queue *q, struct bio *bio)
 	if (do_acct)
 		nd_iostat_end(bio, start);
 
-	if (bio_data_dir(bio))
+	if (bio_data_dir(bio) || (bio->bi_rw & REQ_FLUSH))
 		wmb_pmem();
 
 	bio_endio(bio);
@@ -189,6 +189,7 @@ static int pmem_attach_disk(struct device *dev,
 	blk_queue_physical_block_size(pmem->pmem_queue, PAGE_SIZE);
 	blk_queue_max_hw_sectors(pmem->pmem_queue, UINT_MAX);
 	blk_queue_bounce_limit(pmem->pmem_queue, BLK_BOUNCE_ANY);
+	blk_queue_flush(pmem->pmem_queue, REQ_FLUSH);
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, pmem->pmem_queue);
 
 	disk = alloc_disk(0);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
