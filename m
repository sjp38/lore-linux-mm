Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1FA6B0036
	for <linux-mm@kvack.org>; Wed, 28 May 2014 05:13:56 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so10802172pbc.12
        for <linux-mm@kvack.org>; Wed, 28 May 2014 02:13:56 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id ah3si22829171pad.52.2014.05.28.02.13.54
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 02:13:55 -0700 (PDT)
Date: Wed, 28 May 2014 19:13:45 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140528091345.GD6677@dastard>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <20140528083738.GL8554@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140528083738.GL8554@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, rusty@rustcorp.com.au, mst@redhat.com, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>, xfs@oss.sgi.com

On Wed, May 28, 2014 at 06:37:38PM +1000, Dave Chinner wrote:
> [ cc XFS list ]

[and now there is a complete copy on the XFs list, I'll add my 2c]

> On Wed, May 28, 2014 at 03:53:59PM +0900, Minchan Kim wrote:
> > While I play inhouse patches with much memory pressure on qemu-kvm,
> > 3.14 kernel was randomly crashed. The reason was kernel stack overflow.
> > 
> > When I investigated the problem, the callstack was a little bit deeper
> > by involve with reclaim functions but not direct reclaim path.
> > 
> > I tried to diet stack size of some functions related with alloc/reclaim
> > so did a hundred of byte but overflow was't disappeard so that I encounter
> > overflow by another deeper callstack on reclaim/allocator path.

That's a no win situation. The stack overruns through ->writepage
we've been seeing with XFS over the past *4 years* are much larger
than a few bytes. The worst case stack usage on a virtio block
device was about 10.5KB of stack usage.

And, like this one, it came from the flusher thread as well. The
difference was that the allocation that triggered the reclaim path
you've reported occurred when 5k of the stack had already been
used...

> > Of course, we might sweep every sites we have found for reducing
> > stack usage but I'm not sure how long it saves the world(surely,
> > lots of developer start to add nice features which will use stack
> > agains) and if we consider another more complex feature in I/O layer
> > and/or reclaim path, it might be better to increase stack size(
> > meanwhile, stack usage on 64bit machine was doubled compared to 32bit
> > while it have sticked to 8K. Hmm, it's not a fair to me and arm64
> > already expaned to 16K. )

Yup, that's all been pointed out previously. 8k stacks were never
large enough to fit the linux IO architecture on x86-64, but nobody
outside filesystem and IO developers has been willing to accept that
argument as valid, despite regular stack overruns and filesystem
having to add workaround after workaround to prevent stack overruns.

That's why stuff like this appears in various filesystem's
->writepage:

        /*
         * Refuse to write the page out if we are called from reclaim context.
         *
         * This avoids stack overflows when called from deeply used stacks in
         * random callers for direct reclaim or memcg reclaim.  We explicitly
         * allow reclaim from kswapd as the stack usage there is relatively low.
         *
         * This should never happen except in the case of a VM regression so
         * warn about it.
         */
        if (WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
                        PF_MEMALLOC))
                goto redirty;

That still doesn't guarantee us enough stack space to do writeback,
though, because memory allocation can occur when reading in metadata
needed to do delayed allocation, and so we could trigger GFP_NOFS
memory allocation from the flusher thread with 4-5k of stack already
consumed, so that would still overrun teh stack.

