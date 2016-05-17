Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2E86B025E
	for <linux-mm@kvack.org>; Tue, 17 May 2016 18:35:54 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id i5so61803410ige.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 15:35:54 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id a28si5218021ioj.147.2016.05.17.15.35.52
        for <linux-mm@kvack.org>;
        Tue, 17 May 2016 15:35:53 -0700 (PDT)
Date: Wed, 18 May 2016 08:35:49 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160517223549.GV26977@dastard>
References: <94cea603-2782-1c5a-e2df-42db4459a8ce@cn.fujitsu.com>
 <20160512055756.GE6648@birch.djwong.org>
 <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160517144912.GZ3193@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Tue, May 17, 2016 at 04:49:12PM +0200, Peter Zijlstra wrote:
> 
> Thanks for writing all that down Dave!
> 
> On Tue, May 17, 2016 at 09:10:56AM +1000, Dave Chinner wrote:
> 
> > The reason we don't have lock clases for the ilock is that we aren't
> > supposed to call memory reclaim with that lock held in exclusive
> > mode. This is because reclaim can run transactions, and that may
> > need to flush dirty inodes to make progress. Flushing dirty inode
> > requires taking the ilock in shared mode.
> > 
> > In the code path that was reported, we hold the ilock in /shared/
> > mode with no transaction context (we are doing a read-only
> > operation). This means we can run transactions in memory reclaim
> > because a) we can't deadlock on the inode we hold locks on, and b)
> > transaction reservations will be able to make progress as we don't
> > hold any locks it can block on.
> 
> Just to clarify; I read the above as that we cannot block on recursive
> shared locks, is this correct?
> 
> Because we can in fact block on down_read()+down_read() just fine, so if
> you're assuming that, then something's busted.

The transaction reservation path will run down_read_trylock() on the
inode, not down_read(). Hence if there are no pending writers, it
will happily take the lock twice and make progress, otherwise it
will skip the inode and there's no deadlock.  If there's a pending
writer, then we have another context that is already in a
transaction context and has already pushed the item, hence it is
only in the scope of the current push because IO hasn't completed
yet and removed it from the list.

> Otherwise, I'm not quite reading it right, which is, given the
> complexity of that stuff, entirely possible.

There's a maze of dark, grue-filled twisty passages here...

> The other possible reading is that we cannot deadlock on the inode we
> hold locks on because we hold a reference on it; and the reference
> avoids the inode from being reclaimed. But then the whole
> shared/exclusive thing doesn't seem to make sense.

Right, because that's not the problem. The issue has to do with
transaction contexts and what locks are safe to hold when calling
xfs_trans_reserve(). Direct reclaim is putting xfs_trans_reserve()
behind memory allocation, which means it is unsafe for XFS to hold
the ilock exclusive or be in an existing transaction context when
doing GFP_KERNEL allocation.

> > For the ilock, the number of places where the ilock is held over
> > GFP_KERNEL allocations is pretty small. Hence we've simply added
> > GFP_NOFS to those allocations to - effectively - annotate those
> > allocations as "lockdep causes problems here". There are probably
> > 30-35 allocations in XFS that explicitly use KM_NOFS - some of these
> > are masking lockdep false positive reports.
> 
> 
> > In the end, like pretty much all the complex lockdep false positives
> > we've had to deal in XFS, we've ended up changing the locking or
> > allocation contexts because that's been far easier than trying to
> > make annotations cover everything or convince other people that
> > lockdep annotations are insufficient.
> 
> Well, I don't mind creating lockdep annotations; but explanations of the
> exact details always go a long way towards helping me come up with
> something.
> 
> While going over the code; I see there's complaining about
> MAX_SUBCLASSES being too small. Would it help if we doubled it? We
> cannot grow the thing without limits, but doubling it should be possible
> I think.

Last time I asked cwif we could increase MAX_SUBCLASSES I was told
no. So we've just had to try to fit about 30 different
inode lock contexts into 8 subclasses split across multiple class
types (i.e. xfs_[non]dir_ilock_class). I wasted an entire week on
getting those annotations to fit the limitations of lockdep and
still work.

> In any case; would something like this work for you? Its entirely
> untested, but the idea is to mark an entire class to skip reclaim
> validation, instead of marking individual sites.

Probably would, but it seems like swatting a fly with runaway
train. I'd much prefer a per-site annotation (e.g. as a GFP_ flag)
so that we don't turn off something that will tell us we've made a
mistake while developing new code...

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
