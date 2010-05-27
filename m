Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B21B86B01C3
	for <linux-mm@kvack.org>; Thu, 27 May 2010 18:40:43 -0400 (EDT)
Date: Fri, 28 May 2010 08:40:34 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/5] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20100527224034.GO12087@dastard>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-4-git-send-email-david@fromorbit.com>
 <20100527063523.GJ22536@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100527063523.GJ22536@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, May 27, 2010 at 04:35:23PM +1000, Nick Piggin wrote:
> On Tue, May 25, 2010 at 06:53:06PM +1000, Dave Chinner wrote:
> > --- a/fs/super.c
> > +++ b/fs/super.c
> > @@ -37,6 +37,50 @@
> >  LIST_HEAD(super_blocks);
> >  DEFINE_SPINLOCK(sb_lock);
> >  
> > +static int prune_super(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
> > +{
> > +	struct super_block *sb;
> > +	int count;
> > +
> > +	sb = container_of(shrink, struct super_block, s_shrink);
> > +
> > +	/*
> > +	 * Deadlock avoidance.  We may hold various FS locks, and we don't want
> > +	 * to recurse into the FS that called us in clear_inode() and friends..
> > +	 */
> > +	if (!(gfp_mask & __GFP_FS))
> > +		return -1;
> > +
> > +	/*
> > +	 * if we can't get the umount lock, then there's no point having the
> > +	 * shrinker try again because the sb is being torn down.
> > +	 */
> > +	if (!down_read_trylock(&sb->s_umount))
> > +		return -1;
> > +
> > +	if (!sb->s_root) {
> > +		up_read(&sb->s_umount);
> > +		return -1;
> > +	}
> > +
> > +	if (nr_to_scan) {
> > +		/* proportion the scan between the two cacheN? */
> > +		int total;
> > +
> > +		total = sb->s_nr_dentry_unused + sb->s_nr_inodes_unused + 1;
> > +		count = (nr_to_scan * sb->s_nr_dentry_unused) / total;
> > +
> > +		/* prune dcache first as icache is pinned by it */
> > +		prune_dcache_sb(sb, count);
> > +		prune_icache_sb(sb, nr_to_scan - count);
> 
> Hmm, an interesting dynamic that you've changed is that previously
> we'd scan dcache LRU proportionately to pagecache, and then scan
> inode LRU in proportion to the current number of unused inodes.
> 
> But we can think of inodes that are only in use by unused (and aged)
> dentries as effectively unused themselves. So this sequence under
> estimates how many inodes to scan. This could bias pressure against
> dcache I'd think, especially considering inodes are far larger than
> dentries. Maybe require 2 passes to get the inodes unused inthe
> first pass.

It's self-balancing - it trends towards an equal number of unused
dentries and inodes in the caches. Yes, it will tear down more
dentries at first, but we need to do that to be able to reclaim
inodes. a?<<s reclaim progresses the propotion of inodes increases, so
the amount of inodes reclaimed increases. 

Basically this is a recognition that the important cache for
avoiding IO is the inode cache, not he dentry cache. Once the inode
cache is freed that we need to do IO to repopulate it, but
rebuilding dentries fromteh inode cache only costs CPU time. Hence
under light reclaim, inodes are mostly left in cache but we free up
memory that only costs CPU to rebuild. Under heavy, sustained
reclaim, we trend towards freeing equal amounts of objects from both
caches.

This is pretty much what the current code attempts to do - free a
lot of dentries, then free a smaller amount of the inodes that were
used by the freed dentries. Once again it is a direct encoding of
what is currently an implicit design feature - it makes it *obvious*
how we are trying to balance the caches.

Another reason for this is that the calculation changes again to
allow filesystem caches to modiy this proportioning in the next
patch....

FWIW, this also makes workloads that generate hundreds of thousands
of never-to-be-used again negative dentries free dcache memory really
quickly on memory pressure...

> Part of the problem is the funny shrinker API.
> 
> The right way to do it is to change the shrinker API so that it passes
> down the lru_pages and scanned into the callback. From there, the
> shrinkers can calculate the appropriate ratio of objects to scan.
> No need for 2-call scheme, no need for shrinker->seeks, and the
> ability to calculate an appropriate ratio first for dcache, and *then*
> for icache.

My only concern about this is that exposes the inner workings of the
shrinker and mm subsystem to code that simply doesn't need to know
about it.


> A helper of course can do the calculation (considering that every
> driver and their dog will do the wrong thing if we let them :)).
> 
> unsigned long shrinker_scan(unsigned long lru_pages,
> 			unsigned long lru_scanned,
> 			unsigned long nr_objects,
> 			unsigned long scan_ratio)
> {
> 	unsigned long long tmp = nr_objects;
> 
> 	tmp *= lru_scanned * 100;
> 	do_div(tmp, (lru_pages * scan_ratio) + 1);
> 
> 	return (unsigned long)tmp;
> }
> 
> Then the shrinker callback will go:
> 	sb->s_nr_dentry_scan += shrinker_scan(lru_pages, lru_scanned,
> 				sb->s_nr_dentry_unused,
> 				vfs_cache_pressure * SEEKS_PER_DENTRY);
> 	if (sb->s_nr_dentry_scan > SHRINK_BATCH)
> 		prune_dcache()
> 
> 	sb->s_nr_inode_scan += shrinker_scan(lru_pages, lru_scanned,
> 				sb->s_nr_inodes_unused,
> 				vfs_cache_pressure * SEEKS_PER_INODE);
> 	...
> 
> What do you think of that? Seeing as we're changing the shrinker API
> anyway, I'd think it is high time to do somthing like this.

Ignoring the dcache/icache reclaim ratio issues, I'd prefer a two
call API that matches the current behaviour, leaving the caclulation
of how much to reclaim in shrink_slab(). Encoding it this way makes
it more difficult to change the high level behaviour e.g. if we want
to modify the amount of slab reclaim based on reclaim priority, we'd
have to cahnge every shrinker instead of just shrink_slab().

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
