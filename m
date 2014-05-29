Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED5A6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 19:36:06 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so1049446pbc.9
        for <linux-mm@kvack.org>; Thu, 29 May 2014 16:36:06 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id dm2si2950053pbb.68.2014.05.29.16.36.03
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 16:36:04 -0700 (PDT)
Date: Fri, 30 May 2014 08:36:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140529233638.GJ10092@bbox>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
 <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
 <20140529013007.GF6677@dastard>
 <20140529015830.GG6677@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140529015830.GG6677@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

Hello Dave,

On Thu, May 29, 2014 at 11:58:30AM +1000, Dave Chinner wrote:
> On Thu, May 29, 2014 at 11:30:07AM +1000, Dave Chinner wrote:
> > On Wed, May 28, 2014 at 03:41:11PM -0700, Linus Torvalds wrote:
> > commit a237c1c5bc5dc5c76a21be922dca4826f3eca8ca
> > Author: Jens Axboe <jaxboe@fusionio.com>
> > Date:   Sat Apr 16 13:27:55 2011 +0200
> > 
> >     block: let io_schedule() flush the plug inline
> >     
> >     Linus correctly observes that the most important dispatch cases
> >     are now done from kblockd, this isn't ideal for latency reasons.
> >     The original reason for switching dispatches out-of-line was to
> >     avoid too deep a stack, so by _only_ letting the "accidental"
> >     flush directly in schedule() be guarded by offload to kblockd,
> >     we should be able to get the best of both worlds.
> >     
> >     So add a blk_schedule_flush_plug() that offloads to kblockd,
> >     and only use that from the schedule() path.
> >     
> >     Signed-off-by: Jens Axboe <jaxboe@fusionio.com>
> > 
> > And now we have too deep a stack due to unplugging from io_schedule()...
> 
> So, if we make io_schedule() push the plug list off to the kblockd
> like is done for schedule()....
> 
> > > IOW, swap-out directly caused that extra 3kB of stack use in what was
> > > a deep call chain (due to memory allocation). I really don't
> > > understand why you are arguing anything else on a pure technicality.
> > >
> > > I thought you had some other argument for why swap was different, and
> > > against removing that "page_is_file_cache()" special case in
> > > shrink_page_list().
> > 
> > I've said in the past that swap is different to filesystem
> > ->writepage implementations because it doesn't require significant
> > stack to do block allocation and doesn't trigger IO deep in that
> > allocation stack. Hence it has much lower stack overhead than the
> > filesystem ->writepage implementations and so is much less likely to
> > have stack issues.
> > 
> > This stack overflow shows us that just the memory reclaim + IO
> > layers are sufficient to cause a stack overflow,
> 
> .... we solve this problem directly by being able to remove the IO
> stack usage from the direct reclaim swap path.
> 
> IOWs, we don't need to turn swap off at all in direct reclaim
> because all the swap IO can be captured in a plug list and
> dispatched via kblockd. This could be done either by io_schedule()
> or a new blk_flush_plug_list() wrapper that pushes the work to
> kblockd...

