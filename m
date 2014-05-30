Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id ED4296B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 02:11:41 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so1027418pad.39
        for <linux-mm@kvack.org>; Thu, 29 May 2014 23:11:41 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id az1si4043588pbd.0.2014.05.29.23.11.39
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 23:11:40 -0700 (PDT)
Date: Fri, 30 May 2014 15:12:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140530061215.GS10092@bbox>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
 <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
 <20140529013007.GF6677@dastard>
 <20140529015830.GG6677@dastard>
 <20140529233638.GJ10092@bbox>
 <20140530001558.GB14410@dastard>
 <20140530021247.GR10092@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140530021247.GR10092@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

Final result,

I tested the machine below patch (Dave suggested + some part I modified)
and I couldn't see the problem any more(tested 4hr, I will queue it into
the machine during weekend for long running test if I don't get more
enhanced version before leaving the office today) but as I reported
interim result, still VM's stack usage is high.

Anyway, it's another issue we should really diet of VM functions
(ex, uninlining slow path part from __alloc_pages_nodemask and
alloc_info idea from Linus and more).

Looking forwad to seeing blk_plug_start_async way.
Thanks, Dave!

---
 block/blk-core.c    | 2 +-
 block/blk-mq.c      | 2 +-
 kernel/sched/core.c | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index bfe16d5af9f9..0c81aacec75b 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1585,7 +1585,7 @@ get_rq:
 			trace_block_plug(q);
 		else {
 			if (request_count >= BLK_MAX_REQUEST_COUNT) {
-				blk_flush_plug_list(plug, false);
+				blk_flush_plug_list(plug, true);
 				trace_block_plug(q);
 			}
 		}
diff --git a/block/blk-mq.c b/block/blk-mq.c
index 883f72089015..6e72e700d11e 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -897,7 +897,7 @@ static void blk_mq_make_request(struct request_queue *q, struct bio *bio)
 			if (list_empty(&plug->mq_list))
 				trace_block_plug(q);
 			else if (request_count >= BLK_MAX_REQUEST_COUNT) {
-				blk_flush_plug_list(plug, false);
+				blk_flush_plug_list(plug, true);
 				trace_block_plug(q);
 			}
 			list_add_tail(&rq->queuelist, &plug->mq_list);
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index f5c6635b806c..ebca9e1f200f 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4244,7 +4244,7 @@ void __sched io_schedule(void)
 
 	delayacct_blkio_start();
 	atomic_inc(&rq->nr_iowait);
-	blk_flush_plug(current);
+	blk_schedule_flush_plug(current);
 	current->in_iowait = 1;
 	schedule();
 	current->in_iowait = 0;
@@ -4260,7 +4260,7 @@ long __sched io_schedule_timeout(long timeout)
 
 	delayacct_blkio_start();
 	atomic_inc(&rq->nr_iowait);
-	blk_flush_plug(current);
+	blk_schedule_flush_plug(current);
 	current->in_iowait = 1;
 	ret = schedule_timeout(timeout);
 	current->in_iowait = 0;
-- 
1.9.2


