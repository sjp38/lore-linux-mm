Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF676B0088
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 11:57:39 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so11045682wib.1
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 08:57:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bk1si33667079wjb.171.2014.12.22.08.57.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 08:57:38 -0800 (PST)
Date: Mon, 22 Dec 2014 17:57:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20141222165736.GB2900@dhcp22.suse.cz>
References: <20141218153341.GB832@dhcp22.suse.cz>
 <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
 <20141220020331.GM1942@devil.localdomain>
 <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
 <20141220223504.GI15665@dastard>
 <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
 <20141221204249.GL15665@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141221204249.GL15665@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Mon 22-12-14 07:42:49, Dave Chinner wrote:
[...]
> "memory reclaim gave up"? So why the hell isn't it returning a
> failure to the caller?
> 
> i.e. We have a perfectly good page cache allocation failure error
> path here all the way back to userspace, but we're invoking the
> OOM-killer to kill random processes rather than returning ENOMEM to
> the processes that are generating the memory demand?
> 
> Further: when did the oom-killer become the primary method
> of handling situations when memory allocation needs to fail?
> __GFP_WAIT does *not* mean memory allocation can't fail - that's what
> __GFP_NOFAIL means. And none of the page cache allocations use
> __GFP_NOFAIL, so why aren't we getting an allocation failure before
> the oom-killer is kicked?

Well, it has been an unwritten rule that GFP_KERNEL allocations for
low-order (<=PAGE_ALLOC_COSTLY_ORDER) never fail. This is a long ago
decision which would be tricky to fix now without silently breaking a
lot of code. Sad...
Nevertheless the caller can prevent from an endless loop by using
__GFP_NORETRY so this could be used as a workaround. The default should
be opposite IMO and only those who really require some guarantee should
use a special flag for that purpose.

> > I guess __alloc_pages_direct_reclaim() returns NULL with did_some_progress > 0
> > so that __alloc_pages_may_oom() will not be called easily. As long as
> > try_to_free_pages() returns non-zero, __alloc_pages_direct_reclaim() might
> > return NULL with did_some_progress > 0. So, do_try_to_free_pages() is called
> > for many times and is likely to return non-zero. And when
> > __alloc_pages_may_oom() is called, TIF_MEMDIE is set on the thread waiting
> > for mutex_lock(&"struct inode"->i_mutex) at xfs_file_buffered_aio_write()
> > and I see no further progress.
> 
> Of course - TIF_MEMDIE doesn't do anything to the task that is
> blocked, and the SIGKILL signal can't be delivered until the syscall
> completes or the kernel code checks for pending signals and handles
> EINTR directly. Mutexes are uninterruptible by design so there's no
> EINTR processing, hence the oom killer cannot make progress when
> everything is blocked on mutexes waiting for memory allocation to
> succeed or fail.
> 
> i.e. until the lock holder exists from direct memory reclaim and
> releases the locks it holds, the oom killer will not be able to save
> the system. IOWs, the problem is that memory allocation is not
> failing when it should....
> 
> Focussing on the OOM killer here is the wrong way to solve this
> problem - the problem that needs to be solved is sane handling of
> OOM conditions to avoid needing to invoke the OOM-killer...

Completely agreed!

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
