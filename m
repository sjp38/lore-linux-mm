Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A39A6B03A3
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:16:00 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u126so47706255qka.9
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:16:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h68si11004522qkf.50.2017.06.26.05.15.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:15:59 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 19/51] block: comments on bio_for_each_segment[_all]
Date: Mon, 26 Jun 2017 20:10:02 +0800
Message-Id: <20170626121034.3051-20-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
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
index 4907bea03908..d425be4d1ced 100644
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
@@ -177,6 +180,10 @@ static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
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
