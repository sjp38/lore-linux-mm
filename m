Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id DC1F16B0036
	for <linux-mm@kvack.org>; Wed, 28 May 2014 04:37:51 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so10796643pbc.15
        for <linux-mm@kvack.org>; Wed, 28 May 2014 01:37:51 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id yk1si20612292pbc.41.2014.05.28.01.37.49
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 01:37:50 -0700 (PDT)
Date: Wed, 28 May 2014 18:37:38 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140528083738.GL8554@dastard>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401260039-18189-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, rusty@rustcorp.com.au, mst@redhat.com, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>, xfs@oss.sgi.com

[ cc XFS list ]

On Wed, May 28, 2014 at 03:53:59PM +0900, Minchan Kim wrote:
> While I play inhouse patches with much memory pressure on qemu-kvm,
> 3.14 kernel was randomly crashed. The reason was kernel stack overflow.
> 
> When I investigated the problem, the callstack was a little bit deeper
> by involve with reclaim functions but not direct reclaim path.
> 
> I tried to diet stack size of some functions related with alloc/reclaim
> so did a hundred of byte but overflow was't disappeard so that I encounter
> overflow by another deeper callstack on reclaim/allocator path.
>
> Of course, we might sweep every sites we have found for reducing
> stack usage but I'm not sure how long it saves the world(surely,
> lots of developer start to add nice features which will use stack
> agains) and if we consider another more complex feature in I/O layer
> and/or reclaim path, it might be better to increase stack size(
> meanwhile, stack usage on 64bit machine was doubled compared to 32bit
> while it have sticked to 8K. Hmm, it's not a fair to me and arm64
> already expaned to 16K. )
>
> So, my stupid idea is just let's expand stack size and keep an eye
> toward stack consumption on each kernel functions via stacktrace of ftrace.
> For example, we can have a bar like that each funcion shouldn't exceed 200K
> and emit the warning when some function consumes more in runtime.
> Of course, it could make false positive but at least, it could make a
> chance to think over it.
>
> I guess this topic was discussed several time so there might be
> strong reason not to increase kernel stack size on x86_64, for me not
> knowing so Ccing x86_64 maintainers, other MM guys and virtio
> maintainers.
>
> [ 1065.604404] kworker/-5766    0d..2 1071625990us : stack_trace_call:         Depth    Size   Location    (51 entries)
> [ 1065.604404]         -----    ----   --------
> [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   0)     7696      16   lookup_address+0x28/0x30
> [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   1)     7680      16   _lookup_address_cpa.isra.3+0x3b/0x40
> [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   2)     7664      24   __change_page_attr_set_clr+0xe0/0xb50
> [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   3)     7640     392   kernel_map_pages+0x6c/0x120
> [ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   4)     7248     256   get_page_from_freelist+0x489/0x920
> [ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   5)     6992     352   __alloc_pages_nodemask+0x5e1/0xb20
> [ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   6)     6640       8   alloc_pages_current+0x10f/0x1f0
> [ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   7)     6632     168   new_slab+0x2c5/0x370
> [ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   8)     6464       8   __slab_alloc+0x3a9/0x501
> [ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:   9)     6456      80   __kmalloc+0x1cb/0x200
> [ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  10)     6376     376   vring_add_indirect+0x36/0x200
> [ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  11)     6000     144   virtqueue_add_sgs+0x2e2/0x320
> [ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  12)     5856     288   __virtblk_add_req+0xda/0x1b0
> [ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  13)     5568      96   virtio_queue_rq+0xd3/0x1d0
> [ 1065.604404] kworker/-5766    0d..2 1071625994us : stack_trace_call:  14)     5472     128   __blk_mq_run_hw_queue+0x1ef/0x440
> [ 1065.604404] kworker/-5766    0d..2 1071625994us : stack_trace_call:  15)     5344      16   blk_mq_run_hw_queue+0x35/0x40
> [ 1065.604404] kworker/-5766    0d..2 1071625994us : stack_trace_call:  16)     5328      96   blk_mq_insert_requests+0xdb/0x160
> [ 1065.604404] kworker/-5766    0d..2 1071625994us : stack_trace_call:  17)     5232     112   blk_mq_flush_plug_list+0x12b/0x140
> [ 1065.604404] kworker/-5766    0d..2 1071625994us : stack_trace_call:  18)     5120     112   blk_flush_plug_list+0xc7/0x220
> [ 1065.604404] kworker/-5766    0d..2 1071625995us : stack_trace_call:  19)     5008      64   io_schedule_timeout+0x88/0x100
> [ 1065.604404] kworker/-5766    0d..2 1071625995us : stack_trace_call:  20)     4944     128   mempool_alloc+0x145/0x170
> [ 1065.604404] kworker/-5766    0d..2 1071625995us : stack_trace_call:  21)     4816      96   bio_alloc_bioset+0x10b/0x1d0
> [ 1065.604404] kworker/-5766    0d..2 1071625995us : stack_trace_call:  22)     4720      48   get_swap_bio+0x30/0x90
> [ 1065.604404] kworker/-5766    0d..2 1071625995us : stack_trace_call:  23)     4672     160   __swap_writepage+0x150/0x230
> [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  24)     4512      32   swap_writepage+0x42/0x90
> [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  25)     4480     320   shrink_page_list+0x676/0xa80
> [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  26)     4160     208   shrink_inactive_list+0x262/0x4e0
> [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  27)     3952     304   shrink_lruvec+0x3e1/0x6a0
> [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  28)     3648      80   shrink_zone+0x3f/0x110
> [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  29)     3568     128   do_try_to_free_pages+0x156/0x4c0
> [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  30)     3440     208   try_to_free_pages+0xf7/0x1e0
> [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  31)     3232     352   __alloc_pages_nodemask+0x783/0xb20
> [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  32)     2880       8   alloc_pages_current+0x10f/0x1f0
> [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  33)     2872     200   __page_cache_alloc+0x13f/0x160
> [ 1065.604404] kworker/-5766    0d..2 1071625998us : stack_trace_call:  34)     2672      80   find_or_create_page+0x4c/0xb0
> [ 1065.604404] kworker/-5766    0d..2 1071625998us : stack_trace_call:  35)     2592      80   ext4_mb_load_buddy+0x1e9/0x370
> [ 1065.604404] kworker/-5766    0d..2 1071625998us : stack_trace_call:  36)     2512     176   ext4_mb_regular_allocator+0x1b7/0x460
> [ 1065.604404] kworker/-5766    0d..2 1071625998us : stack_trace_call:  37)     2336     128   ext4_mb_new_blocks+0x458/0x5f0
> [ 1065.604404] kworker/-5766    0d..2 1071625998us : stack_trace_call:  38)     2208     256   ext4_ext_map_blocks+0x70b/0x1010
> [ 1065.604404] kworker/-5766    0d..2 1071625999us : stack_trace_call:  39)     1952     160   ext4_map_blocks+0x325/0x530
> [ 1065.604404] kworker/-5766    0d..2 1071625999us : stack_trace_call:  40)     1792     384   ext4_writepages+0x6d1/0xce0
> [ 1065.604404] kworker/-5766    0d..2 1071625999us : stack_trace_call:  41)     1408      16   do_writepages+0x23/0x40
> [ 1065.604404] kworker/-5766    0d..2 1071625999us : stack_trace_call:  42)     1392      96   __writeback_single_inode+0x45/0x2e0
> [ 1065.604404] kworker/-5766    0d..2 1071625999us : stack_trace_call:  43)     1296     176   writeback_sb_inodes+0x2ad/0x500
> [ 1065.604404] kworker/-5766    0d..2 1071626000us : stack_trace_call:  44)     1120      80   __writeback_inodes_wb+0x9e/0xd0
> [ 1065.604404] kworker/-5766    0d..2 1071626000us : stack_trace_call:  45)     1040     160   wb_writeback+0x29b/0x350
> [ 1065.604404] kworker/-5766    0d..2 1071626000us : stack_trace_call:  46)      880     208   bdi_writeback_workfn+0x11c/0x480
> [ 1065.604404] kworker/-5766    0d..2 1071626000us : stack_trace_call:  47)      672     144   process_one_work+0x1d2/0x570
> [ 1065.604404] kworker/-5766    0d..2 1071626000us : stack_trace_call:  48)      528     112   worker_thread+0x116/0x370
> [ 1065.604404] kworker/-5766    0d..2 1071626001us : stack_trace_call:  49)      416     240   kthread+0xf3/0x110
> [ 1065.604404] kworker/-5766    0d..2 1071626001us : stack_trace_call:  50)      176     176   ret_from_fork+0x7c/0xb0
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  arch/x86/include/asm/page_64_types.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
> index 8de6d9cf3b95..678205195ae1 100644
> --- a/arch/x86/include/asm/page_64_types.h
> +++ b/arch/x86/include/asm/page_64_types.h
> @@ -1,7 +1,7 @@
>  #ifndef _ASM_X86_PAGE_64_DEFS_H
>  #define _ASM_X86_PAGE_64_DEFS_H
>  
> -#define THREAD_SIZE_ORDER	1
> +#define THREAD_SIZE_ORDER	2
>  #define THREAD_SIZE  (PAGE_SIZE << THREAD_SIZE_ORDER)
>  #define CURRENT_MASK (~(THREAD_SIZE - 1))

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
