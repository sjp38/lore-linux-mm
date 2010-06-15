Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C68556B01B4
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 00:16:10 -0400 (EDT)
Date: Mon, 14 Jun 2010 21:15:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-Id: <20100614211515.dd9880dc.akpm@linux-foundation.org>
In-Reply-To: <20100615032034.GR6590@dastard>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	<1276514273-27693-12-git-send-email-mel@csn.ul.ie>
	<20100614231144.GG6590@dastard>
	<20100614162143.04783749.akpm@linux-foundation.org>
	<20100615003943.GK6590@dastard>
	<20100614183957.ad0cdb58.akpm@linux-foundation.org>
	<20100615032034.GR6590@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2010 13:20:34 +1000 Dave Chinner <david@fromorbit.com> wrote:

> On Mon, Jun 14, 2010 at 06:39:57PM -0700, Andrew Morton wrote:
> > On Tue, 15 Jun 2010 10:39:43 +1000 Dave Chinner <david@fromorbit.com> wrote:
> > 
> > > 
> > > IOWs, IMO anywhere there is a context with significant queue of IO,
> > > that's where we should be doing a better job of sorting before that
> > > IO is dispatched to the lower layers. This is still no guarantee of
> > > better IO (e.g. if the filesystem fragments the file) but it does
> > > give the lower layers a far better chance at optimal allocation and
> > > scheduling of IO...
> > 
> > None of what you said had much to do with what I said.
> > 
> > What you've described are implementation problems in the current block
> > layer because it conflates "sorting" with "queueing".  I'm saying "fix
> > that".
> 
> You can't sort until you've queued.

Yes you can.  That's exactly what you're recommending!  Only you're
recommending doing it at the wrong level.  The fs-writeback radix-tree
walks do it at the wrong level too.  Sorting should be done within, or
in a layer above the block queues, not within the large number of
individual callers.

> > And...  sorting at the block layer will always be superior to sorting
> > at the pagecache layer because the block layer sorts at the physical
> > block level and can handle not-well-laid-out files and can sort and merge
> > pages from different address_spaces.
> 
> Yes it, can do that. And it still does that even if the higher
> layers sort their I/O dispatch better,
> 
> Filesystems try very hard to allocate adjacent logical offsets in a
> file in adjacent physical blocks on disk - that's the whole point of
> extent-indexed filesystems. Hence with modern filesystems there is
> generally a direct correlation between the page {mapping,index}
> tuple and the physical location of the mapped block.
> 
> i.e. there is generally zero physical correlation between pages in
> different mappings, but there is a high physical correlation
> between the index of pages on the same mapping.

Nope.  Large-number-of-small-files is a pretty common case.  If the fs
doesn't handle that well (ie: by placing them nearby on disk), it's
borked.

> Hence by sorting
> where we have a {mapping,index} context, we push out IO that is
> much more likely to be in contiguous physical chunks that the
> current random page shootdown.
> 
> We optimise applications to use these sorts of correlations all the
> time to improve IO patterns. Why can't we make the same sort of
> optmisations to the IO that the VM issues?

We can, but it shouldn't be specific to page reclaim.  Other places
submit IO too, and want the same treatment.

> > Still, I suspect none of it will improve anything anyway.  Those pages
> > are still dirty, possibly-locked and need to go to disk.  It doesn't
> > matter from the MM POV whether they sit in some VM list or in the
> > request queue.
> 
> Oh, but it does.....

The only difference is that pages which are in the queue (current
implementation thereof) can't be shot down by truncate.

> > Possibly there may be some benefit to not putting so many of these
> > unreclaimable pages into the queue all at the the same time.  But
> > that's a shortcoming in the block code: we should be able to shove
> > arbitrary numbers of dirty page (segments) into the queue and not gum
> > the system up.  Don't try to work around that in the VM.
> 
> I think you know perfectly well why the system gums up when we
> increase block layer queue depth: it's the fact that the _VM_ relies
> on block layer queue congestion to limit the amount of dirty memory
> in the system.

mm, a little bit still, I guess.  Mainly because dirty memory
management isn't zone aware, so even though we limit dirty memory
globally, a particular zone(set) can get excessively dirtied.

Most of this problem happen on the balance_dirty_pages() path, where we
already sort the pages in ascending logical order.

> We've got a feedback loop between the block layer and the VM that
> only works if block device queues are kept shallow. Keeping the
> number of dirty pages under control is a VM responsibility, but it
> is putting limitations on the block layer to ensure that the VM
> works correctly.  If you want the block layer to have deep queues,
> then someone needs to fix the VM not to require knowledge of the
> internal operation of the block layer for correct operation.
> 
> Adding a few lines of code to sort a list in the VM is far, far
> easier than redesigning the write throttling code....

It's a hack and a workaround.  And I suspect it won't make any
difference, especially given Mel's measurements of the number of dirty
pages he's seeing coming off the LRU.  Although those numbers may well
be due to the new quite-low dirty memory thresholds.  

It would be interesting to code up a little test patch though, see if
there's benefit to be had going down this path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
