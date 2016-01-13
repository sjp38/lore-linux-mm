Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 67AD5828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 07:11:45 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id ik10so170065492igb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 04:11:45 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t8si22041814igd.29.2016.01.13.04.11.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jan 2016 04:11:44 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1601121717220.17063@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1601121717220.17063@chino.kir.corp.google.com>
Message-Id: <201601132111.GIG81705.LFOOHFOtQJSMVF@I-love.SAKURA.ne.jp>
Date: Wed, 13 Jan 2016 21:11:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

David Rientjes wrote:
> I'm not sure why you are proposing adding both of these in the same patch; 
> they have very different usecases and semantics.

Because both of these are for tuning the OOM killer.



> 
> oomkiller_holdoff_ms, as indicated by the changelog, seems to be 
> correcting some deficiency in the oom reaper.

It is not deficiency in the OOM reaper but deficiency in the OOM killer
or in the page allocator.

>                                                I haven't reviewed that, 
> but it seems like something that wouldn't need to be fixed with a 
> timeout-based solution.

The problem is that it takes some amount of time to return memory to
freelist after memory was reclaimed. Unless we add a callback mechanism
for notifying that the memory used by TIF_MEMDIE task was reclaimed and
returned to freelist, there is no means to fix this problem.

>                          We either know if we have completed oom reaping 
> or we haven't, it is something we should easily be able to figure out and 
> not require heuristics such as this.
> 
> This does not seem to have anything to do with current upstream code that 
> does not have the oom reaper since the oom killer clearly has 
> synchronization through oom_lock and we carefully defer for TIF_MEMDIE 
> processes and abort for those that have not yet fully exited to free its 
> memory.  If patches are going to be proposed on top of the oom reaper, 
> please explicitly state that.

The OOM reaper is irrelevant. The OOM reaper is merely an accelerator for
reclaiming memory earlier than now.

> 
> I believe any such race described in the changelog could be corrected by 
> deferring the oom killer entirely until the oom reaper has been able to 
> free memory or the oom victim has fully exited.  I haven't reviewed that, 
> so I can't speak definitively, but I think we should avoid _any_ timeout 
> based solution if possible and there's no indication this is the only way 
> to solve such a problem.

The OOM killer can not know when the reclaimed memory is returned to freelist
(and therefore get_page_from_freelist() might succeed).

Currently timeout is the only way to mitigate this problem.



> 
> oomkiller_victim_wait_ms seems to be another manifestation of the same 
> patch which has been nack'd over and over again.

I believe the situation is changing due to introduction of the OOM reaper.

>                                                   It does not address the 
> situation where there are no additional eligible processes to kill and we 
> end up panicking the machine when additional access to memory reserves may 
> have allowed the victim to exit.  Randomly killing additional processes 
> makes that problem worse since if they cannot exit (which may become more 
> likely than not if all victims are waiting on a mutex held by an 
> allocating thread).
> 
> My solution for that has always been to grant allocating threads temporary 
> access to memory reserves in the hope that the mutex be dropped and the 
> victim may make forward progress.  We have this implemented internally and 
> I've posted a test module that easily exhibits the problem and how it is 
> fixed.

Those who use panic_on_oom = 1 expect that the system triggers kernel panic
rather than stall forever. This is a translation of administrator's wish that
"Please press SysRq-c on behalf of me if the memory exhausted. In that way,
I don't need to stand by in front of the console twenty-four seven."

Those who use panic_on_oom = 0 expect that the OOM killer solves OOM condition
rather than stall forever. This is a translation of administrator's wish that
"Please press SysRq-f on behalf of me if the memory exhausted. In that way,
I don't need to stand by in front of the console twenty-four seven."

However, since the OOM killer never presses SysRq-f again until the OOM
victim terminates, this is annoying administrators.

  Administrator:  "I asked you to press SysRq-f on behalf of me. Why did you
                   let the system stalled forever?"

  The OOM killer: "I did. The system did not recover from OOM condition."

  Administrator:  "Why you don't try pressing SysRq-f again on behalf of me?"

  The OOM killer: "I am not programmed to do so."

  Administrator:  "You are really inattentive assistant. OK. Here is a patch
                   that programs you to press SysRq-f again on behalf of me."

What I want to say to the OOM killer is "Please don't toss the OOM killer's
duty away." when the OOM killer answered "I did something with a hope that
OOM condition is solved". And MM people are still NACKing administrator's
innocent wish.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
