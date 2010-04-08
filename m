Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2F3FF6B020C
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 19:38:42 -0400 (EDT)
Date: Fri, 9 Apr 2010 09:38:37 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: PROBLEM + POSS FIX: kernel stack overflow, xfs, many disks,
 heavy write load, 8k stack, x86-64
Message-ID: <20100408233837.GP11036@dastard>
References: <4BBC6719.7080304@humyo.com>
 <20100407140523.GJ11036@dastard>
 <4BBCAB57.3000106@humyo.com>
 <20100407234341.GK11036@dastard>
 <20100408030347.GM11036@dastard>
 <4BBDC92D.8060503@humyo.com>
 <4BBDEC9A.9070903@humyo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BBDEC9A.9070903@humyo.com>
Sender: owner-linux-mm@kvack.org
To: John Berthels <john@humyo.com>
Cc: linux-kernel@vger.kernel.org, Nick Gregory <nick@humyo.com>, Rob Sanderson <rob@humyo.com>, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 08, 2010 at 03:47:54PM +0100, John Berthels wrote:
> John Berthels wrote:
> >I'll reply again after it's been running long enough to draw conclusions.
> We're getting pretty close on the 8k stack on this box now. It's
> running 2.6.33.2 + your patch, with THREAD_ORDER 1, stack tracing
> and CONFIG_LOCKDEP=y. (Sorry that LOCKDEP is on, please advise if
> that's going to throw the figures and we'll restart the test systems
> with new kernels).
> 
> This is significantly more than 5.6K, so it shows a potential
> problem? Or is 720 bytes enough headroom?
> 
> jb
> 
> [ 4005.541869] apache2 used greatest stack depth: 2480 bytes left
> [ 4005.541973] apache2 used greatest stack depth: 2240 bytes left
> [ 4005.542070] apache2 used greatest stack depth: 1936 bytes left
> [ 4005.542614] apache2 used greatest stack depth: 1616 bytes left
> [ 5531.406529] apache2 used greatest stack depth: 720 bytes left
> 
> $ cat /sys/kernel/debug/tracing/stack_trace
>        Depth    Size   Location    (55 entries)
>        -----    ----   --------
>  0)     7440      48   add_partial+0x26/0x90
>  1)     7392      64   __slab_free+0x1a9/0x380
>  2)     7328      64   kmem_cache_free+0xb9/0x160
>  3)     7264      16   free_buffer_head+0x25/0x50
>  4)     7248      64   try_to_free_buffers+0x79/0xc0
>  5)     7184     160   xfs_vm_releasepage+0xda/0x130 [xfs]
>  6)     7024      16   try_to_release_page+0x33/0x60
>  7)     7008     384   shrink_page_list+0x585/0x860
>  8)     6624     528   shrink_zone+0x636/0xdc0
>  9)     6096     112   do_try_to_free_pages+0xc2/0x3c0
> 10)     5984     112   try_to_free_pages+0x64/0x70
> 11)     5872     256   __alloc_pages_nodemask+0x3d2/0x710
> 12)     5616      48   alloc_pages_current+0x8c/0xe0
> 13)     5568      32   __page_cache_alloc+0x67/0x70
> 14)     5536      80   find_or_create_page+0x50/0xb0
> 15)     5456     160   _xfs_buf_lookup_pages+0x145/0x350 [xfs]
> 16)     5296      64   xfs_buf_get+0x74/0x1d0 [xfs]
> 17)     5232      48   xfs_buf_read+0x2f/0x110 [xfs]
> 18)     5184      80   xfs_trans_read_buf+0x2bf/0x430 [xfs]

We're entering memory reclaim with almost 6k of stack already in
use. If we get down into the IO layer and then have to do a memory
reclaim, then we'll have even less stack to work with. It looks like
memory allocation needs at least 2KB of stack to work with now,
so if we enter anywhere near the top of the stack we can blow it...

Basically this trace is telling us the stack we have to work with
is:

	2KB memory allocation
	4KB page writeback
	2KB write foreground throttling path

So effectively the storage subsystem (NFS, filesystem, DM, MD,
device drivers) have about 4K of stack to work in now. That seems to
be a lot less than last time I looked at this, and we've been really
careful not to increase XFS's stack usage for quite some time now.

Hence I'm not sure exactly what to do about this, John. I can't
really do much about the stack footprint of XFS as all the
low-hanging fruit has already been trimmed. Even if I convert the
foreground throttling to not issue IO, the background flush threads
still have roughly the same stack usage, so a memory allocation and
reclaim in the wrong place could still blow the stack....

I'll have to have a bit of a think on this one - if you could
provide further stack traces as they get deeper (esp. if they go
past 8k) that would be really handy.

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
