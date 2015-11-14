Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1276B0255
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 19:07:35 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so114819429pab.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:07:35 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gh4si30579815pbc.211.2015.11.13.16.07.32
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 16:07:32 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 03/11] pmem: enable REQ_FUA/REQ_FLUSH handling
Date: Fri, 13 Nov 2015 17:06:42 -0700
Message-Id: <1447459610-14259-4-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

Currently the PMEM driver doesn't accept REQ_FLUSH or REQ_FUA bios.  These
are sent down via blkdev_issue_flush() in response to a fsync() or msync()
and are used by filesystems to order their metadata, among other things.

When we get an msync() or fsync() it is the responsibility of the DAX code
to flush all dirty pages to media.  The PMEM driver then just has issue a
wmb_pmem() in response to the REQ_FLUSH to ensure that before we return all
the flushed data has been durably stored on the media.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 drivers/nvdimm/pmem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 0ba6a97..b914d66 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -80,7 +80,7 @@ static void pmem_make_request(struct request_queue *q, struct bio *bio)
 	if (do_acct)
 		nd_iostat_end(bio, start);
 
-	if (bio_data_dir(bio))
+	if (bio_data_dir(bio) || (bio->bi_rw & (REQ_FLUSH|REQ_FUA)))
 		wmb_pmem();
 
 	bio_endio(bio);
@@ -189,6 +189,7 @@ static int pmem_attach_disk(struct device *dev,
 	blk_queue_physical_block_size(pmem->pmem_queue, PAGE_SIZE);
 	blk_queue_max_hw_sectors(pmem->pmem_queue, UINT_MAX);
 	blk_queue_bounce_limit(pmem->pmem_queue, BLK_BOUNCE_ANY);
+	blk_queue_flush(pmem->pmem_queue, REQ_FLUSH|REQ_FUA);
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, pmem->pmem_queue);
 
 	disk = alloc_disk(0);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
