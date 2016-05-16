Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 02FE86B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 19:11:02 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id sq19so3748774igc.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 16:11:01 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id b89si216892iod.103.2016.05.16.16.10.59
        for <linux-mm@kvack.org>;
        Mon, 16 May 2016 16:11:00 -0700 (PDT)
Date: Tue, 17 May 2016 09:10:56 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160516231056.GE18496@dastard>
References: <94cea603-2782-1c5a-e2df-42db4459a8ce@cn.fujitsu.com>
 <20160512055756.GE6648@birch.djwong.org>
 <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160516132541.GP3193@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org

On Mon, May 16, 2016 at 03:25:41PM +0200, Peter Zijlstra wrote:
> On Mon, May 16, 2016 at 03:05:19PM +0200, Michal Hocko wrote:
> > On Mon 16-05-16 12:41:30, Peter Zijlstra wrote:
> > > On Fri, May 13, 2016 at 06:03:41PM +0200, Michal Hocko wrote:
> > IIRC Dave's emails they have tried that by using lockdep classes and
> > that turned out to be an overly complex maze which still doesn't work
> > 100% reliably.
> 
> So that would be the: 
> 
> > >  but we can't tell lockdep that easily in any way
> > > without going back to the bad old ways of creating a new lockdep
> > > class for inode ilocks the moment they enter ->evict. This then
> > > disables "entire lifecycle" lockdep checking on the xfs inode ilock,
> > > which is why we got rid of it in the first place."
> > > 
> > > But fails to explain the problems with the 'old' approach.
> > > 
> > > So clearly this is a 'problem' that has existed for quite a while, so I
> > > don't see any need to rush half baked solutions either.
> > 
> > Well, at least my motivation for _some_ solution here is that xfs has
> > worked around this deficiency by forcing GFP_NOFS also for contexts which
> > are perfectly OK to do __GFP_FS allocation. And that in turn leads to
> > other issues which I would really like to sort out. So the idea was to
> > give xfs another way to express that workaround that would be a noop
> > without lockdep configured.
> 
> Right, that's unfortunate. But I would really like to understand the
> problem with the classes vs lifecycle thing.
> 
> Is there an email explaining that somewhere?

Years ago (i.e. last time I bothered mentioning that lockdep didn't
cover these cases) but buggered if I can find a reference.

We used to have iolock classes. Added in commit 033da48 ("xfs: reset
the i_iolock lock class in the reclaim path") in 2010, removed by
commit 4f59af7 ("xfs: remove iolock lock classes") a couple of years
later.

We needed distinct lock classes above and below reclaim because the
same locks were taken above and below memory allocation, and the
reclaimed inode recycling made lockdep think it had a loop in it's
graph:


inode lookup	memory reclaim		inode lookup
------------	--------------		------------
not found
allocate inode
init inode
take active reference
return to caller
.....
		  inode shrinker
		  find inode with no active reference
		   ->evict
		     start transaction
		       take inode locks
		     .....
		     commit transaction
		     mark for reclaim
		     .....

					find inactive inode in reclaimable state
					remove from reclaim list
					re-initialise inode state
					take active reference
					return to caller

So you can see that an inode can go through the reclaim context
without being freed but having taken locks, but then immediately
reused in a non-reclaim context. Hence we had to split the two
lockdep contexts and re-initialise the lock contexts in the
different allocation paths.

The reason we don't have lock clases for the ilock is that we aren't
supposed to call memory reclaim with that lock held in exclusive
mode. This is because reclaim can run transactions, and that may
need to flush dirty inodes to make progress. Flushing dirty inode
requires taking the ilock in shared mode.

In the code path that was reported, we hold the ilock in /shared/
mode with no transaction context (we are doing a read-only
operation). This means we can run transactions in memory reclaim
because a) we can't deadlock on the inode we hold locks on, and b)
transaction reservations will be able to make progress as we don't
hold any locks it can block on.

Sure, we can have multiple lock classes so that this can be done,
but that then breaks lock order checking between the two contexts.
Both contexts require locking order and transactional behaviour to
be identical and, from this perspective, class separation is
effectively no different from turning lockdep off.

For the ilock, the number of places where the ilock is held over
GFP_KERNEL allocations is pretty small. Hence we've simply added
GFP_NOFS to those allocations to - effectively - annotate those
allocations as "lockdep causes problems here". There are probably
30-35 allocations in XFS that explicitly use KM_NOFS - some of these
are masking lockdep false positive reports.

The reason why we had lock classes for the *iolock* (not the ilock)
was because ->evict processing used to require the iolock for
attribute removal. This caused all sorts of problems with
GFP_KERNEL allocations in the IO path (e.g. allocate a page cache
page under the IO lock, direct reclaim would trigger lockdep
warnings - there's another reason why XFS always used GFP_NOFS
contexts for page cache allocations) which were all false positives
because the inode holding the lock has active references and hence
will never be accessed by the reclaim path. The only workable
solution iwe could come up with at the time this was reported was
to this was to split the lock classes.

In the end, like pretty much all the complex lockdep false positives
we've had to deal in XFS, we've ended up changing the locking or
allocation contexts because that's been far easier than trying to
make annotations cover everything or convince other people that
lockdep annotations are insufficient.

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
