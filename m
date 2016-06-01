Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF75C6B0262
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 09:18:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n2so11741650wma.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 06:18:01 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id kh5si56959211wjb.185.2016.06.01.06.18.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 06:18:00 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q62so6718437wmg.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 06:18:00 -0700 (PDT)
Date: Wed, 1 Jun 2016 15:17:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160601131758.GO26601@dhcp22.suse.cz>
References: <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160519081146.GS3193@twins.programming.kicks-ass.net>
 <20160520001714.GC26977@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160520001714.GC26977@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

Thanks Dave for your detailed explanation again! Peter do you have any
other idea how to deal with these situations other than opt out from
lockdep reclaim machinery?

If not I would rather go with an annotation than a gfp flag to be honest
but if you absolutely hate that approach then I will try to check wheter
a CONFIG_LOCKDEP GFP_FOO doesn't break something else. Otherwise I would
steal the description from Dave's email and repost my patch.

I plan to repost my scope gfp patches in few days and it would be good
to have some mechanism to drop those GFP_NOFS to paper over lockdep
false positives for that.

[keeping Dave's explanation for reference]

On Fri 20-05-16 10:17:14, Dave Chinner wrote:
> On Thu, May 19, 2016 at 10:11:46AM +0200, Peter Zijlstra wrote:
> > On Wed, May 18, 2016 at 08:35:49AM +1000, Dave Chinner wrote:
[...]
> > > There's a maze of dark, grue-filled twisty passages here...
> > 
> > OK; I might need a bit more again.
> > 
> > So now the code does something like:
> > 
> > 	down_read(&i_lock);		-- lockdep marks lock as held
> > 	kmalloc(GFP_KERNEL);		-- lockdep marks held locks as ENABLED_RECLAIM_FS
> > 	  --> reclaim()
> > 	     down_read_trylock(&i_lock); -- lockdep does _NOT_ mark as USED_IN_RECLAIM_FS
> > 
> > Right?
> 
> In the path that can deadlock the log, yes. It's actually way more
> complex than the above, because the down_read_trylock(&i_lock) that
> matters is run in a completely separate, async kthread that
> xfs_trans_reserve() will block waiting for.
> 
> process context				xfsaild kthread(*)
> ---------------				------------------
> down_read(&i_lock);		-- lockdep marks lock as held
> kmalloc(GFP_KERNEL);		-- lockdep marks held locks as ENABLED_RECLAIM_FS
>   --> reclaim()
>      xfs_trans_reserve()
>      ....
> 	  xfs_trans_push_ail()	---- called if no space in the log to kick the xfsaild into action
> 	  ....
>        xlog_grant_head_wait()	---- blocks waiting for log space
>        .....
> 
> 					xfsaild_push()   ----- iterates AIL
> 					  grabs log item
> 					    lock log item
> 	>>>>>>>>>>>>>>>>>>>>>		      down_read_trylock(&i_lock);
> 					      format item into buffer
> 					      add to dirty buffer list
> 					  ....
> 					  submit dirty buffer list for IO
> 					    buffer IO started
> 					.....
> 					<async IO completion context>
> 					buffer callbacks
> 					  mark inode clean
> 					  remove inode from AIL
> 					  move tail of log forwards
> 					    wake grant head waiters
> 	<woken by log tail moving>
> 	<log space available>
> 	transaction reservation granted
>      .....
>      down_write(some other inode ilock)
>      <modify some other inode>
>      xfs_trans_commit
>      .....
> 
> (*) xfsaild runs with PF_MEMALLOC context.
> 
> The problem is that if the ilock is held exclusively at GFP_KERNEL
> time, the xfsaild cannot lock the inode to flush it, so if that
> inode pins the tail of the log then we can't make space available
> for xfs_trans_reserve and there is the deadlock.
> 
> Once xfs_trans_reserve completes, however, we'll take the ilock on
> *some other inode*, and that's where the "it can't be the inode we
> currently hold locked because we have references to it" and
> henceit's safe to have a pattern like:
> 
> down_read(&i_lock);		-- lockdep marks lock as held
> kmalloc(GFP_KERNEL);		-- lockdep marks held locks as ENABLED_RECLAIM_FS
>   --> reclaim()
>     down_write(&ilock)
> 
> because the lock within reclaim context is completely unrelated to
> the lock we already hold.
> 
> Lockdep can't possibly know about this because the deadlock involves
> locking contexts that *aren't doing anything wrong within their own
> contexts*. It's only when you add the dependency of log space
> reservation requirements needed to make forwards progress that
> there's then an issue with locking and reclaim.
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
