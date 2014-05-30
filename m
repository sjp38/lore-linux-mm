Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E300E6B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 03:00:46 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so1386096pad.23
        for <linux-mm@kvack.org>; Fri, 30 May 2014 00:00:46 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id xm4si4182261pbc.45.2014.05.30.00.00.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 May 2014 00:00:45 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio ring cleanups, which save stack on older gcc
In-Reply-To: <20140529234522.GL10092@bbox>
References: <87oayh6s3s.fsf@rustcorp.com.au> <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au> <20140529074117.GI10092@bbox> <87fvjs7sge.fsf@rustcorp.com.au> <20140529234522.GL10092@bbox>
Date: Fri, 30 May 2014 16:26:47 +0930
Message-ID: <871tvb7o0g.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

Minchan Kim <minchan@kernel.org> writes:
> On Thu, May 29, 2014 at 08:38:33PM +0930, Rusty Russell wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>> > Hello Rusty,
>> >
>> > On Thu, May 29, 2014 at 04:56:41PM +0930, Rusty Russell wrote:
>> >> They don't make much difference: the easier fix is use gcc 4.8
>> >> which drops stack required across virtio block's virtio_queue_rq
>> >> down to that kmalloc in virtio_ring from 528 to 392 bytes.
>> >> 
>> >> Still, these (*lightly tested*) patches reduce to 432 bytes,
>> >> even for gcc 4.6.4.  Posted here FYI.
>> >
>> > I am testing with below which was hack for Dave's idea so don't have
>> > a machine to test your patches until tomorrow.
>> > So, I will queue your patches into testing machine tomorrow morning.
>> 
>> More interesting would be updating your compiler to 4.8, I think.
>> Saving <100 bytes on virtio is not going to save you, right?
>
> But in my report, virtio_ring consumes more than yours.

Yeah, weird.  I wonder if it's because I'm measuring before the call to
kmalloc; gcc probably spills extra crap on the stack before that.

You got 904 bytes:

5928     376   vring_add_indirect+0x36/0x200
[  111.404781]    <...>-15987   5d..2 111689538us : stack_trace_call:   9)    
5552     144   virtqueue_add_sgs+0x2e2/0x320
[  111.404781]    <...>-15987   5d..2 111689538us : stack_trace_call:  10)    
5408     288   __virtblk_add_req+0xda/0x1b0
[  111.404781]    <...>-15987   5d..2 111689538us : stack_trace_call:  11)    
5120      96   virtio_queue_rq+0xd3/0x1d0

When I move my "stack_top" save code into __kmalloc, with gcc 4.6 and your
.config I get:

[    2.506869] virtio_blk: stack used = 640

So I don't know quite what's going on :(

Cheers,
Rusty.

diff --git a/drivers/block/virtio_blk.c b/drivers/block/virtio_blk.c
index cb9b1f8326c3..894e290b4bd2 100644
--- a/drivers/block/virtio_blk.c
+++ b/drivers/block/virtio_blk.c
@@ -151,15 +151,19 @@ static void virtblk_done(struct virtqueue *vq)
 	spin_unlock_irqrestore(&vblk->vq_lock, flags);
 }
 
+extern struct task_struct *record_stack;
+extern unsigned long stack_top;
+
 static int virtio_queue_rq(struct blk_mq_hw_ctx *hctx, struct request *req)
 {
 	struct virtio_blk *vblk = hctx->queue->queuedata;
 	struct virtblk_req *vbr = req->special;
 	unsigned long flags;
 	unsigned int num;
+	unsigned long stack_bottom;
 	const bool last = (req->cmd_flags & REQ_END) != 0;
 	int err;
-
+	
 	BUG_ON(req->nr_phys_segments + 2 > vblk->sg_elems);
 
 	vbr->req = req;
@@ -199,7 +203,12 @@ static int virtio_queue_rq(struct blk_mq_hw_ctx *hctx, struct request *req)
 	}
 
 	spin_lock_irqsave(&vblk->vq_lock, flags);
+	record_stack = current;
+	__asm__ __volatile__("movq %%rsp,%0" : "=g" (stack_bottom));
 	err = __virtblk_add_req(vblk->vq, vbr, vbr->sg, num);
+	record_stack = NULL;
+
+	printk("virtio_blk: stack used = %lu\n", stack_bottom - stack_top);
 	if (err) {
 		virtqueue_kick(vblk->vq);
 		blk_mq_stop_hw_queue(hctx);
diff --git a/mm/slub.c b/mm/slub.c
index 2b1ce697fc4b..0f9a1a6b381e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3278,11 +3278,22 @@ static int __init setup_slub_nomerge(char *str)
 
 __setup("slub_nomerge", setup_slub_nomerge);
 
+extern struct task_struct *record_stack;
+struct task_struct *record_stack;
+EXPORT_SYMBOL(record_stack);
+
+extern unsigned long stack_top;
+unsigned long stack_top;
+EXPORT_SYMBOL(stack_top);
+
 void *__kmalloc(size_t size, gfp_t flags)
 {
 	struct kmem_cache *s;
 	void *ret;
 
+	if (record_stack == current)
+		__asm__ __volatile__("movq %%rsp,%0" : "=g" (stack_top));
+
 	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
 		return kmalloc_large(size, flags);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
