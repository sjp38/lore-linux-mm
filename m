Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id BAC756B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 08:44:37 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id z14so80915955igp.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 05:44:37 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g139si11797155ioe.82.2016.01.27.05.44.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 05:44:36 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] proposals for topics
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160125133357.GC23939@dhcp22.suse.cz>
	<56A63A6C.9070301@I-love.SAKURA.ne.jp>
	<20160126094359.GB27563@dhcp22.suse.cz>
In-Reply-To: <20160126094359.GB27563@dhcp22.suse.cz>
Message-Id: <201601272244.ICD59441.FOOMSOtQLFVHJF@I-love.SAKURA.ne.jp>
Date: Wed, 27 Jan 2016 22:44:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Michal Hocko wrote:
> On Tue 26-01-16 00:08:28, Tetsuo Handa wrote:
> [...]
> > If it turned out that we are using GFP_NOFS from LSM hooks correctly,
> > I'd expect such GFP_NOFS allocations retry unless SIGKILL is pending.
> > Filesystems might be able to handle GFP_NOFS allocation failures. But
> > userspace might not be able to handle system call failures caused by
> > GFP_NOFS allocation failures; OOM-unkillable processes might unexpectedly
> > terminate as if they are OOM-killed. Would you please add GFP_KILLABLE
> > to list of the topics?
> 
> Are there so many places to justify a flag? Isn't it easier to check for
> fatal_signal_pending in the failed path and do the retry otherwise? This
> allows for a more flexible fallback strategy - e.g. drop the locks and
> retry again, sleep for reasonable time, wait for some event etc... This
> sounds much more extensible than a single flag burried down in the
> allocator path.

If you allow any in-kernel code to directly call out_of_memory(), I'm
OK with that.

I consider that whether to invoke the OOM killer should not be determined
based on ability to reclaim memory; it should be determined based on
importance and/or purpose of that memory allocation request.

We allocate memory on behalf of userspace processes. If a userspace process
asks for a page via page fault, we are using __GFP_FS. If in-kernel code
does something on behalf of a userspace process, we should use __GFP_FS.

Forcing in-kernel code to use !__GFP_FS allocation requests is a hack for
workarounding inconvenient circumstances in memory allocation (memory
reclaim deadlock) which is not fault of userspace processes.

Userspace controls oom_score_adj and makes a bet between processes.
If process A wins, the OOM killer kills process B, and process A gets memory.
If process B wins, the OOM killer kills process A, and process B gets memory.
Not invoking the OOM killer due to lack of __GFP_FS is something like forcing
processes to use oom_kill_allocating_task = 1.

Therefore, since __GFP_KILLABLE does not exist and out_of_memory() is not
exported, I'll change my !__GFP_FS allocation requests to __GFP_NOFAIL
(in order to allow processes to make a bet) if mm people change small !__GFP_FS
allocation requests to fail upon OOM. Note that there is no need to retry such
__GFP_NOFAIL allocation requests if SIGKILL is pending, but __GFP_NOFAIL does
not allow fail upon SIGKILL. __GFP_KILLABLE (with current "no-fail unless chosen
by the OOM killer" behavior) will handle it perfectly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
