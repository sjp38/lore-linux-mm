Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C086D6B049A
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:50:03 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id s18so12869821qks.4
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:50:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u51si751840qth.477.2017.08.08.01.50.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:50:03 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 19/49] block: implement sp version of bvec iterator helpers
Date: Tue,  8 Aug 2017 16:45:18 +0800
Message-Id: <20170808084548.18963-20-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

This patch implements singlepage version of the following
3 helpers:
	- bvec_iter_offset_sp()
	- bvec_iter_len_sp()
	- bvec_iter_page_sp()

So that one multipage bvec can be splited to singlepage
bvec, and make users of current bvec iterator happy.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 1eaf7ca5cab3..d5f999a493de 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -23,6 +23,7 @@
 #include <linux/kernel.h>
 #include <linux/bug.h>
 #include <linux/errno.h>
+#include <linux/mm.h>
 
 /*
  * What is multipage bvecs(segment)?
@@ -98,14 +99,25 @@ struct bvec_iter {
 #define bvec_iter_offset_mp(bvec, iter)				\
 	(__bvec_iter_bvec((bvec), (iter))->bv_offset + (iter).bi_bvec_done)
 
+#define bvec_iter_page_idx_mp(bvec, iter)			\
+	(bvec_iter_offset_mp((bvec), (iter)) / PAGE_SIZE)
+
+
 /*
  * <page, offset,length> of singlepage(sp) segment.
  *
  * This helpers will be implemented for building sp bvec in flight.
  */
-#define bvec_iter_offset_sp(bvec, iter)	bvec_iter_offset_mp((bvec), (iter))
-#define bvec_iter_len_sp(bvec, iter)	bvec_iter_len_mp((bvec), (iter))
-#define bvec_iter_page_sp(bvec, iter)	bvec_iter_page_mp((bvec), (iter))
+#define bvec_iter_offset_sp(bvec, iter)					\
+	(bvec_iter_offset_mp((bvec), (iter)) % PAGE_SIZE)
+
+#define bvec_iter_len_sp(bvec, iter)					\
+	min_t(unsigned, bvec_iter_len_mp((bvec), (iter)),		\
+	    (PAGE_SIZE - (bvec_iter_offset_sp((bvec), (iter)))))
+
+#define bvec_iter_page_sp(bvec, iter)					\
+	nth_page(bvec_iter_page_mp((bvec), (iter)),			\
+		 bvec_iter_page_idx_mp((bvec), (iter)))
 
 /* current interfaces support sp style at default */
 #define bvec_iter_page(bvec, iter)	bvec_iter_page_sp((bvec), (iter))
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
