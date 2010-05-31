Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2281C6B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 03:29:00 -0400 (EDT)
Date: Mon, 31 May 2010 17:28:50 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 3/5] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20100531072850.GB9453@laptop>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-4-git-send-email-david@fromorbit.com>
 <20100527063523.GJ22536@laptop>
 <20100527224034.GO12087@dastard>
 <20100528051924.GZ22536@laptop>
 <20100531063938.GE1395@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100531063938.GE1395@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, May 31, 2010 at 04:39:38PM +1000, Dave Chinner wrote:
> On Fri, May 28, 2010 at 03:19:24PM +1000, Nick Piggin wrote:
> > On Fri, May 28, 2010 at 08:40:34AM +1000, Dave Chinner wrote:
> > > On Thu, May 27, 2010 at 04:35:23PM +1000, Nick Piggin wrote:
> > > > But we can think of inodes that are only in use by unused (and aged)
> > > > dentries as effectively unused themselves. So this sequence under
> > > > estimates how many inodes to scan. This could bias pressure against
> > > > dcache I'd think, especially considering inodes are far larger than
> > > > dentries. Maybe require 2 passes to get the inodes unused inthe
> > > > first pass.
> > > 
> > > It's self-balancing - it trends towards an equal number of unused
> > > dentries and inodes in the caches. Yes, it will tear down more
> > > dentries at first, but we need to do that to be able to reclaim
> > > inodes.
> > 
> > But then it doesn't scan enough inodes on the inode pass.
> 
> We don't get a single shrinker call - we get batches of them fo each
> shrinker.

OK fair point. However

[...]

> In other words, we have roughly 18k dentries and 1.9k inodes
> reclaimed for the code I wrote new algorithm. That does mean it
> initially attempts to reclaim dentries faster than the current code, but
> as the number of unused inodes increases, this comes back to parity
> with the current code and we end up with a 1:1 reclaim ratio.
> 
> This is good behaviour - dentries are cheap to reconstruct from the
> inode cache, and we should hold onto the inode cache as much as
> possible. i.e. we should reclaim them more aggressively only if
> there is sustained pressure on the superblock and that is what the
> above algorithm does.

I prefer just to keep changes to a minimum and split into seperate
patches (each with at least basic test or two showing no regression).

As-is you're already changing global inode/dentry passes into per
sb inode and dentry passes. I think it can only be a good thing
for that changeset if other changes are minimised.

Then if it is so obviously good behaviour to reduce dcache pressure,
it should be easy to justify that too.

 
> > > a?<<s reclaim progresses the propotion of inodes increases, so
> > > the amount of inodes reclaimed increases. 
> > > 
> > > Basically this is a recognition that the important cache for
> > > avoiding IO is the inode cache, not he dentry cache. Once the inode
> > 
> > You can bias against the dcache using multipliers.
> 
> Multipliers are not self-balancing, and generally just amplify any
> imbalance an algorithm tends towards. The vfs_cache_pressure
> multiplier is a shining example of this kind of utterly useless
> knob...

Well you can also bias against the dcache with any other means,
including the change you've made here. My main point I guess is
that it should not be in the same as this patchset (or at least
an individual patch).

 
> > > > Part of the problem is the funny shrinker API.
> > > > 
> > > > The right way to do it is to change the shrinker API so that it passes
> > > > down the lru_pages and scanned into the callback. From there, the
> > > > shrinkers can calculate the appropriate ratio of objects to scan.
> > > > No need for 2-call scheme, no need for shrinker->seeks, and the
> > > > ability to calculate an appropriate ratio first for dcache, and *then*
> > > > for icache.
> > > 
> > > My only concern about this is that exposes the inner workings of the
> > > shrinker and mm subsystem to code that simply doesn't need to know
> > > about it.
> > 
> > It's just providing a ratio. The shrinkers allready know they are
> > scanning based on a ratio of pagecache scanned.
> 
> Sure, but the shrinkers are just a simple mechanism for implementing
> VM policy decisions. IMO reclaim policy decisions should not be
> pushed down and replicated in every one of these reclaim mechanisms.

Not really. The VM doesn't know about any of those. They are just
told to provide a ratio and some scanning based on some abstract cost.

The VM doesn't know anything about usage patterns, inuse vs unused
objects, exactly how their LRU algorithms are supposed to work, etc.

There is very little policy decision by the VM in the shrinkers.

 
> > But shrinkers are very subsystem specific.
> 
> And as such should concentrate on getting their subsystem reclaim
> correct, not have to worry about implementing VM policy
> calculations...

Clearly they wouldn't with what I was proposing. And the result would
be much more flexible and also gives the shrinkers more information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
