Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id BACF98E0025
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:18:35 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id w185so18684484qka.9
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:18:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q7si344465qvc.195.2019.01.21.00.18.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:18:35 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V14 01/18] btrfs: look at bi_size for repair decisions
Date: Mon, 21 Jan 2019 16:17:48 +0800
Message-Id: <20190121081805.32727-2-ming.lei@redhat.com>
In-Reply-To: <20190121081805.32727-1-ming.lei@redhat.com>
References: <20190121081805.32727-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

From: Christoph Hellwig <hch@lst.de>

bio_readpage_error currently uses bi_vcnt to decide if it is worth
retrying an I/O.  But the vector count is mostly an implementation
artifact - it really should figure out if there is more than a
single sector worth retrying.  Use bi_size for that and shift by
PAGE_SHIFT.  This really should be blocks/sectors, but given that
btrfs doesn't support a sector size different from the PAGE_SIZE
using the page size keeps the changes to a minimum.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Reviewed-by: David Sterba <dsterba@suse.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/btrfs/extent_io.c | 2 +-
 include/linux/bio.h  | 6 ------
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 52abe4082680..dc8ba3ee515d 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2350,7 +2350,7 @@ static int bio_readpage_error(struct bio *failed_bio, u64 phy_offset,
 	int read_mode = 0;
 	blk_status_t status;
 	int ret;
-	unsigned failed_bio_pages = bio_pages_all(failed_bio);
+	unsigned failed_bio_pages = failed_bio->bi_iter.bi_size >> PAGE_SHIFT;
 
 	BUG_ON(bio_op(failed_bio) == REQ_OP_WRITE);
 
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 7380b094dcca..72b4f7be2106 100644
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
