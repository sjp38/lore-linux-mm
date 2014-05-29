Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id CA37C6B003D
	for <linux-mm@kvack.org>; Thu, 29 May 2014 03:28:45 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so12415253pbb.8
        for <linux-mm@kvack.org>; Thu, 29 May 2014 00:28:45 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id tf8si10454044pbc.25.2014.05.29.00.28.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 May 2014 00:28:44 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 3/4] virtio_ring: assume sgs are always well-formed.
Date: Thu, 29 May 2014 16:56:44 +0930
Message-Id: <1401348405-18614-4-git-send-email-rusty@rustcorp.com.au>
In-Reply-To: <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
References: <87oayh6s3s.fsf@rustcorp.com.au>
 <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>

We used to have several callers which just used arrays.  They're
gone, so we can use sg_next() everywhere, simplifying the code.

Before:
	gcc 4.8.2: virtio_blk: stack used = 392
	gcc 4.6.4: virtio_blk: stack used = 528

After:
	gcc 4.8.2: virtio_blk: stack used = 392
	gcc 4.6.4: virtio_blk: stack used = 480

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/virtio/virtio_ring.c | 68 +++++++++++++-------------------------------
 1 file changed, 19 insertions(+), 49 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index f6ad99ffdc40..5d29cd85d6cf 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -107,28 +107,10 @@ struct vring_virtqueue
 
 #define to_vvq(_vq) container_of(_vq, struct vring_virtqueue, vq)
 
-static inline struct scatterlist *sg_next_chained(struct scatterlist *sg,
-						  unsigned int *count)
-{
-	return sg_next(sg);
-}
-
-static inline struct scatterlist *sg_next_arr(struct scatterlist *sg,
-					      unsigned int *count)
-{
-	if (--(*count) == 0)
-		return NULL;
-	return sg + 1;
-}
-
 /* Set up an indirect table of descriptors and add it to the queue. */
 static inline int vring_add_indirect(struct vring_virtqueue *vq,
 				     struct scatterlist *sgs[],
-				     struct scatterlist *(*next)
-				       (struct scatterlist *, unsigned int *),
 				     unsigned int total_sg,
-				     unsigned int total_out,
-				     unsigned int total_in,
 				     unsigned int out_sgs,
 				     unsigned int in_sgs,
 				     gfp_t gfp)
