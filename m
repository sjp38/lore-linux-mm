Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 526EB6B026C
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:23:47 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id v8so8914570otd.4
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:23:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w64si3760040oif.480.2017.12.18.04.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:23:46 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 03/45] fs: convert to bio_last_bvec_all()
Date: Mon, 18 Dec 2017 20:22:05 +0800
Message-Id: <20171218122247.3488-4-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

This patch convers 3 users to bio_last_bvec_all(), so that we can go
ahread to convert to multipage bvec.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/btrfs/compression.c | 2 +-
 fs/btrfs/extent_io.c   | 2 +-
 fs/buffer.c            | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 38a6b091bc25..75610d23d197 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -411,7 +411,7 @@ blk_status_t btrfs_submit_compressed_write(struct inode *inode, u64 start,
 
 static u64 bio_end_offset(struct bio *bio)
 {
-	struct bio_vec *last = &bio->bi_io_vec[bio->bi_vcnt - 1];
+	struct bio_vec *last = bio_last_bvec_all(bio);
 
 	return page_offset(last->bv_page) + last->bv_len + last->bv_offset;
 }
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 012d63870b99..69cd63d4503d 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2724,7 +2724,7 @@ static int __must_check submit_one_bio(struct bio *bio, int mirror_num,
 				       unsigned long bio_flags)
 {
 	blk_status_t ret = 0;
-	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
+	struct bio_vec *bvec = bio_last_bvec_all(bio);
 	struct page *page = bvec->bv_page;
 	struct extent_io_tree *tree = bio->bi_private;
 	u64 start;
diff --git a/fs/buffer.c b/fs/buffer.c
index 0736a6a2e2f0..8b26295a56fe 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3014,7 +3014,7 @@ static void end_bio_bh_io_sync(struct bio *bio)
 void guard_bio_eod(int op, struct bio *bio)
 {
 	sector_t maxsector;
-	struct bio_vec *bvec = &bio->bi_io_vec[bio->bi_vcnt - 1];
+	struct bio_vec *bvec = bio_last_bvec_all(bio);
 	unsigned truncated_bytes;
 	struct hd_struct *part;
 
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
