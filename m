Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id C01066B0011
	for <linux-mm@kvack.org>; Fri,  1 Jan 2016 02:54:55 -0500 (EST)
Received: by mail-io0-f172.google.com with SMTP id 77so76600849ioc.2
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 23:54:55 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v15si24430529igd.66.2015.12.31.23.54.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Dec 2015 23:54:54 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Always sleep before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201512301101.GJD12974.LOVFFtFMOHOJSQ@I-love.SAKURA.ne.jp>
In-Reply-To: <201512301101.GJD12974.LOVFFtFMOHOJSQ@I-love.SAKURA.ne.jp>
Message-Id: <201601011654.IFC09303.MOLOFFVOQtHSFJ@I-love.SAKURA.ne.jp>
Date: Fri, 1 Jan 2016 16:54:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp

Tetsuo Handa wrote:
> When we entered into "Reclaim has failed us, start killing things"
> state, sleep function is called only when mutex_trylock(&oom_lock)
> in __alloc_pages_may_oom() failed or immediately after returning from
> oom_kill_process() in out_of_memory(). This may be insufficient for
> giving other tasks a chance to run because mutex_trylock(&oom_lock)
> will not fail under non-preemptive UP kernel.

My misunderstanding. I thought cond_resched() is a no-op under
non-preemptive UP kernel.

Calling schedule_timeout_uninterruptible(1) will allow other pending
workqueue items a chance to run if current thread is kworker thread.
But if current thread is one of threads which the OOM victim depends
on, calling it merely delays termination of the OOM victim. Therefore,
nobody can judge whether calling it will help the OOM victim and its
dependent threads to make use of CPU cycles for making progress.
Although always sleeping helps saving CPU cycles under OOM livelock,
we need to give up waiting for the OOM victim at some point (i.e.
trigger kernel panic like panic_on_oom_timeout or choose subsequent
OOM victims).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
