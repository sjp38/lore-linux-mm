Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id E50636B0274
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:25:10 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id z30so8920384otd.9
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:25:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q32si325795otc.318.2017.12.18.04.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:25:10 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 09/45] btrfs: avoid access to .bi_vcnt directly
Date: Mon, 18 Dec 2017 20:22:11 +0800
Message-Id: <20171218122247.3488-10-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org

BTRFS uses bio->bi_vcnt to figure out page numbers, this way becomes not
correct once we start to enable multipage bvec.

So use bio_nr_pages() to do that instead.

Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
Cc: David Sterba <dsterba@suse.com>
Cc: linux-btrfs@vger.kernel.org
Acked-by: David Sterba <dsterba@suse.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/btrfs/extent_io.c | 9 +++++----
 fs/btrfs/extent_io.h | 2 +-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 69cd63d4503d..d43360b33ef6 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2257,7 +2257,7 @@ int btrfs_get_io_failure_record(struct inode *inode, u64 start, u64 end,
 	return 0;
 }
 
-bool btrfs_check_repairable(struct inode *inode, struct bio *failed_bio,
+bool btrfs_check_repairable(struct inode *inode, unsigned failed_bio_pages,
 			   struct io_failure_record *failrec, int failed_mirror)
 {
 	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -2281,7 +2281,7 @@ bool btrfs_check_repairable(struct inode *inode, struct bio *failed_bio,
 	 *	a) deliver good data to the caller
 	 *	b) correct the bad sectors on disk
 	 */
-	if (failed_bio->bi_vcnt > 1) {
+	if (failed_bio_pages > 1) {
 		/*
 		 * to fulfill b), we need to know the exact failing sectors, as
 		 * we don't want to rewrite any more than the failed ones. thus,
@@ -2374,6 +2374,7 @@ static int bio_readpage_error(struct bio *failed_bio, u64 phy_offset,
 	int read_mode = 0;
 	blk_status_t status;
 	int ret;
+	unsigned failed_bio_pages = bio_pages_all(failed_bio);
 
 	BUG_ON(bio_op(failed_bio) == REQ_OP_WRITE);
 
@@ -2381,13 +2382,13 @@ static int bio_readpage_error(struct bio *failed_bio, u64 phy_offset,
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
index 93dcae0c3183..20854d63c75b 100644
--- a/fs/btrfs/extent_io.h
+++ b/fs/btrfs/extent_io.h
@@ -540,7 +540,7 @@ void btrfs_free_io_failure_record(struct btrfs_inode *inode, u64 start,
 		u64 end);
 int btrfs_get_io_failure_record(struct inode *inode, u64 start, u64 end,
 				struct io_failure_record **failrec_ret);
-bool btrfs_check_repairable(struct inode *inode, struct bio *failed_bio,
+bool btrfs_check_repairable(struct inode *inode, unsigned failed_bio_pages,
 			    struct io_failure_record *failrec, int fail_mirror);
 struct bio *btrfs_create_repair_bio(struct inode *inode, struct bio *failed_bio,
 				    struct io_failure_record *failrec,
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
