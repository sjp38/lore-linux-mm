Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 038626B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 04:33:28 -0400 (EDT)
Date: Fri, 23 Jul 2010 16:33:15 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100723083315.GC5043@localhost>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
 <20100719142145.GD12510@infradead.org>
 <20100719144046.GR13117@csn.ul.ie>
 <20100722085210.GA26714@localhost>
 <20100722094208.GE13117@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722094208.GE13117@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Thu, Jul 22, 2010 at 05:42:09PM +0800, Mel Gorman wrote:
> On Thu, Jul 22, 2010 at 04:52:10PM +0800, Wu Fengguang wrote:
> > > Some insight on how the other writeback changes that are being floated
> > > around might affect the number of dirty pages reclaim encounters would also
> > > be helpful.
> > 
> > Here is an interesting related problem about the wait_on_page_writeback() call
> > inside shrink_page_list():
> > 
> >         http://lkml.org/lkml/2010/4/4/86

I guess you've got the answers from the above thread, anyway here is
the brief answers to your questions.

> > 
> > The problem is, wait_on_page_writeback() is called too early in the
> > direct reclaim path, which blocks many random/unrelated processes when
> > some slow (USB stick) writeback is on the way.
> > 
> > A simple dd can easily create a big range of dirty pages in the LRU
> > list. Therefore priority can easily go below (DEF_PRIORITY - 2) in a
> > typical desktop, which triggers the lumpy reclaim mode and hence
> > wait_on_page_writeback().
> > 
> 
> Lumpy reclaim is for high-order allocations. A simple dd should not be
> triggering it regularly unless there was a lot of forking going on at the
> same time.

dd could create the dirty file fast enough, so that no other processes 
are injecting pages into the LRU lists besides dd itself. So it's
creating a large range of hard-to-reclaim LRU pages which will trigger
this code

+       else if (sc->order && priority < DEF_PRIORITY - 2)
+               lumpy_reclaim = 1;


> Also, how would a random or unrelated process get blocked on
> writeback unless they were also doing high-order allocations?  What was the
> source of the high-order allocations?

sc->order is 1 on fork().

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
