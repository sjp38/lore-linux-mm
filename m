Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1942A6B0272
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:24:43 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id d76so6950820oig.12
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:24:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h132si3695899oib.274.2017.12.18.04.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:24:42 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 07/45] bcache: comment on direct access to bvec table
Date: Mon, 18 Dec 2017 20:22:09 +0800
Message-Id: <20171218122247.3488-8-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>, linux-bcache@vger.kernel.org

All direct access to bvec table are safe even after multipage bvec is supported.

Cc: linux-bcache@vger.kernel.org
Acked-by: Coly Li <colyli@suse.de>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/bcache/btree.c | 1 +
 drivers/md/bcache/util.c  | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index 81e8dc3dbe5e..02a4cf646fdc 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -432,6 +432,7 @@ static void do_btree_node_write(struct btree *b)
 
 		continue_at(cl, btree_node_write_done, NULL);
 	} else {
+		/* No problem for multipage bvec since the bio is just allocated */
 		b->bio->bi_vcnt = 0;
 		bch_bio_map(b->bio, i);
 
diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
index e548b8b51322..61813d230015 100644
--- a/drivers/md/bcache/util.c
+++ b/drivers/md/bcache/util.c
@@ -249,6 +249,13 @@ uint64_t bch_next_delay(struct bch_ratelimit *d, uint64_t done)
 		: 0;
 }
 
+/*
+ * Generally it isn't good to access .bi_io_vec and .bi_vcnt directly,
+ * the preferred way is bio_add_page, but in this case, bch_bio_map()
+ * supposes that the bvec table is empty, so it is safe to access
+ * .bi_vcnt & .bi_io_vec in this way even after multipage bvec is
+ * supported.
+ */
 void bch_bio_map(struct bio *bio, void *base)
 {
 	size_t size = bio->bi_iter.bi_size;
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
