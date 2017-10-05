Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 22FCA6B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 07:14:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p5so36174602pgn.7
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 04:14:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i6si1302168plt.221.2017.10.05.04.14.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 04:14:05 -0700 (PDT)
Date: Thu, 5 Oct 2017 13:14:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171005111402.53gplrzxhodslvvp@dhcp22.suse.cz>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-4-guro@fb.com>
 <20171004192720.GC1501@cmpxchg.org>
 <20171004195110.GA18900@castle>
 <alpine.DEB.2.10.1710041316120.67374@chino.kir.corp.google.com>
 <20171004203138.GA2632@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171004203138.GA2632@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 04-10-17 16:31:38, Johannes Weiner wrote:
> On Wed, Oct 04, 2017 at 01:17:14PM -0700, David Rientjes wrote:
> > On Wed, 4 Oct 2017, Roman Gushchin wrote:
> > 
> > > > > @@ -828,6 +828,12 @@ static void __oom_kill_process(struct task_struct *victim)
> > > > >  	struct mm_struct *mm;
> > > > >  	bool can_oom_reap = true;
> > > > >  
> > > > > +	if (is_global_init(victim) || (victim->flags & PF_KTHREAD) ||
> > > > > +	    victim->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > > > > +		put_task_struct(victim);
> > > > > +		return;
> > > > > +	}
> > > > > +
> > > > >  	p = find_lock_task_mm(victim);
> > > > >  	if (!p) {
> > > > >  		put_task_struct(victim);
> > > > 
> > > > Is this necessary? The callers of this function use oom_badness() to
> > > > find a victim, and that filters init, kthread, OOM_SCORE_ADJ_MIN.
> > > 
> > > It is. __oom_kill_process() is used to kill all processes belonging
> > > to the selected memory cgroup, so we should perform these checks
> > > to avoid killing unkillable processes.
> > > 
> > 
> > That's only true after the next patch in the series which uses the 
> > oom_kill_memcg_member() callback to kill processes for oom_group, correct?  
> > Would it be possible to move this check to that patch so it's more 
> > obvious?
> 
> Yup, I realized it when reviewing the next patch. Moving this hunk to
> the next patch would probably make sense. Although, us reviewers have
> been made aware of this now, so I don't feel strongly about it. Won't
> make much of a difference once the patches are merged.

I think it would be better to move it because it will be less confusing
that way. Especially for those who are going to read git history in
order to understand why this is needed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
