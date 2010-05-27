Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BA0976B01C3
	for <linux-mm@kvack.org>; Thu, 27 May 2010 18:54:25 -0400 (EDT)
Date: Fri, 28 May 2010 08:54:18 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/5] inode: Make unused inode LRU per superblock
Message-ID: <20100527225418.GP12087@dastard>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-2-git-send-email-david@fromorbit.com>
 <20100527133230.780be6c7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100527133230.780be6c7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, May 27, 2010 at 01:32:30PM -0700, Andrew Morton wrote:
> On Tue, 25 May 2010 18:53:04 +1000
> Dave Chinner <david@fromorbit.com> wrote:
> 
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > The inode unused list is currently a global LRU. This does not match
> > the other global filesystem cache - the dentry cache - which uses
> > per-superblock LRU lists. Hence we have related filesystem object
> > types using different LRU reclaimatin schemes.
> > 
> > To enable a per-superblock filesystem cache shrinker, both of these
> > caches need to have per-sb unused object LRU lists. Hence this patch
> > converts the global inode LRU to per-sb LRUs.
> > 
> > The patch only does rudimentary per-sb propotioning in the shrinker
> > infrastructure, as this gets removed when the per-sb shrinker
> > callouts are introduced later on.
> > 
> > ...
> >
> > +			list_move(&inode->i_list, &inode->i_sb->s_inode_lru);
> 
> It's a shape that s_inode_lru is still protected by inode_lock.  One
> day we're going to get in trouble over that lock.  Migrating to a
> per-sb lock would be logical and might help.
> 
> Did you look into this? 

Yes, I have. Yes, it's possible.  It's solving a different problem,
so I figured it can be done in a different patch set.

> I expect we'd end up taking both inode_lock
> and the new sb->lru_lock in several places, which wouldn't be of any
> help, at least in the interim.  Long-term, the locking for
> fs-writeback.c should move to the per-superblock one also, at which
> time this problem largely goes away I think.  Unfortunately the
> writeback inode lists got moved into the backing_dev_info, whcih messes
> things up a bit.

*nod*

> 
> >  	inodes_stat.nr_unused--;
> > +	inode->i_sb->s_nr_inodes_unused--;
> 
> It's regrettable to be counting the same thing twice.  Did you look
> into removing (or no longer using) inodes_stat.nr_unused?

Sort of. The complexity is the stats are userspace visible, so they
can't just be removed. Replacing the current stats means that when
they are read from /proc we would need to walk all the superblocks
to aggregate them. The bit I haven't looked at yet is whether
walking superblocks is allowed in a proc handler.

So in the mean time, I just copied what was done for the
dentry_stats. If it's ok to do this walk, then we can change both
the dentry and inode stats at the same time.

> > +		/* Now, we reclaim unused dentrins with fairness.
> 
> May as well fix the typo while we're there.
> 
> Please review all these comments to ensure that they are still accurate
> and complete.

Will do.

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
