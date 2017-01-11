Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 404306B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:12:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so28678755wmi.6
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:12:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y47si4723366wrc.336.2017.01.11.08.12.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Jan 2017 08:12:34 -0800 (PST)
Date: Wed, 11 Jan 2017 17:12:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Ignore __GFP_NOWARN when reporting stalls
Message-ID: <20170111161228.GE16365@dhcp22.suse.cz>
References: <1484132120-35288-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484132120-35288-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 11-01-17 19:55:20, Tetsuo Handa wrote:
> Currently, warn_alloc() prints warning messages only if __GFP_NOWARN
> is not specified. When warn_alloc() was proposed, I asserted that
> warn_alloc() should print stall warning messages even if __GFP_NOWARN
> is specified, but that assertion was not accepted [1].
> 
> Compared to asynchronous watchdog [2], warn_alloc() for reporting stalls
> is broken in many aspects. First of all, we can't guarantee forward
> progress of memory allocation request. It is important to understand that
> the reason is not limited to the "too small to fail" memory-allocation
> rule [3]. We need to learn that the caller may fail to call warn_alloc()
>  from page allocator whereas warn_alloc() assumes that stalling threads
> can call warn_alloc() from page allocator.
> 
> An easily reproducible situation is that kswapd is blocked on other
> threads doing memory allocations while other threads doing memory
> allocations are blocked on kswapd [4].

This all is unrelated to whether we should or shouldn't warn when
__GFP_NOWARN is specified.

> But what is silly is that, even
> if some allocation request was lucky enough to escape from
> too_many_isolated() loop because it was GFP_NOIO or GFP_NOFS, it fails
> to print warning messages because it was __GFP_NOWARN when all other
> allocations were looping inside too_many_isolated() loop (an example [5]
> is shown below). We are needlessly discarding a chance to know that
> the system got livelocked.

But the caller had some reason to not warn. So why should we ignore
that? The reason this flag is usually added is that the allocation
failure is tolerable and it shouldn't alarm the admin to do any action.

So rather than repeating why you think that warn_alloc is worse than a
different solution which you are trying to push through you should in
fact explain why we should handle stall and allocation failure warnings
differently and how are we going to handle potential future users who
would like to disable warning for both. Because once you change the
semantic we will have problems to change it like for other gfp flags.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
