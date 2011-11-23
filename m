Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 009C26B00A4
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 20:14:36 -0500 (EST)
Received: by iaek3 with SMTP id k3so1191743iae.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 17:14:34 -0800 (PST)
Date: Tue, 22 Nov 2011 17:14:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 for-3.2] block: initialize request_queue's numa node during
 allocation
In-Reply-To: <20111122220218.GA17543@redhat.com>
Message-ID: <alpine.DEB.2.00.1111221703590.18644@chino.kir.corp.google.com>
References: <4ECB5C80.8080609@redhat.com> <alpine.DEB.2.00.1111220140470.4306@chino.kir.corp.google.com> <20111122152739.GA5663@redhat.com> <20111122211954.GA17120@redhat.com> <alpine.DEB.2.00.1111221342320.2621@chino.kir.corp.google.com>
 <20111122220218.GA17543@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>, Jens Axboe <axboe@kernel.dk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, Dave Young <dyoung@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, stable@vger.kernel.org

From: Mike Snitzer <snitzer@redhat.com>

struct request_queue is allocated with __GFP_ZERO so its "node" field is 
zero before initialization.  This causes an oops if node 0 is offline in 
the page allocator because its zonelists are not initialized.  From Dave 
Young's dmesg:

	SRAT: Node 1 PXM 2 0-d0000000
	SRAT: Node 1 PXM 2 100000000-330000000
	SRAT: Node 0 PXM 1 330000000-630000000
	Initmem setup node 1 0000000000000000-000000000affb000
	...
	Built 1 zonelists in Node order, mobility grouping on.
	...
	BUG: unable to handle kernel paging request at 0000000000001c08
	IP: [<ffffffff8111c355>] __alloc_pages_nodemask+0xb5/0x870

and __alloc_pages_nodemask+0xb5 translates to a NULL pointer on 
zonelist->_zonerefs.

The fix is to initialize q->node at the time of allocation so the correct 
node is passed to the slab allocator later.

Since blk_init_allocated_queue_node() is no longer needed, merge it with 
blk_init_allocated_queue().

[rientjes@google.com: changelog, initializing q->node]
Cc: stable@vger.kernel.org [2.6.37+]
Reported-by: Dave Young <dyoung@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 block/blk-core.c       |   14 +++-----------
 include/linux/blkdev.h |    3 ---
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -467,6 +467,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 	q->backing_dev_info.state = 0;
 	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
 	q->backing_dev_info.name = "block";
+	q->node = node_id;
 
 	err = bdi_init(&q->backing_dev_info);
 	if (err) {
@@ -551,7 +552,7 @@ blk_init_queue_node(request_fn_proc *rfn, spinlock_t *lock, int node_id)
 	if (!uninit_q)
 		return NULL;
 
-	q = blk_init_allocated_queue_node(uninit_q, rfn, lock, node_id);
+	q = blk_init_allocated_queue(uninit_q, rfn, lock);
 	if (!q)
 		blk_cleanup_queue(uninit_q);
 
@@ -563,18 +564,9 @@ struct request_queue *
 blk_init_allocated_queue(struct request_queue *q, request_fn_proc *rfn,
 			 spinlock_t *lock)
 {
-	return blk_init_allocated_queue_node(q, rfn, lock, -1);
-}
-EXPORT_SYMBOL(blk_init_allocated_queue);
-
-struct request_queue *
-blk_init_allocated_queue_node(struct request_queue *q, request_fn_proc *rfn,
-			      spinlock_t *lock, int node_id)
-{
 	if (!q)
 		return NULL;
 
-	q->node = node_id;
 	if (blk_init_free_list(q))
 		return NULL;
 
@@ -604,7 +596,7 @@ blk_init_allocated_queue_node(struct request_queue *q, request_fn_proc *rfn,
 
 	return NULL;
 }
-EXPORT_SYMBOL(blk_init_allocated_queue_node);
+EXPORT_SYMBOL(blk_init_allocated_queue);
 
 int blk_get_queue(struct request_queue *q)
 {
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -805,9 +805,6 @@ extern void blk_unprep_request(struct request *);
  */
 extern struct request_queue *blk_init_queue_node(request_fn_proc *rfn,
 					spinlock_t *lock, int node_id);
-extern struct request_queue *blk_init_allocated_queue_node(struct request_queue *,
-							   request_fn_proc *,
-							   spinlock_t *, int node_id);
 extern struct request_queue *blk_init_queue(request_fn_proc *, spinlock_t *);
 extern struct request_queue *blk_init_allocated_queue(struct request_queue *,
 						      request_fn_proc *, spinlock_t *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
