Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2786B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 14:37:02 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id m124so12532549oig.3
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 11:37:02 -0800 (PST)
Received: from mail-ot0-x233.google.com (mail-ot0-x233.google.com. [2607:f8b0:4003:c0f::233])
        by mx.google.com with ESMTPS id o8si507546oih.22.2017.03.07.11.37.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 11:37:01 -0800 (PST)
Received: by mail-ot0-x233.google.com with SMTP id x37so14998995ota.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 11:37:01 -0800 (PST)
Date: Tue, 7 Mar 2017 14:36:59 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
Message-ID: <20170307193659.GD31179@htj.duckdns.org>
References: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
 <20170303133950.GD31582@dhcp22.suse.cz>
 <20170303232512.GI17542@dastard>
 <20170307121503.GJ28642@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307121503.GJ28642@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

Hello,

On Tue, Mar 07, 2017 at 01:15:04PM +0100, Michal Hocko wrote:
> > The real problem here is that the XFS code has /no idea/ of what
> > workqueue context it is operating in - the fact it is in a rescuer

I don't see how whether something is running off of a rescuer or not
matters here.  The only thing workqueue guarantees is that there's
gonna be at least one kworker thread executing work items from the
workqueue.  Running on a rescuer doesn't necessarily indicate memory
pressure condition.

> > thread is completely hidden from the executing context. It seems to
> > me that the workqueue infrastructure's responsibility to tell memory
> > reclaim that the rescuer thread needs special access to the memory
> > reserves to allow the work it is running to allow forwards progress
> > to be made. i.e.  setting PF_MEMALLOC on the rescuer thread or
> > something similar...
>
> I am not sure an automatic access to memory reserves from the rescuer
> context is safe. This sounds too easy to break (read consume all the
> reserves) - note that we have almost 200 users of WQ_MEM_RECLAIM and
> chances are some of them will not be careful with the memory
> allocations. I agree it would be helpful to know that the current item
> runs from the rescuer context, though. In such a case the implementation
> can do what ever it takes to make a forward progress. If that is using
> __GFP_MEMALLOC then be it but it would be at least explicit and well
> thought through (I hope).

I don't think doing this automatically is a good idea.  xfs work items
are free to mark itself PF_MEMALLOC while running tho.  It makes sense
to mark these cases explicitly anyway.  We can update workqueue code
so that it automatically clears the flag after each work item
completion to help.

> Tejun, would it be possible/reasonable to add current_is_wq_rescuer() API?

It's implementable for sure.  I'm just not sure how it'd help
anything.  It's not a relevant information on anything.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
