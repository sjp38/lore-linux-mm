Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 217396B06F6
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 11:54:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r187so21063847pfr.8
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 08:54:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m23si1306522plk.947.2017.08.04.08.54.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 08:54:48 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for once.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1501718104-8099-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<a9a57062-a56d-4cc8-7027-6b80d12a8996@caviumnetworks.com>
	<201708050024.ABD87010.SFFOVQOFOJMHtL@I-love.SAKURA.ne.jp>
In-Reply-To: <201708050024.ABD87010.SFFOVQOFOJMHtL@I-love.SAKURA.ne.jp>
Message-Id: <201708050054.FDD64564.tMQSVOFOFOLFJH@I-love.SAKURA.ne.jp>
Date: Sat, 5 Aug 2017 00:54:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mjaggi@caviumnetworks.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, rientjes@google.com, mhocko@suse.com, oleg@redhat.com, vdavydov.dev@gmail.com

Tetsuo Handa wrote:
> Manish Jaggi wrote:
> > Wanted to understand the envisaged effect of this patch
> > - would this patch kill the task fully or it will still take few more 
> > iterations of oom-kill to kill other process to free memory
> > - when I apply this patch I see other tasks getting killed, though I 
> > didnt got panic in initial testing, I saw login process getting killed.
> > So I am not sure if this patch works...
> 
> Thank you for testing. This patch is working as intended.
> 
> This patch (or any other patches) won't wait for the OOM victim (in this case
> oom02) to be fully killed. We don't want to risk OOM lockup situation by waiting
> for the OOM victim to be fully killed. If the OOM reaper kernel thread waits for
> the OOM victim forever, different OOM stress will trigger OOM lockup situation.
> Thus, the OOM reaper kernel thread gives up waiting for the OOM victim as soon as
> memory which can be reclaimed before __mmput() from mmput() from exit_mm() from
> do_exit() is called is reclaimed and sets MMF_OOM_SKIP.
> 
> Other tasks might be getting killed, for threads which task_will_free_mem(current)
> returns false will call select_bad_process() and select_bad_process() will ignore
> existing OOM victims with MMF_OOM_SKIP already set. Compared to older kernels
> which do not have the OOM reaper support, this behavior looks like a regression.
> But please be patient. This behavior is our choice for not to risk OOM lockup
> situation.
> 
> This patch will prevent _all_ threads which task_will_free_mem(current) returns
> true from calling select_bad_process(). And Michal's patch will prevent _most_
> threads which task_will_free_mem(current) returns true from calling select_bad_process().
> Since oom02 has many threads which task_will_free_mem(current) returns true,
> this patch (or Michal's patch) will reduce possibility of killing all threads.
> 

Oh, the last line was confusing.

Since oom02 has many threads which task_will_free_mem(current) returns true,
this patch (or Michal's patch) will reduce possibility of killing other tasks
(i.e. processes other than oom02) by increasing possibility of allocations by
OOM victim threads (i.e. threads in oom02) to succeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
