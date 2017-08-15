Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1AC6B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 08:16:25 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 123so13206405pga.5
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:16:25 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u20si5480284pfa.678.2017.08.15.05.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 05:16:24 -0700 (PDT)
Date: Tue, 15 Aug 2017 13:15:58 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v5 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170815121558.GA15892@castle.dhcp.TheFacebook.com>
References: <20170814183213.12319-1-guro@fb.com>
 <20170814183213.12319-3-guro@fb.com>
 <alpine.DEB.2.10.1708141532300.63207@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1708141532300.63207@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Aug 14, 2017 at 03:42:54PM -0700, David Rientjes wrote:
> On Mon, 14 Aug 2017, Roman Gushchin wrote:
> > +
> > +static long oom_evaluate_memcg(struct mem_cgroup *memcg,
> > +			       const nodemask_t *nodemask)
> > +{
> > +	struct css_task_iter it;
> > +	struct task_struct *task;
> > +	int elegible = 0;
> > +
> > +	css_task_iter_start(&memcg->css, 0, &it);
> > +	while ((task = css_task_iter_next(&it))) {
> > +		/*
> > +		 * If there are no tasks, or all tasks have oom_score_adj set
> > +		 * to OOM_SCORE_ADJ_MIN and oom_kill_all_tasks is not set,
> > +		 * don't select this memory cgroup.
> > +		 */
> > +		if (!elegible &&
> > +		    (memcg->oom_kill_all_tasks ||
> > +		     task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN))
> > +			elegible = 1;
> 
> I'm curious about the decision made in this conditional and how 
> oom_kill_memcg_member() ignores task->signal->oom_score_adj.  It means 
> that memory.oom_kill_all_tasks overrides /proc/pid/oom_score_adj if it 
> should otherwise be disabled.
> 
> It's undocumented in the changelog, but I'm questioning whether it's the 
> right decision.  Doesn't it make sense to kill all tasks that are not oom 
> disabled, and allow the user to still protect certain processes by their 
> /proc/pid/oom_score_adj setting?  Otherwise, there's no way to do that 
> protection without a sibling memcg and its own reservation of memory.  I'm 
> thinking about a process that governs jobs inside the memcg and if there 
> is an oom kill, it wants to do logging and any cleanup necessary before 
> exiting itself.  It seems like a powerful combination if coupled with oom 
> notification.

Good question!
I think, that an ability to override any oom_score_adj value and get all tasks
killed is more important, than an ability to kill all processes with some
exceptions.

In your example someone still needs to look after the remaining process,
and kill it after some timeout, if it will not quit by itself, right?

The special treatment of the -1000 value (without oom_kill_all_tasks)
is required only to not to break the existing setups.

Generally, oom_score_adj should have a meaning only on a cgroup level,
so extending it to the system level doesn't sound as a good idea.

> 
> Also, s/elegible/eligible/

Shame on me :)
Will fix, thanks!

> 
> Otherwise, looks good!

Great!
Thank you for the reviewing and testing.

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
