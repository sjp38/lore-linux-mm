Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 71EFF6B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 03:39:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v104so21122675wrb.6
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 00:39:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y16si8538622wrb.0.2017.06.12.00.39.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 00:39:27 -0700 (PDT)
Date: Mon, 12 Jun 2017 09:39:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the#PF
Message-ID: <20170612073922.GA7476@dhcp22.suse.cz>
References: <20170519112604.29090-3-mhocko@kernel.org>
 <20170608143606.GK19866@dhcp22.suse.cz>
 <20170609140853.GA14760@cmpxchg.org>
 <20170609144642.GH21764@dhcp22.suse.cz>
 <20170610084901.GB12347@dhcp22.suse.cz>
 <201706102057.GGG13003.OtFMJSQOVLFOHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706102057.GGG13003.OtFMJSQOVLFOHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, guro@fb.com, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 10-06-17 20:57:46, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > And just to clarify a bit. The OOM killer should be invoked whenever
> > appropriate from the allocation context. If we decide to fail the
> > allocation in the PF path then we can safely roll back and retry the
> > whole PF. This has an advantage that any locks held while doing the
> > allocation will be released and that alone can help to make a further
> > progress. Moreover we can relax retry-for-ever _inside_ the allocator
> > semantic for the PF path and fail allocations when we cannot make
> > further progress even after we hit the OOM condition or we do stall for
> > too long.
> 
> What!? Are you saying that leave the allocator loop rather than invoke
> the OOM killer if it is from page fault event without __GFP_FS set?
> With below patch applied (i.e. ignore __GFP_FS for emulation purpose),
> I can trivially observe systemwide lockup where the OOM killer is
> never called.

Because you have ruled the OOM out of the game completely from the PF
path AFICS. So that is clearly _not_ what I meant (read the second
sentence). What I meant was that page fault allocations _could_ fail
_after_ we have used _all_ the reclaim opportunities. Without this patch
this would be impossible. Note that I am not proposing that change now
because that would require a deeper audit but it sounds like a viable
way to go long term.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b896897..c79dfd5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3255,6 +3255,9 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  
>  	*did_some_progress = 0;
>  
> +	if (current->in_pagefault)
> +		return NULL;
> +
>  	/*
>  	 * Acquire the oom lock.  If that fails, somebody else is
>  	 * making progress for us.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
