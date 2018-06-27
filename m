Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id ACE7E6B0269
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:46:26 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l10-v6so1860359qth.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:46:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s10-v6si1176415qvd.106.2018.06.27.05.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:46:25 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V7 02/24] bcache: don't clone bio in bch_data_verify
Date: Wed, 27 Jun 2018 20:45:26 +0800
Message-Id: <20180627124548.3456-3-ming.lei@redhat.com>
In-Reply-To: <20180627124548.3456-1-ming.lei@redhat.com>
References: <20180627124548.3456-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Christoph Hellwig <hch@lst.de>

From: Christoph Hellwig <hch@lst.de>

We immediately overwrite the biovec array, so instead just allocate
a new bio and copy over the disk, setor and size.

Acked-by: Coly Li <colyli@suse.de>
Reviewed-by: Ming Lei <ming.lei@redhat.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/md/bcache/debug.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/md/bcache/debug.c b/drivers/md/bcache/debug.c
index d030ce3025a6..04d146711950 100644
--- a/drivers/md/bcache/debug.c
+++ b/drivers/md/bcache/debug.c
@@ -110,11 +110,15 @@ void bch_data_verify(struct cached_dev *dc, struct bio *bio)
 	struct bio_vec bv, cbv;
 	struct bvec_iter iter, citer = { 0 };
 
-	check = bio_clone_kmalloc(bio, GFP_NOIO);
+	check = bio_kmalloc(GFP_NOIO, bio_segments(bio));
 	if (!check)
 		return;
+	check->bi_disk = bio->bi_disk;
 	check->bi_opf = REQ_OP_READ;
+	check->bi_iter.bi_sector = bio->bi_iter.bi_sector;
+	check->bi_iter.bi_size = bio->bi_iter.bi_size;
 
+	bch_bio_map(check, NULL);
 	if (bch_bio_alloc_pages(check, GFP_NOIO))
 		goto out_put;
 
-- 
2.9.5
