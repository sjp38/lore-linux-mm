Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 475206B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 18:25:17 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 77so3642948pgc.5
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 15:25:17 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id f17si11846010pgh.74.2017.03.03.15.25.15
        for <linux-mm@kvack.org>;
        Fri, 03 Mar 2017 15:25:16 -0800 (PST)
Date: Sat, 4 Mar 2017 10:25:12 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
Message-ID: <20170303232512.GI17542@dastard>
References: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
 <20170303133950.GD31582@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303133950.GD31582@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 03, 2017 at 02:39:51PM +0100, Michal Hocko wrote:
> On Fri 03-03-17 19:48:30, Tetsuo Handa wrote:
> > Continued from http://lkml.kernel.org/r/201702261530.JDD56292.OFOLFHQtVMJSOF@I-love.SAKURA.ne.jp :
> > 
> > While I was testing a patch which avoids infinite too_many_isolated() loop in
> > shrink_inactive_list(), I hit a lockup where WQ_MEM_RECLAIM threads got stuck
> > waiting for memory allocation. I guess that we overlooked a basic thing about
> > WQ_MEM_RECLAIM.
> > 
> >   WQ_MEM_RECLAIM helps only when the cause of failing to complete
> >   a work item is lack of "struct task_struct" to run that work item, for
> >   WQ_MEM_RECLAIM preallocates one "struct task_struct" so that the workqueue
> >   will not be blocked waiting for memory allocation for "struct task_struct".
> > 
> >   WQ_MEM_RECLAIM does not help when "struct task_struct" running that work
> >   item is blocked waiting for memory allocation (or is indirectly blocked
> >   on a lock where the owner of that lock is blocked waiting for memory
> >   allocation). That is, WQ_MEM_RECLAIM users must guarantee forward progress
> >   if memory allocation (including indirect memory allocation via
> >   locks/completions) is needed.
> > 
> > In XFS, "xfs_mru_cache", "xfs-buf/%s", "xfs-data/%s", "xfs-conv/%s", "xfs-cil/%s",
> > "xfs-reclaim/%s", "xfs-log/%s", "xfs-eofblocks/%s", "xfsalloc" and "xfsdiscard"
> > workqueues are used, and all but "xfsdiscard" are WQ_MEM_RECLAIM workqueues.
> > 
> > What I observed is at http://I-love.SAKURA.ne.jp/tmp/serial-20170226.txt.xz .
> > I guess that the key of this lockup is that xfs-data/sda1 and xfs-eofblocks/s
> > workqueues (which are RESCUER) got stuck waiting for memory allocation.
> 
> If those workers are really required for a further progress of the
> memory reclaim then they shouldn't block on allocation at all and either
> use pre allocated memory or use PF_MEMALLOC in case there is a guarantee
> that only very limited amount of memory is allocated from that context
> and there will be at least the same amount of memory freed as a result
> in a reasonable time.
> 
> This is something for xfs people to answer though. Please note that I
> didn't really have time to look through the below traces so the above
> note is rather generic. It would be really helpful if you could provide
> a high level dependency chains to see why those rescuers are necessary
> for the forward progress because it is really easy to get lost in so
> many traces.

Data IO completion is required to make progress to free memory. IO
completion is done via work queues, so they need rescuer threads to
ensure work can be run.

IO completion can require transactions to run. Transactions require
memory allocation. Freeing memory therefore requires IO completion
to have access to memory reserves if it's occurring from rescuer
threads to allow progress to be made.

That means metadata IO completion require rescuer threads, because
data IO completion can be dependent on metadata buffers being
available. e.g. reserving space in the log for the transaction can
require waiting on metadata IO dispatch and completion. Hence the
buffer IO completion workqueues need rescuer threads.

Transactions can also require log forces and flushes to occur, which
means they require the log workqueues (both the CIL flush and IO
completion workqueues) to make progress.  Log flushes also require
both IO and memory allocation to make progress to complete. Again,
this means the log workqueues need rescuer threads. It also needs
the log workqueues to be high priority so that they can make
progress before IO completion work that is dependent on
transactions making progress are processed.

IOWs, pretty much all the XFS workqueues are involved in memory
reclaim in one way or another.

The real problem here is that the XFS code has /no idea/ of what
workqueue context it is operating in - the fact it is in a rescuer
thread is completely hidden from the executing context. It seems to
me that the workqueue infrastructure's responsibility to tell memory
reclaim that the rescuer thread needs special access to the memory
reserves to allow the work it is running to allow forwards progress
to be made. i.e.  setting PF_MEMALLOC on the rescuer thread or
something similar...

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
