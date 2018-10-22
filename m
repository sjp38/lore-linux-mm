Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1076B000D
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 17:11:14 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bb3-v6so9276463plb.20
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 14:11:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i90-v6sor19138509pli.26.2018.10.22.14.11.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 14:11:13 -0700 (PDT)
Date: Mon, 22 Oct 2018 14:11:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: Use timeout based back off.
In-Reply-To: <1540033021-3258-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.21.1810221406400.120157@chino.kir.corp.google.com>
References: <1540033021-3258-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On Sat, 20 Oct 2018, Tetsuo Handa wrote:

> This patch changes the OOM killer to wait for either
> 
>   (A) __mmput() of the OOM victim's mm completes
> 
> or
> 
>   (B) the OOM reaper gives up waiting for (A) because memory pages
>       used by the OOM victim's mm did not decrease for one second
> 
> in order to mitigate at least three problems
> 
>   (1) an OOM victim needlessly selects next OOM victim if the OOM-killed
>       processes are using clone(CLONE_VM) without CLONE_THREAD because
>       task_will_free_mem(current) in out_of_memory() returns false when
>       MMF_OOM_SKIP was set before remaining OOM-killed processes reach
>       out_of_memory().
> 
>   (2) an memcg OOM event needlessly selects next OOM victim because we
>       are assuming that the OOM reaper can reclaim majority of the OOM
>       victim's mm, but sometimes we need to wait for completion of
>       free_pgtables() in exit_mmap() in order to reclaim enough memory.
> 
>   (3) an memcg OOM event from a multithreaded process by an unprivileged
>       user can needlessly trigger flooding of "Out of memory and no
>       killable processes..." and dump_header() messages because
>       task_will_free_mem(current) in out_of_memory() returns false when
>       MMF_OOM_SKIP was set before remaining OOM-killed threads reach
>       out_of_memory().
> 
> all caused by setting MMF_OOM_SKIP too early.
> 
> Michal has proposed an attempt to handover setting of MMF_OOM_SKIP to
> the OOM victim's exit path [1] in order to handle (2), but there was no
> feedback (except me) and nobody knows whether it is really safe and is
> worth constrain future changes. Not only that attempt can mitigate only
> portion of exit_mmap() (rather than until the OOM victim thread becomes
> invisible from the OOM killer), that attempt does not help at all for (1)
> and (3) because __mmput() cannot be called.
> 
> I have proposed many patches which mitigate (1) and (3) without using
> timeout based approach, but Michal is rejecting them and wants to address
> the root cause that MMF_OOM_SKIP is set too early. And nobody (including
> Michal) has time to make the OOM reaper reclaim more memory (including
> mlock()ed and shared memory, and mmap_sem contention) before setting
> MMF_OOM_SKIP. We are deadlocked there.
> 
> Michal has been refusing timeout based approach, but I don't think this
> is something we have to be frayed around the edge about possibility of
> overlooking races/bugs just because Michal does not want to use timeout.
> I believe that timeout based back off is the only approach we can use
> for now.
> 

I've proposed patches that have been running for months in a production 
environment that make the oom killer useful without serially killing many 
processes unnecessarily.  At this point, it is *much* easier to just fork 
the oom killer logic rather than continue to invest time into fixing it in 
Linux.  That's unfortunate because I'm sure you realize how problematic 
the current implementation is, how abusive it is, and have seen its 
effects yourself.  I admire your persistance in trying to fix the issues 
surrounding the oom killer, but have come to the conclusion that forking 
it is a much better use of time.
