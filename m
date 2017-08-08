Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8418C6B03AB
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:48:11 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q198so12969235qke.13
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:48:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s4si762917qks.546.2017.08.08.01.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:48:10 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 11/49] btrfs: avoid access to .bi_vcnt directly
Date: Tue,  8 Aug 2017 16:45:10 +0800
Message-Id: <20170808084548.18963-12-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org

BTRFS uses bio->bi_vcnt to figure out page numbers, this
way becomes not correct once we start to enable multipage
bvec.

So use bio_for_each_segment_all() to do that instead.

Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
Cc: David Sterba <dsterba@suse.com>
Cc: linux-btrfs@vger.kernel.org
Acked-by: David Sterba <dsterba@suse.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/btrfs/extent_io.c | 20 ++++++++++++++++----
 fs/btrfs/extent_io.h |  2 +-
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 0aff9b278c19..0e7367817b92 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2258,7 +2258,7 @@ int btrfs_get_io_failure_record(struct inode *inode, u64 start, u64 end,
 	return 0;
 }
 
-bool btrfs_check_repairable(struct inode *inode, struct bio *failed_bio,
+bool btrfs_check_repairable(struct inode *inode, unsigned failed_bio_pages,
 			   struct io_failure_record *failrec, int failed_mirror)
 {
 	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -2282,7 +2282,7 @@ bool btrfs_check_repairable(struct inode *inode, struct bio *failed_bio,
 	 *	a) deliver good data to the caller
 	 *	b) correct the bad sectors on disk
 	 */
-	if (failed_bio->bi_vcnt > 1) {
+	if (failed_bio_pages > 1) {
 		/*
 		 * to fulfill b), we need to know the exact failing sectors, as
 		 * we don't want to rewrite any more than the failed ones. thus,
@@ -2355,6 +2355,17 @@ struct bio *btrfs_create_repair_bio(struct inode *inode, struct bio *failed_bio,
 	return bio;
 }
 
+static unsigned int get_bio_pages(struct bio *bio)
+{
+	unsigned i;
+	struct bio_vec *bv;
+
+	bio_for_each_segment_all(bv, bio, i)
+		;
+
+	return i;
+}
+
 /*
  * this is a generic handler for readpage errors (default
  * readpage_io_failed_hook). if other copies exist, read those and write back
@@ -2375,6 +2386,7 @@ static int bio_readpage_error(struct bio *failed_bio, u64 phy_offset,
 	int read_mode = 0;
 	blk_status_t status;
 	int ret;
+	unsigned failed_bio_pages = get_bio_pages(failed_bio);
 
 	BUG_ON(bio_op(failed_bio) == REQ_OP_WRITE);
 
@@ -2382,13 +2394,13 @@ static int bio_readpage_error(struct bio *failed_bio, u64 phy_offset,
 	if (ret)
 		return ret;
 
-	if (!btrfs_check_repairable(inode, failed_bio, failrec,
+	if (!btrfs_check_repairable(inode, failed_bio_pages, failrec,
 				    failed_mirror)) {
 		free_io_failure(failure_tree, tree, failrec);
 		return -EIO;
 	}
 
-	if (failed_bio->bi_vcnt > 1)
+	if (failed_bio_pages > 1)
 		read_mode |= REQ_FAILFAST_DEV;
 
 	phy_offset >>= inode->i_sb->s_blocksize_bits;
diff --git a/fs/btrfs/extent_io.h b/fs/btrfs/extent_io.h
index 4f030912f3ef..300ee10f39f2 100644
--- a/fs/btrfs/extent_io.h
+++ b/fs/btrfs/extent_io.h
@@ -539,7 +539,7 @@ void btrfs_free_io_failure_record(struct btrfs_inode *inode, u64 start,
 		u64 end);
 int btrfs_get_io_failure_record(struct inode *inode, u64 start, u64 end,
 				struct io_failure_record **failrec_ret);
-bool btrfs_check_repairable(struct inode *inode, struct bio *failed_bio,
+bool btrfs_check_repairable(struct inode *inode, unsigned failed_bio_pages,
 			    struct io_failure_record *failrec, int fail_mirror);
 struct bio *btrfs_create_repair_bio(struct inode *inode, struct bio *failed_bio,
 				    struct io_failure_record *failrec,
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
