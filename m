Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B808E6B04A8
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:51:22 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 6so12687517qts.7
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:51:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r21si758326qte.305.2017.08.08.01.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:51:21 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 26/49] block: introduce bvec_for_each_sp_bvec()
Date: Tue,  8 Aug 2017 16:45:25 +0800
Message-Id: <20170808084548.18963-27-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

This helper can be used to iterate each singlepage bvec
from one multipage bvec.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index c1ec0945451a..23d3abdf057c 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -224,4 +224,18 @@ static inline bool bvec_iter_advance_mp(const struct bio_vec *bv,
 	.bi_bvec_done	= 0,						\
 }
 
+/*
+ * This helper iterates over the multipage bvec of @mp_bvec and
+ * returns each singlepage bvec via @sp_bvl.
+ */
+#define __bvec_for_each_sp_bvec(sp_bvl, mp_bvec, iter, start)		\
+	for (iter = start,						\
+	     (iter).bi_size = (mp_bvec)->bv_len  - (iter).bi_bvec_done;	\
+	     (iter).bi_size &&						\
+		((sp_bvl = bvec_iter_bvec((mp_bvec), (iter))), 1);	\
+	     bvec_iter_advance((mp_bvec), &(iter), (sp_bvl).bv_len))
+
+#define bvec_for_each_sp_bvec(sp_bvl, mp_bvec, iter)			\
+	__bvec_for_each_sp_bvec(sp_bvl, mp_bvec, iter, BVEC_ITER_ALL_INIT)
+
 #endif /* __LINUX_BVEC_ITER_H */
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
