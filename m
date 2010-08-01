Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 37E6A600429
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 12:21:53 -0400 (EDT)
Subject: Re: [PATCH 6/6] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20100801170115.4AFC.A69D9226@jp.fujitsu.com>
References: <20100730150601.199c5618.akpm@linux-foundation.org>
	 <1280529653.12852.67.camel@heimdal.trondhjem.org>
	 <20100801170115.4AFC.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 01 Aug 2010 12:21:26 -0400
Message-ID: <1280679686.3081.28.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-08-01 at 17:19 +0900, KOSAKI Motohiro wrote:
> Hi Trond,
> 
> > There is that, and then there are issues with the VM simply lying to the
> > filesystems.
> > 
> > See https://bugzilla.kernel.org/show_bug.cgi?id=16056
> > 
> > Which basically boils down to the following: kswapd tells the filesystem
> > that it is quite safe to do GFP_KERNEL allocations in pageouts and as
> > part of try_to_release_page().
> > 
> > In the case of pageouts, it does set the 'WB_SYNC_NONE', 'nonblocking'
> > and 'for_reclaim' flags in the writeback_control struct, and so the
> > filesystem has at least some hint that it should do non-blocking i/o.
> > 
> > However if you trust the GFP_KERNEL flag in try_to_release_page() then
> > the kernel can and will deadlock, and so I had to add in a hack
> > specifically to tell the NFS client not to trust that flag if it comes
> > from kswapd.
> 
> Can you please elaborate your issue more? vmscan logic is, briefly, below
> 
> 	if (PageDirty(page))
> 		pageout(page)
> 	if (page_has_private(page)) {
> 		try_to_release_page(page, sc->gfp_mask))
> 
> So, I'm interest why nfs need to writeback at ->release_page again even
> though pageout() call ->writepage and it was successfull.
> 
> In other word, an argument gfp_mask of try_to_release_page() is suspected
> to pass kmalloc()/alloc_page() familiy. and page allocator have already care
> PF_MEMALLOC flag.
> 
> So, My question is, What do you want additional work to VM folks?
> Can you please share nfs design and what we should?
> 
> 
> btw, Another question, Recently, Xiaotian Feng posted "swap over nfs -v21"
> patch series. they have new reservation memory framework. Is this help you?

The problem that I am seeing is that the try_to_release_page() needs to
be told to act as a non-blocking call when the process is kswapd, just
like the pageout() call.

Currently, the sc->gfp_mask is set to GFP_KERNEL, which normally means
that the call may wait on I/O to complete. However, what I'm seeing in
the bugzilla above is that if kswapd waits on an RPC call, then the
whole VM may gum up: typically, the traces show that the socket layer
cannot allocate memory to hold the RPC reply from the server, and so it
is kicking kswapd to have it reclaim some pages, however kswapd is stuck
in try_to_release_page() waiting for that same I/O to complete, hence
the deadlock...

IOW: I think kswapd at least should be calling try_to_release_page()
with a gfp-flag of '0' to avoid deadlocking on I/O.

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
