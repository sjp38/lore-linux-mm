Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE1896B007E
	for <linux-mm@kvack.org>; Tue,  3 May 2016 21:00:11 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so73860877pfy.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 18:00:11 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id y66si1355553pfy.88.2016.05.03.18.00.08
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 18:00:09 -0700 (PDT)
Date: Wed, 4 May 2016 11:00:04 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/2] scop GFP_NOFS api
Message-ID: <20160504010004.GX26977@dastard>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <8737q5ugcx.fsf@notabene.neil.brown.name>
 <20160430001138.GO26977@dastard>
 <87r3dmu4cf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87r3dmu4cf.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <mr@neil.brown.name>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Sun, May 01, 2016 at 08:19:44AM +1000, NeilBrown wrote:
> On Sat, Apr 30 2016, Dave Chinner wrote:
> > Indeed, blocking the superblock shrinker in reclaim is a key part of
> > balancing inode cache pressure in XFS. If the shrinker starts
> > hitting dirty inodes, it blocks on cleaning them, thereby slowing
> > the rate of allocation to that which inodes can be cleaned and
> > reclaimed. There are also background threads that walk ahead freeing
> > clean inodes, but we have to throttle direct reclaim in this manner
> > otherwise the allocation pressure vastly outweighs the ability to
> > reclaim inodes. if we don't balance this, inode allocation triggers
> > the OOM killer because reclaim keeps reporting "no progress being
> > made" because dirty inodes are skipped. BY blocking on such inodes,
> > the shrinker makes progress (slowly) and reclaim sees that memory is
> > being freed and so continues without invoking the OOM killer...
> 
> I'm very aware of the need to throttle allocation based on IO.  I
> remember when NFS didn't quite get this right and filled up memory :-)
> 
> balance_dirty_pages() used to force threads to wait on the write-out of
> one page for every page that they dirtied (or wait on 128 pages for every 128
> dirtied or whatever).  This was exactly to provide the sort of
> throttling you are talking about.
> 
> We don't do that any more.  It was problematic.  I don't recall all the
> reasons but I think that different backing devices having different
> clearance rates was part of the problem.

As the original architect of those changes (the IO-less dirty page
throttling was an evolution of the algorithm I developed for Irix
years before it was done in linux) I remember the reasons very well.

Mostly it was to prevent what we termed "IO breakdown" where so many
different foreground threads were dispatching writeback that it
turned dirty page writeback into random IO instead of being nice,
large sequential IOs.

> So now we monitor clearance rates and wait for some number of blocks to
> be written, rather than waiting for some specific blocks to be written.

Right - we have a limited pool of flusher threads dispatching IO
efficiently as possible, and foreground dirtying processes wait for
that to do the work of cleaning pages.

> We should be able to do the same thing to balance dirty inodes as
> we do to balance dirty pages.

No, we can't. Dirty inode state is deeply tied into filesystem
implementations - it's intertwined with the journal operation in
many filesystems and can't be separated easily.  Indeed, some
filesystem don't even use the VFS for tracking dirty inode state,
nor do they implement the ->write_inode method. Hence the VFS northe
inode cache shrinkers are able to determine if an inode is dirty, or
if it is, trigger writeback of it.

IOWs, inode caches are not unified in allocation, behaviour, design
or implementation like the page cache is, and so balancing dirty
inodes is likely not to be possible....

> >>    If it could be changed
> >>    to just schedule the IO without waiting for it then I think this
> >>    would be safe to be called in any FS allocation context.  It already
> >>    uses a 'trylock' in xfs_dqlock_nowait() to avoid deadlocking
> >>    if the lock is held.
> >
> > We could, but then we have the same problem as the inode cache -
> > there's no indication of progress going back to the memory reclaim
> > subsystem, nor is reclaim able to throttle memory allocation back to
> > the rate at which reclaim is making progress.
> >
> > There's feedback loops all throughout the XFS reclaim code - it's
> > designed specifically that way - I made changes to the shrinker
> > infrastructure years ago to enable this. It's no different to the
> > dirty page throttling that was done at roughly the same time -
> > that's also one big feedback loop controlled by the rate at which
> > pages can be cleaned. Indeed, it was designed was based on the same
> > premise as all the XFS shrinker code: in steady state conditions
> > we can't allocate a resource faster than we can reclaim it, so we
> > need to make reclaim as efficient at possible...
> 
> You seem to be referring here to the same change that I was referred to
> above, but seem to be seeing it from a different perspective.

