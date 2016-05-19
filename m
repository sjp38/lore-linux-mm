Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 836756B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 04:11:51 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id sq19so143407676igc.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 01:11:51 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 68si11625735ioq.126.2016.05.19.01.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 01:11:50 -0700 (PDT)
Date: Thu, 19 May 2016 10:11:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160519081146.GS3193@twins.programming.kicks-ass.net>
References: <94cea603-2782-1c5a-e2df-42db4459a8ce@cn.fujitsu.com>
 <20160512055756.GE6648@birch.djwong.org>
 <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160517223549.GV26977@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Wed, May 18, 2016 at 08:35:49AM +1000, Dave Chinner wrote:
> On Tue, May 17, 2016 at 04:49:12PM +0200, Peter Zijlstra wrote:
> > On Tue, May 17, 2016 at 09:10:56AM +1000, Dave Chinner wrote:
> > 
> > > The reason we don't have lock clases for the ilock is that we aren't
> > > supposed to call memory reclaim with that lock held in exclusive
> > > mode. This is because reclaim can run transactions, and that may
> > > need to flush dirty inodes to make progress. Flushing dirty inode
> > > requires taking the ilock in shared mode.
> > > 
> > > In the code path that was reported, we hold the ilock in /shared/
> > > mode with no transaction context (we are doing a read-only
> > > operation). This means we can run transactions in memory reclaim
> > > because a) we can't deadlock on the inode we hold locks on, and b)
> > > transaction reservations will be able to make progress as we don't
> > > hold any locks it can block on.
> > 
> > Just to clarify; I read the above as that we cannot block on recursive
> > shared locks, is this correct?
> > 
> > Because we can in fact block on down_read()+down_read() just fine, so if
> > you're assuming that, then something's busted.
> 
> The transaction reservation path will run down_read_trylock() on the
> inode, not down_read(). Hence if there are no pending writers, it
> will happily take the lock twice and make progress, otherwise it
> will skip the inode and there's no deadlock.  If there's a pending
> writer, then we have another context that is already in a
> transaction context and has already pushed the item, hence it is
> only in the scope of the current push because IO hasn't completed
> yet and removed it from the list.
> 
> > Otherwise, I'm not quite reading it right, which is, given the
> > complexity of that stuff, entirely possible.
> 
> There's a maze of dark, grue-filled twisty passages here...

OK; I might need a bit more again.

So now the code does something like:

	down_read(&i_lock);		-- lockdep marks lock as held
	kmalloc(GFP_KERNEL);		-- lockdep marks held locks as ENABLED_RECLAIM_FS
	  --> reclaim()
	     down_read_trylock(&i_lock); -- lockdep does _NOT_ mark as USED_IN_RECLAIM_FS

Right?

My 'problem' is that lockdep doesn't consider a trylock for the USED_IN
annotation, so the i_lock class will only get the ENABLED tag but not
get the USED_IN tag, and therefore _should_ not trigger the inversion.


So what exactly is triggering the inversion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