So, a couple of years ago we started defering half the writeback
stack usage to a worker thread (commit c999a22 "xfs: introduce an
allocation workqueue"), under the assumption that the worst stack
usage when we call memory allocation is around 3-3.5k of stack used.
We thought that would be safe, but the stack trace you've posted
shows that alloc_page(GFP_NOFS) can consume upwards of 5k of stack,
which means we're still screwed despite all the workarounds we have
in place.

We've also had recent reports of allocation from direct IO blowing
the stack, as well as block allocation adding an entry to a
directory.  We're basically at the point where we have to push every
XFS operation that requires block allocation off to another thread
to get enough stack space for normal operation.....

> > So, my stupid idea is just let's expand stack size and keep an eye

Not stupid: it's been what I've been advocating we need to do for
the past 3-4 years. XFS has always been the stack usage canary and
this issue is basically a repeat of the 4k stack on i386 kernel
debacle.

> > toward stack consumption on each kernel functions via stacktrace of ftrace.
> > For example, we can have a bar like that each funcion shouldn't exceed 200K
> > and emit the warning when some function consumes more in runtime.
> > Of course, it could make false positive but at least, it could make a
> > chance to think over it.

I don't think that's a good idea. There are reasons for putting a
150-200 byte structure on the stack (e.g. used in a context where
allocation cannot be guaranteed to succeed because forward progress
cannot be guaranteed). hence having these users warn all the time
will quickly get very annoying and that functionality switched off
or removed....

> > I guess this topic was discussed several time so there might be
> > strong reason not to increase kernel stack size on x86_64, for me not
> > knowing so Ccing x86_64 maintainers, other MM guys and virtio
> > maintainers.
> >
> >          Depth    Size   Location    (51 entries)
> > 
> >    0)     7696      16   lookup_address+0x28/0x30
> >    1)     7680      16   _lookup_address_cpa.isra.3+0x3b/0x40
> >    2)     7664      24   __change_page_attr_set_clr+0xe0/0xb50
> >    3)     7640     392   kernel_map_pages+0x6c/0x120
> >    4)     7248     256   get_page_from_freelist+0x489/0x920
> >    5)     6992     352   __alloc_pages_nodemask+0x5e1/0xb20
> >    6)     6640       8   alloc_pages_current+0x10f/0x1f0
> >    7)     6632     168   new_slab+0x2c5/0x370
> >    8)     6464       8   __slab_alloc+0x3a9/0x501
> >    9)     6456      80   __kmalloc+0x1cb/0x200
> >   10)     6376     376   vring_add_indirect+0x36/0x200
> >   11)     6000     144   virtqueue_add_sgs+0x2e2/0x320
> >   12)     5856     288   __virtblk_add_req+0xda/0x1b0
> >   13)     5568      96   virtio_queue_rq+0xd3/0x1d0
> >   14)     5472     128   __blk_mq_run_hw_queue+0x1ef/0x440
> >   15)     5344      16   blk_mq_run_hw_queue+0x35/0x40
> >   16)     5328      96   blk_mq_insert_requests+0xdb/0x160
> >   17)     5232     112   blk_mq_flush_plug_list+0x12b/0x140
> >   18)     5120     112   blk_flush_plug_list+0xc7/0x220
> >   19)     5008      64   io_schedule_timeout+0x88/0x100
> >   20)     4944     128   mempool_alloc+0x145/0x170
> >   21)     4816      96   bio_alloc_bioset+0x10b/0x1d0
> >   22)     4720      48   get_swap_bio+0x30/0x90
> >   23)     4672     160   __swap_writepage+0x150/0x230
> >   24)     4512      32   swap_writepage+0x42/0x90
> >   25)     4480     320   shrink_page_list+0x676/0xa80
> >   26)     4160     208   shrink_inactive_list+0x262/0x4e0
> >   27)     3952     304   shrink_lruvec+0x3e1/0x6a0
> >   28)     3648      80   shrink_zone+0x3f/0x110
> >   29)     3568     128   do_try_to_free_pages+0x156/0x4c0
> >   30)     3440     208   try_to_free_pages+0xf7/0x1e0
> >   31)     3232     352   __alloc_pages_nodemask+0x783/0xb20
> >   32)     2880       8   alloc_pages_current+0x10f/0x1f0
> >   33)     2872     200   __page_cache_alloc+0x13f/0x160
> >   34)     2672      80   find_or_create_page+0x4c/0xb0
> >   35)     2592      80   ext4_mb_load_buddy+0x1e9/0x370
> >   36)     2512     176   ext4_mb_regular_allocator+0x1b7/0x460
> >   37)     2336     128   ext4_mb_new_blocks+0x458/0x5f0
> >   38)     2208     256   ext4_ext_map_blocks+0x70b/0x1010
> >   39)     1952     160   ext4_map_blocks+0x325/0x530
> >   40)     1792     384   ext4_writepages+0x6d1/0xce0
> >   41)     1408      16   do_writepages+0x23/0x40
> >   42)     1392      96   __writeback_single_inode+0x45/0x2e0
> >   43)     1296     176   writeback_sb_inodes+0x2ad/0x500
> >   44)     1120      80   __writeback_inodes_wb+0x9e/0xd0
> >   45)     1040     160   wb_writeback+0x29b/0x350
> >   46)      880     208   bdi_writeback_workfn+0x11c/0x480
> >   47)      672     144   process_one_work+0x1d2/0x570
> >   48)      528     112   worker_thread+0x116/0x370
> >   49)      416     240   kthread+0xf3/0x110
> >   50)      176     176   ret_from_fork+0x7c/0xb0

Impressive: 3 nested allocations - GFP_NOFS, GFP_NOIO and then
GFP_ATOMIC before the stack goes boom. XFS usually only needs 2...

However, add another 1000 bytes of stack for each IO by going
through the FC/scsi layers and hitting command allocation at the
bottom of the IO stack rather than bio allocation at the top and
maybe stack usage for 2-3 layers of MD and LVM as well, and you
start to see how that stack pushes >10k of usage rather than just
overflowing 8k....

> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  arch/x86/include/asm/page_64_types.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
> > index 8de6d9cf3b95..678205195ae1 100644
> > --- a/arch/x86/include/asm/page_64_types.h
> > +++ b/arch/x86/include/asm/page_64_types.h
> > @@ -1,7 +1,7 @@
> >  #ifndef _ASM_X86_PAGE_64_DEFS_H
> >  #define _ASM_X86_PAGE_64_DEFS_H
> >  
> > -#define THREAD_SIZE_ORDER	1
> > +#define THREAD_SIZE_ORDER	2
> >  #define THREAD_SIZE  (PAGE_SIZE << THREAD_SIZE_ORDER)
> >  #define CURRENT_MASK (~(THREAD_SIZE - 1))

Got my vote. Can we get this into 3.16, please?

Acked-by: Dave Chinner <david@fromorbit.com>

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
