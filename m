Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B58C6B0292
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:47:40 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j33-v6so2816367qtc.18
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:47:40 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x42-v6si1772569qvf.286.2018.05.24.20.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:47:39 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 04/33] block: introduce multipage page bvec helpers
Date: Fri, 25 May 2018 11:45:52 +0800
Message-Id: <20180525034621.31147-5-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

This patch introduces helpers of 'bvec_iter_segment_*' for multipage
bvec(segment) support.

The introduced interfaces treate one bvec as real multipage segment,
for example, .bv_len is the total length of the multipage segment.

The existed helpers of bvec_iter_* are interfaces for supporting current
bvec iterator which is thought as singlepage only by drivers, fs, dm and
etc. These helpers will build singlepage bvec in flight, so users of
current bio/bvec iterator still can work well and needn't change even
though we store real multipage segment into bvec table.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 63 +++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 60 insertions(+), 3 deletions(-)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index fe7a22dd133b..2433c73fa5ea 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -23,6 +23,44 @@
 #include <linux/kernel.h>
 #include <linux/bug.h>
 #include <linux/errno.h>
+#include <linux/mm.h>
+
+/*
+ * What is multipage bvecs(segment)?
+ *
+ * - bvec stored in bio->bi_io_vec is always multipage(mp) style
+ *
+ * - bvec(struct bio_vec) represents one physically contiguous I/O
+ *   buffer, now the buffer may include more than one pages since
+ *   multipage(mp) bvec is supported, and all these pages represented
+ *   by one bvec is physically contiguous. Before mp support, at most
+ *   one page can be included in one bvec, we call it singlepage(sp)
+ *   bvec.
+ *
+ * - .bv_page of th bvec represents the 1st page in the mp segment
+ *
+ * - .bv_offset of the bvec represents offset of the buffer in the bvec
+ *
+ * The effect on the current drivers/filesystem/dm/bcache/...:
+ *
+ * - almost everyone supposes that one bvec only includes one single
+ *   page, so we keep the sp interface not changed, for example,
+ *   bio_for_each_page() still returns bvec with single page
+ *
+ * - bio_for_each_page_all() will be changed to return singlepage
+ *   bvec too
+ *
+ * - during iterating, iterator variable(struct bvec_iter) is always
+ *   updated in multipage bvec style and that means bvec_iter_advance()
+ *   is kept not changed
+ *
+ * - returned(copied) singlepage bvec is generated in flight by bvec
+ *   helpers from the stored multipage bvec(segment)
+ *
+ * - In case that some components(such as iov_iter) need to support
+ *   multipage segment, we introduce new helpers(bvec_iter_segment_*) for
+ *   them.
+ */
 
 /*
  * was unsigned short, but we might as well be ready for > 64kB I/O pages
@@ -52,16 +90,35 @@ struct bvec_iter {
  */
 #define __bvec_iter_bvec(bvec, iter)	(&(bvec)[(iter).bi_idx])
 
-#define bvec_iter_page(bvec, iter)				\
+#define bvec_iter_segment_page(bvec, iter)				\
 	(__bvec_iter_bvec((bvec), (iter))->bv_page)
 
-#define bvec_iter_len(bvec, iter)				\
+#define bvec_iter_segment_len(bvec, iter)				\
 	min((iter).bi_size,					\
 	    __bvec_iter_bvec((bvec), (iter))->bv_len - (iter).bi_bvec_done)
 
-#define bvec_iter_offset(bvec, iter)				\
+#define bvec_iter_segment_offset(bvec, iter)				\
 	(__bvec_iter_bvec((bvec), (iter))->bv_offset + (iter).bi_bvec_done)
 
+#define bvec_iter_page_idx_in_seg(bvec, iter)			\
+	(bvec_iter_segment_offset((bvec), (iter)) / PAGE_SIZE)
+
+/*
+ * <page, offset,length> of singlepage(sp) segment.
+ *
+ * This helpers will be implemented for building sp bvec in flight.
+ */
+#define bvec_iter_offset(bvec, iter)					\
+	(bvec_iter_segment_offset((bvec), (iter)) % PAGE_SIZE)
+
+#define bvec_iter_len(bvec, iter)					\
+	min_t(unsigned, bvec_iter_segment_len((bvec), (iter)),		\
+	    (PAGE_SIZE - (bvec_iter_offset((bvec), (iter)))))
+
+#define bvec_iter_page(bvec, iter)					\
+	nth_page(bvec_iter_segment_page((bvec), (iter)),		\
+		 bvec_iter_page_idx_in_seg((bvec), (iter)))
+
 #define bvec_iter_bvec(bvec, iter)				\
 ((struct bio_vec) {						\
 	.bv_page	= bvec_iter_page((bvec), (iter)),	\
-- 
2.9.5
