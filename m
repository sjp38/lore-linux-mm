Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B25FB6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 02:48:43 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y192so119635073pgd.12
        for <linux-mm@kvack.org>; Sun, 13 Aug 2017 23:48:43 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id j11si3700660pgn.944.2017.08.13.23.48.41
        for <linux-mm@kvack.org>;
        Sun, 13 Aug 2017 23:48:42 -0700 (PDT)
Date: Mon, 14 Aug 2017 16:48:38 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How can we share page cache pages for reflinked files?
Message-ID: <20170814064838.GB21024@dastard>
References: <20170810042849.GK21024@dastard>
 <20170810161159.GI31390@bombadil.infradead.org>
 <20170811042519.GS21024@dastard>
 <20170811170847.GK31390@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170811170847.GK31390@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 11, 2017 at 10:08:47AM -0700, Matthew Wilcox wrote:
> On Fri, Aug 11, 2017 at 02:25:19PM +1000, Dave Chinner wrote:
> > On Thu, Aug 10, 2017 at 09:11:59AM -0700, Matthew Wilcox wrote:
> > > On Thu, Aug 10, 2017 at 02:28:49PM +1000, Dave Chinner wrote:
> > > > If we scale this up to a container host which is using reflink trees
> > > > it's shared root images, there might be hundreds of copies of the
> > > > same data held in cache (i.e. one page per container). Given that
> > > > the filesystem knows that the underlying data extent is shared when
> > > > we go to read it, it's relatively easy to add mechanisms to the
> > > > filesystem to return the same page for all attempts to read the
> > > > from a shared extent from all inodes that share it.
> > > 
> > > I agree the problem exists.  Should we try to fix this problem, or
> > > should we steer people towards solutions which don't have this problem?
> > > The solutions I've been seeing use COW block devices instead of COW
> > > filesystems, and DAX to share the common pages between the host and
> > > each guest.
> > 
> > That's one possible solution for people using hardware
> > virutalisation, but not everyone is doing that. It also relies on
> > block devices, which rules out a whole bunch of interesting stuff we
> > can do with filesystems...
> 
> Assuming there's something fun we can do with filesystems that's
> interesting to this type of user, what do you think to this:
> 
> Create a block device (maybe it's a loop device, maybe it's dm-raid0)
> which supports DAX and uses the page cache to cache the physical pages
> of the block device it's fronting.

/me shudders and runs away screaming

<puff, puff, gasp>

Ok, I'm far away enough now. :P

> Use XFS+reflink+DAX on top of this loop device.  Now there's only one
> copy of each page in RAM.

Yes, I can see how that could work. Crazy, out of the box, abuses
DAX for non-DAX purposes and uses stuff we haven't enabled yet
because nobody has done the work to validate it. Full points for
creativity! :)

However, I don't think it's a viable solution.

First, now *everything* is cached in a single global mapping tree
and that's going to affect scalability and likely also the working
set tracking in the mapping tree (now global rather than per-file).
That, in turn, will affect reclaim behaviour and patterns. I'll come
back to that.

Second, direct IO is no longer direct - it would now by cached
and concurrency is limited by the block device page cache, not the
capability and queue depth of the underlying device.

Third, I have a concern that while the filesystem might present to
userspace as a DAX filesystem, it does not present userspace with
same semantics as direct access to CPU addressable non-volatile
storage. That seems, to me, like minefield we don't want to step into.

And, finally, i can't see how it would work for sharing between
cloned filesystem images and snapshots.  e.g. you use reflink to
clone the filesystem images exported by loopback devices. Or
dm-thinp to clone devices - there's no way for share page cache
pages for blocks that are shared across different dm-thinp devices
in the same pool. (And no, turtles is not the answer here :)

> We'd need to be able to shoot down all mapped pages when evicting pages
> from the loop device's page cache, but we have the right data structures
> in place for that; we just need to use them.

Sure. My biggest concern is whether reclaim can easily determine the
difference between a heavily shared page and a single use page? We'd
want to make sure we don't do stupid things like reclaim widely
shared pages from libc before we reclaim a page that has be read
only once in one context.

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
