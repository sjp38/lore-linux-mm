Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D77B6B0496
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:49:43 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e2so12528830qta.13
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:49:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u4si745787qtd.472.2017.08.08.01.49.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:49:42 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 17/49] block: comments on bio_for_each_segment[_all]
Date: Tue,  8 Aug 2017 16:45:16 +0800
Message-Id: <20170808084548.18963-18-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

This patch clarifies the fact that even though both
bio_for_each_segment() and bio_for_each_segment_all()
are named as _segment/_segment_all, they still return
one page in each vector, instead of real segment(multipage bvec).

With comming multipage bvec, both the two helpers
are capable of returning real segment(multipage bvec),
but the callers(users) of the two helpers may not be
capable of handling of the multipage bvec or real
segment, so we still keep the interfaces of the helpers
not changed. And new helpers for returning multipage bvec(real segment)
will be introduced later.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 7b1cf4ba0902..80defb3cfca4 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -155,7 +155,10 @@ static inline void *bio_data(struct bio *bio)
 
 /*
  * drivers should _never_ use the all version - the bio may have been split
- * before it got to the driver and the driver won't own all of it
+ * before it got to the driver and the driver won't own all of it.
+ *
+ * Even though the helper is named as _segment_all, it still returns
+ * page one by one instead of real segment.
  */
 #define bio_for_each_segment_all(bvl, bio, i)				\
 	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
@@ -194,6 +197,10 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 		((bvl = bio_iter_iovec((bio), (iter))), 1);		\
 	     bio_advance_iter((bio), &(iter), (bvl).bv_len))
 
+/*
+ * Even though the helper is named as _segment, it still returns
+ * page one by one instead of real segment.
+ */
 #define bio_for_each_segment(bvl, bio, iter)				\
 	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