@@ -155,7 +137,7 @@ static inline int vring_add_indirect(struct vring_virtqueue *vq,
 	/* Transfer entries from the sg lists into the indirect page */
 	i = 0;
 	for (n = 0; n < out_sgs; n++) {
-		for (sg = sgs[n]; sg; sg = next(sg, &total_out)) {
+		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
 			desc[i].flags = VRING_DESC_F_NEXT;
 			desc[i].addr = sg_phys(sg);
 			desc[i].len = sg->length;
@@ -164,7 +146,7 @@ static inline int vring_add_indirect(struct vring_virtqueue *vq,
 		}
 	}
 	for (; n < (out_sgs + in_sgs); n++) {
-		for (sg = sgs[n]; sg; sg = next(sg, &total_in)) {
+		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
 			desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
 			desc[i].addr = sg_phys(sg);
 			desc[i].len = sg->length;
@@ -197,10 +179,7 @@ static inline int vring_add_indirect(struct vring_virtqueue *vq,
 
 static inline int virtqueue_add(struct virtqueue *_vq,
 				struct scatterlist *sgs[],
-				struct scatterlist *(*next)
-				  (struct scatterlist *, unsigned int *),
-				unsigned int total_out,
-				unsigned int total_in,
+				unsigned int total_sg,
 				unsigned int out_sgs,
 				unsigned int in_sgs,
 				void *data,
@@ -208,7 +187,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
 	struct scatterlist *sg;
-	unsigned int i, n, avail, uninitialized_var(prev), total_sg;
+	unsigned int i, n, avail, uninitialized_var(prev);
 	int head;
 
 	START_USE(vq);
@@ -233,13 +212,10 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	}
 #endif
 
-	total_sg = total_in + total_out;
-
 	/* If the host supports indirect descriptor tables, and we have multiple
 	 * buffers, then go indirect. FIXME: tune this threshold */
 	if (vq->indirect && total_sg > 1 && vq->vq.num_free) {
-		head = vring_add_indirect(vq, sgs, next, total_sg, total_out,
-					  total_in,
+		head = vring_add_indirect(vq, sgs, total_sg, 
 					  out_sgs, in_sgs, gfp);
 		if (likely(head >= 0))
 			goto add_head;
@@ -265,7 +241,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 
 	head = i = vq->free_head;
 	for (n = 0; n < out_sgs; n++) {
-		for (sg = sgs[n]; sg; sg = next(sg, &total_out)) {
+		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
 			vq->vring.desc[i].flags = VRING_DESC_F_NEXT;
 			vq->vring.desc[i].addr = sg_phys(sg);
 			vq->vring.desc[i].len = sg->length;
@@ -274,7 +250,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 		}
 	}
 	for (; n < (out_sgs + in_sgs); n++) {
-		for (sg = sgs[n]; sg; sg = next(sg, &total_in)) {
+		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
 			vq->vring.desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
 			vq->vring.desc[i].addr = sg_phys(sg);
 			vq->vring.desc[i].len = sg->length;
@@ -335,29 +311,23 @@ int virtqueue_add_sgs(struct virtqueue *_vq,
 		      void *data,
 		      gfp_t gfp)
 {
-	unsigned int i, total_out, total_in;
+	unsigned int i, total_sg = 0;
 
 	/* Count them first. */
-	for (i = total_out = total_in = 0; i < out_sgs; i++) {
-		struct scatterlist *sg;
-		for (sg = sgs[i]; sg; sg = sg_next(sg))
-			total_out++;
-	}
-	for (; i < out_sgs + in_sgs; i++) {
+	for (i = 0; i < out_sgs + in_sgs; i++) {
 		struct scatterlist *sg;
 		for (sg = sgs[i]; sg; sg = sg_next(sg))
-			total_in++;
+			total_sg++;
 	}
-	return virtqueue_add(_vq, sgs, sg_next_chained,
-			     total_out, total_in, out_sgs, in_sgs, data, gfp);
+	return virtqueue_add(_vq, sgs, total_sg, out_sgs, in_sgs, data, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_sgs);
 
 /**
  * virtqueue_add_outbuf - expose output buffers to other end
  * @vq: the struct virtqueue we're talking about.
- * @sgs: array of scatterlists (need not be terminated!)
- * @num: the number of scatterlists readable by other side
+ * @sg: scatterlist (must be well-formed and terminated!)
+ * @num: the number of entries in @sg readable by other side
  * @data: the token identifying the buffer.
  * @gfp: how to do memory allocations (if necessary).
  *
@@ -367,19 +337,19 @@ EXPORT_SYMBOL_GPL(virtqueue_add_sgs);
  * Returns zero or a negative error (ie. ENOSPC, ENOMEM, EIO).
  */
 int virtqueue_add_outbuf(struct virtqueue *vq,
-			 struct scatterlist sg[], unsigned int num,
+			 struct scatterlist *sg, unsigned int num,
 			 void *data,
 			 gfp_t gfp)
 {
-	return virtqueue_add(vq, &sg, sg_next_arr, num, 0, 1, 0, data, gfp);
+	return virtqueue_add(vq, &sg, num, 1, 0, data, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_outbuf);
 
 /**
  * virtqueue_add_inbuf - expose input buffers to other end
  * @vq: the struct virtqueue we're talking about.
- * @sgs: array of scatterlists (need not be terminated!)
- * @num: the number of scatterlists writable by other side
+ * @sg: scatterlist (must be well-formed and terminated!)
+ * @num: the number of entries in @sg writable by other side
  * @data: the token identifying the buffer.
  * @gfp: how to do memory allocations (if necessary).
  *
@@ -389,11 +359,11 @@ EXPORT_SYMBOL_GPL(virtqueue_add_outbuf);
  * Returns zero or a negative error (ie. ENOSPC, ENOMEM, EIO).
  */
 int virtqueue_add_inbuf(struct virtqueue *vq,
-			struct scatterlist sg[], unsigned int num,
+			struct scatterlist *sg, unsigned int num,
 			void *data,
 			gfp_t gfp)
 {
-	return virtqueue_add(vq, &sg, sg_next_arr, 0, num, 0, 1, data, gfp);
+	return virtqueue_add(vq, &sg, num, 0, 1, data, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_inbuf);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
