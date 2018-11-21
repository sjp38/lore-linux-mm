Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3BE6B23A8
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:27:33 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id m37so2188054qte.10
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 19:27:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o14si9123169qtb.200.2018.11.20.19.27.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 19:27:32 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V11 11/19] bcache: avoid to use bio_for_each_segment_all() in bch_bio_alloc_pages()
Date: Wed, 21 Nov 2018 11:23:19 +0800
Message-Id: <20181121032327.8434-12-ming.lei@redhat.com>
In-Reply-To: <20181121032327.8434-1-ming.lei@redhat.com>
References: <20181121032327.8434-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

bch_bio_alloc_pages() is always called on one new bio, so it is safe
to access the bvec table directly. Given it is the only kind of this
case, open code the bvec table access since bio_for_each_segment_all()
will be changed to support for iterating over multipage bvec.

Acked-by: Coly Li <colyli@suse.de>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/bcache/util.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
index 20eddeac1531..62fb917f7a4f 100644
--- a/drivers/md/bcache/util.c
+++ b/drivers/md/bcache/util.c
@@ -270,7 +270,11 @@ int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
 	int i;
 	struct bio_vec *bv;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	/*
+	 * This is called on freshly new bio, so it is safe to access the
+	 * bvec table directly.
+	 */
+	for (i = 0, bv = bio->bi_io_vec; i < bio->bi_vcnt; bv++, i++) {
 		bv->bv_page = alloc_page(gfp_mask);
 		if (!bv->bv_page) {
 			while (--bv >= bio->bi_io_vec)
-- 
2.9.5
