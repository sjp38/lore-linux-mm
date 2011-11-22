Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 35F1E6B009D
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 16:20:04 -0500 (EST)
Date: Tue, 22 Nov 2011 16:19:58 -0500
From: Mike Snitzer <snitzer@redhat.com>
Subject: [PATCH] block: initialize request_queue's numa node during allocation
Message-ID: <20111122211954.GA17120@redhat.com>
References: <4ECB5C80.8080609@redhat.com>
 <alpine.DEB.2.00.1111220140470.4306@chino.kir.corp.google.com>
 <20111122152739.GA5663@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111122152739.GA5663@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Dave Young <dyoung@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

On Tue, Nov 22 2011 at 10:27am -0500,
Vivek Goyal <vgoyal@redhat.com> wrote:

> On Tue, Nov 22, 2011 at 02:00:24AM -0800, David Rientjes wrote:
...
> > 
> > blk_throtl_init() is trying to allocate on a specific node and it appears 
> > like its zonelists were never built successfully.  I'd guess it's trying 
> > to allocate on node 0 since it's not onlined above, probably because this 
> > is the crashkernel.  Your SRAT maps two different nodes but it's only 
> > onlining node 1 and not node 0.
> > 
> > The problem is that blk_alloc_queue_node() allocs the requeue_queue with 
> > __GFP_ZERO, which zeros it and never initialized the node field so it 
> > remains zero.  blk_throtl_init() then calls kzalloc_node() on node 0 which 
> > doesn't have initialized zonelists.
> > 
> > Maybe try this?
> > 
> > diff --git a/block/blk-core.c b/block/blk-core.c
> > index ea70e6c..99c1881 100644
> > --- a/block/blk-core.c
> > +++ b/block/blk-core.c
> > @@ -467,6 +467,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
> >  	q->backing_dev_info.state = 0;
> >  	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
> >  	q->backing_dev_info.name = "block";
> > +	q->node = node_id;
> >  
> 
> Storing q->node info at queue allocation time makes sense to me. In fact
> it might make sense to clean it up from blk_init_allocated_queue_node
> and assume that passed queue has queue->node set at the allocation time.
>
> CCing Mike Snitzer who introduced blk_init_allocated_queue_node(). Mike
> what do you think. I am not sure it makes sense to pass in nodeid, both
> at queue allocation and queue initialization time. To me, it should make
> more sense to allocate the queue at one node and that becomes the default
> node for reset of the initialization.

Yeah, that makes sense to me too:

From: Mike Snitzer <snitzer@redhat.com>
Subject: block: initialize request_queue's numa node during allocation

Set request_queue's node in blk_alloc_queue_node() rather than
blk_init_allocated_queue_node().  This avoids blk_throtl_init() using
q->node before it is initialized.

Rename blk_init_allocated_queue_node() to blk_init_allocated_queue().

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 block/blk-core.c       |   14 +++-----------
 include/linux/blkdev.h |    3 ---
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index ea70e6c..20d69f6 100644
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
index c7a6d3b..94acd81 100644
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