I did below hacky test to apply your idea and the result is overflow again.
So, again it would second stack expansion. Otherwise, we should prevent
swapout in direct reclaim.

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index f5c6635b806c..95f169e85dbe 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4241,10 +4241,13 @@ EXPORT_SYMBOL_GPL(yield_to);
 void __sched io_schedule(void)
 {
 	struct rq *rq = raw_rq();
+	struct blk_plug *plug = current->plug;
 
 	delayacct_blkio_start();
 	atomic_inc(&rq->nr_iowait);
-	blk_flush_plug(current);
+	if (plug)
+		blk_flush_plug_list(plug, true);
+
 	current->in_iowait = 1;
 	schedule();
 	current->in_iowait = 0;


[ 1209.764725] kworker/u24:0 (23627) used greatest stack depth: 304 bytes left
[ 1510.835509] kworker/u24:1 (25817) used greatest stack depth: 144 bytes left
[ 3701.482790] PANIC: double fault, error_code: 0x0
[ 3701.483297] CPU: 8 PID: 6117 Comm: kworker/u24:1 Not tainted 3.14.0+ #201
[ 3701.483980] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 3701.484366] Workqueue: writeback bdi_writeback_workfn (flush-253:0)
[ 3701.484366] task: ffff8800353c41c0 ti: ffff880000106000 task.ti: ffff880000106000
[ 3701.484366] RIP: 0010:[<ffffffff810a5390>]  [<ffffffff810a5390>] __lock_acquire+0x170/0x1ca0
[ 3701.484366] RSP: 0000:ffff880000105f58  EFLAGS: 00010046
[ 3701.484366] RAX: 0000000000000001 RBX: ffff8800353c41c0 RCX: 0000000000000002
[ 3701.484366] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff81c4a1e0
[ 3701.484366] RBP: ffff880000106048 R08: 0000000000000001 R09: 0000000000000001
[ 3701.484366] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000001
[ 3701.484366] R13: 0000000000000000 R14: ffffffff81c4a1e0 R15: 0000000000000000
[ 3701.484366] FS:  0000000000000000(0000) GS:ffff880037d00000(0000) knlGS:0000000000000000
[ 3701.484366] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3701.484366] CR2: ffff880000105f48 CR3: 0000000001c0b000 CR4: 00000000000006e0
[ 3701.484366] Stack:
[ 3701.484366] BUG: unable to handle kernel paging request at ffff880000105f58
[ 3701.484366] IP: [<ffffffff81004e14>] show_stack_log_lvl+0x134/0x1a0
[ 3701.484366] PGD 28c5067 PUD 28c6067 PMD 28c7067 PTE 8000000000105060
[ 3701.484366] Thread overran stack, or stack corrupted
[ 3701.484366] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[ 3701.484366] Dumping ftrace buffer:
[ 3701.484366] ---------------------------------
[ 3701.484366]    <...>-6117    8d..4 3786719374us : stack_trace_call:         Depth    Size   Location    (46 entries)
[ 3701.484366]         -----    ----   --------
[ 3701.484366]    <...>-6117    8d..4 3786719395us : stack_trace_call:   0)     7200       8   _raw_spin_lock_irqsave+0x51/0x60
[ 3701.484366]    <...>-6117    8d..4 3786719395us : stack_trace_call:   1)     7192     296   get_page_from_freelist+0x886/0x920
[ 3701.484366]    <...>-6117    8d..4 3786719395us : stack_trace_call:   2)     6896     352   __alloc_pages_nodemask+0x5e1/0xb20
[ 3701.484366]    <...>-6117    8d..4 3786719396us : stack_trace_call:   3)     6544       8   alloc_pages_current+0x10f/0x1f0
[ 3701.484366]    <...>-6117    8d..4 3786719396us : stack_trace_call:   4)     6536     168   new_slab+0x2c5/0x370
[ 3701.484366]    <...>-6117    8d..4 3786719396us : stack_trace_call:   5)     6368       8   __slab_alloc+0x3a9/0x501
[ 3701.484366]    <...>-6117    8d..4 3786719396us : stack_trace_call:   6)     6360      80   __kmalloc+0x1cb/0x200
[ 3701.484366]    <...>-6117    8d..4 3786719396us : stack_trace_call:   7)     6280     376   vring_add_indirect+0x36/0x200
[ 3701.484366]    <...>-6117    8d..4 3786719397us : stack_trace_call:   8)     5904     144   virtqueue_add_sgs+0x2e2/0x320
[ 3701.484366]    <...>-6117    8d..4 3786719397us : stack_trace_call:   9)     5760     288   __virtblk_add_req+0xda/0x1b0
[ 3701.484366]    <...>-6117    8d..4 3786719397us : stack_trace_call:  10)     5472      96   virtio_queue_rq+0xd3/0x1d0
[ 3701.484366]    <...>-6117    8d..4 3786719397us : stack_trace_call:  11)     5376     128   __blk_mq_run_hw_queue+0x1ef/0x440
[ 3701.484366]    <...>-6117    8d..4 3786719397us : stack_trace_call:  12)     5248      16   blk_mq_run_hw_queue+0x35/0x40
[ 3701.484366]    <...>-6117    8d..4 3786719397us : stack_trace_call:  13)     5232      96   blk_mq_insert_requests+0xdb/0x160
[ 3701.484366]    <...>-6117    8d..4 3786719398us : stack_trace_call:  14)     5136     112   blk_mq_flush_plug_list+0x12b/0x140
[ 3701.484366]    <...>-6117    8d..4 3786719398us : stack_trace_call:  15)     5024     112   blk_flush_plug_list+0xc7/0x220
[ 3701.484366]    <...>-6117    8d..4 3786719398us : stack_trace_call:  16)     4912     128   blk_mq_make_request+0x42a/0x600
[ 3701.484366]    <...>-6117    8d..4 3786719398us : stack_trace_call:  17)     4784      48   generic_make_request+0xc0/0x100
[ 3701.484366]    <...>-6117    8d..4 3786719398us : stack_trace_call:  18)     4736     112   submit_bio+0x86/0x160
[ 3701.484366]    <...>-6117    8d..4 3786719398us : stack_trace_call:  19)     4624     160   __swap_writepage+0x198/0x230
[ 3701.484366]    <...>-6117    8d..4 3786719399us : stack_trace_call:  20)     4464      32   swap_writepage+0x42/0x90
[ 3701.484366]    <...>-6117    8d..4 3786719399us : stack_trace_call:  21)     4432     320   shrink_page_list+0x676/0xa80
[ 3701.484366]    <...>-6117    8d..4 3786719399us : stack_trace_call:  22)     4112     208   shrink_inactive_list+0x262/0x4e0
[ 3701.484366]    <...>-6117    8d..4 3786719399us : stack_trace_call:  23)     3904     304   shrink_lruvec+0x3e1/0x6a0
[ 3701.484366]    <...>-6117    8d..4 3786719399us : stack_trace_call:  24)     3600      80   shrink_zone+0x3f/0x110
[ 3701.484366]    <...>-6117    8d..4 3786719400us : stack_trace_call:  25)     3520     128   do_try_to_free_pages+0x156/0x4c0
[ 3701.484366]    <...>-6117    8d..4 3786719400us : stack_trace_call:  26)     3392     208   try_to_free_pages+0xf7/0x1e0
[ 3701.484366]    <...>-6117    8d..4 3786719400us : stack_trace_call:  27)     3184     352   __alloc_pages_nodemask+0x783/0xb20
[ 3701.484366]    <...>-6117    8d..4 3786719400us : stack_trace_call:  28)     2832       8   alloc_pages_current+0x10f/0x1f0
[ 3701.484366]    <...>-6117    8d..4 3786719400us : stack_trace_call:  29)     2824     200   __page_cache_alloc+0x13f/0x160
[ 3701.484366]    <...>-6117    8d..4 3786719400us : stack_trace_call:  30)     2624      80   find_or_create_page+0x4c/0xb0
[ 3701.484366]    <...>-6117    8d..4 3786719401us : stack_trace_call:  31)     2544     112   __getblk+0x109/0x2f0
[ 3701.484366]    <...>-6117    8d..4 3786719401us : stack_trace_call:  32)     2432     224   ext4_ext_insert_extent+0x4d8/0x1270
[ 3701.484366]    <...>-6117    8d..4 3786719401us : stack_trace_call:  33)     2208     256   ext4_ext_map_blocks+0x8d4/0x1010
[ 3701.484366]    <...>-6117    8d..4 3786719401us : stack_trace_call:  34)     1952     160   ext4_map_blocks+0x325/0x530
[ 3701.484366]    <...>-6117    8d..4 3786719401us : stack_trace_call:  35)     1792     384   ext4_writepages+0x6d1/0xce0
[ 3701.484366]    <...>-6117    8d..4 3786719402us : stack_trace_call:  36)     1408      16   do_writepages+0x23/0x40
[ 3701.484366]    <...>-6117    8d..4 3786719402us : stack_trace_call:  37)     1392      96   __writeback_single_inode+0x45/0x2e0
[ 3701.484366]    <...>-6117    8d..4 3786719402us : stack_trace_call:  38)     1296     176   writeback_sb_inodes+0x2ad/0x500
[ 3701.484366]    <...>-6117    8d..4 3786719402us : stack_trace_call:  39)     1120      80   __writeback_inodes_wb+0x9e/0xd0
[ 3701.484366]    <...>-6117    8d..4 3786719402us : stack_trace_call:  40)     1040     160   wb_writeback+0x29b/0x350
[ 3701.484366]    <...>-6117    8d..4 3786719402us : stack_trace_call:  41)      880     208   bdi_writeback_workfn+0x11c/0x480
[ 3701.484366]    <...>-6117    8d..4 3786719403us : stack_trace_call:  42)      672     144   process_one_work+0x1d2/0x570
[ 3701.484366]    <...>-6117    8d..4 3786719403us : stack_trace_call:  43)      528     112   worker_thread+0x116/0x370
[ 3701.484366]    <...>-6117    8d..4 3786719403us : stack_trace_call:  44)      416     240   kthread+0xf3/0x110
[ 3701.484366]    <...>-6117    8d..4 3786719403us : stack_trace_call:  45)      176     176   ret_from_fork+0x7c/0xb0
[ 3701.484366] ---------------------------------
[ 3701.484366] Modules linked in:
[ 3701.484366] CPU: 8 PID: 6117 Comm: kworker/u24:1 Not tainted 3.14.0+ #201
[ 3701.484366] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 3701.484366] Workqueue: writeback bdi_writeback_workfn (flush-253:0)
[ 3701.484366] task: ffff8800353c41c0 ti: ffff880000106000 task.ti: ffff880000106000
[ 3701.484366] RIP: 0010:[<ffffffff81004e14>]  [<ffffffff81004e14>] show_stack_log_lvl+0x134/0x1a0
[ 3701.484366] RSP: 0000:ffff880037d06e58  EFLAGS: 00010046
[ 3701.484366] RAX: 000000000000000c RBX: 0000000000000000 RCX: 0000000000000000
[ 3701.484366] RDX: ffff880037cfffc0 RSI: ffff880037d06f58 RDI: 0000000000000000
[ 3701.484366] RBP: ffff880037d06ea8 R08: ffffffff81a0804c R09: 0000000000000000
[ 3701.484366] R10: 0000000000000002 R11: 0000000000000002 R12: ffff880037d06f58
[ 3701.484366] R13: 0000000000000000 R14: ffff880000105f58 R15: ffff880037d03fc0
[ 3701.484366] FS:  0000000000000000(0000) GS:ffff880037d00000(0000) knlGS:0000000000000000
[ 3701.484366] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3701.484366] CR2: ffff880000105f58 CR3: 0000000001c0b000 CR4: 00000000000006e0
[ 3701.484366] Stack:
[ 3701.484366]  0000000000000000 ffff880000105f58 ffff880037d06f58 ffff880000105f58
[ 3701.484366]  ffff880000106000 ffff880037d06f58 0000000000000040 ffff880037d06f58
[ 3701.484366]  ffff880000105f58 0000000000000000 ffff880037d06ef8 ffffffff81004f1c
[ 3701.484366] Call Trace:
[ 3701.484366]  <#DF> 
[ 3701.484366]  [<ffffffff81004f1c>] show_regs+0x9c/0x1f0
[ 3701.484366]  [<ffffffff8103aa37>] df_debug+0x27/0x40
[ 3701.484366]  [<ffffffff81003361>] do_double_fault+0x61/0x80
[ 3701.484366]  [<ffffffff816f0907>] double_fault+0x27/0x30
[ 3701.484366]  [<ffffffff810a5390>] ? __lock_acquire+0x170/0x1ca0
[ 3701.484366]  <<EOE>> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
