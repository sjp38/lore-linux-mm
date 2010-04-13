Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5BBA46B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 15:34:53 -0400 (EDT)
Date: Tue, 13 Apr 2010 20:34:29 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100413193428.GI25756@csn.ul.ie>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com> <20100413095815.GU25756@csn.ul.ie> <20100413111902.GY2493@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100413111902.GY2493@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 09:19:02PM +1000, Dave Chinner wrote:
> On Tue, Apr 13, 2010 at 10:58:15AM +0100, Mel Gorman wrote:
> > On Tue, Apr 13, 2010 at 10:17:58AM +1000, Dave Chinner wrote:
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > When we enter direct reclaim we may have used an arbitrary amount of stack
> > > space, and hence enterring the filesystem to do writeback can then lead to
> > > stack overruns. This problem was recently encountered x86_64 systems with
> > > 8k stacks running XFS with simple storage configurations.
> > > 
> > > Writeback from direct reclaim also adversely affects background writeback. The
> > > background flusher threads should already be taking care of cleaning dirty
> > > pages, and direct reclaim will kick them if they aren't already doing work. If
> > > direct reclaim is also calling ->writepage, it will cause the IO patterns from
> > > the background flusher threads to be upset by LRU-order writeback from
> > > pageout() which can be effectively random IO. Having competing sources of IO
> > > trying to clean pages on the same backing device reduces throughput by
> > > increasing the amount of seeks that the backing device has to do to write back
> > > the pages.
> > > 
> > 
> > It's already known that the VM requesting specific pages be cleaned and
> > reclaimed is a bad IO pattern but unfortunately it is still required by
> > lumpy reclaim. This change would appear to break that although I haven't
> > tested it to be 100% sure.
> 
> How do you test it? I'd really like to be able to test this myself....
> 

Depends. For raw effectiveness, I run a series of performance-related
benchmarks with a final test that

o Starts a number of parallel compiles that in combination are 1.25 times
  of physical memory in total size
o Sleep three minutes
o Start allocating huge pages recording the latency required for each one
o Record overall success rate and graph latency over time

Lumpy reclaim both increases the success rate and reduces the latency.

