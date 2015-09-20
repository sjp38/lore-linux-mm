Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5D64F6B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 10:50:53 -0400 (EDT)
Received: by oiww128 with SMTP id w128so47353605oiw.2
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 07:50:53 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q126si9874752oia.45.2015.09.20.07.50.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 20 Sep 2015 07:50:52 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
	<20150919150316.GB31952@redhat.com>
In-Reply-To: <20150919150316.GB31952@redhat.com>
Message-Id: <201509202350.DDG21892.FFStOLHOQOFMVJ@I-love.SAKURA.ne.jp>
Date: Sun, 20 Sep 2015 23:50:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com, kwalker@redhat.com, cl@linux.com, torvalds@linux-foundation.org, mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Oleg Nesterov wrote:
> On 09/17, Kyle Walker wrote:
> >
> > Currently, the oom killer will attempt to kill a process that is in
> > TASK_UNINTERRUPTIBLE state. For tasks in this state for an exceptional
> > period of time, such as processes writing to a frozen filesystem during
> > a lengthy backup operation, this can result in a deadlock condition as
> > related processes memory access will stall within the page fault
> > handler.
> 
> And there are other potential reasons for deadlock.
> 
> Stupid idea. Can't we help the memory hog to free its memory? This is
> orthogonal to other improvements we can do.

So, we are trying to release memory without waiting for arriving at
exit_mm() from do_exit(), right? If it works, it will be a simple and
small change that will be easy to backport.

The idea is that since fatal_signal_pending() tasks no longer return to
user space, we can release memory allocated for use by user space, right?

Then, I think that this approach can be applied to not only OOM-kill case
but also regular kill(pid, SIGKILL) case (i.e. kick from signal_wake_up(1)
or somewhere?). A dedicated kernel thread (not limited to OOM-kill purpose)
scans for fatal_signal_pending() tasks and release that task's memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
