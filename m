Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1A56B0007
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 16:45:47 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id jx14so77476116pad.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 13:45:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f2si14102638pfj.33.2015.12.21.13.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 13:45:46 -0800 (PST)
Date: Mon, 21 Dec 2015 13:45:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kernel/hung_task.c: use timeout diff when timeout is
 updated
Message-Id: <20151221134545.cb0558878932913e348656e9@linux-foundation.org>
In-Reply-To: <201512212045.HHC00516.SQOJVHLFFtMOOF@I-love.SAKURA.ne.jp>
References: <201512172123.DFJ69220.SFFOLOJtVHOQMF@I-love.SAKURA.ne.jp>
	<20151217141805.f418cf9b137da08656504001@linux-foundation.org>
	<201512212045.HHC00516.SQOJVHLFFtMOOF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: oleg@redhat.com, atomlin@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On Mon, 21 Dec 2015 20:45:23 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > 
> > And it would be helpful to add a comment to hung_timeout_jiffies()
> > which describes the behaviour and explains the reasons for it.
> 
> But before doing it, I'd like to confirm hung task maintainer's will.
> 
> The reason I proposed this patch is that I want to add a watchdog task
> which emits warning messages when memory allocations are stalling.
> http://lkml.kernel.org/r/201512130033.ABH90650.FtFOMOFLVOJHQS@I-love.SAKURA.ne.jp
> 
> But concurrently emitting multiple backtraces is problematic. Concurrent
> emitting by hung task watchdog and memory allocation stall watchdog is very
> likely to occur, for it is likely that other task is also stuck in
> uninterruptible sleep when one task got stuck at memory allocation.
> 
> Therefore, I started trying to use same thread for both watchdogs.
> A draft patch is at
> http://lkml.kernel.org/r/201512170011.IAC73451.FLtFMSJHOQFVOO@I-love.SAKURA.ne.jp .
> 
> If you prefer current hang task behavior, I'll try to preseve current
> behavior. Instead, I might use two threads and try to mutex both watchdogs
> using console_lock() or something like that.
> 
> So, may I ask what your preference is?

I've added linux-mm to Cc.  Please never forget that.

The general topic here is "add more diagnostics around an out-of-memory
event".  Clearly we need this, but Michal is working on the same thing
as part of his "OOM detection rework v4" work, so can we please do the
appropriate coordination and review there?

Preventing watchdog-triggered backtraces from messing each other up is
of course a good idea.  Your malloc watchdog patch adds a surprising
amount of code and adding yet another kernel thread is painful but
perhaps it's all worth it.  It's a matter of people reviewing, testing
and using the code in realistic situations and that process has hardly
begun, alas.

Sorry, that was waffly but I don't feel able to be more definite at
this time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