Sure, not many people have the same viewpoint as the preson who had
to convince everyone else that it was a sound idea even before
prototypes were written...

> Waiting for inodes to be freed in important.  Waiting for any one
> specific inode to be freed is dangerous.

Sure. But there's a difference between waiting on an inode you have
no idea when you'll be able to reclaim it, versus waiting on IO
completion for an inode you've already guaranteed can complete
reclaim and are the only context that has access to the inode....

Not to mention that XFS also triggers an async inode reclaim worker
thread to do non-blocking reclaim of inodes in the background, so
while direct reclaim throttles (and hence prevents excessive
concurrent direct reclaim from trashing the working set of clean
inodes whilst ignoring dirty inodes) we still get appropriate
amounts of inode cache reclaim occurring...

> > The problem with this is that a single kswapd thread can't keep
> > up with all of the allocation pressure that occurs. e.g. a
> > 20-core intel CPU with local memory will be seen as a single
> > node and so will have a single kswapd thread to do reclaim.
> > There's a massive imbalance between maximum reclaim rate and
> > maximum allocation rate in situations like this. If we want
> > memory reclaim to run faster, we to be able to do more work
> > *now*, not defer it to a context with limited execution
> > resources.
> 
> I agree it makes sense to do *work* locally on the core that sees
> the need.  What I want to avoid is *sleeping* locally.

With direct reclaim, sleeping locally is the only way we can
throttle it. If we want to avoid reclaim from doing this, then we
need to move to a reclaim model similar to the IO-less dirty page
throttling mechanism which directly limits reclaim concurrency and
so individual subsystem shrinkers don't need to do this to prevent
reclaim from trashing the working set.

Indeed, I've proposed this in the past, and been told by various
developers that it can't possibly work and, besides, fs developers
know nothing about mm/ design.... I've got better things to do than
bash my head against brick walls like this, even though I know such
algorithms both perform and scale for memory reclaim because that's
exactly where I got the original inspriation for IO-less dirty page
throttling from: the Irix memory reclaim algorithms....

> How would
> it be to make evict_inode non-blocking?

We can't without completely redesigning how iput_final() and evict()
work and order operations. Indeed, by the time we call
->evict_inode(), we've already marked the inode as I_FREEING,
removed the inode from the superblock inode list, dirty writeback
lists, the LRU lists and blocked waiting for any inode writeback in
progress to complete.

We'd also have to redesign the shrinker code, because it does bulk
operations to isolate inodes from the LRU onto temporary lists after
marking them I_FREEING, which then does evict() calls from a
separate context. We'd then have to change all that code to handle
inodes that can't be reclaimed and re-insert them into the LRUs
approriately, and that would have to be managed in a way that we
don't end up live-locking the shrinker lru scanning on unreferenced
inodes that cannot be evicted. I'm also not sure whether
dispose_list() function can add inodes back onto the LRU safely
because contexts calling evict() make the assumption the inode is no
longer on the LRU and don't need to access LRU locks at all...

Also, evict() is called when unmounting the filesystem, and so in
those cases we actually want it to block and do everything that is
necessary to free the inode, so this would introduce more complex
interactions depending on caller context....

> It would do as much work
> as it can, which in many cases would presumably complete the whole
> task.  But if it cannot progress for some reason, it returns
> -EAGAIN and then the rest gets queued for later.  Might that work,
> or is there often still lots of CPU work to be done after things
> have been waited for?

Freeing the inode occurs after it's been waited for, usually. i.e.
no wait, no inode being freed and no feedback for throttling of the
inode reclaim rate...

FWIW, I don't think making evict() non-blocking is going to be worth
the effort here. Making memory reclaim wait on a priority ordered
queue while asynchronous reclaim threads run reclaim as efficiently
as possible and wakes waiters as it frees the memory the waiters
require is a model that has been proven to work in the past, and
this appears to me to be the model you are advocating for. I agree
that direct reclaim needs to die and be replaced with something
entirely more predictable, controllable and less prone to deadlock
contexts - you just need to convince the mm developers that it will
perform and scale better than what we have now.

In the mean time, having a slightly more fine grained GFP_NOFS
equivalent context will allow us to avoid the worst of the current
GFP_NOFS problems with very little extra code.

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
