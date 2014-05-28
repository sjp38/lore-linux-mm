Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id EE62F6B0037
	for <linux-mm@kvack.org>; Wed, 28 May 2014 02:53:34 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id um1so10632216pbc.32
        for <linux-mm@kvack.org>; Tue, 27 May 2014 23:53:34 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id fy1si21973356pbb.65.2014.05.27.23.53.32
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 23:53:33 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/2] ftrace: print stack usage right before Oops
Date: Wed, 28 May 2014 15:53:58 +0900
Message-Id: <1401260039-18189-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, rusty@rustcorp.com.au, mst@redhat.com, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>, Minchan Kim <minchan@kernel.org>

While I played with my own feature(ex, something on the way to reclaim),
kernel went to oops easily. I guessed reason would be stack overflow
and wanted to prove it.

I found stack tracer which would be very useful for me but kernel went
oops before my user program gather the information via
"watch cat /sys/kernel/debug/tracing/stack_trace" so I couldn't get an
stack usage of each functions.

What I want was that emit the kernel stack usage when kernel goes oops.

This patch records callstack of max stack usage into ftrace buffer
right before Oops and print that information with ftrace_dump_on_oops.
At last, I can find a culprit. :)

The result is as follows.

  111.402376] ------------[ cut here ]------------
[  111.403077] kernel BUG at kernel/trace/trace_stack.c:177!
[  111.403831] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  111.404635] Dumping ftrace buffer:
[  111.404781] ---------------------------------
[  111.404781]    <...>-15987   5d..2 111689526us : stack_trace_call:         Depth    Size   Location    (49 entries)
[  111.404781]         -----    ----   --------
[  111.404781]    <...>-15987   5d..2 111689535us : stack_trace_call:   0)     7216      24   __change_page_attr_set_clr+0xe0/0xb50
[  111.404781]    <...>-15987   5d..2 111689535us : stack_trace_call:   1)     7192     392   kernel_map_pages+0x6c/0x120
[  111.404781]    <...>-15987   5d..2 111689535us : stack_trace_call:   2)     6800     256   get_page_from_freelist+0x489/0x920
[  111.404781]    <...>-15987   5d..2 111689536us : stack_trace_call:   3)     6544     352   __alloc_pages_nodemask+0x5e1/0xb20
[  111.404781]    <...>-15987   5d..2 111689536us : stack_trace_call:   4)     6192       8   alloc_pages_current+0x10f/0x1f0
[  111.404781]    <...>-15987   5d..2 111689537us : stack_trace_call:   5)     6184     168   new_slab+0x2c5/0x370
[  111.404781]    <...>-15987   5d..2 111689537us : stack_trace_call:   6)     6016       8   __slab_alloc+0x3a9/0x501
[  111.404781]    <...>-15987   5d..2 111689537us : stack_trace_call:   7)     6008      80   __kmalloc+0x1cb/0x200
[  111.404781]    <...>-15987   5d..2 111689538us : stack_trace_call:   8)     5928     376   vring_add_indirect+0x36/0x200
[  111.404781]    <...>-15987   5d..2 111689538us : stack_trace_call:   9)     5552     144   virtqueue_add_sgs+0x2e2/0x320
[  111.404781]    <...>-15987   5d..2 111689538us : stack_trace_call:  10)     5408     288   __virtblk_add_req+0xda/0x1b0
[  111.404781]    <...>-15987   5d..2 111689538us : stack_trace_call:  11)     5120      96   virtio_queue_rq+0xd3/0x1d0
[  111.404781]    <...>-15987   5d..2 111689539us : stack_trace_call:  12)     5024     128   __blk_mq_run_hw_queue+0x1ef/0x440
[  111.404781]    <...>-15987   5d..2 111689539us : stack_trace_call:  13)     4896      16   blk_mq_run_hw_queue+0x35/0x40
[  111.404781]    <...>-15987   5d..2 111689539us : stack_trace_call:  14)     4880      96   blk_mq_insert_requests+0xdb/0x160
[  111.404781]    <...>-15987   5d..2 111689540us : stack_trace_call:  15)     4784     112   blk_mq_flush_plug_list+0x12b/0x140
[  111.404781]    <...>-15987   5d..2 111689540us : stack_trace_call:  16)     4672     112   blk_flush_plug_list+0xc7/0x220
[  111.404781]    <...>-15987   5d..2 111689540us : stack_trace_call:  17)     4560      64   io_schedule_timeout+0x88/0x100
[  111.404781]    <...>-15987   5d..2 111689541us : stack_trace_call:  18)     4496     128   mempool_alloc+0x145/0x170
[  111.404781]    <...>-15987   5d..2 111689541us : stack_trace_call:  19)     4368      96   bio_alloc_bioset+0x10b/0x1d0
[  111.404781]    <...>-15987   5d..2 111689541us : stack_trace_call:  20)     4272      48   get_swap_bio+0x30/0x90
[  111.404781]    <...>-15987   5d..2 111689542us : stack_trace_call:  21)     4224     160   __swap_writepage+0x150/0x230
[  111.404781]    <...>-15987   5d..2 111689542us : stack_trace_call:  22)     4064      32   swap_writepage+0x42/0x90
[  111.404781]    <...>-15987   5d..2 111689542us : stack_trace_call:  23)     4032     320   shrink_page_list+0x676/0xa80
[  111.404781]    <...>-15987   5d..2 111689543us : stack_trace_call:  24)     3712     208   shrink_inactive_list+0x262/0x4e0
[  111.404781]    <...>-15987   5d..2 111689543us : stack_trace_call:  25)     3504     304   shrink_lruvec+0x3e1/0x6a0
[  111.404781]    <...>-15987   5d..2 111689543us : stack_trace_call:  26)     3200      80   shrink_zone+0x3f/0x110
[  111.404781]    <...>-15987   5d..2 111689544us : stack_trace_call:  27)     3120     128   do_try_to_free_pages+0x156/0x4c0
[  111.404781]    <...>-15987   5d..2 111689544us : stack_trace_call:  28)     2992     208   try_to_free_pages+0xf7/0x1e0
[  111.404781]    <...>-15987   5d..2 111689544us : stack_trace_call:  29)     2784     352   __alloc_pages_nodemask+0x783/0xb20
[  111.404781]    <...>-15987   5d..2 111689545us : stack_trace_call:  30)     2432       8   alloc_pages_current+0x10f/0x1f0
[  111.404781]    <...>-15987   5d..2 111689545us : stack_trace_call:  31)     2424     168   new_slab+0x2c5/0x370
[  111.404781]    <...>-15987   5d..2 111689545us : stack_trace_call:  32)     2256       8   __slab_alloc+0x3a9/0x501
[  111.404781]    <...>-15987   5d..2 111689546us : stack_trace_call:  33)     2248      80   kmem_cache_alloc+0x1ac/0x1c0
[  111.404781]    <...>-15987   5d..2 111689546us : stack_trace_call:  34)     2168     296   mempool_alloc_slab+0x15/0x20
[  111.404781]    <...>-15987   5d..2 111689546us : stack_trace_call:  35)     1872     128   mempool_alloc+0x5e/0x170
[  111.404781]    <...>-15987   5d..2 111689547us : stack_trace_call:  36)     1744      96   bio_alloc_bioset+0x10b/0x1d0
[  111.404781]    <...>-15987   5d..2 111689547us : stack_trace_call:  37)     1648      48   mpage_alloc+0x38/0xa0
[  111.404781]    <...>-15987   5d..2 111689547us : stack_trace_call:  38)     1600     208   do_mpage_readpage+0x49b/0x5d0
[  111.404781]    <...>-15987   5d..2 111689548us : stack_trace_call:  39)     1392     224   mpage_readpages+0xcf/0x120
[  111.404781]    <...>-15987   5d..2 111689548us : stack_trace_call:  40)     1168      48   ext4_readpages+0x45/0x60
[  111.404781]    <...>-15987   5d..2 111689548us : stack_trace_call:  41)     1120     224   __do_page_cache_readahead+0x222/0x2d0
[  111.404781]    <...>-15987   5d..2 111689549us : stack_trace_call:  42)      896      16   ra_submit+0x21/0x30
[  111.404781]    <...>-15987   5d..2 111689549us : stack_trace_call:  43)      880     112   filemap_fault+0x2d7/0x4f0
[  111.404781]    <...>-15987   5d..2 111689549us : stack_trace_call:  44)      768     144   __do_fault+0x6d/0x4c0
[  111.404781]    <...>-15987   5d..2 111689550us : stack_trace_call:  45)      624     160   handle_mm_fault+0x1a6/0xaf0
[  111.404781]    <...>-15987   5d..2 111689550us : stack_trace_call:  46)      464     272   __do_page_fault+0x18a/0x590
[  111.404781]    <...>-15987   5d..2 111689550us : stack_trace_call:  47)      192      16   do_page_fault+0xc/0x10
[  111.404781]    <...>-15987   5d..2 111689551us : stack_trace_call:  48)      176     176   page_fault+0x22/0x30
[  111.404781] ---------------------------------
[  111.404781] Modules linked in:
[  111.404781] CPU: 5 PID: 15987 Comm: cc1 Not tainted 3.14.0+ #162
[  111.404781] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  111.404781] task: ffff880008a4a0e0 ti: ffff88000002c000 task.ti: ffff88000002c000
[  111.404781] RIP: 0010:[<ffffffff8112340f>]  [<ffffffff8112340f>] stack_trace_call+0x37f/0x390
[  111.404781] RSP: 0000:ffff88000002c2b0  EFLAGS: 00010092
[  111.404781] RAX: ffff88000002c000 RBX: 0000000000000005 RCX: 0000000000000002
[  111.404781] RDX: 0000000000000006 RSI: 0000000000000002 RDI: ffff88002780be00
[  111.404781] RBP: ffff88000002c310 R08: 00000000000009e8 R09: ffffffffffffffff
[  111.404781] R10: ffff88000002dfd8 R11: 0000000000000001 R12: 000000000000f2e8
[  111.404781] R13: 0000000000000005 R14: ffffffff82768dfc R15: 00000000000000f8
[  111.404781] FS:  00002ae66a6e4640(0000) GS:ffff880027ca0000(0000) knlGS:0000000000000000
[  111.404781] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  111.404781] CR2: 00002ba016c8e004 CR3: 00000000045b7000 CR4: 00000000000006e0
[  111.404781] Stack:
[  111.404781]  0000000000000005 ffffffff81042410 0000000000000087 0000000000001c30
[  111.404781]  ffff88000002c000 00002ae66a6f3000 ffffffffffffe000 0000000000000002
[  111.404781]  ffff88000002c510 ffff880000d04000 ffff88000002c4b8 0000000000000002
[  111.404781] Call Trace:
[  111.404781]  [<ffffffff81042410>] ? __change_page_attr_set_clr+0xe0/0xb50
[  111.404781]  [<ffffffff816efdff>] ftrace_call+0x5/0x2f
[  111.404781]  [<ffffffff81004ba7>] ? dump_trace+0x177/0x2b0
[  111.404781]  [<ffffffff81041a65>] ? _lookup_address_cpa.isra.3+0x5/0x40
[  111.404781]  [<ffffffff81041a65>] ? _lookup_address_cpa.isra.3+0x5/0x40
[  111.404781]  [<ffffffff81042410>] ? __change_page_attr_set_clr+0xe0/0xb50
[  111.404781]  [<ffffffff811231a9>] ? stack_trace_call+0x119/0x390
[  111.404781]  [<ffffffff81043eac>] ? kernel_map_pages+0x6c/0x120
[  111.404781]  [<ffffffff810a22dd>] ? trace_hardirqs_off+0xd/0x10
[  111.404781]  [<ffffffff81150131>] ? get_page_from_freelist+0x3d1/0x920
[  111.404781]  [<ffffffff81043eac>] kernel_map_pages+0x6c/0x120
[  111.404781]  [<ffffffff811501e9>] get_page_from_freelist+0x489/0x920
[  111.404781]  [<ffffffff81150c61>] __alloc_pages_nodemask+0x5e1/0xb20
[  111.404781]  [<ffffffff8119188f>] alloc_pages_current+0x10f/0x1f0
[  111.404781]  [<ffffffff8119ac35>] ? new_slab+0x2c5/0x370
[  111.404781]  [<ffffffff8119ac35>] new_slab+0x2c5/0x370
[  111.404781]  [<ffffffff816dbfc9>] __slab_alloc+0x3a9/0x501
[  111.404781]  [<ffffffff8119beeb>] ? __kmalloc+0x1cb/0x200
[  111.404781]  [<ffffffff8141eba6>] ? vring_add_indirect+0x36/0x200
[  111.404781]  [<ffffffff8141eba6>] ? vring_add_indirect+0x36/0x200
[  111.404781]  [<ffffffff8141eba6>] ? vring_add_indirect+0x36/0x200
[  111.404781]  [<ffffffff8119beeb>] __kmalloc+0x1cb/0x200
[  111.404781]  [<ffffffff8141ed70>] ? vring_add_indirect+0x200/0x200
[  111.404781]  [<ffffffff8141eba6>] vring_add_indirect+0x36/0x200
[  111.404781]  [<ffffffff8141f362>] virtqueue_add_sgs+0x2e2/0x320
[  111.404781]  [<ffffffff8148f2ba>] __virtblk_add_req+0xda/0x1b0
[  111.404781]  [<ffffffff813780c5>] ? __delay+0x5/0x20
[  111.404781]  [<ffffffff8148f463>] virtio_queue_rq+0xd3/0x1d0
[  111.404781]  [<ffffffff8134b96f>] __blk_mq_run_hw_queue+0x1ef/0x440
[  111.404781]  [<ffffffff8134c035>] blk_mq_run_hw_queue+0x35/0x40
[  111.404781]  [<ffffffff8134c71b>] blk_mq_insert_requests+0xdb/0x160
[  111.404781]  [<ffffffff8134cdbb>] blk_mq_flush_plug_list+0x12b/0x140
[  111.404781]  [<ffffffff810c5ab5>] ? ktime_get_ts+0x125/0x150
[  111.404781]  [<ffffffff81343197>] blk_flush_plug_list+0xc7/0x220
[  111.404781]  [<ffffffff816e70bf>] ? _raw_spin_unlock_irqrestore+0x3f/0x70
[  111.404781]  [<ffffffff816e26b8>] io_schedule_timeout+0x88/0x100
[  111.404781]  [<ffffffff816e2635>] ? io_schedule_timeout+0x5/0x100
[  111.404781]  [<ffffffff81149465>] mempool_alloc+0x145/0x170
[  111.404781]  [<ffffffff8109baf0>] ? __init_waitqueue_head+0x60/0x60
[  111.404781]  [<ffffffff811e33cb>] bio_alloc_bioset+0x10b/0x1d0
[  111.404781]  [<ffffffff81184280>] ? end_swap_bio_read+0xc0/0xc0
[  111.404781]  [<ffffffff81184280>] ? end_swap_bio_read+0xc0/0xc0
[  111.404781]  [<ffffffff81184160>] get_swap_bio+0x30/0x90
[  111.404781]  [<ffffffff81184280>] ? end_swap_bio_read+0xc0/0xc0
[  111.404781]  [<ffffffff811846b0>] __swap_writepage+0x150/0x230
[  111.404781]  [<ffffffff81184280>] ? end_swap_bio_read+0xc0/0xc0
[  111.404781]  [<ffffffff81184565>] ? __swap_writepage+0x5/0x230
[  111.404781]  [<ffffffff811847d2>] swap_writepage+0x42/0x90
[  111.404781]  [<ffffffff8115aee6>] shrink_page_list+0x676/0xa80
[  111.404781]  [<ffffffff816efdff>] ? ftrace_call+0x5/0x2f
[  111.404781]  [<ffffffff8115b8c2>] shrink_inactive_list+0x262/0x4e0
[  111.404781]  [<ffffffff8115c211>] shrink_lruvec+0x3e1/0x6a0
[  111.404781]  [<ffffffff8115c50f>] shrink_zone+0x3f/0x110
[  111.404781]  [<ffffffff816efdff>] ? ftrace_call+0x5/0x2f
[  111.404781]  [<ffffffff8115ca36>] do_try_to_free_pages+0x156/0x4c0
[  111.404781]  [<ffffffff8115cf97>] try_to_free_pages+0xf7/0x1e0
[  111.404781]  [<ffffffff81150e03>] __alloc_pages_nodemask+0x783/0xb20
[  111.404781]  [<ffffffff8119188f>] alloc_pages_current+0x10f/0x1f0
[  111.404781]  [<ffffffff8119ac35>] ? new_slab+0x2c5/0x370
[  111.404781]  [<ffffffff8119ac35>] new_slab+0x2c5/0x370
[  111.404781]  [<ffffffff816dbfc9>] __slab_alloc+0x3a9/0x501
[  111.404781]  [<ffffffff8119d95c>] ? kmem_cache_alloc+0x1ac/0x1c0
[  111.404781]  [<ffffffff81149025>] ? mempool_alloc_slab+0x15/0x20
[  111.404781]  [<ffffffff81149025>] ? mempool_alloc_slab+0x15/0x20
[  111.404781]  [<ffffffff8119d95c>] kmem_cache_alloc+0x1ac/0x1c0
[  111.404781]  [<ffffffff81149025>] ? mempool_alloc_slab+0x15/0x20
[  111.404781]  [<ffffffff81149025>] mempool_alloc_slab+0x15/0x20
[  111.404781]  [<ffffffff8114937e>] mempool_alloc+0x5e/0x170
[  111.404781]  [<ffffffff811e33cb>] bio_alloc_bioset+0x10b/0x1d0
[  111.404781]  [<ffffffff811ea618>] mpage_alloc+0x38/0xa0
[  111.404781]  [<ffffffff811eb2eb>] do_mpage_readpage+0x49b/0x5d0
[  111.404781]  [<ffffffff812512f0>] ? ext4_get_block_write+0x20/0x20
[  111.404781]  [<ffffffff811eb55f>] mpage_readpages+0xcf/0x120
[  111.404781]  [<ffffffff812512f0>] ? ext4_get_block_write+0x20/0x20
[  111.404781]  [<ffffffff812512f0>] ? ext4_get_block_write+0x20/0x20
[  111.404781]  [<ffffffff816efdff>] ? ftrace_call+0x5/0x2f
[  111.404781]  [<ffffffff816efdff>] ? ftrace_call+0x5/0x2f
[  111.404781]  [<ffffffff81153e21>] ? __do_page_cache_readahead+0xc1/0x2d0
[  111.404781]  [<ffffffff812512f0>] ? ext4_get_block_write+0x20/0x20
[  111.404781]  [<ffffffff8124d045>] ext4_readpages+0x45/0x60
[  111.404781]  [<ffffffff81153f82>] __do_page_cache_readahead+0x222/0x2d0
[  111.404781]  [<ffffffff81153e21>] ? __do_page_cache_readahead+0xc1/0x2d0
[  111.404781]  [<ffffffff811541c1>] ra_submit+0x21/0x30
[  111.404781]  [<ffffffff811482f7>] filemap_fault+0x2d7/0x4f0
[  111.404781]  [<ffffffff8116f3ad>] __do_fault+0x6d/0x4c0
[  111.404781]  [<ffffffff81172596>] handle_mm_fault+0x1a6/0xaf0
[  111.404781]  [<ffffffff816eb1aa>] __do_page_fault+0x18a/0x590
[  111.404781]  [<ffffffff816efdff>] ? ftrace_call+0x5/0x2f
[  111.404781]  [<ffffffff81081e9c>] ? finish_task_switch+0x7c/0x120
[  111.404781]  [<ffffffff81081e5f>] ? finish_task_switch+0x3f/0x120
[  111.404781]  [<ffffffff816eb5bc>] do_page_fault+0xc/0x10
[  111.404781]  [<ffffffff816e7a52>] page_fault+0x22/0x30

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 kernel/trace/trace_stack.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/trace_stack.c b/kernel/trace/trace_stack.c
index 5aa9a5b9b6e2..5eb88e60bc5e 100644
--- a/kernel/trace/trace_stack.c
+++ b/kernel/trace/trace_stack.c
@@ -51,6 +51,30 @@ static DEFINE_MUTEX(stack_sysctl_mutex);
 int stack_tracer_enabled;
 static int last_stack_tracer_enabled;
 
