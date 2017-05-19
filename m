Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E7229280753
	for <linux-mm@kvack.org>; Fri, 19 May 2017 19:43:49 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c15so55999650ith.7
        for <linux-mm@kvack.org>; Fri, 19 May 2017 16:43:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f80si10966579ioj.36.2017.05.19.16.43.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 16:43:48 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the #PF
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170519112604.29090-3-mhocko@kernel.org>
	<201705192202.EDD30719.OSLJHFMOFtFVOQ@I-love.SAKURA.ne.jp>
	<20170519132209.GG29839@dhcp22.suse.cz>
	<201705200022.BFJ12428.JFOSMLFOtFHOVQ@I-love.SAKURA.ne.jp>
	<20170519155057.GM29839@dhcp22.suse.cz>
In-Reply-To: <20170519155057.GM29839@dhcp22.suse.cz>
Message-Id: <201705200843.HAI95393.FQSFLOHVMJtOFO@I-love.SAKURA.ne.jp>
Date: Sat, 20 May 2017 08:43:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, guro@fb.com, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sat 20-05-17 00:22:30, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 19-05-17 22:02:44, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > Any allocation failure during the #PF path will return with VM_FAULT_OOM
> > > > > which in turn results in pagefault_out_of_memory. This can happen for
> > > > > 2 different reasons. a) Memcg is out of memory and we rely on
> > > > > mem_cgroup_oom_synchronize to perform the memcg OOM handling or b)
> > > > > normal allocation fails.
> > > > > 
> > > > > The later is quite problematic because allocation paths already trigger
> > > > > out_of_memory and the page allocator tries really hard to not fail
> > > > 
> > > > We made many memory allocation requests from page fault path (e.g. XFS)
> > > > __GFP_FS some time ago, didn't we? But if I recall correctly (I couldn't
> > > > find the message), there are some allocation requests from page fault path
> > > > which cannot use __GFP_FS. Then, not all allocation requests can call
> > > > oom_kill_process() and reaching pagefault_out_of_memory() will be
> > > > inevitable.
> > > 
> > > Even if such an allocation fail without the OOM killer then we simply
> > > retry the PF and will do that the same way how we keep retrying the
> > > allocation inside the page allocator. So how is this any different?
> > 
> > You are trying to remove out_of_memory() from pagefault_out_of_memory()
> > by this patch. But you also want to make !__GFP_FS allocations not to
> > keep retrying inside the page allocator in future kernels, don't you?
> 
> I would _love_ to but I am much less optimistic this is achiveable
> 
> > Then, a thread which need to allocate memory from page fault path but
> > cannot call oom_kill_process() will spin forever (unless somebody else
> > calls oom_kill_process() via a __GFP_FS allocation request). I consider
> > that introducing such possibility is a problem.
> 
> What I am trying to say is that this is already happening. The
> difference with the VM_FAULT_OOM would only be that the whole PF path
> would be unwinded back to the PF, all locks dropped and then the PF
> retries so in principle this would be safer.

I can't understand why the PF retries helps. If the PF has to be retried due to
failing to allocate memory, situation will not improve until memory is allocated.
And I don't like an assumption that somebody else calls oom_kill_process() via
a __GFP_FS allocation request so that the PF will succeed without calling
oom_kill_process().

> 
> > > > > allocations. Anyway, if the OOM killer has been already invoked there
> > > > > is no reason to invoke it again from the #PF path. Especially when the
> > > > > OOM condition might be gone by that time and we have no way to find out
> > > > > other than allocate.
> > > > > 
> > > > > Moreover if the allocation failed and the OOM killer hasn't been
> > > > > invoked then we are unlikely to do the right thing from the #PF context
> > > > > because we have already lost the allocation context and restictions and
> > > > > therefore might oom kill a task from a different NUMA domain.
> > > > 
> > > > If we carry a flag via task_struct that indicates whether it is an memory
> > > > allocation request from page fault and allocation failure is not acceptable,
> > > > we can call out_of_memory() from page allocator path.
> > > 
> > > I do not understand
> > 
> > We need to allocate memory from page fault path in order to avoid spinning forever
> > (unless somebody else calls oom_kill_process() via a __GFP_FS allocation request),
> > doesn't it? Then, memory allocation requests from page fault path can pass flags
> > like __GFP_NOFAIL | __GFP_KILLABLE because retrying the page fault without
> > allocating memory is pointless. I called such flags as carry a flag via task_struct.
> > 
> > > > By the way, can page fault occur after reaching do_exit()? When a thread
> > > > reached do_exit(), fatal_signal_pending(current) becomes false, doesn't it?
> > > 
> > > yes fatal_signal_pending will be false at the time and I believe we can
> > > perform a page fault past that moment  and go via allocation path which would
> > > trigger the OOM or give this task access to reserves but it is more
> > > likely that the oom reaper will push to kill another task by that time
> > > if the situation didn't get resolved. Or did I miss your concern?
> > 
> > How checking fatal_signal_pending() here helps?
> 
> It just skips the warning because we know that we would handle the
> signal before retrying the page fault and go to exit path. Those that do
> not have such a signal should warn just that we know that such a
> situation happens. With the current allocator semantic it shouldn't
> 
> > It only suppresses printk().
> > If current thread needs to allocate memory because not all allocation requests
> > can call oom_kill_process(), doing printk() is not the right thing to do.
> > Allocate memory by some means (e.g. __GFP_NOFAIL | __GFP_KILLABLE) will be
> > the right thing to do.
> 
> Why would looping inside an allocator with a restricted context be any
> better than retrying the whole thing?

I'm not suggesting you to loop inside an allocator nor retry the whole thing.
I'm suggesting you to avoid returning VM_FAULT_OOM by making allocations succeed
(by e.g. calling oom_kill_process()) regardless of restricted context if you
want to remove out_of_memory() from pagefault_out_of_memory(), for situation
will not improve until memory is allocated (e.g. somebody else calls
oom_kill_process() via a __GFP_FS allocation request).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
