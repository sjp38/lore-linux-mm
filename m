Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 16F4A6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 10:31:37 -0400 (EDT)
Date: Wed, 21 Jul 2010 15:31:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in
	direct reclaim
Message-ID: <20100721143118.GA13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-5-git-send-email-mel@csn.ul.ie> <20100719221420.GA16031@cmpxchg.org> <20100720134555.GU13117@csn.ul.ie> <20100720220218.GE16031@cmpxchg.org> <20100721115250.GX13117@csn.ul.ie> <20100721130435.GH16031@cmpxchg.org> <20100721133857.GY13117@csn.ul.ie> <20100721142819.GA10480@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100721142819.GA10480@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 04:28:44PM +0200, Johannes Weiner wrote:
> On Wed, Jul 21, 2010 at 02:38:57PM +0100, Mel Gorman wrote:
> > Here is an updated version. Thanks very much
> > 
> > ==== CUT HERE ====
> > vmscan: Do not writeback filesystem pages in direct reclaim
> > 
> > When memory is under enough pressure, a process may enter direct
> > reclaim to free pages in the same manner kswapd does. If a dirty page is
> > encountered during the scan, this page is written to backing storage using
> > mapping->writepage. This can result in very deep call stacks, particularly
> > if the target storage or filesystem are complex. It has already been observed
> > on XFS that the stack overflows but the problem is not XFS-specific.
> > 
> > This patch prevents direct reclaim writing back filesystem pages by checking
> > if current is kswapd or the page is anonymous before writing back.  If the
> > dirty pages cannot be written back, they are placed back on the LRU lists
> > for either background writing by the BDI threads or kswapd. If in direct
> > lumpy reclaim and dirty pages are encountered, the process will stall for
> > the background flusher before trying to reclaim the pages again.
> > 
> > As the call-chain for writing anonymous pages is not expected to be deep
> > and they are not cleaned by flusher threads, anonymous pages are still
> > written back in direct reclaim.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Acked-by: Rik van Riel <riel@redhat.com>
> 
> Cool!
> 
> Except for one last tiny thing...
> 
> > @@ -858,7 +872,7 @@ keep:
> >  
> >  	free_page_list(&free_pages);
> >  
> > -	list_splice(&ret_pages, page_list);
> 
> This will lose all retry pages forever, I think.
> 

Above this is

while (!list_empty(page_list)) {
	...
}

page_list should be empty and keep_locked is putting the pages on ret_pages
already so I think it's ok.

> > +	*nr_still_dirty = nr_dirty;
> >  	count_vm_events(PGACTIVATE, pgactivate);
> >  	return nr_reclaimed;
> >  }
> 
> Otherwise,
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
> 

Thanks!

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
