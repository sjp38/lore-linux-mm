Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3986B0298
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 08:35:50 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u127-v6so15542228qka.9
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 05:35:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c85-v6si335091qkj.206.2018.06.09.05.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 05:35:49 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V6 28/30] block: enable multipage bvecs
Date: Sat,  9 Jun 2018 20:30:12 +0800
Message-Id: <20180609123014.8861-29-ming.lei@redhat.com>
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
References: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

This patch pulls the trigger for multipage bvecs.

Now any request queue which supports queue cluster will see multipage
bvecs.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 276fc35ec559..284085ab97e7 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -870,12 +870,23 @@ bool __bio_try_merge_page(struct bio *bio, struct page *page,
 
 	if (bio->bi_vcnt > 0) {
 		struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
-
-		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
-			bv->bv_len += len;
-			bio->bi_iter.bi_size += len;
-			return true;
-		}
+		struct request_queue *q = NULL;
+
+		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len)
+			goto merge;
+
+		if (bio->bi_disk)
+			q = bio->bi_disk->queue;
+
+		/* disable multipage bvec too if cluster isn't enabled */
+		if (!q || !blk_queue_cluster(q) ||
+		    (bvec_to_phys(bv) + bv->bv_len !=
+		     page_to_phys(page) + off))
+			return false;
+ merge:
+		bv->bv_len += len;
+		bio->bi_iter.bi_size += len;
+		return true;
 	}
 	return false;
 }
-- 
2.9.5
