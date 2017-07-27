Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39F086B049B
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:55:39 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id n140so236265291ywd.13
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:55:39 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l125si4362414ywd.69.2017.07.27.07.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 07:55:38 -0700 (PDT)
Date: Thu, 27 Jul 2017 15:55:13 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 2/2] mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
Message-ID: <20170727145513.GA1185@castle.DHCP.thefacebook.com>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170727090357.3205-3-mhocko@kernel.org>
 <201707272301.EII82876.tOOJOFLMHFQSFV@I-love.SAKURA.ne.jp>
 <20170727144544.GC31031@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170727144544.GC31031@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 27, 2017 at 04:45:44PM +0200, Michal Hocko wrote:
> On Thu 27-07-17 23:01:05, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 544d47e5cbbd..86a48affb938 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1896,7 +1896,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> > >  	 * bypass the last charges so that they can exit quickly and
> > >  	 * free their memory.
> > >  	 */
> > > -	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
> > > +	if (unlikely(tsk_is_oom_victim(current) ||
> > >  		     fatal_signal_pending(current) ||
> > >  		     current->flags & PF_EXITING))
> > >  		goto force;
> > 
> > Did we check http://lkml.kernel.org/r/20160909140508.GO4844@dhcp22.suse.cz ?
> 
> OK, so your concern was
> 
> > Does this test_thread_flag(TIF_MEMDIE) (or tsk_is_oom_victim(current)) make sense?
> > 
> > If current thread is OOM-killed, SIGKILL must be pending before arriving at
> > do_exit() and PF_EXITING must be set after arriving at do_exit().
> 
> > But I can't find locations which do memory allocation between clearing
> > SIGKILL and setting PF_EXITING.
> 
> I can't find them either and maybe there are none. But why do we care
> in this particular patch which merely replaces TIF_MEMDIE check by
> tsk_is_oom_victim? The code will surely not become less valid. If
> you believe this check is redundant then send a patch with the clear
> justification. But I would say, at least from the robustness point of
> view I would just keep it there. We do not really have any control on
> what happens between clearing signals and setting PF_EXITING.

I agree, this check is probably redundant, but it really makes no difference,
let's keep it bullet-proof. If we care about performance here, we can rearrange
the checks:
  if (unlikely(fatal_signal_pending(current) ||
  	     current->flags & PF_EXITING) ||
  	     tsk_is_oom_victim(current))
  	goto force;

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
