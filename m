Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2DB966B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 02:39:48 -0400 (EDT)
Date: Mon, 31 May 2010 16:39:38 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/5] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20100531063938.GE1395@dastard>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-4-git-send-email-david@fromorbit.com>
 <20100527063523.GJ22536@laptop>
 <20100527224034.GO12087@dastard>
 <20100528051924.GZ22536@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100528051924.GZ22536@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, May 28, 2010 at 03:19:24PM +1000, Nick Piggin wrote:
> On Fri, May 28, 2010 at 08:40:34AM +1000, Dave Chinner wrote:
> > On Thu, May 27, 2010 at 04:35:23PM +1000, Nick Piggin wrote:
> > > But we can think of inodes that are only in use by unused (and aged)
> > > dentries as effectively unused themselves. So this sequence under
> > > estimates how many inodes to scan. This could bias pressure against
> > > dcache I'd think, especially considering inodes are far larger than
> > > dentries. Maybe require 2 passes to get the inodes unused inthe
> > > first pass.
> > 
> > It's self-balancing - it trends towards an equal number of unused
> > dentries and inodes in the caches. Yes, it will tear down more
> > dentries at first, but we need to do that to be able to reclaim
> > inodes.
> 
> But then it doesn't scan enough inodes on the inode pass.

We don't get a single shrinker call - we get batches of them fo each
shrinker.  The shrinker determines how many objects to scan in the
cache, and that only changes for each shrinker to call based on the
the shrinker->seeks and the number of objects in the cache.  Once
the number is decided, then the shrinker gets batches of reclaim to
operate on.

Fundamentally, the current shrinker will ask for the same percentage
of each cache to be scanned - if it decides to scan 20% of the
dentry cache, it will also decide to scan 20% of the inode cache
Hence what the inode shrinker is doing is scanning 20% of the inodes
freed by the dcache shrinker.

In rough numbers, say we have 100k dentries, and the shrinker
calculates it needs to scan 20% of the caches to reclaim them, the
current code will end up with:

		unused dentries		unused inodes
before		 100k			    0
after dentry	  80k			  20k
after inode	  80k			  16k

So we get 20k dentries freed and 4k inodes freed on that shrink_slab
pass.

To contrast this against the code I proposed, I'll make a couple of
simplicfications to avoid hurting my brain. That is, I'll assume
SHRINK_BATCH=100 (rather than 128) and forgetting about rounding
errors. With this, the algorithm I encoded gives roughly the
following for a 20% object reclaim:

number of batches = 20k / 100 = 200

				Unused
		dentries+inodes		dentries	inodes
before		  100k			100k		    0
batch 1		  100k			99900		  100
batch 2		  100k			99800		  200
....
batch 10	  100k			99000		 1000
batch 20	  99990			98010		 1990
batch 30	  99980			97030		 2950
batch 50	  99910			95100		 4810
batch 60	  99860			94150		 5710
.....
batch 200	  98100			81900		16200

And so (roughly) we see that the number of inodes being reclaim per
set of 10 batches roughly equals the (batch number - 10). Hence over
200 batches, we can expect to see roughly 190 + 180 + ... + 10
inodes reclaimed. That is 1900 inodes.  Similarly for dentries, we
get roughly 1000 + 990 + 980 + ... 810 dentries reclaimed - 18,100
in total.

In other words, we have roughly 18k dentries and 1.9k inodes
reclaimed for the code I wrote new algorithm. That does mean it
initially attempts to reclaim dentries faster than the current code, but
as the number of unused inodes increases, this comes back to parity
with the current code and we end up with a 1:1 reclaim ratio.

This is good behaviour - dentries are cheap to reconstruct from the
inode cache, and we should hold onto the inode cache as much as
possible. i.e. we should reclaim them more aggressively only if
there is sustained pressure on the superblock and that is what the
above algorithm does.

> > a?<<s reclaim progresses the propotion of inodes increases, so
> > the amount of inodes reclaimed increases. 
> > 
> > Basically this is a recognition that the important cache for
> > avoiding IO is the inode cache, not he dentry cache. Once the inode
> 
> You can bias against the dcache using multipliers.

Multipliers are not self-balancing, and generally just amplify any
imbalance an algorithm tends towards. The vfs_cache_pressure
multiplier is a shining example of this kind of utterly useless
knob...

> > > Part of the problem is the funny shrinker API.
> > > 
> > > The right way to do it is to change the shrinker API so that it passes
> > > down the lru_pages and scanned into the callback. From there, the
> > > shrinkers can calculate the appropriate ratio of objects to scan.
> > > No need for 2-call scheme, no need for shrinker->seeks, and the
> > > ability to calculate an appropriate ratio first for dcache, and *then*
> > > for icache.
> > 
> > My only concern about this is that exposes the inner workings of the
> > shrinker and mm subsystem to code that simply doesn't need to know
> > about it.
> 
> It's just providing a ratio. The shrinkers allready know they are
> scanning based on a ratio of pagecache scanned.

Sure, but the shrinkers are just a simple mechanism for implementing
VM policy decisions. IMO reclaim policy decisions should not be
pushed down and replicated in every one of these reclaim mechanisms.

> But shrinkers are very subsystem specific.

And as such should concentrate on getting their subsystem reclaim
correct, not have to worry about implementing VM policy
calculations...

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
