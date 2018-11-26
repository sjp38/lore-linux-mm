Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9C06B3F66
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:18:05 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 98so17818932qkp.22
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:18:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s16si5789310qtk.382.2018.11.25.18.18.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 18:18:04 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V12 02/20] btrfs: look at bi_size for repair decisions
Date: Mon, 26 Nov 2018 10:17:02 +0800
Message-Id: <20181126021720.19471-3-ming.lei@redhat.com>
In-Reply-To: <20181126021720.19471-1-ming.lei@redhat.com>
References: <20181126021720.19471-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

From: Christoph Hellwig <hch@lst.de>

bio_readpage_error currently uses bi_vcnt to decide if it is worth
retrying an I/O.  But the vector count is mostly an implementation
artifact - it really should figure out if there is more than a
single sector worth retrying.  Use bi_size for that and shift by
PAGE_SHIFT.  This really should be blocks/sectors, but given that
btrfs doesn't support a sector size different from the PAGE_SIZE
using the page size keeps the changes to a minimum.

Reviewed-by: David Sterba <dsterba@suse.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/btrfs/extent_io.c | 2 +-
 include/linux/bio.h  | 6 ------
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 15fd46582bb2..40751e86a2a9 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2368,7 +2368,7 @@ static int bio_readpage_error(struct bio *failed_bio, u64 phy_offset,
 	int read_mode = 0;
 	blk_status_t status;
 	int ret;
-	unsigned failed_bio_pages = bio_pages_all(failed_bio);
+	unsigned failed_bio_pages = failed_bio->bi_iter.bi_size >> PAGE_SHIFT;
 
 	BUG_ON(bio_op(failed_bio) == REQ_OP_WRITE);
 
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 056fb627edb3..6f6bc331a5d1 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -263,12 +263,6 @@ static inline void bio_get_last_bvec(struct bio *bio, struct bio_vec *bv)
 		bv->bv_len = iter.bi_bvec_done;
 }
 
-static inline unsigned bio_pages_all(struct bio *bio)
-{
-	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
-	return bio->bi_vcnt;
-}
-
 static inline struct bio_vec *bio_first_bvec_all(struct bio *bio)
 {
 	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
-- 
2.9.5
