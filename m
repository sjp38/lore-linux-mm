Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63BE66B0387
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 07:15:07 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n11so767914wma.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 04:15:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si13567057wrt.162.2017.03.07.04.15.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 04:15:05 -0800 (PST)
Date: Tue, 7 Mar 2017 13:15:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
Message-ID: <20170307121503.GJ28642@dhcp22.suse.cz>
References: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
 <20170303133950.GD31582@dhcp22.suse.cz>
 <20170303232512.GI17542@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303232512.GI17542@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Tejun Heo <tj@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

[Let's add Tejun]

On Sat 04-03-17 10:25:12, Dave Chinner wrote:
> On Fri, Mar 03, 2017 at 02:39:51PM +0100, Michal Hocko wrote:
> > On Fri 03-03-17 19:48:30, Tetsuo Handa wrote:
> > > Continued from http://lkml.kernel.org/r/201702261530.JDD56292.OFOLFHQtVMJSOF@I-love.SAKURA.ne.jp :
> > > 
> > > While I was testing a patch which avoids infinite too_many_isolated() loop in
> > > shrink_inactive_list(), I hit a lockup where WQ_MEM_RECLAIM threads got stuck
> > > waiting for memory allocation. I guess that we overlooked a basic thing about
> > > WQ_MEM_RECLAIM.
> > > 
> > >   WQ_MEM_RECLAIM helps only when the cause of failing to complete
> > >   a work item is lack of "struct task_struct" to run that work item, for
> > >   WQ_MEM_RECLAIM preallocates one "struct task_struct" so that the workqueue
> > >   will not be blocked waiting for memory allocation for "struct task_struct".
> > > 
> > >   WQ_MEM_RECLAIM does not help when "struct task_struct" running that work
> > >   item is blocked waiting for memory allocation (or is indirectly blocked
> > >   on a lock where the owner of that lock is blocked waiting for memory
> > >   allocation). That is, WQ_MEM_RECLAIM users must guarantee forward progress
> > >   if memory allocation (including indirect memory allocation via
> > >   locks/completions) is needed.
> > > 
> > > In XFS, "xfs_mru_cache", "xfs-buf/%s", "xfs-data/%s", "xfs-conv/%s", "xfs-cil/%s",
> > > "xfs-reclaim/%s", "xfs-log/%s", "xfs-eofblocks/%s", "xfsalloc" and "xfsdiscard"
> > > workqueues are used, and all but "xfsdiscard" are WQ_MEM_RECLAIM workqueues.
> > > 
> > > What I observed is at http://I-love.SAKURA.ne.jp/tmp/serial-20170226.txt.xz .
> > > I guess that the key of this lockup is that xfs-data/sda1 and xfs-eofblocks/s
> > > workqueues (which are RESCUER) got stuck waiting for memory allocation.
> > 
> > If those workers are really required for a further progress of the
> > memory reclaim then they shouldn't block on allocation at all and either
> > use pre allocated memory or use PF_MEMALLOC in case there is a guarantee
> > that only very limited amount of memory is allocated from that context
> > and there will be at least the same amount of memory freed as a result
> > in a reasonable time.
> > 
> > This is something for xfs people to answer though. Please note that I
> > didn't really have time to look through the below traces so the above
> > note is rather generic. It would be really helpful if you could provide
> > a high level dependency chains to see why those rescuers are necessary
> > for the forward progress because it is really easy to get lost in so
> > many traces.
> 
> Data IO completion is required to make progress to free memory. IO
> completion is done via work queues, so they need rescuer threads to
> ensure work can be run.
> 
> IO completion can require transactions to run. Transactions require
> memory allocation. Freeing memory therefore requires IO completion
> to have access to memory reserves if it's occurring from rescuer
> threads to allow progress to be made.
> 
> That means metadata IO completion require rescuer threads, because
> data IO completion can be dependent on metadata buffers being
> available. e.g. reserving space in the log for the transaction can
> require waiting on metadata IO dispatch and completion. Hence the
> buffer IO completion workqueues need rescuer threads.
> 
> Transactions can also require log forces and flushes to occur, which
> means they require the log workqueues (both the CIL flush and IO
> completion workqueues) to make progress.  Log flushes also require
> both IO and memory allocation to make progress to complete. Again,
> this means the log workqueues need rescuer threads. It also needs
> the log workqueues to be high priority so that they can make
> progress before IO completion work that is dependent on
> transactions making progress are processed.
> 
> IOWs, pretty much all the XFS workqueues are involved in memory
> reclaim in one way or another.
> 
> The real problem here is that the XFS code has /no idea/ of what
> workqueue context it is operating in - the fact it is in a rescuer
> thread is completely hidden from the executing context. It seems to
> me that the workqueue infrastructure's responsibility to tell memory
> reclaim that the rescuer thread needs special access to the memory
> reserves to allow the work it is running to allow forwards progress
> to be made. i.e.  setting PF_MEMALLOC on the rescuer thread or
> something similar...

I am not sure an automatic access to memory reserves from the rescuer
context is safe. This sounds too easy to break (read consume all the
reserves) - note that we have almost 200 users of WQ_MEM_RECLAIM and
chances are some of them will not be careful with the memory
allocations. I agree it would be helpful to know that the current item
runs from the rescuer context, though. In such a case the implementation
can do what ever it takes to make a forward progress. If that is using
__GFP_MEMALLOC then be it but it would be at least explicit and well
thought through (I hope).

Tejun, would it be possible/reasonable to add current_is_wq_rescuer() API?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
