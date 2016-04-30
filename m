Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 814CD6B025E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 20:11:44 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so194041922pad.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 17:11:44 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id ul1si2352813pab.19.2016.04.29.17.11.42
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 17:11:43 -0700 (PDT)
Date: Sat, 30 Apr 2016 10:11:38 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/2] scop GFP_NOFS api
Message-ID: <20160430001138.GO26977@dastard>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <8737q5ugcx.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8737q5ugcx.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <mr@neil.brown.name>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 29, 2016 at 03:35:42PM +1000, NeilBrown wrote:
> On Tue, Apr 26 2016, Michal Hocko wrote:
> 
> > Hi,
> > we have discussed this topic at LSF/MM this year. There was a general
> > interest in the scope GFP_NOFS allocation context among some FS
> > developers. For those who are not aware of the discussion or the issue
> > I am trying to sort out (or at least start in that direction) please
> > have a look at patch 1 which adds memalloc_nofs_{save,restore} api
> > which basically copies what we have for the scope GFP_NOIO allocation
> > context. I haven't converted any of the FS myself because that is way
> > beyond my area of expertise but I would be happy to help with further
> > changes on the MM front as well as in some more generic code paths.
> >
> > Dave had an idea on how to further improve the reclaim context to be
> > less all-or-nothing wrt. GFP_NOFS. In short he was suggesting an opaque
> > and FS specific cookie set in the FS allocation context and consumed
> > by the FS reclaim context to allow doing some provably save actions
> > that would be skipped due to GFP_NOFS normally.  I like this idea and
> > I believe we can go that direction regardless of the approach taken here.
> > Many filesystems simply need to cleanup their NOFS usage first before
> > diving into a more complex changes.>
> 
> This strikes me as over-engineering to work around an unnecessarily
> burdensome interface.... but without details it is hard to be certain.
> 
> Exactly what things happen in "FS reclaim context" which may, or may
> not, be safe depending on the specific FS allocation context?  Do they
> need to happen at all?
> 
> My research suggests that for most filesystems the only thing that
> happens in reclaim context that is at all troublesome is the final
> 'evict()' on an inode.  This needs to flush out dirty pages and sync the
> inode to storage.  Some time ago we moved most dirty-page writeout out
> of the reclaim context and into kswapd.  I think this was an excellent
> advance in simplicity.

No, we didn't move dirty page writeout to kswapd - we moved it back
to the background writeback threads where it can be done
efficiently.  kswapd should almost never do single page writeback
because of how inefficient it is from an IO perspective, even though
it can. i.e. if we are doing any significant amount of dirty page
writeback from memory reclaim (direct, kswapd or otherwise) then
we've screwed something up.

> If we could similarly move evict() into kswapd (and I believe we can)
> then most file systems would do nothing in reclaim context that
> interferes with allocation context.

When lots of GFP_NOFS allocation is being done, this already
happens. The shrinkers that can't run due to context accumulate the
work on the shrinker structure, and when the shrinker can next run
(e.g. run from kswapd) it runs all the deferred work from GFP_NOFS
reclaim contexts.

IOWs, we already move shrinker work from direct reclaim to kswapd
when appropriate.

> The exceptions include:
>  - nfs and any filesystem using fscache can block for up to 1 second
>    in ->releasepage().  They used to block waiting for some IO, but that
>    caused deadlocks and wasn't really needed.  I left the timeout because
>    it seemed likely that some throttling would help.  I suspect that a
>    careful analysis will show that there is sufficient throttling
>    elsewhere.
> 
>  - xfs_qm_shrink_scan is nearly unique among shrinkers in that it waits
>    for IO so it can free some quotainfo things. 

No it's not. evict() can block on IO - waiting for data or inode
writeback to complete, or even for filesystems to run transactions
on the inode. Hence the superblock shrinker can and does block in
inode cache reclaim.

Indeed, blocking the superblock shrinker in reclaim is a key part of
balancing inode cache pressure in XFS. If the shrinker starts
hitting dirty inodes, it blocks on cleaning them, thereby slowing
the rate of allocation to that which inodes can be cleaned and
reclaimed. There are also background threads that walk ahead freeing
clean inodes, but we have to throttle direct reclaim in this manner
otherwise the allocation pressure vastly outweighs the ability to
reclaim inodes. if we don't balance this, inode allocation triggers
the OOM killer because reclaim keeps reporting "no progress being
made" because dirty inodes are skipped. BY blocking on such inodes,
the shrinker makes progress (slowly) and reclaim sees that memory is
being freed and so continues without invoking the OOM killer...

>    If it could be changed
>    to just schedule the IO without waiting for it then I think this
>    would be safe to be called in any FS allocation context.  It already
>    uses a 'trylock' in xfs_dqlock_nowait() to avoid deadlocking
>    if the lock is held.

We could, but then we have the same problem as the inode cache -
there's no indication of progress going back to the memory reclaim
subsystem, nor is reclaim able to throttle memory allocation back to
the rate at which reclaim is making progress.

There's feedback loops all throughout the XFS reclaim code - it's
designed specifically that way - I made changes to the shrinker
infrastructure years ago to enable this. It's no different to the
dirty page throttling that was done at roughly the same time -
that's also one big feedback loop controlled by the rate at which
pages can be cleaned. Indeed, it was designed was based on the same
premise as all the XFS shrinker code: in steady state conditions
we can't allocate a resource faster than we can reclaim it, so we
need to make reclaim as efficient at possible...

> I think you/we would end up with a much simpler system if instead of
> focussing on the places where GFP_NOFS is used, we focus on places where
> __GFP_FS is tested, and try to remove them.  If we get rid of enough of
> them the remainder could just use __GFP_IO.

The problem with this is that a single kswapd thread can't keep up
with all of the allocation pressure that occurs. e.g. a 20-core
intel CPU with local memory will be seen as a single node and so
will have a single kswapd thread to do reclaim. There's a massive
imbalance between maximum reclaim rate and maximum allocation rate
in situations like this. If we want memory reclaim to run faster,
we to be able to do more work *now*, not defer it to a context with
limited execution resources.

i.e. IMO deferring more work to a single reclaim thread per node is
going to limit memory reclaim scalability and performance, not
improve it.

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
