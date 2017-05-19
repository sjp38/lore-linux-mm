Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5552806DC
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:22:13 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g67so5156162wrd.0
        for <linux-mm@kvack.org>; Fri, 19 May 2017 06:22:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d34si8104704ede.101.2017.05.19.06.22.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 06:22:12 -0700 (PDT)
Date: Fri, 19 May 2017 15:22:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the
 #PF
Message-ID: <20170519132209.GG29839@dhcp22.suse.cz>
References: <20170519112604.29090-1-mhocko@kernel.org>
 <20170519112604.29090-3-mhocko@kernel.org>
 <201705192202.EDD30719.OSLJHFMOFtFVOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201705192202.EDD30719.OSLJHFMOFtFVOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, guro@fb.com, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 19-05-17 22:02:44, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Any allocation failure during the #PF path will return with VM_FAULT_OOM
> > which in turn results in pagefault_out_of_memory. This can happen for
> > 2 different reasons. a) Memcg is out of memory and we rely on
> > mem_cgroup_oom_synchronize to perform the memcg OOM handling or b)
> > normal allocation fails.
> > 
> > The later is quite problematic because allocation paths already trigger
> > out_of_memory and the page allocator tries really hard to not fail
> 
> We made many memory allocation requests from page fault path (e.g. XFS)
> __GFP_FS some time ago, didn't we? But if I recall correctly (I couldn't
> find the message), there are some allocation requests from page fault path
> which cannot use __GFP_FS. Then, not all allocation requests can call
> oom_kill_process() and reaching pagefault_out_of_memory() will be
> inevitable.

Even if such an allocation fail without the OOM killer then we simply
retry the PF and will do that the same way how we keep retrying the
allocation inside the page allocator. So how is this any different?

> > allocations. Anyway, if the OOM killer has been already invoked there
> > is no reason to invoke it again from the #PF path. Especially when the
> > OOM condition might be gone by that time and we have no way to find out
> > other than allocate.
> > 
> > Moreover if the allocation failed and the OOM killer hasn't been
> > invoked then we are unlikely to do the right thing from the #PF context
> > because we have already lost the allocation context and restictions and
> > therefore might oom kill a task from a different NUMA domain.
> 
> If we carry a flag via task_struct that indicates whether it is an memory
> allocation request from page fault and allocation failure is not acceptable,
> we can call out_of_memory() from page allocator path.

I do not understand

> > -	if (!mutex_trylock(&oom_lock))
> > +	if (fatal_signal_pending)
> 
> fatal_signal_pending(current)

right, fixed

> By the way, can page fault occur after reaching do_exit()? When a thread
> reached do_exit(), fatal_signal_pending(current) becomes false, doesn't it?

yes fatal_signal_pending will be false at the time and I believe we can
perform a page fault past that moment  and go via allocation path which would
trigger the OOM or give this task access to reserves but it is more
likely that the oom reaper will push to kill another task by that time
if the situation didn't get resolved. Or did I miss your concern?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
