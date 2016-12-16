Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB17F6B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:39:40 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id i145so24103869qke.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 03:39:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c133si2537236itc.1.2016.12.16.03.39.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Dec 2016 03:39:39 -0800 (PST)
Subject: Re: [PATCH v2] mm: consolidate GFP_NOFAIL checks in the allocator slowpath
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161214150706.27412-1-mhocko@kernel.org>
	<04b001d256a8$7bc813d0$73583b70$@alibaba-inc.com>
	<20161215102838.GA8602@dhcp22.suse.cz>
In-Reply-To: <20161215102838.GA8602@dhcp22.suse.cz>
Message-Id: <201612162039.EEI17197.HSFFMFOJOVQOLt@I-love.SAKURA.ne.jp>
Date: Fri, 16 Dec 2016 20:39:12 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hillf.zj@alibaba-inc.com
Cc: akpm@linux-foundation.org, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 15-12-16 15:54:37, Hillf Danton wrote:
> > On Wednesday, December 14, 2016 11:07 PM Michal Hocko wrote: 
> [...]
> > >  	/* Avoid allocations with no watermarks from looping endlessly */
> > > -	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> > > +	if (test_thread_flag(TIF_MEMDIE))
> > >  		goto nopage;
> > > 
> > Nit: currently we allow TIF_MEMDIE & __GFP_NOFAIL request to
> > try direct reclaim. Are you intentionally reclaiming that chance?
> 
> That is definitely not a nit! Thanks for catching that. We definitely
> shouldn't bypass the direct reclaim because that would mean we rely on
> somebody else makes progress for us.
> 
> Updated patch below:
> --- 
> From cebd2d933f245a59504fdce31312b67186311e50 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 22 Nov 2016 07:52:58 +0100
> Subject: [PATCH] mm: consolidate GFP_NOFAIL checks in the allocator slowpath
> 
> Tetsuo Handa has pointed out that 0a0337e0d1d1 ("mm, oom: rework oom
> detection") has subtly changed semantic for costly high order requests
> with __GFP_NOFAIL and withtout __GFP_REPEAT and those can fail right now.
> My code inspection didn't reveal any such users in the tree but it is
> true that this might lead to unexpected allocation failures and
> subsequent OOPs.
> 
> __alloc_pages_slowpath wrt. GFP_NOFAIL is hard to follow currently.
> There are few special cases but we are lacking a catch all place to be
> sure we will not miss any case where the non failing allocation might
> fail. This patch reorganizes the code a bit and puts all those special
> cases under nopage label which is the generic go-to-fail path. Non
> failing allocations are retried or those that cannot retry like
> non-sleeping allocation go to the failure point directly. This should
> make the code flow much easier to follow and make it less error prone
> for future changes.
> 
> While we are there we have to move the stall check up to catch
> potentially looping non-failing allocations.

Currently we allow TIF_MEMDIE && __GFP_NOFAIL threads to call
__alloc_pages_may_oom() after !__alloc_pages_direct_reclaim() &&
!__alloc_pages_direct_compact() && !should_reclaim_retry() &&
!should_compact_retry().

But this patch changes TIF_MEMDIE && __GFP_NOFAIL threads not to call
__alloc_pages_may_oom(). If this is intentional, please describe it
(i.e. this patch adds a location which currently does not cause OOM
livelock) in change log. (I don't trust your assumption that __GFP_FS
allocations are running in parallel and they will call out_of_memory()
on behalf of TIF_MEMDIE && __GFP_NOFAIL threads. Surprising things
(e.g. all __GFP_FS allocations get stuck due to kswapd v.s.
shrink_inactive_list() trap) can happen if TIF_MEMDIE && __GFP_NOFAIL
has to loop forever. The OOM reaper allows selecting next OOM victim
by setting MMF_OOM_REAPED does not help if we hit surprising traps.

> 
> Changes since v1
> - do not skip direct reclaim for TIF_MEMDIE && GFP_NOFAIL as per Hillf
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> ---
>  mm/page_alloc.c | 75 +++++++++++++++++++++++++++++++++------------------------
>  1 file changed, 44 insertions(+), 31 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
