Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 759E1831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 10:57:40 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d127so35765161pga.11
        for <linux-mm@kvack.org>; Thu, 18 May 2017 07:57:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v2si5542711plk.313.2017.05.18.07.57.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 07:57:39 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: fix oom invocation issues
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201705180703.JGH95344.SOHJtFFMOQFLOV@I-love.SAKURA.ne.jp>
	<20170518084729.GB25462@dhcp22.suse.cz>
	<20170518090039.GC25462@dhcp22.suse.cz>
	<201705182257.HJJ52185.OQStFLFMHVOJOF@I-love.SAKURA.ne.jp>
	<20170518142901.GA13940@dhcp22.suse.cz>
In-Reply-To: <20170518142901.GA13940@dhcp22.suse.cz>
Message-Id: <201705182357.GJH90607.FVHMQOJtOLFFOS@I-love.SAKURA.ne.jp>
Date: Thu, 18 May 2017 23:57:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 18-05-17 22:57:10, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > It is racy and it basically doesn't have any allocation context so we
> > > might kill a task from a different domain. So can we do this instead?
> > > There is a slight risk that somebody might have returned VM_FAULT_OOM
> > > without doing an allocation but from my quick look nobody does that
> > > currently.
> > 
> > I can't tell whether it is safe to remove out_of_memory() from
> > pagefault_out_of_memory().  There are VM_FAULT_OOM users in fs/
> > directory. What happens if pagefault_out_of_memory() was called as a
> > result of e.g. GFP_NOFS allocation failure?
> 
> Then we would bypass GFP_NOFS oom protection and could trigger a
> premature OOM killer invocation.

Excuse me, but I couldn't understand your answer.

We have __GFP_FS check in out_of_memory(). If we remove out_of_memory() from
pagefault_out_of_memory(), pagefault_out_of_memory() called as a result of
a !__GFP_FS allocation failure won't be able to call oom_kill_process().
Unless somebody else calls oom_kill_process() via a __GFP_FS allocation
request, a thread which triggered a page fault event will spin forever.

> 
> > Is it guaranteed that all memory allocations that might occur from
> > page fault event (or any action that might return VM_FAULT_OOM)
> > are allowed to call oom_kill_process() from out_of_memory() before
> > reaching pagefault_out_of_memory() ?
> 
> The same applies here.

So, my question is, can pagefault_out_of_memory() be called as a result of
an allocation request (or action) which cannot call oom_kill_process() ?
Please answer with "yes" or "no".

> 
> > Anyway, I want
> > 
> > 	/* Avoid allocations with no watermarks from looping endlessly */
> > -	if (test_thread_flag(TIF_MEMDIE))
> > +	if (alloc_flags == ALLOC_NO_WATERMARKS && test_thread_flag(TIF_MEMDIE))
> > 		goto nopage;
> > 
> > so that we won't see similar backtraces and memory information from both
> > out_of_memory() and warn_alloc().
> 
> I do not think this is an improvement and it is unrelated to the
> discussion here.

If we allow current thread to allocate memory when current thread was
chosen as an OOM victim by giving current thread a chance to do
ALLOC_NO_WATERMARKS allocation request, all memory allocation requests
that might occur from page fault event will likely succeed and thus
current thread will not call pagefault_out_of_memory(). This will
prevent current thread from selecting next OOM victim by calling
out_of_memory() from pagefault_out_of_memory().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
