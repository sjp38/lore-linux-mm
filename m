Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E77726B01C7
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 02:37:40 -0400 (EDT)
Date: Tue, 15 Jun 2010 16:36:43 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-ID: <20100615063643.GS6590@dastard>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
 <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
 <20100614231144.GG6590@dastard>
 <20100614162143.04783749.akpm@linux-foundation.org>
 <20100615003943.GK6590@dastard>
 <20100614183957.ad0cdb58.akpm@linux-foundation.org>
 <20100615032034.GR6590@dastard>
 <20100614211515.dd9880dc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100614211515.dd9880dc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 14, 2010 at 09:15:15PM -0700, Andrew Morton wrote:
> On Tue, 15 Jun 2010 13:20:34 +1000 Dave Chinner <david@fromorbit.com> wrote:
> 
> > On Mon, Jun 14, 2010 at 06:39:57PM -0700, Andrew Morton wrote:
> > > On Tue, 15 Jun 2010 10:39:43 +1000 Dave Chinner <david@fromorbit.com> wrote:
> > > 
> > > > 
> > > > IOWs, IMO anywhere there is a context with significant queue of IO,
> > > > that's where we should be doing a better job of sorting before that
> > > > IO is dispatched to the lower layers. This is still no guarantee of
> > > > better IO (e.g. if the filesystem fragments the file) but it does
> > > > give the lower layers a far better chance at optimal allocation and
> > > > scheduling of IO...
> > > 
> > > None of what you said had much to do with what I said.
> > > 
> > > What you've described are implementation problems in the current block
> > > layer because it conflates "sorting" with "queueing".  I'm saying "fix
> > > that".
> > 
> > You can't sort until you've queued.
> 
> Yes you can.  That's exactly what you're recommending!

Umm, I suggested sorting a queue dirty pages that was build by
reclaim before dispatching them. How does that translate to
me recommending "sort before queuing"?

> Only you're
> recommending doing it at the wrong level.

If you feed a filesystem garbage IO, you'll get garbage performance
and there's nothing that a block layer sort queue can do to fix the
damage it does to both performance and filesystem fragmentation
levels. It's not just about IO issue - delayed allocation pretty
much requires writeback to be issuing well formed IOs to reap the
benefits it can provide....

> > > And...  sorting at the block layer will always be superior to sorting
> > > at the pagecache layer because the block layer sorts at the physical
> > > block level and can handle not-well-laid-out files and can sort and merge
> > > pages from different address_spaces.
> > 
> > Yes it, can do that. And it still does that even if the higher
> > layers sort their I/O dispatch better,
> > 
> > Filesystems try very hard to allocate adjacent logical offsets in a
> > file in adjacent physical blocks on disk - that's the whole point of
> > extent-indexed filesystems. Hence with modern filesystems there is
> > generally a direct correlation between the page {mapping,index}
> > tuple and the physical location of the mapped block.
> > 
> > i.e. there is generally zero physical correlation between pages in
> > different mappings, but there is a high physical correlation
> > between the index of pages on the same mapping.
> 
> Nope.  Large-number-of-small-files is a pretty common case.  If the fs
> doesn't handle that well (ie: by placing them nearby on disk), it's
> borked.

Filesystems already handle this case just fine as we see it from
writeback all the time. Untarring a kernel is a good example of
this...

I suggested sorting all the IO to be issued into per-mapping page
groups because:
	a) makes IO issued from reclaim look almost exactly the same
	   to the filesytem as if writeback is pushing out the IO.
	b) it looks to be a trivial addition to the new code.

To me that's a no-brainer.

> It would be interesting to code up a little test patch though, see if
> there's benefit to be had going down this path.

I doubt Mel's tests cases will show anything - they simply didn't
show enough IO issued from reclaim to make any difference.

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
