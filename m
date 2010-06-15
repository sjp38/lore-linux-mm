Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BC9A06B01AD
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 21:41:13 -0400 (EDT)
Date: Mon, 14 Jun 2010 18:39:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-Id: <20100614183957.ad0cdb58.akpm@linux-foundation.org>
In-Reply-To: <20100615003943.GK6590@dastard>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	<1276514273-27693-12-git-send-email-mel@csn.ul.ie>
	<20100614231144.GG6590@dastard>
	<20100614162143.04783749.akpm@linux-foundation.org>
	<20100615003943.GK6590@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2010 10:39:43 +1000 Dave Chinner <david@fromorbit.com> wrote:

> On Mon, Jun 14, 2010 at 04:21:43PM -0700, Andrew Morton wrote:
> > On Tue, 15 Jun 2010 09:11:44 +1000
> > > 10-15% reduction in seeks on simple kernel compile workloads. This
> > > shows that if we optimise IO patterns at higher layers where the
> > > sort window is much, much larger than in the IO scheduler, then
> > > overall system performance improves....
> > 
> > Yup.
> > 
> > But then, this all really should be done at the block layer so other
> > io-submitting-paths can benefit from it.
> 
> That was what we did in the past with really, really deep IO
> scheduler queues. That leads to IO latency and OOM problems because
> we could lock gigabytes of memory away under IO and take minutes to
> clean it.
> 
> Besides, there really isn't the right context in the block layer to
> be able to queue and prioritise large amounts of IO without
> significant penalties to some higher layer operation.
> 
> > IOW, maybe "the sort queue is the submission queue" wasn't a good idea.
> 
> Perhaps, but IMO sorting should be done where the context allows it
> to be done most efficiently. Sorting is most effective when ever a
> significant queue of IO is formed, whether it be in the filesystem,
> the VFS, the VM or the block layer because the IO stack is very much
> a GIGO queue.
> 
> Simply put, there's nothing the lower layers can do to optimise bad
> IO patterns from the higher layers because they have small sort
> windows which are necessary to keep IO latency in check. Hence if
> the higher layers feed the lower layers crap they simply don't have
> the context or depth to perform the same level of optimistations we
> can do easily higher up the stack.
> 
> IOWs, IMO anywhere there is a context with significant queue of IO,
> that's where we should be doing a better job of sorting before that
> IO is dispatched to the lower layers. This is still no guarantee of
> better IO (e.g. if the filesystem fragments the file) but it does
> give the lower layers a far better chance at optimal allocation and
> scheduling of IO...

None of what you said had much to do with what I said.

What you've described are implementation problems in the current block
layer because it conflates "sorting" with "queueing".  I'm saying "fix
that".

And...  sorting at the block layer will always be superior to sorting
at the pagecache layer because the block layer sorts at the physical
block level and can handle not-well-laid-out files and can sort and merge
pages from different address_spaces.

Still, I suspect none of it will improve anything anyway.  Those pages
are still dirty, possibly-locked and need to go to disk.  It doesn't
matter from the MM POV whether they sit in some VM list or in the
request queue.

Possibly there may be some benefit to not putting so many of these
unreclaimable pages into the queue all at the the same time.  But
that's a shortcoming in the block code: we should be able to shove
arbitrary numbers of dirty page (segments) into the queue and not gum
the system up.  Don't try to work around that in the VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
