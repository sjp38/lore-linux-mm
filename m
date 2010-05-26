Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D98D76B01B2
	for <linux-mm@kvack.org>; Wed, 26 May 2010 19:12:28 -0400 (EDT)
Received: from dastard (unverified [121.45.174.97])
	by mail.internode.on.net (SurgeMail 3.8f2) with ESMTP id 25577584-1927428
	for <linux-mm@kvack.org>; Thu, 27 May 2010 08:42:25 +0930 (CST)
Date: Thu, 27 May 2010 09:12:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/5] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20100526231214.GB1395@dastard>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-4-git-send-email-david@fromorbit.com>
 <20100526164116.GD22536@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100526164116.GD22536@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, May 27, 2010 at 02:41:16AM +1000, Nick Piggin wrote:
> On Tue, May 25, 2010 at 06:53:06PM +1000, Dave Chinner wrote:
> > @@ -456,21 +456,16 @@ static void prune_one_dentry(struct dentry * dentry)
> >   * which flags are set. This means we don't need to maintain multiple
> >   * similar copies of this loop.
> >   */
> > -static void __shrink_dcache_sb(struct super_block *sb, int *count, int flags)
> > +static void __shrink_dcache_sb(struct super_block *sb, int count, int flags)
> >  {
> >  	LIST_HEAD(referenced);
> >  	LIST_HEAD(tmp);
> >  	struct dentry *dentry;
> > -	int cnt = 0;
> >  
> >  	BUG_ON(!sb);
> > -	BUG_ON((flags & DCACHE_REFERENCED) && count == NULL);
> > +	BUG_ON((flags & DCACHE_REFERENCED) && count == -1);
> >  	spin_lock(&dcache_lock);
> > -	if (count != NULL)
> > -		/* called from prune_dcache() and shrink_dcache_parent() */
> > -		cnt = *count;
> > -restart:
> > -	if (count == NULL)
> > +	if (count == -1)
> >  		list_splice_init(&sb->s_dentry_lru, &tmp);
> >  	else {
> >  		while (!list_empty(&sb->s_dentry_lru)) {
> > @@ -492,13 +487,13 @@ restart:
> >  			} else {
> >  				list_move_tail(&dentry->d_lru, &tmp);
> >  				spin_unlock(&dentry->d_lock);
> > -				cnt--;
> > -				if (!cnt)
> > +				if (--count == 0)
> >  					break;
> >  			}
> >  			cond_resched_lock(&dcache_lock);
> >  		}
> >  	}
> > +prune_more:
> >  	while (!list_empty(&tmp)) {
> >  		dentry = list_entry(tmp.prev, struct dentry, d_lru);
> >  		dentry_lru_del_init(dentry);
> > @@ -516,88 +511,29 @@ restart:
> >  		/* dentry->d_lock was dropped in prune_one_dentry() */
> >  		cond_resched_lock(&dcache_lock);
> >  	}
> > -	if (count == NULL && !list_empty(&sb->s_dentry_lru))
> > -		goto restart;
> > -	if (count != NULL)
> > -		*count = cnt;
> > +	if (count == -1 && !list_empty(&sb->s_dentry_lru)) {
> > +		list_splice_init(&sb->s_dentry_lru, &tmp);
> > +		goto prune_more;
> > +	}
> 
> Nitpick but I prefer just the restart label wher it is previously. This
> is moving setup for the next iteration into the "error" case.

Ok, will fix.

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
> 
> Would you just elaborate on the lock order problem somewhere? (the
> comment makes it look like we *could* take the mutex if we wanted
> to).

The shrinker is unregistered in deactivate_locked_super() which is
just before ->kill_sb is called. The sb->s_umount lock is held at
this point. hence is the shrinker is operating, we will deadlock if
we try to lock it like this:

	unmount:			shrinker:
					down_read(&shrinker_lock);
	down_write(&sb->s_umount)
	unregister_shrinker()
	down_write(&shrinker_lock)
					prune_super()
					  down_read(&sb->s_umount);
					  (deadlock)

hence if we can't get the sb->s_umount lock in prune_super(), then
the superblock must be being unmounted and the shrinker should abort
as the ->kill_sb method will clean up everything after the shrinker
is unregistered. Hence the down_read_trylock().


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
> > +	}
> > +
> > +	count = ((sb->s_nr_dentry_unused + sb->s_nr_inodes_unused) / 100)
> > +						* sysctl_vfs_cache_pressure;
> 
> Do you think truncating in the divisions is at all a problem? It
> probably doesn't matter much I suppose.

Same code as currently exists. IIRC, the reasoning is that if we've
got less that 100 objects to reclaim, then we're unlikely to be able
to free up any memory from the caches, anyway.

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
