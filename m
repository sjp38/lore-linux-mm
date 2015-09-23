Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C05626B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 10:26:53 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so42686207pac.2
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 07:26:53 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id pc2si10959855pbb.178.2015.09.23.07.26.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 23 Sep 2015 07:26:52 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: Disable preemption during OOM-kill operation.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201509191605.CAF13520.QVSFHLtFJOMOOF@I-love.SAKURA.ne.jp>
	<20150922165523.GD4027@dhcp22.suse.cz>
In-Reply-To: <20150922165523.GD4027@dhcp22.suse.cz>
Message-Id: <201509232326.JEB43777.SOFMJOVOLFFtQH@I-love.SAKURA.ne.jp>
Date: Wed, 23 Sep 2015 23:26:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Sat 19-09-15 16:05:12, Tetsuo Handa wrote:
> > Well, this seems to be a problem which prevents me from testing various
> > patches that tries to address OOM livelock problem.
> > 
> > ---------- rcu-stall.c start ----------
> > #define _GNU_SOURCE
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <unistd.h>
> > #include <sys/types.h>
> > #include <sys/stat.h>
> > #include <fcntl.h>
> > #include <sched.h>
> > 
> > static int dummy(void *fd)
> > {
> > 	char c;
> > 	/* Wait until the first child thread is killed by the OOM killer. */
> > 	read(* (int *) fd, &c, 1);
> > 	/* Try to consume as much CPU time as possible via preemption. */
> > 	while (1);
> 
> You would kill the system by this alone. Having 1000 busy loops just
> kills your machine from doing anything useful and you are basically
> DoS-ed. I am not sure sprinkling preempt_{enable,disable} all around the
> oom path makes much difference. If anything having a kernel high
> priority kernel thread sounds like a better approach.

Of course, this is not a reproducer which I'm using when I'm bothered by
this problem. I used 1000 in rcu-stall just as an extreme example. I'm
bothered by this problem when there are probably only a few runnable tasks.

If this patch is not applied on preemptive kernels, the OOM-kill operation
by rcu-stall took 20 minutes. On the other hand, if this patch is applied
on preemptive kernels, or the kernel is not preemptive from the beginning,
the OOM-kill operation by rcu-stall took only 3 seconds.

The delay in OOM-kill operation in preemptive kernels varies depending on
number of runnable tasks (on a CPU which is executing the oom path) and
their priority.

Sprinkling preempt_{enable,disable} all around the oom path can temporarily
slow down threads with higher priority. But doing so can guarantee that
the oom path is not delayed indefinitely. Imagine a scenario where a task
with idle priority called the oom path and other tasks with normal or
realtime priority preempt. How long will we hold oom_lock and keep the
system under oom?

So, I think it makes sense to disable preemption during OOM-kill
operation.

By the way, I'm not familiar with cgroups. If CPU resource the task which
called the oom path is allowed to use only one percent of single CPU, is
the delay multiplied by 100 (e.g. 1 second -> 100 seconds)?

> 
> [...]
> 
> > 	for (i = 0; i < 1000; i++) {
> > 		clone(dummy, malloc(1024) + 1024, CLONE_SIGHAND | CLONE_VM,
> > 		      &pipe_fd[0]);
> > 		if (!i)
> > 			close(pipe_fd[1]);
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
