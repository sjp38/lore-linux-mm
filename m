Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BEB826B0071
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 19:32:03 -0400 (EDT)
Date: Mon, 11 Oct 2010 10:31:30 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Results of my VFS scaling evaluation.
Message-ID: <20101010233130.GO4681@dastard>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
 <20101009031609.GK4681@dastard>
 <87y6a6fsg4.fsf@basil.nowhere.org>
 <20101010073732.GA4097@infradead.org>
 <20101010082038.GA17133@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101010082038.GA17133@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>, Frank Mayhar <fmayhar@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Sun, Oct 10, 2010 at 10:20:39AM +0200, Andi Kleen wrote:
> > Certainly not for .37, where even the inode_lock splitup is pretty damn
> > later.  Nick disappearing for a few weeks and others having to pick up
> > the work to sort it out certainly doesn't help.  And the dcache_lock
> > splitup is a much larget task than that anyway.  Getting that into .38
> > is the enabler for doing more fancy things.  And as Dave mentioned at
> > least in the writeback area it's much better to sort out the algorithmic
> > problems now than to blindly split some locks up more.
> 
> I don't see why the algorithmic work can't be done in parallel 
> to the lock split up?

It is - see Fengguang Wu's 17 patch series RFC for removing
writeback from balance_dirty_pages(). That change is complex enough
that few people can understand it well enough to review it, and even
fewer have the hardware and time available to test it thoroughly.

That patch series is *exactly* what we need to test for fixing the
writeback lock contention, but I cannot do that while I'm still
trying to get the current series sorted out. It's next on my list
because it's now the biggest problem I'm seeing on small file
intensive workloads on XFS.

> Just the lock split up on its own gives us large gains here.

The writeback lock split up is an algorithmic change in itself, one
which no-one has yet analysed for undesirable behaviour. At minimum
it changes the writeback IO patterns because of the different list
traversal ordering, and that is not something that should go into
mainline without close scrutiny.

Indeed, I showed that Nick's patch series actually significantly
increased the amount of IO during certain workloads. There was
plenty of handwaving about possible causes, but it was never
analysed or explained. The only way to determine the cause is to go
step by step and work out which algorithmic change caused that - it
might be the RCU changes, the zone LRU reclaim, the writeback
locking, or it might be something else. This series has not shown
such a regression, so I've aleast ruled out the lock breakup as the
cause.

IMO, pushing Nick's changes into mainline without answering such
questions is the _worst_ thing we can do. Writeback has been a mess
for a long time and so shovelling a truck-load of badly understood,
unmaintainable crap into the writeback path to "fix lock contention"
is not going to improve the situation at all. It is premature
optimisation at it's finest.

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
