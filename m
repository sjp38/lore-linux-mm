Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1260B6B025F
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 16:31:45 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l10so387559wre.4
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 13:31:45 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s6si3528636eda.14.2017.10.04.13.31.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Oct 2017 13:31:43 -0700 (PDT)
Date: Wed, 4 Oct 2017 16:31:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171004203138.GA2632@cmpxchg.org>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-4-guro@fb.com>
 <20171004192720.GC1501@cmpxchg.org>
 <20171004195110.GA18900@castle>
 <alpine.DEB.2.10.1710041316120.67374@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710041316120.67374@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 04, 2017 at 01:17:14PM -0700, David Rientjes wrote:
> On Wed, 4 Oct 2017, Roman Gushchin wrote:
> 
> > > > @@ -828,6 +828,12 @@ static void __oom_kill_process(struct task_struct *victim)
> > > >  	struct mm_struct *mm;
> > > >  	bool can_oom_reap = true;
> > > >  
> > > > +	if (is_global_init(victim) || (victim->flags & PF_KTHREAD) ||
> > > > +	    victim->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > > > +		put_task_struct(victim);
> > > > +		return;
> > > > +	}
> > > > +
> > > >  	p = find_lock_task_mm(victim);
> > > >  	if (!p) {
> > > >  		put_task_struct(victim);
> > > 
> > > Is this necessary? The callers of this function use oom_badness() to
> > > find a victim, and that filters init, kthread, OOM_SCORE_ADJ_MIN.
> > 
> > It is. __oom_kill_process() is used to kill all processes belonging
> > to the selected memory cgroup, so we should perform these checks
> > to avoid killing unkillable processes.
> > 
> 
> That's only true after the next patch in the series which uses the 
> oom_kill_memcg_member() callback to kill processes for oom_group, correct?  
> Would it be possible to move this check to that patch so it's more 
> obvious?

Yup, I realized it when reviewing the next patch. Moving this hunk to
the next patch would probably make sense. Although, us reviewers have
been made aware of this now, so I don't feel strongly about it. Won't
make much of a difference once the patches are merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
