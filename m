Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2B4596B01BC
	for <linux-mm@kvack.org>; Fri, 28 May 2010 01:19:30 -0400 (EDT)
Date: Fri, 28 May 2010 15:19:24 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 3/5] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20100528051924.GZ22536@laptop>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-4-git-send-email-david@fromorbit.com>
 <20100527063523.GJ22536@laptop>
 <20100527224034.GO12087@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100527224034.GO12087@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, May 28, 2010 at 08:40:34AM +1000, Dave Chinner wrote:
> On Thu, May 27, 2010 at 04:35:23PM +1000, Nick Piggin wrote:
> > But we can think of inodes that are only in use by unused (and aged)
> > dentries as effectively unused themselves. So this sequence under
> > estimates how many inodes to scan. This could bias pressure against
> > dcache I'd think, especially considering inodes are far larger than
> > dentries. Maybe require 2 passes to get the inodes unused inthe
> > first pass.
> 
> It's self-balancing - it trends towards an equal number of unused
> dentries and inodes in the caches. Yes, it will tear down more
> dentries at first, but we need to do that to be able to reclaim
> inodes.

But then it doesn't scan enough inodes on the inode pass.


> a?<<s reclaim progresses the propotion of inodes increases, so
> the amount of inodes reclaimed increases. 
> 
> Basically this is a recognition that the important cache for
> avoiding IO is the inode cache, not he dentry cache. Once the inode

You can bias against the dcache using multipliers.


> cache is freed that we need to do IO to repopulate it, but
> rebuilding dentries fromteh inode cache only costs CPU time. Hence
> under light reclaim, inodes are mostly left in cache but we free up
> memory that only costs CPU to rebuild. Under heavy, sustained
> reclaim, we trend towards freeing equal amounts of objects from both
> caches.

I don't know if you've got numbers or patterns to justify that.
My point is that things should stay as close to the old code as
possible without good reason.

 
> This is pretty much what the current code attempts to do - free a
> lot of dentries, then free a smaller amount of the inodes that were
> used by the freed dentries. Once again it is a direct encoding of
> what is currently an implicit design feature - it makes it *obvious*
> how we are trying to balance the caches.

With your patches, if there are no inodes free you would need to take
2 passes at freeing the dentry cache. My suggestion is closer to the
current code.
 

> Another reason for this is that the calculation changes again to
> allow filesystem caches to modiy this proportioning in the next
> patch....
> 
> FWIW, this also makes workloads that generate hundreds of thousands
> of never-to-be-used again negative dentries free dcache memory really
> quickly on memory pressure...

That would still be the case because used inodes aren't getting their
dentries freed so little inode scanning will occur.

> 
> > Part of the problem is the funny shrinker API.
> > 
> > The right way to do it is to change the shrinker API so that it passes
> > down the lru_pages and scanned into the callback. From there, the
> > shrinkers can calculate the appropriate ratio of objects to scan.
> > No need for 2-call scheme, no need for shrinker->seeks, and the
> > ability to calculate an appropriate ratio first for dcache, and *then*
> > for icache.
> 
> My only concern about this is that exposes the inner workings of the
> shrinker and mm subsystem to code that simply doesn't need to know
> about it.

It's just providing a ratio. The shrinkers allready know they are
scanning based on a ratio of pagecache scanned.


> > A helper of course can do the calculation (considering that every
> > driver and their dog will do the wrong thing if we let them :)).
> > 
> > unsigned long shrinker_scan(unsigned long lru_pages,
> > 			unsigned long lru_scanned,
> > 			unsigned long nr_objects,
> > 			unsigned long scan_ratio)
> > {
> > 	unsigned long long tmp = nr_objects;
> > 
> > 	tmp *= lru_scanned * 100;
> > 	do_div(tmp, (lru_pages * scan_ratio) + 1);
> > 
> > 	return (unsigned long)tmp;
> > }
> > 
> > Then the shrinker callback will go:
> > 	sb->s_nr_dentry_scan += shrinker_scan(lru_pages, lru_scanned,
> > 				sb->s_nr_dentry_unused,
> > 				vfs_cache_pressure * SEEKS_PER_DENTRY);
> > 	if (sb->s_nr_dentry_scan > SHRINK_BATCH)
> > 		prune_dcache()
> > 
> > 	sb->s_nr_inode_scan += shrinker_scan(lru_pages, lru_scanned,
> > 				sb->s_nr_inodes_unused,
> > 				vfs_cache_pressure * SEEKS_PER_INODE);
> > 	...
> > 
> > What do you think of that? Seeing as we're changing the shrinker API
> > anyway, I'd think it is high time to do somthing like this.
> 
> Ignoring the dcache/icache reclaim ratio issues, I'd prefer a two

Well if it is an issue, it should be changed in a different patch
I think (with numbers).


> call API that matches the current behaviour, leaving the caclulation
> of how much to reclaim in shrink_slab(). Encoding it this way makes
> it more difficult to change the high level behaviour e.g. if we want
> to modify the amount of slab reclaim based on reclaim priority, we'd
> have to cahnge every shrinker instead of just shrink_slab().

We can modifiy the ratios before calling if needed, or have a default
ratio define to multiply with as well.

But shrinkers are very subsystem specific.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
