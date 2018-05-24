Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA2306B0269
	for <linux-mm@kvack.org>; Thu, 24 May 2018 07:50:20 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j8-v6so659684wrh.18
        for <linux-mm@kvack.org>; Thu, 24 May 2018 04:50:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g2-v6si162798edd.8.2018.05.24.04.50.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 04:50:19 -0700 (PDT)
Date: Thu, 24 May 2018 13:50:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180524115017.GE20441@dhcp22.suse.cz>
References: <20180522061850.GB20020@dhcp22.suse.cz>
 <201805231924.EED86916.FSQJMtHOLVOFOF@I-love.SAKURA.ne.jp>
 <20180523115726.GP20441@dhcp22.suse.cz>
 <201805232245.IGI00539.HLtMFOQSJFFOOV@I-love.SAKURA.ne.jp>
 <20180523145639.GT20441@dhcp22.suse.cz>
 <201805241951.IFF48475.FMOSOJFQHLVtFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805241951.IFF48475.FMOSOJFQHLVtFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Thu 24-05-18 19:51:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Look. I am fed up with this discussion. You are fiddling with the code
> > and moving hacks around with a lot of hand waving. Rahter than trying to
> > look at the underlying problem. Your patch completely ignores PREEMPT as
> > I've mentioned in previous versions.
> 
> I'm not ignoring PREEMPT. To fix this OOM lockup problem properly, as much
> efforts as fixing Spectre/Meltdown problems will be required. This patch is
> a mitigation for regression introduced by fixing CVE-2018-1000200. Nothing
> is good with deferring this patch.
> 
> > I would be OK with removing the sleep from the out_of_memory path based
> > on your argumentation that we have a _proper_ synchronization with the
> > exit path now.
> 
> Such attempt should be made in a separate patch.
> 
> You suggested removing this sleep from my patch without realizing that
> we need explicit schedule_timeout_*() for PF_WQ_WORKER threads.

And that sleep is in should_reclaim_retry. If that is not sufficient it
should be addressed rather than spilling more of that crud all over the
place.

> My patch
> is trying to be as conservative/safe as possible (for easier backport)
> while reducing the risk of falling into OOM lockup.

And it adss more crud
 
> I worry that you are completely overlooking
> 
>                 char *fmt, ...)
>  	 */
>  	if (!mutex_trylock(&oom_lock)) {
>  		*did_some_progress = 1;
> -		schedule_timeout_uninterruptible(1);
>  		return NULL;
>  	}
>  
> 
> part in this patch.

I am not. But it doesn't really make much sense to convince you if you
are not reading what I am writing. I am done with this thread.
Discussion is just a waste of time.

-- 
Michal Hocko
SUSE Labs
