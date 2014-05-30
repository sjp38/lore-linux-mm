Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 354AC6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 20:16:04 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so303504pdj.15
        for <linux-mm@kvack.org>; Thu, 29 May 2014 17:16:03 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id ty7si3123315pab.10.2014.05.29.17.16.01
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 17:16:02 -0700 (PDT)
Date: Fri, 30 May 2014 10:15:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140530001558.GB14410@dastard>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
 <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
 <20140529013007.GF6677@dastard>
 <20140529015830.GG6677@dastard>
 <20140529233638.GJ10092@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140529233638.GJ10092@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Fri, May 30, 2014 at 08:36:38AM +0900, Minchan Kim wrote:
> Hello Dave,
> 
> On Thu, May 29, 2014 at 11:58:30AM +1000, Dave Chinner wrote:
> > On Thu, May 29, 2014 at 11:30:07AM +1000, Dave Chinner wrote:
> > > On Wed, May 28, 2014 at 03:41:11PM -0700, Linus Torvalds wrote:
> > > commit a237c1c5bc5dc5c76a21be922dca4826f3eca8ca
> > > Author: Jens Axboe <jaxboe@fusionio.com>
> > > Date:   Sat Apr 16 13:27:55 2011 +0200
> > > 
> > >     block: let io_schedule() flush the plug inline
> > >     
> > >     Linus correctly observes that the most important dispatch cases
> > >     are now done from kblockd, this isn't ideal for latency reasons.
> > >     The original reason for switching dispatches out-of-line was to
> > >     avoid too deep a stack, so by _only_ letting the "accidental"
> > >     flush directly in schedule() be guarded by offload to kblockd,
> > >     we should be able to get the best of both worlds.
> > >     
> > >     So add a blk_schedule_flush_plug() that offloads to kblockd,
> > >     and only use that from the schedule() path.
> > >     
> > >     Signed-off-by: Jens Axboe <jaxboe@fusionio.com>
> > > 
> > > And now we have too deep a stack due to unplugging from io_schedule()...
> > 
> > So, if we make io_schedule() push the plug list off to the kblockd
> > like is done for schedule()....
....
> I did below hacky test to apply your idea and the result is overflow again.
> So, again it would second stack expansion. Otherwise, we should prevent
> swapout in direct reclaim.
> 
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index f5c6635b806c..95f169e85dbe 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -4241,10 +4241,13 @@ EXPORT_SYMBOL_GPL(yield_to);
>  void __sched io_schedule(void)
>  {
>  	struct rq *rq = raw_rq();
> +	struct blk_plug *plug = current->plug;
>  
>  	delayacct_blkio_start();
>  	atomic_inc(&rq->nr_iowait);
> -	blk_flush_plug(current);
> +	if (plug)
> +		blk_flush_plug_list(plug, true);
> +
>  	current->in_iowait = 1;
>  	schedule();
>  	current->in_iowait = 0;

.....

>         Depth    Size   Location    (46 entries)
>
>   0)     7200       8   _raw_spin_lock_irqsave+0x51/0x60
>   1)     7192     296   get_page_from_freelist+0x886/0x920
>   2)     6896     352   __alloc_pages_nodemask+0x5e1/0xb20
>   3)     6544       8   alloc_pages_current+0x10f/0x1f0
>   4)     6536     168   new_slab+0x2c5/0x370
>   5)     6368       8   __slab_alloc+0x3a9/0x501
>   6)     6360      80   __kmalloc+0x1cb/0x200
>   7)     6280     376   vring_add_indirect+0x36/0x200
>   8)     5904     144   virtqueue_add_sgs+0x2e2/0x320
>   9)     5760     288   __virtblk_add_req+0xda/0x1b0
>  10)     5472      96   virtio_queue_rq+0xd3/0x1d0
>  11)     5376     128   __blk_mq_run_hw_queue+0x1ef/0x440
>  12)     5248      16   blk_mq_run_hw_queue+0x35/0x40
>  13)     5232      96   blk_mq_insert_requests+0xdb/0x160
>  14)     5136     112   blk_mq_flush_plug_list+0x12b/0x140
>  15)     5024     112   blk_flush_plug_list+0xc7/0x220
>  16)     4912     128   blk_mq_make_request+0x42a/0x600
>  17)     4784      48   generic_make_request+0xc0/0x100
>  18)     4736     112   submit_bio+0x86/0x160
>  19)     4624     160   __swap_writepage+0x198/0x230
>  20)     4464      32   swap_writepage+0x42/0x90
>  21)     4432     320   shrink_page_list+0x676/0xa80
>  22)     4112     208   shrink_inactive_list+0x262/0x4e0
>  23)     3904     304   shrink_lruvec+0x3e1/0x6a0

The device is supposed to be plugged here in shrink_lruvec().

Oh, a plug can only hold 16 individual bios, and then it does a
synchronous flush. Hmmm - perhaps that should also defer the flush
to the kblockd, because if we are overrunning a plug then we've
already surrendered IO dispatch latency....

So, in blk_mq_make_request(), can you do:

			if (list_empty(&plug->mq_list))
				trace_block_plug(q);
			else if (request_count >= BLK_MAX_REQUEST_COUNT) {
-				blk_flush_plug_list(plug, false);
+				blk_flush_plug_list(plug, true);
				trace_block_plug(q);
			}
			list_add_tail(&rq->queuelist, &plug->mq_list);

To see if that defers all the swap IO to kblockd?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
