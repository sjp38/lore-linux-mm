Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 696A4831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 10:29:07 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b28so9631116wrb.2
        for <linux-mm@kvack.org>; Thu, 18 May 2017 07:29:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z9si5639932edb.89.2017.05.18.07.29.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 07:29:06 -0700 (PDT)
Date: Thu, 18 May 2017 16:29:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: fix oom invocation issues
Message-ID: <20170518142901.GA13940@dhcp22.suse.cz>
References: <20170517161446.GB20660@dhcp22.suse.cz>
 <20170517194316.GA30517@castle>
 <201705180703.JGH95344.SOHJtFFMOQFLOV@I-love.SAKURA.ne.jp>
 <20170518084729.GB25462@dhcp22.suse.cz>
 <20170518090039.GC25462@dhcp22.suse.cz>
 <201705182257.HJJ52185.OQStFLFMHVOJOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201705182257.HJJ52185.OQStFLFMHVOJOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 18-05-17 22:57:10, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > It is racy and it basically doesn't have any allocation context so we
> > might kill a task from a different domain. So can we do this instead?
> > There is a slight risk that somebody might have returned VM_FAULT_OOM
> > without doing an allocation but from my quick look nobody does that
> > currently.
> 
> I can't tell whether it is safe to remove out_of_memory() from
> pagefault_out_of_memory().  There are VM_FAULT_OOM users in fs/
> directory. What happens if pagefault_out_of_memory() was called as a
> result of e.g. GFP_NOFS allocation failure?

Then we would bypass GFP_NOFS oom protection and could trigger a
premature OOM killer invocation.

> Is it guaranteed that all memory allocations that might occur from
> page fault event (or any action that might return VM_FAULT_OOM)
> are allowed to call oom_kill_process() from out_of_memory() before
> reaching pagefault_out_of_memory() ?

The same applies here.

> Anyway, I want
> 
> 	/* Avoid allocations with no watermarks from looping endlessly */
> -	if (test_thread_flag(TIF_MEMDIE))
> +	if (alloc_flags == ALLOC_NO_WATERMARKS && test_thread_flag(TIF_MEMDIE))
> 		goto nopage;
> 
> so that we won't see similar backtraces and memory information from both
> out_of_memory() and warn_alloc().

I do not think this is an improvement and it is unrelated to the
discussion here.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
