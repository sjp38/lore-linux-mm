Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEAE6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 09:36:52 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id p187so6140589oia.2
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 06:36:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id bv7si5363515oec.61.2016.01.20.06.36.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 06:36:50 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1601141400170.16227@chino.kir.corp.google.com>
	<20160114225850.GA23382@cmpxchg.org>
	<alpine.DEB.2.10.1601141500370.22665@chino.kir.corp.google.com>
	<201601151936.IJJ09362.OOFLtVFJHSFQMO@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1601191502230.7346@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1601191502230.7346@chino.kir.corp.google.com>
Message-Id: <201601202336.BJC04687.FOFVOQJOLSFtMH@I-love.SAKURA.ne.jp>
Date: Wed, 20 Jan 2016 23:36:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes wrote:
> On Fri, 15 Jan 2016, Tetsuo Handa wrote:
> 
> > Leaving a system OOM-livelocked forever is very very annoying thing.
> 
> Agreed.
> 
> > My goal is to ask the OOM killer not to toss the OOM killer's duty away.
> > What is important for me is that the OOM killer takes next action when
> > current action did not solve the OOM situation.
> > 
> 
> What is the "next action" when there are no more processes on your system, 

Just call panic(), as with select_bad_process() from out_of_memory() returned
NULL.

> or attached to your memcg hierarchy, that are killable?

I think we have nothing to do for mem_cgroup_out_of_memory() case.



> The final solution may combine both approaches, which are the only real 
> approaches on how to make forward progress.  We could first try allowing 
> temporary access to memory reserves when a livelock has been detected, 
> similar to my patch, and then fallback to killing additional processes 
> since the oom reaper should be able to at least free some of that memory 
> immediately, if it fails.

If we can agree on combining both approaches, I'm OK with it. That will keep
the OOM reaper simple, for the OOM reaper will not need to clear TIF_MEMDIE
flag which is unfriendly for wait_event() in oom_killer_disable(), and the
OOM reaper will not need to care about situations where TIF_MEMDIE flag is
set when it is not safe to reap.

What we need to do before "fallback to killing additional processes" is
make sure that the OOM killer won't select processes which already have
TIF_MEMDIE flag, as with SysRq-f case.

> 
> However, I think the best course of action at the moment is to review and 
> get the oom reaper merged, if applicable, since it should greatly aid this 
> issue and then look at livelock issues as they arise once it is deployed.  
> I'm not enthusiastic about adding additional heuristics and tunables for 
> theoretical issues that may arise, especially considering the oom reaper 
> is not even upstream.
> 

We already know there is a flaw. For example,

	if (current->mm &&
	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
		mark_oom_victim(current);
		return true;
	}

in out_of_memory() omits sending SIGKILL to processes sharing same memory
when current process received SIGKILL by now (but that SIGKILL was not sent
by oom_kill_process()) or current thread is exiting normally, which can result
in problems which "Kill all user processes sharing victim->mm in other thread
groups, if any." tried to avoid. And the OOM reaper does not help because the
OOM reaper does not know whether it is safe to reap memory used by current
thread.

I think we should decide what to do for managing (or papering over) such
corner cases before we get the OOM reaper merged. I'm OK with combination of
your global access to memory reserves and my OOM killer re-enabling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
