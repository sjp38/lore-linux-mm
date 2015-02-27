Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 34BD06B006E
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 03:00:14 -0500 (EST)
Received: by pdev10 with SMTP id v10so19313236pde.10
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 00:00:13 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id zw4si1836847pac.59.2015.02.27.00.00.10
        for <linux-mm@kvack.org>;
        Fri, 27 Feb 2015 00:00:12 -0800 (PST)
Date: Fri, 27 Feb 2015 18:39:49 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150227073949.GJ4251@dastard>
References: <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1502231347510.21127@chino.kir.corp.google.com>
 <201502242020.IDI64912.tOOQSVJFOFLHMF@I-love.SAKURA.ne.jp>
 <20150224152033.GA3782@thunk.org>
 <20150224210244.GA13666@dastard>
 <201502252331.IEJ78629.OOOFSLFMHQtFVJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502252331.IEJ78629.OOOFSLFMHQtFVJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: tytso@mit.edu, rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, fernando_b1@lab.ntt.co.jp

On Wed, Feb 25, 2015 at 11:31:17PM +0900, Tetsuo Handa wrote:
> Dave Chinner wrote:
> > This exact discussion is already underway.
> > 
> > My initial proposal:
> > 
> > http://oss.sgi.com/archives/xfs/2015-02/msg00314.html
> > 
> > Why mempools don't work but transaction based reservations will:
> > 
> > http://oss.sgi.com/archives/xfs/2015-02/msg00339.html
> > 
> > Reservation needs to be an accounting mechanisms, not preallocation:
> > 
> > http://oss.sgi.com/archives/xfs/2015-02/msg00456.html
> > http://oss.sgi.com/archives/xfs/2015-02/msg00457.html
> > http://oss.sgi.com/archives/xfs/2015-02/msg00458.html
> > 
> > And that's where the discussion currently sits.
> 
> I got two problems (one is stall at io_schedule()

This is a typical "blame the messenger" bug report. XFS is stuck in
inode reclaim waiting for log IO completion to occur, along with all
the other processes iin xfs_log_force also stuck waiting for the
same Io completion.

You need to find where that IO completion that everything is waiting
on has got stuck or show that it's not a lost IO and actually an
XFS problem. e.g has the IO stack got stuck on a mempool somewhere?

> , the other is kernel panic
> due to xfs's assertion failure) using Linux 3.19.

> http://I-love.SAKURA.ne.jp/tmp/crash-20150225-2.log.xz )
> ----------
> [  189.586204] Out of memory: Kill process 3701 (a.out) score 834 or sacrifice child
> [  189.586205] Killed process 3701 (a.out) total-vm:2167392kB, anon-rss:1465820kB, file-rss:4kB
> [  189.586210] Kill process 3702 (a.out) sharing same memory
> [  189.586211] Kill process 3714 (a.out) sharing same memory
> [  189.586212] Kill process 3748 (a.out) sharing same memory
> [  189.586213] Kill process 3755 (a.out) sharing same memory
> [  189.593470] XFS: Assertion failed: XFS_FORCED_SHUTDOWN(mp), file: fs/xfs/xfs_inode.c, line: 1701

Which is a failure of xfs_trans_reserve(), and through the calling
context and parameters can only be from xfs_log_reserve().  That's
got a pretty clear cause:

        tic = xlog_ticket_alloc(log, unit_bytes, cnt, client, permanent,
                                KM_SLEEP | KM_MAYFAIL);
        if (!tic)
                return -ENOMEM;

And the reason for the ASSERT is pretty clear: we put it there
because we need to know - as developers - what failures (if any)
ever come through that path. This is called from evict():

> [  189.593565] Call Trace:
> [  189.593568]  [<ffffffff812ab2d7>] xfs_inactive_truncate+0x67/0x150
> [  189.593569]  [<ffffffff812acb98>] xfs_inactive+0x1c8/0x1f0
> [  189.593570]  [<ffffffff812b3216>] xfs_fs_evict_inode+0x86/0xd0
> [  189.593572]  [<ffffffff811da0f8>] evict+0xb8/0x190
> [  189.593574]  [<ffffffff811daa15>] iput+0xf5/0x180

And as such there is no mechanism for actually reporting the error
to userspace and in failing here we are about to leak an inode.

When an XFS developer is testing new code, having a failure like
that get trapped is immensely useful. However, on production
systems, we can just keep going because it's not a fatal error and,
even more importantly, the leaked inode will get cleaned up by log
recovery next time the filesystem is mounted.

IOWs, when you run CONFIG_XFS_DEBUG=y, you'll often get failures
that are valuable to XFS developers but have no runtime effect on
production systems.

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
