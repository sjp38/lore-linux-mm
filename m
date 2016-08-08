Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 187316B0253
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 08:00:00 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f14so228000025ioj.2
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 05:00:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q31si14349934ota.54.2016.08.08.04.59.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Aug 2016 04:59:58 -0700 (PDT)
Subject: Re: [PATCH/RFC] mm, oom: Fix uninitialized ret in task_will_free_mem()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1470255599-24841-1-git-send-email-geert@linux-m68k.org>
	<178c5e9b-b92d-b62b-40a9-ee98b10d6bce@I-love.SAKURA.ne.jp>
	<20160804144649.7ac4727ad0d93097c4055610@linux-foundation.org>
In-Reply-To: <20160804144649.7ac4727ad0d93097c4055610@linux-foundation.org>
Message-Id: <201608082059.DAD64516.MQVLSFHOFFtOJO@I-love.SAKURA.ne.jp>
Date: Mon, 8 Aug 2016 20:59:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: geert@linux-m68k.org, mhocko@suse.com, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andrew Morton wrote:
> On Thu, 4 Aug 2016 21:28:13 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > > 
> > > Fixes: 1af8bb43269563e4 ("mm, oom: fortify task_will_free_mem()")
> > > Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > > ---
> > > Untested. I'm not familiar with the code, hence the default value of
> > > true was deducted from the logic in the loop (return false as soon as
> > > __task_will_free_mem() has returned false).
> > 
> > I think ret = true is correct. Andrew, please send to linux.git.
> 
> task_will_free_mem() is too hard to understand.
> 
> We're examining task "A":
> 
> : 	for_each_process(p) {
> : 		if (!process_shares_mm(p, mm))
> : 			continue;
> : 		if (same_thread_group(task, p))
> : 			continue;
> 
> So here, we've found a process `p' which shares A's mm and which does
> not share A's thread group.

Correct.

> 
> : 		ret = __task_will_free_mem(p);
> 
> And here we check to see if killing `p' would free up memory.

Not correct. Basic idea of __task_will_free_mem() is "check whether
the given task is already killed or exiting" in order to avoid sending
SIGKILL to tasks more than needed, and task_will_free_mem() is "check
whether all of the given mm users are already killed or exiting" in
order to avoid sending SIGKILL to tasks more than needed.

__task_will_free_mem(p) == true means p is already killed or exiting
and therefore the OOM killer does not need to send SIGKILL to `p'.

> 
> : 		if (!ret)
> : 			break;
> 
> If killing `p' will not free memory then give up the scan of all
> processes because <reasons>, and we decide that killing `A' will
> not free memory either, because some other task is holding onto
> A's memory anyway.

If `p' is not already killed or exiting, the OOM reaper cannot reap
p->mm because p will crash if p->mm suddenly disappears. Therefore,
the OOM killer needs to send SIGKILL to somebody.

> 
> : 	}
> 
> And if no task is found to be sharing A's mm while not sharing A's
> thread group then fall through and decide to kill A.  In which case the
> patch to return `true' is correct.

`A' is already killed or exiting, for it passed

	if (!__task_will_free_mem(task))
		return false;

test before the for_each_process(p) loop.

Although

	if (atomic_read(&mm->mm_users) <= 1)
		return true;

test was false as of atomic_read(), it is possible that `p'
releases its mm before reaching

	if (!process_shares_mm(p, mm))
		continue;

test. Therefore, it is possible that __task_will_free_mem(p) is
never called inside the for_each_process(p) loop. In that case,
task_will_free_mem(task) should return true, for it passed

	if (!__task_will_free_mem(task))
		return false;

test before the for_each_process(p) loop.



It is possible that `p' and `A' are the same thread group because
`A' (which can be "current") is not always a thread group leader.
If there is no external process sharing A's mm,

	if (!process_shares_mm(p, mm))
		continue;

test is true for all processes except the process for `A', and

	if (same_thread_group(task, p))
		continue;

test is true for the process for `A'. Therefore, it is possible that
__task_will_free_mem(p) is never called inside the for_each_process(p)
loop. In that case, task_will_free_mem(task) should return true.

> 
> Correctish?  Maybe.  Can we please get some comments in there to
> demystify the decision-making?
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
