Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B349F6B0388
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 16:21:37 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y17so23929496pgh.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 13:21:37 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id q10si1106145plk.101.2017.03.07.13.21.35
        for <linux-mm@kvack.org>;
        Tue, 07 Mar 2017 13:21:36 -0800 (PST)
Date: Wed, 8 Mar 2017 08:21:32 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
Message-ID: <20170307212132.GQ17542@dastard>
References: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
 <20170303133950.GD31582@dhcp22.suse.cz>
 <20170303232512.GI17542@dastard>
 <20170307121503.GJ28642@dhcp22.suse.cz>
 <20170307193659.GD31179@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307193659.GD31179@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 07, 2017 at 02:36:59PM -0500, Tejun Heo wrote:
> Hello,
> 
> On Tue, Mar 07, 2017 at 01:15:04PM +0100, Michal Hocko wrote:
> > > The real problem here is that the XFS code has /no idea/ of what
> > > workqueue context it is operating in - the fact it is in a rescuer
> 
> I don't see how whether something is running off of a rescuer or not
> matters here.  The only thing workqueue guarantees is that there's
> gonna be at least one kworker thread executing work items from the
> workqueue.  Running on a rescuer doesn't necessarily indicate memory
> pressure condition.

That's news to me. In what situations do we run the rescuer thread
other than memory allocation failure when queuing work?

> > > thread is completely hidden from the executing context. It seems to
> > > me that the workqueue infrastructure's responsibility to tell memory
> > > reclaim that the rescuer thread needs special access to the memory
> > > reserves to allow the work it is running to allow forwards progress
> > > to be made. i.e.  setting PF_MEMALLOC on the rescuer thread or
> > > something similar...
> >
> > I am not sure an automatic access to memory reserves from the rescuer
> > context is safe. This sounds too easy to break (read consume all the
> > reserves) - note that we have almost 200 users of WQ_MEM_RECLAIM and
> > chances are some of them will not be careful with the memory
> > allocations. I agree it would be helpful to know that the current item
> > runs from the rescuer context, though. In such a case the implementation
> > can do what ever it takes to make a forward progress. If that is using
> > __GFP_MEMALLOC then be it but it would be at least explicit and well
> > thought through (I hope).
> 
> I don't think doing this automatically is a good idea.  xfs work items
> are free to mark itself PF_MEMALLOC while running tho.

I don't think that's a good idea to do unconditionally.It's quite
common to have IO intensive XFS workloads queue so much work that we
see several /thousand/ kworker threads running at once, even
on realtively small 16p systems.

> It makes sense
> to mark these cases explicitly anyway. 

Doing it on every work we queue will lead to immediate depletion of
memory reserves under heavy IO loads.

> W  can update workqueue code
> so that it automatically clears the flag after each work item
> completion to help.
> 
> > Tejun, would it be possible/reasonable to add current_is_wq_rescuer() API?
> 
> It's implementable for sure.  I'm just not sure how it'd help
> anything.  It's not a relevant information on anything.

Except to enable us to get closer to the "rescuer must make forwards
progress" guarantee. In this context, the rescuer is the only
context we should allow to dip into memory reserves. I'm happy if we
have to explicitly check for that and set PF_MEMALLOC ourselves 
(we do that for XFS kernel threads involved in memory reclaim),
but it's not something we should set automatically on every
IO completion work item we run....

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