On Fri, May 30, 2014 at 11:12:47AM +0900, Minchan Kim wrote:
> On Fri, May 30, 2014 at 10:15:58AM +1000, Dave Chinner wrote:
> > On Fri, May 30, 2014 at 08:36:38AM +0900, Minchan Kim wrote:
> > > Hello Dave,
> > > 
> > > On Thu, May 29, 2014 at 11:58:30AM +1000, Dave Chinner wrote:
> > > > On Thu, May 29, 2014 at 11:30:07AM +1000, Dave Chinner wrote:
> > > > > On Wed, May 28, 2014 at 03:41:11PM -0700, Linus Torvalds wrote:
> > > > > commit a237c1c5bc5dc5c76a21be922dca4826f3eca8ca
> > > > > Author: Jens Axboe <jaxboe@fusionio.com>
> > > > > Date:   Sat Apr 16 13:27:55 2011 +0200
> > > > > 
> > > > >     block: let io_schedule() flush the plug inline
> > > > >     
> > > > >     Linus correctly observes that the most important dispatch cases
> > > > >     are now done from kblockd, this isn't ideal for latency reasons.
> > > > >     The original reason for switching dispatches out-of-line was to
> > > > >     avoid too deep a stack, so by _only_ letting the "accidental"
> > > > >     flush directly in schedule() be guarded by offload to kblockd,
> > > > >     we should be able to get the best of both worlds.
> > > > >     
> > > > >     So add a blk_schedule_flush_plug() that offloads to kblockd,
> > > > >     and only use that from the schedule() path.
> > > > >     
> > > > >     Signed-off-by: Jens Axboe <jaxboe@fusionio.com>
> > > > > 
> > > > > And now we have too deep a stack due to unplugging from io_schedule()...
> > > > 
> > > > So, if we make io_schedule() push the plug list off to the kblockd
> > > > like is done for schedule()....
> > ....
> > > I did below hacky test to apply your idea and the result is overflow again.
> > > So, again it would second stack expansion. Otherwise, we should prevent
> > > swapout in direct reclaim.
> > > 
> > > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > > index f5c6635b806c..95f169e85dbe 100644
> > > --- a/kernel/sched/core.c
> > > +++ b/kernel/sched/core.c
> > > @@ -4241,10 +4241,13 @@ EXPORT_SYMBOL_GPL(yield_to);
> > >  void __sched io_schedule(void)
> > >  {
> > >  	struct rq *rq = raw_rq();
> > > +	struct blk_plug *plug = current->plug;
> > >  
> > >  	delayacct_blkio_start();
> > >  	atomic_inc(&rq->nr_iowait);
> > > -	blk_flush_plug(current);
> > > +	if (plug)
> > > +		blk_flush_plug_list(plug, true);
> > > +
> > >  	current->in_iowait = 1;
> > >  	schedule();
> > >  	current->in_iowait = 0;
> > 
> > .....
> > 
> > >         Depth    Size   Location    (46 entries)
> > >
> > >   0)     7200       8   _raw_spin_lock_irqsave+0x51/0x60
> > >   1)     7192     296   get_page_from_freelist+0x886/0x920
> > >   2)     6896     352   __alloc_pages_nodemask+0x5e1/0xb20
> > >   3)     6544       8   alloc_pages_current+0x10f/0x1f0
> > >   4)     6536     168   new_slab+0x2c5/0x370
> > >   5)     6368       8   __slab_alloc+0x3a9/0x501
> > >   6)     6360      80   __kmalloc+0x1cb/0x200
> > >   7)     6280     376   vring_add_indirect+0x36/0x200
> > >   8)     5904     144   virtqueue_add_sgs+0x2e2/0x320
> > >   9)     5760     288   __virtblk_add_req+0xda/0x1b0
> > >  10)     5472      96   virtio_queue_rq+0xd3/0x1d0
> > >  11)     5376     128   __blk_mq_run_hw_queue+0x1ef/0x440
> > >  12)     5248      16   blk_mq_run_hw_queue+0x35/0x40
> > >  13)     5232      96   blk_mq_insert_requests+0xdb/0x160
> > >  14)     5136     112   blk_mq_flush_plug_list+0x12b/0x140
> > >  15)     5024     112   blk_flush_plug_list+0xc7/0x220
> > >  16)     4912     128   blk_mq_make_request+0x42a/0x600
> > >  17)     4784      48   generic_make_request+0xc0/0x100
> > >  18)     4736     112   submit_bio+0x86/0x160
> > >  19)     4624     160   __swap_writepage+0x198/0x230
> > >  20)     4464      32   swap_writepage+0x42/0x90
> > >  21)     4432     320   shrink_page_list+0x676/0xa80
> > >  22)     4112     208   shrink_inactive_list+0x262/0x4e0
> > >  23)     3904     304   shrink_lruvec+0x3e1/0x6a0
> > 
> > The device is supposed to be plugged here in shrink_lruvec().
> > 
> > Oh, a plug can only hold 16 individual bios, and then it does a
> > synchronous flush. Hmmm - perhaps that should also defer the flush
> > to the kblockd, because if we are overrunning a plug then we've
> > already surrendered IO dispatch latency....
> > 
> > So, in blk_mq_make_request(), can you do:
> > 
> > 			if (list_empty(&plug->mq_list))
> > 				trace_block_plug(q);
> > 			else if (request_count >= BLK_MAX_REQUEST_COUNT) {
> > -				blk_flush_plug_list(plug, false);
> > +				blk_flush_plug_list(plug, true);
> > 				trace_block_plug(q);
> > 			}
> > 			list_add_tail(&rq->queuelist, &plug->mq_list);
> > 
> > To see if that defers all the swap IO to kblockd?
> > 
> 
> Interim report,
> 
> I applied below(we need to fix io_schedule_timeout due to mempool_alloc)
> 
> diff --git a/block/blk-core.c b/block/blk-core.c
> index bfe16d5af9f9..0c81aacec75b 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -1585,7 +1585,7 @@ get_rq:
>  			trace_block_plug(q);
>  		else {
>  			if (request_count >= BLK_MAX_REQUEST_COUNT) {
> -				blk_flush_plug_list(plug, false);
> +				blk_flush_plug_list(plug, true);
>  				trace_block_plug(q);
>  			}
>  		}
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index f5c6635b806c..ebca9e1f200f 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -4244,7 +4244,7 @@ void __sched io_schedule(void)
>  
>  	delayacct_blkio_start();
>  	atomic_inc(&rq->nr_iowait);
> -	blk_flush_plug(current);
> +	blk_schedule_flush_plug(current);
>  	current->in_iowait = 1;
>  	schedule();
>  	current->in_iowait = 0;
> @@ -4260,7 +4260,7 @@ long __sched io_schedule_timeout(long timeout)
>  
>  	delayacct_blkio_start();
>  	atomic_inc(&rq->nr_iowait);
> -	blk_flush_plug(current);
> +	blk_schedule_flush_plug(current);
>  	current->in_iowait = 1;
>  	ret = schedule_timeout(timeout);
>  	current->in_iowait = 0;
> 
> And result is as follows, It reduce about 800-byte compared to
> my first report but still stack usage seems to be high.
> Really needs diet of VM functions.
> 
>         -----    ----   --------
>   0)     6896      16   lookup_address+0x28/0x30
>   1)     6880      16   _lookup_address_cpa.isra.3+0x3b/0x40
>   2)     6864     304   __change_page_attr_set_clr+0xe0/0xb50
>   3)     6560     112   kernel_map_pages+0x6c/0x120
>   4)     6448     256   get_page_from_freelist+0x489/0x920
>   5)     6192     352   __alloc_pages_nodemask+0x5e1/0xb20
>   6)     5840       8   alloc_pages_current+0x10f/0x1f0
>   7)     5832     168   new_slab+0x35d/0x370
>   8)     5664       8   __slab_alloc+0x3a9/0x501
>   9)     5656      80   kmem_cache_alloc+0x1ac/0x1c0
>  10)     5576     296   mempool_alloc_slab+0x15/0x20
>  11)     5280     128   mempool_alloc+0x5e/0x170
>  12)     5152      96   bio_alloc_bioset+0x10b/0x1d0
>  13)     5056      48   get_swap_bio+0x30/0x90
>  14)     5008     160   __swap_writepage+0x150/0x230
>  15)     4848      32   swap_writepage+0x42/0x90
>  16)     4816     320   shrink_page_list+0x676/0xa80
>  17)     4496     208   shrink_inactive_list+0x262/0x4e0
>  18)     4288     304   shrink_lruvec+0x3e1/0x6a0
>  19)     3984      80   shrink_zone+0x3f/0x110
>  20)     3904     128   do_try_to_free_pages+0x156/0x4c0
>  21)     3776     208   try_to_free_pages+0xf7/0x1e0
>  22)     3568     352   __alloc_pages_nodemask+0x783/0xb20
>  23)     3216       8   alloc_pages_current+0x10f/0x1f0
>  24)     3208     168   new_slab+0x2c5/0x370
>  25)     3040       8   __slab_alloc+0x3a9/0x501
>  26)     3032      80   kmem_cache_alloc+0x1ac/0x1c0
>  27)     2952     296   mempool_alloc_slab+0x15/0x20
>  28)     2656     128   mempool_alloc+0x5e/0x170
>  29)     2528      96   bio_alloc_bioset+0x10b/0x1d0
>  30)     2432      48   mpage_alloc+0x38/0xa0
>  31)     2384     208   do_mpage_readpage+0x49b/0x5d0
>  32)     2176     224   mpage_readpages+0xcf/0x120
>  33)     1952      48   ext4_readpages+0x45/0x60
>  34)     1904     224   __do_page_cache_readahead+0x222/0x2d0
>  35)     1680      16   ra_submit+0x21/0x30
>  36)     1664     112   filemap_fault+0x2d7/0x4f0
>  37)     1552     144   __do_fault+0x6d/0x4c0
>  38)     1408     160   handle_mm_fault+0x1a6/0xaf0
>  39)     1248     272   __do_page_fault+0x18a/0x590
>  40)      976      16   do_page_fault+0xc/0x10
>  41)      960     208   page_fault+0x22/0x30
>  42)      752      16   clear_user+0x2e/0x40
>  43)      736      16   padzero+0x2d/0x40
>  44)      720     304   load_elf_binary+0xa47/0x1a40
>  45)      416      48   search_binary_handler+0x9c/0x1a0
>  46)      368     144   do_execve_common.isra.25+0x58d/0x700
>  47)      224      16   do_execve+0x18/0x20
>  48)      208      32   SyS_execve+0x2e/0x40
>  49)      176     176   stub_execve+0x69/0xa0
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
