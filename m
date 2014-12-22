Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 26F416B006C
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 16:31:26 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so6576480pdj.28
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 13:31:25 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id wp13si26556918pac.230.2014.12.22.13.31.22
        for <linux-mm@kvack.org>;
        Mon, 22 Dec 2014 13:31:24 -0800 (PST)
Date: Tue, 23 Dec 2014 08:30:58 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20141222213058.GQ15665@dastard>
References: <20141218153341.GB832@dhcp22.suse.cz>
 <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
 <20141220020331.GM1942@devil.localdomain>
 <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
 <20141220223504.GI15665@dastard>
 <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
 <20141221204249.GL15665@dastard>
 <20141222165736.GB2900@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141222165736.GB2900@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Mon, Dec 22, 2014 at 05:57:36PM +0100, Michal Hocko wrote:
> On Mon 22-12-14 07:42:49, Dave Chinner wrote:
> [...]
> > "memory reclaim gave up"? So why the hell isn't it returning a
> > failure to the caller?
> > 
> > i.e. We have a perfectly good page cache allocation failure error
> > path here all the way back to userspace, but we're invoking the
> > OOM-killer to kill random processes rather than returning ENOMEM to
> > the processes that are generating the memory demand?
> > 
> > Further: when did the oom-killer become the primary method
> > of handling situations when memory allocation needs to fail?
> > __GFP_WAIT does *not* mean memory allocation can't fail - that's what
> > __GFP_NOFAIL means. And none of the page cache allocations use
> > __GFP_NOFAIL, so why aren't we getting an allocation failure before
> > the oom-killer is kicked?
> 
> Well, it has been an unwritten rule that GFP_KERNEL allocations for
> low-order (<=PAGE_ALLOC_COSTLY_ORDER) never fail. This is a long ago
> decision which would be tricky to fix now without silently breaking a
> lot of code. Sad...

Wow.

We have *always* been told memory allocations are not guaranteed to
succeed, ever, unless __GFP_NOFAIL is set, but that's deprecated and
nobody is allowed to use it any more.

Lots of code has dependencies on memory allocation making progress
or failing for the system to work in low memory situations. The page
cache is one of them, which means all filesystems have that
dependency. We don't explicitly ask memory allocations to fail, we
*expect* the memory allocation failures will occur in low memory
conditions. We've been designing and writing code with this in mind
for the past 15 years.

How did we get so far away from the message of "the memory allocator
never guarantees success" that it will never fail to allocate memory
even if it means we livelock the entire system?

> Nevertheless the caller can prevent from an endless loop by using
> __GFP_NORETRY so this could be used as a workaround.

That's just a never-ending game of whack-a-mole that we will
continually lose. It's not a workable solution.

> The default should be opposite IMO and only those who really
> require some guarantee should use a special flag for that purpose.

Yup, totally agree.

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
