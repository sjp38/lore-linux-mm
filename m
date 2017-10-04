Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 880FF6B025F
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 16:17:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v78so3291341pgb.4
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 13:17:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v68sor2161228pfb.42.2017.10.04.13.17.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 13:17:16 -0700 (PDT)
Date: Wed, 4 Oct 2017 13:17:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20171004195110.GA18900@castle>
Message-ID: <alpine.DEB.2.10.1710041316120.67374@chino.kir.corp.google.com>
References: <20171004154638.710-1-guro@fb.com> <20171004154638.710-4-guro@fb.com> <20171004192720.GC1501@cmpxchg.org> <20171004195110.GA18900@castle>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 4 Oct 2017, Roman Gushchin wrote:

> > > @@ -828,6 +828,12 @@ static void __oom_kill_process(struct task_struct *victim)
> > >  	struct mm_struct *mm;
> > >  	bool can_oom_reap = true;
> > >  
> > > +	if (is_global_init(victim) || (victim->flags & PF_KTHREAD) ||
> > > +	    victim->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > > +		put_task_struct(victim);
> > > +		return;
> > > +	}
> > > +
> > >  	p = find_lock_task_mm(victim);
> > >  	if (!p) {
> > >  		put_task_struct(victim);
> > 
> > Is this necessary? The callers of this function use oom_badness() to
> > find a victim, and that filters init, kthread, OOM_SCORE_ADJ_MIN.
> 
> It is. __oom_kill_process() is used to kill all processes belonging
> to the selected memory cgroup, so we should perform these checks
> to avoid killing unkillable processes.
> 

That's only true after the next patch in the series which uses the 
oom_kill_memcg_member() callback to kill processes for oom_group, correct?  
Would it be possible to move this check to that patch so it's more 
obvious?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
