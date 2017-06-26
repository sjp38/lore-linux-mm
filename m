Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 133386B0313
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:14:46 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u126so47696018qka.9
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:14:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g21si11466139qtf.199.2017.06.26.05.14.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:14:45 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 12/51] md: raid10: avoid to access bvec table directly
Date: Mon, 26 Jun 2017 20:09:55 +0800
Message-Id: <20170626121034.3051-13-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org

Inside sync_request_write(), .bi_vcnt is written after this bio
is reseted, this way won't work any more after multipage bvec
is enabled.

So reset_bvec_table() is introduced for re-add these pages into
bio, then .bi_vcnt needn't to be touched any more.

Cc: Shaohua Li <shli@kernel.org>
Cc: linux-raid@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/raid10.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/md/raid10.c b/drivers/md/raid10.c
index 5026e7ad51d3..2fca1fe67092 100644
--- a/drivers/md/raid10.c
+++ b/drivers/md/raid10.c
@@ -1995,6 +1995,24 @@ static void end_sync_write(struct bio *bio)
 	end_sync_request(r10_bio);
 }
 
+/* called after bio_reset() */
+static void reset_bvec_table(struct bio *bio, struct resync_pages *rp, int size)
+{
+	/* initialize bvec table again */
+	rp->idx = 0;
+	do {
+		struct page *page = resync_fetch_page(rp, rp->idx++);
+		int len = min_t(int, size, PAGE_SIZE);
+
+		/*
+		 * won't fail because the vec table is big
+		 * enough to hold all these pages
+		 */
+		bio_add_page(bio, page, len, 0);
+		size -= len;
+	} while (rp->idx < RESYNC_PAGES && size > 0);
+}
+
 /*
  * Note: sync and recover and handled very differently for raid10
  * This code is for resync.
@@ -2087,8 +2105,8 @@ static void sync_request_write(struct mddev *mddev, struct r10bio *r10_bio)
 		rp = get_resync_pages(tbio);
 		bio_reset(tbio);
 
-		tbio->bi_vcnt = vcnt;
-		tbio->bi_iter.bi_size = fbio->bi_iter.bi_size;
+		reset_bvec_table(tbio, rp, fbio->bi_iter.bi_size);
+
 		rp->raid_bio = r10_bio;
 		tbio->bi_private = rp;
 		tbio->bi_iter.bi_sector = r10_bio->devs[i].addr;
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
