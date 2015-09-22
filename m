Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 49A676B0255
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:55:26 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so33466751wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 09:55:25 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id lf10si3521488wjc.47.2015.09.22.09.55.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 09:55:25 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so33463141wic.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 09:55:24 -0700 (PDT)
Date: Tue, 22 Sep 2015 18:55:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: Disable preemption during OOM-kill operation.
Message-ID: <20150922165523.GD4027@dhcp22.suse.cz>
References: <201509191605.CAF13520.QVSFHLtFJOMOOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201509191605.CAF13520.QVSFHLtFJOMOOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Sat 19-09-15 16:05:12, Tetsuo Handa wrote:
> Well, this seems to be a problem which prevents me from testing various
> patches that tries to address OOM livelock problem.
> 
> ---------- rcu-stall.c start ----------
> #define _GNU_SOURCE
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <sched.h>
> 
> static int dummy(void *fd)
> {
> 	char c;
> 	/* Wait until the first child thread is killed by the OOM killer. */
> 	read(* (int *) fd, &c, 1);
> 	/* Try to consume as much CPU time as possible via preemption. */
> 	while (1);

You would kill the system by this alone. Having 1000 busy loops just
kills your machine from doing anything useful and you are basically
DoS-ed. I am not sure sprinkling preempt_{enable,disable} all around the
oom path makes much difference. If anything having a kernel high
priority kernel thread sounds like a better approach.

[...]

> 	for (i = 0; i < 1000; i++) {
> 		clone(dummy, malloc(1024) + 1024, CLONE_SIGHAND | CLONE_VM,
> 		      &pipe_fd[0]);
> 		if (!i)
> 			close(pipe_fd[1]);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
