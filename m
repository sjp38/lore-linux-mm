Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED636B0293
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:29:19 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id u126so7033357oia.19
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:29:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f207si3719994oib.520.2017.12.18.04.29.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:29:18 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 24/45] btrfs: use segment_last_page to get bio's last page
Date: Mon, 18 Dec 2017 20:22:26 +0800
Message-Id: <20171218122247.3488-25-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org

Preparing for supporting multipage bvec.

Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
Cc: David Sterba <dsterba@suse.com>
Cc: linux-btrfs@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/btrfs/compression.c | 5 ++++-
 fs/btrfs/extent_io.c   | 5 +++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 15430c9fc6d7..1a62725a5f08 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -412,8 +412,11 @@ blk_status_t btrfs_submit_compressed_write(struct inode *inode, u64 start,
 static u64 bio_end_offset(struct bio *bio)
 {
 	struct bio_vec *last = bio_last_bvec_all(bio);
+	struct bio_vec bv;
 
-	return page_offset(last->bv_page) + last->bv_len + last->bv_offset;
+	segment_last_page(last, &bv);
+
+	return page_offset(bv.bv_page) + bv.bv_len + bv.bv_offset;
 }
 
 static noinline int add_ra_bio_pages(struct inode *inode,
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 6984e0d5b00d..f466289b66a3 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2726,11 +2726,12 @@ static int __must_check submit_one_bio(struct bio *bio, int mirror_num,
 {
 	blk_status_t ret = 0;
 	struct bio_vec *bvec = bio_last_bvec_all(bio);
-	struct page *page = bvec->bv_page;
+	struct bio_vec bv;
 	struct extent_io_tree *tree = bio->bi_private;
 	u64 start;
 
-	start = page_offset(page) + bvec->bv_offset;
+	segment_last_page(bvec, &bv);
+	start = page_offset(bv.bv_page) + bv.bv_offset;
 
 	bio->bi_private = NULL;
 	bio_get(bio);
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
