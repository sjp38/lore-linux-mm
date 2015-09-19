Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id EC60A6B0038
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 10:33:25 -0400 (EDT)
Received: by obbbh8 with SMTP id bh8so56296619obb.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 07:33:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id mv15si7511053obb.64.2015.09.19.07.33.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Sep 2015 07:33:24 -0700 (PDT)
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150917192204.GA2728@redhat.com>
	<alpine.DEB.2.11.1509181035180.11189@east.gentwo.org>
	<20150918162423.GA18136@redhat.com>
	<alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
	<20150919083218.GD28815@dhcp22.suse.cz>
In-Reply-To: <20150919083218.GD28815@dhcp22.suse.cz>
Message-Id: <201509192333.AGJ30797.OQOFLFSMJVFOtH@I-love.SAKURA.ne.jp>
Date: Sat, 19 Sep 2015 23:33:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, cl@linux.com
Cc: oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Michal Hocko wrote:
> This has been posted in various forms many times over past years. I
> still do not think this is a right approach of dealing with the problem.

I do not think "GFP_NOFS can fail" patch is a right approach because
that patch easily causes messages like below.

  Buffer I/O error on dev sda1, logical block 34661831, lost async page write
  XFS: possible memory allocation deadlock in kmem_alloc (mode:0x8250)
  XFS: possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
  XFS: possible memory allocation deadlock in kmem_zone_alloc (mode:0x8250)

Adding __GFP_NOFAIL will hide these messages but OOM stall remains anyway.

I believe choosing more OOM victims is the only way which can solve OOM stalls.

> You can quickly deplete memory reserves this way without making further
> progress (I am afraid you can even trigger this from userspace without
> having big privileges) so even administrator will have no way to
> intervene.

I think that use of ALLOC_NO_WATERMARKS via TIF_MEMDIE is the underlying
cause. ALLOC_NO_WATERMARKS via TIF_MEMDIE is intended for terminating the
OOM victim task as soon as possible, but it turned out that it will not
work if there is invisible lock dependency. Therefore, why not to give up
"there should be only up to 1 TIF_MEMDIE task" rule?

What this patch (and many others posted in various forms many times over
past years) does is to give up "there should be only up to 1 TIF_MEMDIE
task" rule. I think that we need to tolerate more than 1 TIF_MEMDIE tasks
and somehow manage in a way memory reserves will not deplete.

In my proposal which favors all fatal_signal_pending() tasks evenly
( http://lkml.kernel.org/r/201509102318.GHG18789.OHMSLFJOQFOtFV@I-love.SAKURA.ne.jp )
suggests that the OOM victim task unlikely needs all of memory reserves.
In other words, the OOM victim task can likely make forward progress
if some amount of memory reserves are allowed (compared to normal tasks
waiting for memory).

So, I think that getting rid of "ALLOC_NO_WATERMARKS via TIF_MEMDIE" rule
and replace test_thread_flag(TIF_MEMDIE) with fatal_signal_pending(current)
will handle many cases if fatal_signal_pending() tasks are allowed to access
some amount of memory reserves. And my proposal which chooses next OOM
victim upon timeout will handle the remaining cases without depleting
memory reserves.

If you still want to keep "there should be only up to 1 TIF_MEMDIE task"
rule, what alternative do you have? (I do not like panic_on_oom_timeout
because it is more data-lossy approach than choosing next OOM victim.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