> > Even without high-order considerations, this patch would appear to make
> > fairly large changes to how direct reclaim behaves. It would no longer
> > wait on page writeback for example so direct reclaim will return sooner
> 
> AFAICT it still waits for pages under writeback in exactly the same manner
> it does now. shrink_page_list() does the following completely
> separately to the sc->may_writepage flag:
> 
>  666                 may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
>  667                         (PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
>  668
>  669                 if (PageWriteback(page)) {
>  670                         /*
>  671                          * Synchronous reclaim is performed in two passes,
>  672                          * first an asynchronous pass over the list to
>  673                          * start parallel writeback, and a second synchronous
>  674                          * pass to wait for the IO to complete.  Wait here
>  675                          * for any page for which writeback has already
>  676                          * started.
>  677                          */
>  678                         if (sync_writeback == PAGEOUT_IO_SYNC && may_enter_fs)
>  679                                 wait_on_page_writeback(page);
>  680                         else
>  681                                 goto keep_locked;
>  682                 }
> 

Right, so it'll still wait on writeback but won't kick it off. That
would still be a fairly significant change in behaviour though. Think of
synchronous lumpy reclaim for example where it queues up a contiguous
batch of patches and then waits on them to writeback..

> So if the page is under writeback, PAGEOUT_IO_SYNC is set and
> we can enter the fs, it will still wait for writeback to complete
> just like it does now.
> 

But it would be no longer queueing them for writeback so it'd be
depending heavily on kswapd or a background cleaning daemon to clean
them.

> However, the current code only uses PAGEOUT_IO_SYNC in lumpy
> reclaim, so for most typical workloads direct reclaim does not wait
> on page writeback, either.

No, but it does queue them back on the LRU where they might be clean the
next time they are found on the list. How significant a problem this is
I couldn't tell you but it could show a corner case where a large number
of direct reclaimers are encountering dirty pages frequenctly and
recycling them around the LRU list instead of cleaning them.

> Hence, this patch doesn't appear to
> change the actions taken on a page under writeback in direct
> reclaim....
> 

It does, but indirectly. The impact is very direct for lumpy reclaim
obviously. For other direct reclaim, pages that were at the end of the
LRU list are no longer getting cleaned before doing another lap through
the LRU list.

The consequences of the latter are harder to predict.

> > than it did potentially going OOM if there were a lot of dirty pages and
> > it made no progress during direct reclaim.
> 
> I did a fair bit of low/small memory testing. This is a subjective
> observation, but I definitely seemed to get less severe OOM
> situations and better overall responisveness with this patch than
> compared to when direct reclaim was doing writeback.
> 

And it is possible that it is best overall of only kswapd and the
background cleaner are queueing pages for IO. All I can say for sure is
that this does appear to hurt lumpy reclaim and does affect normal
direct reclaim where I have no predictions.

> > > Hence for direct reclaim we should not allow ->writepages to be entered at all.
> > > Set up the relevant scan_control structures to enforce this, and prevent
> > > sc->may_writepage from being set in other places in the direct reclaim path in
> > > response to other events.
> > > 
> > 
> > If an FS caller cannot re-enter the FS, it should be using GFP_NOFS
> > instead of GFP_KERNEL.
> 
> This problem is not a filesystem recursion problem which is, as I
> understand it, what GFP_NOFS is used to prevent. It's _any_ kernel
> code that uses signficant stack before trying to allocate memory
> that is the problem. e.g a select() system call:
> 
>        Depth    Size   Location    (47 entries)
>        -----    ----   --------
>  0)     7568      16   mempool_alloc_slab+0x16/0x20
>  1)     7552     144   mempool_alloc+0x65/0x140
>  2)     7408      96   get_request+0x124/0x370
>  3)     7312     144   get_request_wait+0x29/0x1b0
>  4)     7168      96   __make_request+0x9b/0x490
>  5)     7072     208   generic_make_request+0x3df/0x4d0
>  6)     6864      80   submit_bio+0x7c/0x100
>  7)     6784      96   _xfs_buf_ioapply+0x128/0x2c0 [xfs]
> ....
> 32)     3184      64   xfs_vm_writepage+0xab/0x160 [xfs]
> 33)     3120     384   shrink_page_list+0x65e/0x840
> 34)     2736     528   shrink_zone+0x63f/0xe10
> 35)     2208     112   do_try_to_free_pages+0xc2/0x3c0
> 36)     2096     128   try_to_free_pages+0x77/0x80
> 37)     1968     240   __alloc_pages_nodemask+0x3e4/0x710
> 38)     1728      48   alloc_pages_current+0x8c/0xe0
> 39)     1680      16   __get_free_pages+0xe/0x50
> 40)     1664      48   __pollwait+0xca/0x110
> 41)     1616      32   unix_poll+0x28/0xc0
> 42)     1584      16   sock_poll+0x1d/0x20
> 43)     1568     912   do_select+0x3d6/0x700
> 44)      656     416   core_sys_select+0x18c/0x2c0
> 45)      240     112   sys_select+0x4f/0x110
> 46)      128     128   system_call_fastpath+0x16/0x1b
> 
> There's 1.6k of stack used before memory allocation is called, 3.1k
> used there before ->writepage is entered, XFS used 3.5k, and
> if the mempool needed to allocate a page it would have blown the
> stack. If there was any significant storage subsystem (add dm, md
> and/or scsi of some kind), it would have blown the stack.
> 
> Basically, there is not enough stack space available to allow direct
> reclaim to enter ->writepage _anywhere_ according to the stack usage
> profiles we are seeing here....
> 

I'm not denying the evidence but how has it been gotten away with for years
then? Prevention of writeback isn't the answer without figuring out how
direct reclaimers can queue pages for IO and in the case of lumpy reclaim
doing sync IO, then waiting on those pages.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
