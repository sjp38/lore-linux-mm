Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 829C56B03BD
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:18:09 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 91so47475621qkq.2
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:18:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w187si11220862qkb.201.2017.06.26.05.18.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:18:08 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 31/51] fs/buffer.c: use bvec iterator to truncate the bio
Date: Mon, 26 Jun 2017 20:10:14 +0800
Message-Id: <20170626121034.3051-32-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

Once multipage bvec is enabled, the last bvec may include
more than one page, this patch use bvec_get_last_page()
to truncate the bio.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/buffer.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 1910f539770b..53b8a29f4525 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3055,8 +3055,7 @@ void guard_bio_eod(int op, struct bio *bio)
 	unsigned truncated_bytes;
 	/*
 	 * It is safe to truncate the last bvec in the following way
-	 * even though multipage bvec is supported, but we need to
-	 * fix the parameters passed to zero_user().
+	 * even though multipage bvec is supported.
 	 */
 	struct bio_vec *bvec = &bio->bi_io_vec[bio->bi_vcnt - 1];
 
@@ -3085,7 +3084,10 @@ void guard_bio_eod(int op, struct bio *bio)
 
 	/* ..and clear the end of the buffer for reads */
 	if (op == REQ_OP_READ) {
-		zero_user(bvec->bv_page, bvec->bv_offset + bvec->bv_len,
+		struct bio_vec bv;
+
+		bvec_get_last_page(bvec, &bv);
+		zero_user(bv.bv_page, bv.bv_offset + bv.bv_len,
 				truncated_bytes);
 	}
 }
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
