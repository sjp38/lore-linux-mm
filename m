Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2296B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 20:25:14 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id yu3so111789768obb.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 17:25:14 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id qb8si1811375igc.55.2016.05.19.17.25.12
        for <linux-mm@kvack.org>;
        Thu, 19 May 2016 17:25:13 -0700 (PDT)
Date: Fri, 20 May 2016 10:17:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160520001714.GC26977@dastard>
References: <20160512055756.GE6648@birch.djwong.org>
 <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160519081146.GS3193@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160519081146.GS3193@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu, May 19, 2016 at 10:11:46AM +0200, Peter Zijlstra wrote:
> On Wed, May 18, 2016 at 08:35:49AM +1000, Dave Chinner wrote:
> > On Tue, May 17, 2016 at 04:49:12PM +0200, Peter Zijlstra wrote:
> > > On Tue, May 17, 2016 at 09:10:56AM +1000, Dave Chinner wrote:
> > > 
> > > > The reason we don't have lock clases for the ilock is that we aren't
> > > > supposed to call memory reclaim with that lock held in exclusive
> > > > mode. This is because reclaim can run transactions, and that may
> > > > need to flush dirty inodes to make progress. Flushing dirty inode
> > > > requires taking the ilock in shared mode.
> > > > 
> > > > In the code path that was reported, we hold the ilock in /shared/
> > > > mode with no transaction context (we are doing a read-only
> > > > operation). This means we can run transactions in memory reclaim
> > > > because a) we can't deadlock on the inode we hold locks on, and b)
> > > > transaction reservations will be able to make progress as we don't
> > > > hold any locks it can block on.
> > > 
> > > Just to clarify; I read the above as that we cannot block on recursive
> > > shared locks, is this correct?
> > > 
> > > Because we can in fact block on down_read()+down_read() just fine, so if
> > > you're assuming that, then something's busted.
> > 
> > The transaction reservation path will run down_read_trylock() on the
> > inode, not down_read(). Hence if there are no pending writers, it
> > will happily take the lock twice and make progress, otherwise it
> > will skip the inode and there's no deadlock.  If there's a pending
> > writer, then we have another context that is already in a
> > transaction context and has already pushed the item, hence it is
> > only in the scope of the current push because IO hasn't completed
> > yet and removed it from the list.
> > 
> > > Otherwise, I'm not quite reading it right, which is, given the
> > > complexity of that stuff, entirely possible.
> > 
> > There's a maze of dark, grue-filled twisty passages here...
> 
> OK; I might need a bit more again.
> 
> So now the code does something like:
> 
> 	down_read(&i_lock);		-- lockdep marks lock as held
> 	kmalloc(GFP_KERNEL);		-- lockdep marks held locks as ENABLED_RECLAIM_FS
> 	  --> reclaim()
> 	     down_read_trylock(&i_lock); -- lockdep does _NOT_ mark as USED_IN_RECLAIM_FS
> 
> Right?

In the path that can deadlock the log, yes. It's actually way more
complex than the above, because the down_read_trylock(&i_lock) that
matters is run in a completely separate, async kthread that
xfs_trans_reserve() will block waiting for.

process context				xfsaild kthread(*)
---------------				------------------
down_read(&i_lock);		-- lockdep marks lock as held
kmalloc(GFP_KERNEL);		-- lockdep marks held locks as ENABLED_RECLAIM_FS
  --> reclaim()
     xfs_trans_reserve()
     ....
	  xfs_trans_push_ail()	---- called if no space in the log to kick the xfsaild into action
	  ....
       xlog_grant_head_wait()	---- blocks waiting for log space
       .....

					xfsaild_push()   ----- iterates AIL
					  grabs log item
					    lock log item
	>>>>>>>>>>>>>>>>>>>>>		      down_read_trylock(&i_lock);
					      format item into buffer
					      add to dirty buffer list
					  ....
					  submit dirty buffer list for IO
					    buffer IO started
					.....
					<async IO completion context>
					buffer callbacks
					  mark inode clean
					  remove inode from AIL
					  move tail of log forwards
					    wake grant head waiters
	<woken by log tail moving>
	<log space available>
	transaction reservation granted
     .....
     down_write(some other inode ilock)
     <modify some other inode>
     xfs_trans_commit
     .....

(*) xfsaild runs with PF_MEMALLOC context.

The problem is that if the ilock is held exclusively at GFP_KERNEL
time, the xfsaild cannot lock the inode to flush it, so if that
inode pins the tail of the log then we can't make space available
for xfs_trans_reserve and there is the deadlock.

Once xfs_trans_reserve completes, however, we'll take the ilock on
*some other inode*, and that's where the "it can't be the inode we
currently hold locked because we have references to it" and
henceit's safe to have a pattern like:

down_read(&i_lock);		-- lockdep marks lock as held
kmalloc(GFP_KERNEL);		-- lockdep marks held locks as ENABLED_RECLAIM_FS
  --> reclaim()
    down_write(&ilock)

because the lock within reclaim context is completely unrelated to
the lock we already hold.

Lockdep can't possibly know about this because the deadlock involves
locking contexts that *aren't doing anything wrong within their own
contexts*. It's only when you add the dependency of log space
reservation requirements needed to make forwards progress that
there's then an issue with locking and reclaim.

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
