Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA2A6B0494
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:45:48 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z48so33504856wrc.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:45:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e204si7298675wme.193.2017.07.27.07.45.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 07:45:47 -0700 (PDT)
Date: Thu, 27 Jul 2017 16:45:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
Message-ID: <20170727144544.GC31031@dhcp22.suse.cz>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170727090357.3205-3-mhocko@kernel.org>
 <201707272301.EII82876.tOOJOFLMHFQSFV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707272301.EII82876.tOOJOFLMHFQSFV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 27-07-17 23:01:05, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 544d47e5cbbd..86a48affb938 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1896,7 +1896,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >  	 * bypass the last charges so that they can exit quickly and
> >  	 * free their memory.
> >  	 */
> > -	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
> > +	if (unlikely(tsk_is_oom_victim(current) ||
> >  		     fatal_signal_pending(current) ||
> >  		     current->flags & PF_EXITING))
> >  		goto force;
> 
> Did we check http://lkml.kernel.org/r/20160909140508.GO4844@dhcp22.suse.cz ?

OK, so your concern was

> Does this test_thread_flag(TIF_MEMDIE) (or tsk_is_oom_victim(current)) make sense?
> 
> If current thread is OOM-killed, SIGKILL must be pending before arriving at
> do_exit() and PF_EXITING must be set after arriving at do_exit().

> But I can't find locations which do memory allocation between clearing
> SIGKILL and setting PF_EXITING.

I can't find them either and maybe there are none. But why do we care
in this particular patch which merely replaces TIF_MEMDIE check by
tsk_is_oom_victim? The code will surely not become less valid. If
you believe this check is redundant then send a patch with the clear
justification. But I would say, at least from the robustness point of
view I would just keep it there. We do not really have any control on
what happens between clearing signals and setting PF_EXITING.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
