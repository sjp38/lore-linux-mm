Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F04C76B0047
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 22:13:46 -0400 (EDT)
Date: Wed, 8 Sep 2010 10:13:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-ID: <20100908021341.GA6182@localhost>
References: <20100903202101.f937b0bb.akpm@linux-foundation.org>
 <20100904075840.GE705@dastard>
 <20100904081414.GF705@dastard>
 <20100905015400.GA10714@localhost>
 <20100905021555.GG705@dastard>
 <20100905060539.GA17450@localhost>
 <20100905131447.GJ705@dastard>
 <20100905134554.GA7083@localhost>
 <20100906040243.GA7362@dastard>
 <alpine.DEB.2.00.1009070918030.14634@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009070918030.14634@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 07, 2010 at 10:23:48PM +0800, Christoph Lameter wrote:
> On Mon, 6 Sep 2010, Dave Chinner wrote:
> 
> > [  596.628086]  [<ffffffff81108a8c>] ? drain_all_pages+0x1c/0x20
> > [  596.628086]  [<ffffffff81108fad>] ? __alloc_pages_nodemask+0x42d/0x700
> > [  596.628086]  [<ffffffff8113d0f2>] ? kmem_getpages+0x62/0x160
> > [  596.628086]  [<ffffffff8113dce6>] ? fallback_alloc+0x196/0x240
> 
> fallback_alloc() showing up here means that one page allocator call from
> SLAB has already failed.

That may be due to the GFP_THISNODE flag which includes __GFP_NORETRY
which may fail the allocation simply because there are many concurrent
page allocating tasks, but not necessary in real short of memory.

The concurrent page allocating tasks may consume all the pages freed
by try_to_free_pages() inside __alloc_pages_direct_reclaim(), before
the direct reclaim task is able to get it's page with
get_page_from_freelist(). Then should_alloc_retry() returns 0 for
__GFP_NORETRY which stops further retries.

In theory, __GFP_NORETRY might fail even without other tasks
concurrently stealing current task's direct reclaimed pages. The pcp
lists might happen to be low populated (pcp.count ranges 0 to pcp.batch),
and try_to_free_pages() might not free enough pages to fill them to
the pcp.high watermark, hence no pages are freed into the buddy system
and NR_FREE_PAGES increased. Then zone_watermark_ok() will remain
false and allocation fails. Mel's patch to increase accuracy of
zone_watermark_ok() should help this case.

> SLAB then did an expensive search through all
> object caches on all nodes to find some available object. There were no
> objects in queues at all therefore SLAB called the page allocator again
> (kmem_getpages()).
> 
> As soon as memory is available (on any node or any cpu, they are all
> empty) SLAB will repopulate its queues(!).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
