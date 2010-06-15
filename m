Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 09CBC6B01AD
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 20:40:41 -0400 (EDT)
Date: Tue, 15 Jun 2010 10:39:43 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-ID: <20100615003943.GK6590@dastard>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
 <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
 <20100614231144.GG6590@dastard>
 <20100614162143.04783749.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100614162143.04783749.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 14, 2010 at 04:21:43PM -0700, Andrew Morton wrote:
> On Tue, 15 Jun 2010 09:11:44 +1000
> Dave Chinner <david@fromorbit.com> wrote:
> 
> > On Mon, Jun 14, 2010 at 12:17:52PM +0100, Mel Gorman wrote:
> > > Page reclaim cleans individual pages using a_ops->writepage() because from
> > > the VM perspective, it is known that pages in a particular zone must be freed
> > > soon, it considers the target page to be the oldest and it does not want
> > > to wait while background flushers cleans other pages. From a filesystem
> > > perspective this is extremely inefficient as it generates a very seeky
> > > IO pattern leading to the perverse situation where it can take longer to
> > > clean all dirty pages than it would have otherwise.
> > > 
> > > This patch queues all dirty pages at once to maximise the chances that
> > > the write requests get merged efficiently. It also makes the next patch
> > > that avoids writeout from direct reclaim more straight-forward.
> > 
> > Seeing as you have a list of pages for IO, perhaps they could be sorted
> > before issuing ->writepage on them.
> > 
> > That is, while this patch issues all the IO in one hit, it doesn't
> > change the order in which the IO is issued - it is still issued in
> > LRU order. Given that they are issued in a short period of time now,
> > rather than across a longer scan period, it is likely that it will
> > not be any faster as:
> > 
> > 	a) IO will not be started as soon, and
> > 	b) the IO scheduler still only has a small re-ordering
> > 	   window and will choke just as much on random IO patterns.
> > 
> > However, there is a list_sort() function that could be used to sort
> > the list; sorting the list of pages by mapping and page->index
> > within the mapping would result in all the pages on each mapping
> > being sent down in ascending offset order at once - exactly how the
> > filesystems want IO to be sent to it.  Perhaps this is a simple
> > improvement that can be made to this code that will make a big
> > difference to worst case performance.
> > 
> > FWIW, I did this for delayed metadata buffer writeback in XFS
> > recently (i.e. sort the queue of (potentially tens of thousands of)
> > buffers in ascending block order before dispatch) and that showed a
> > 10-15% reduction in seeks on simple kernel compile workloads. This
> > shows that if we optimise IO patterns at higher layers where the
> > sort window is much, much larger than in the IO scheduler, then
> > overall system performance improves....
> 
> Yup.
> 
> But then, this all really should be done at the block layer so other
> io-submitting-paths can benefit from it.

That was what we did in the past with really, really deep IO
scheduler queues. That leads to IO latency and OOM problems because
we could lock gigabytes of memory away under IO and take minutes to
clean it.

Besides, there really isn't the right context in the block layer to
be able to queue and prioritise large amounts of IO without
significant penalties to some higher layer operation.

> IOW, maybe "the sort queue is the submission queue" wasn't a good idea.

Perhaps, but IMO sorting should be done where the context allows it
to be done most efficiently. Sorting is most effective when ever a
significant queue of IO is formed, whether it be in the filesystem,
the VFS, the VM or the block layer because the IO stack is very much
a GIGO queue.

Simply put, there's nothing the lower layers can do to optimise bad
IO patterns from the higher layers because they have small sort
windows which are necessary to keep IO latency in check. Hence if
the higher layers feed the lower layers crap they simply don't have
the context or depth to perform the same level of optimistations we
can do easily higher up the stack.

IOWs, IMO anywhere there is a context with significant queue of IO,
that's where we should be doing a better job of sorting before that
IO is dispatched to the lower layers. This is still no guarantee of
better IO (e.g. if the filesystem fragments the file) but it does
give the lower layers a far better chance at optimal allocation and
scheduling of IO...

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
