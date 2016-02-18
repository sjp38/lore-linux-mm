Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id DCC04828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 06:21:15 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id jq7so61257937obb.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 03:21:15 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id b9si8750196oif.3.2016.02.18.03.21.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 03:21:15 -0800 (PST)
Subject: Re: [PATCH 2/6] mm,oom: don't abort on exiting processes when selecting a victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160217140006.GM29196@dhcp22.suse.cz>
	<201602172339.JBJ57868.tSQVJLHMFFOOFO@I-love.SAKURA.ne.jp>
	<20160217150127.GR29196@dhcp22.suse.cz>
	<201602180029.HHG73447.QSFOHJOtLVOFFM@I-love.SAKURA.ne.jp>
	<20160217161742.GS29196@dhcp22.suse.cz>
In-Reply-To: <20160217161742.GS29196@dhcp22.suse.cz>
Message-Id: <201602182021.EEH86916.JOLtFFVHOOMQFS@I-love.SAKURA.ne.jp>
Date: Thu, 18 Feb 2016 20:21:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > We want to teach the OOM reaper to
> > operate whenever TIF_MEMDIE is set. But this means that we want
> > mm_is_reapable() check because there might be !SIGKILL && !PF_EXITING
> > threads when we run these optimized paths.
>
> > We will need to use timer if mm_is_reapable() == false after all.
>
> Or we should re-evaluate those heuristics for multithreaded processes.

TIF_MEMDIE heuristics are per a task_struct basis but OOM-kill operation
is per a signal_struct basis or per a mm_struct basis.

Since we set TIF_MEMDIE to only one thread (with a wrong assumption that
remaining threads will get TIF_MEMDIE due to fatal_signal_pending()),
we are bothered by corner cases.

> Does it even make sense to shortcut and block the OOM killer if the
> single thread is exiting?

Do we check for clone(!CLONE_SIGHAND && CLONE_VM) threads (i.e. walk the
process list) for checking whether it is really a single thread?
That would be mm_is_reapable().

>                           Only very small amount of memory gets released
> during its exit anyway.

Currently exit_mm() is called before exit_files() etc. are called.
Can we expect a single page of memory being released when such thread
gets stuck at down_read(&mm->mmap_sem) ?

>                         Don't we want to catch only the group exit to
> catch fatal_signal_pending -> exit_signals -> exit_mm -> allocation
> cases? I am not really sure what to check for, to be honest though.
>

I don't know what this line is saying.

> > Why don't you accept timer based workaround now, even if you have a plan
> > to update the OOM reaper for handling these optimized paths?
>
> Because I believe that the timeout based solutions are distracting from
> a proper solution which would be based on actual algorithm/heurstic that
> can be measured and evaluated. And because I can see future discussion
> of whether $FOO or $BAR is a better timeout... I really do not see any
> reason to rush into quick solutions now.

OOM-livelock bugs are caused by over-throttling based on optimistic
assumptions. This [PATCH 5/6] patch is for unthrottling in order to
guarantee forward progress (and eventually trigger kernel panic if
there is no more OOM-killable processes).

I can't see future discussion of whether $FOO or $BAR is a better timeout
because timeout based unthrottling should seldom occur. Even without the
OOM reaper, more than e.g. 99% of innocent OOM events would successfully
solve the OOM condition before this timeout expires. After we merge the
OOM reaper, more than e.g. 99% of malicious OOM events would successfully
solve the OOM condition before this timeout expires. Who can gather data
for discussing whether $FOO or $BAR is a better timeout? Only those who want
to explore this e.g. 1% possibility and those who hate any timeout would
want to disable this timeout.

If we make sure that timeout based unthrottling guarantees forward
progress, we can try to utilize memory reserves more aggressively.
For example, we can set TIF_MEMDIE on all fatal_signal_pending() threads
using a mm_struct chosen by the OOM killer. This will eliminate a wrong
assumption that remaining threads will get TIF_MEMDIE due to
fatal_signal_pending(). We had been too cowardly about use of memory
reserves because currently we have no means to refill the memory reserves.
If timeout based unthrottling kills next OOM victim (and the OOM reaper
reaps it), we can overcommit memory reserves (like we overcommit normal
memory).

I don't think we can manage without timeout based solutions.
I really do not see any reason not to accept [PATCH 5/6] now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