+static inline void print_max_stack(void)
+{
+	long i;
+	int size;
+
+	trace_printk("        Depth    Size   Location"
+			   "    (%d entries)\n"
+			   "        -----    ----   --------\n",
+			   max_stack_trace.nr_entries - 1);
+
+	for (i = 0; i < max_stack_trace.nr_entries; i++) {
+		if (stack_dump_trace[i] == ULONG_MAX)
+			break;
+		if (i+1 == max_stack_trace.nr_entries ||
+				stack_dump_trace[i+1] == ULONG_MAX)
+			size = stack_dump_index[i];
+		else
+			size = stack_dump_index[i] - stack_dump_index[i+1];
+
+		trace_printk("%3ld) %8d   %5d   %pS\n", i, stack_dump_index[i],
+				size, (void *)stack_dump_trace[i]);
+	}
+}
+
 static inline void
 check_stack(unsigned long ip, unsigned long *stack)
 {
@@ -149,8 +173,12 @@ check_stack(unsigned long ip, unsigned long *stack)
 			i++;
 	}
 
-	BUG_ON(current != &init_task &&
-		*(end_of_stack(current)) != STACK_END_MAGIC);
+	if ((current != &init_task &&
+		*(end_of_stack(current)) != STACK_END_MAGIC)) {
+		print_max_stack();
+		BUG();
+	}
+
  out:
 	arch_spin_unlock(&max_stack_lock);
 	local_irq_restore(flags);
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
