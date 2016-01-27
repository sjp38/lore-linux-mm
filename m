Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9C36B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:33:51 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l65so147367670wmf.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 06:33:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k128si12530183wma.55.2016.01.27.06.33.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 06:33:50 -0800 (PST)
Date: Wed, 27 Jan 2016 15:33:59 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] proposals for topics
Message-ID: <20160127143359.GC7726@quack.suse.cz>
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <56A63A6C.9070301@I-love.SAKURA.ne.jp>
 <20160126094359.GB27563@dhcp22.suse.cz>
 <201601272244.ICD59441.FOOMSOtQLFVHJF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601272244.ICD59441.FOOMSOtQLFVHJF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Wed 27-01-16 22:44:30, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 26-01-16 00:08:28, Tetsuo Handa wrote:
> > [...]
> > > If it turned out that we are using GFP_NOFS from LSM hooks correctly,
> > > I'd expect such GFP_NOFS allocations retry unless SIGKILL is pending.
> > > Filesystems might be able to handle GFP_NOFS allocation failures. But
> > > userspace might not be able to handle system call failures caused by
> > > GFP_NOFS allocation failures; OOM-unkillable processes might unexpectedly
> > > terminate as if they are OOM-killed. Would you please add GFP_KILLABLE
> > > to list of the topics?
> > 
> > Are there so many places to justify a flag? Isn't it easier to check for
> > fatal_signal_pending in the failed path and do the retry otherwise? This
> > allows for a more flexible fallback strategy - e.g. drop the locks and
> > retry again, sleep for reasonable time, wait for some event etc... This
> > sounds much more extensible than a single flag burried down in the
> > allocator path.
> 
> If you allow any in-kernel code to directly call out_of_memory(), I'm
> OK with that.
> 
> I consider that whether to invoke the OOM killer should not be determined
> based on ability to reclaim memory; it should be determined based on
> importance and/or purpose of that memory allocation request.

Well, in my opinion that's fairly difficult to judge at the site doing the
memory allocation. E.g. is it better to loop in allocator to be able to
satisfy allocation request to do IO, or is it better to fail the IO with
error, or is it better to invoke OOM killer to free some memory and then do
the IO? Who knows... This is a policy decision and as such it is better
done by the administrator and there should be one common place to tune such
things. Not call sites spread around the kernel...

> We allocate memory on behalf of userspace processes. If a userspace process
> asks for a page via page fault, we are using __GFP_FS. If in-kernel code
> does something on behalf of a userspace process, we should use __GFP_FS.
> 
> Forcing in-kernel code to use !__GFP_FS allocation requests is a hack for
> workarounding inconvenient circumstances in memory allocation (memory
> reclaim deadlock) which is not fault of userspace processes.

It is as if you said that using GFP_ATOMIC allocation is a hack for device
drivers to do allocation in atomic context. It is a reality of kernel
programming that you sometimes have to do allocation in restricted context.
One kind of this restricted context is that you cannot recurse back into
the filesystem to free memory. I see nothing hacky in it.

> Userspace controls oom_score_adj and makes a bet between processes.
> If process A wins, the OOM killer kills process B, and process A gets memory.
> If process B wins, the OOM killer kills process A, and process B gets memory.
> Not invoking the OOM killer due to lack of __GFP_FS is something like forcing
> processes to use oom_kill_allocating_task = 1.
> 
> Therefore, since __GFP_KILLABLE does not exist and out_of_memory() is not
> exported, I'll change my !__GFP_FS allocation requests to __GFP_NOFAIL
> (in order to allow processes to make a bet) if mm people change small !__GFP_FS
> allocation requests to fail upon OOM. Note that there is no need to retry such
> __GFP_NOFAIL allocation requests if SIGKILL is pending, but __GFP_NOFAIL does
> not allow fail upon SIGKILL. __GFP_KILLABLE (with current "no-fail unless chosen
> by the OOM killer" behavior) will handle it perfectly.

So GFP_KILLABLE with GFP_NOFAIL combination actually makes sense to me.
Although most of the places I'm aware of which need GFP_NOFAIL wouldn't use
GFP_KILLABLE either - they are places where we have two options:

1) lose user data without a way to tell that back to the user

2) allocate more memory

And from these two options, looping trying option 2) and hoping that
someone will solve the problem for us is the best we can do.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
