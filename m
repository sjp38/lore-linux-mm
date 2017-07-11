Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 483806B04FC
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 08:52:00 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 77so31560721wrb.11
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 05:52:00 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u10si8706460wmg.100.2017.07.11.05.51.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 05:51:58 -0700 (PDT)
Date: Tue, 11 Jul 2017 13:51:24 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v3 2/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20170711125124.GA12406@castle>
References: <1498079956-24467-1-git-send-email-guro@fb.com>
 <1498079956-24467-3-git-send-email-guro@fb.com>
 <alpine.DEB.2.10.1707101547010.116811@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1707101547010.116811@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jul 10, 2017 at 04:05:49PM -0700, David Rientjes wrote:
> On Wed, 21 Jun 2017, Roman Gushchin wrote:
> 
> > Traditionally, the OOM killer is operating on a process level.
> > Under oom conditions, it finds a process with the highest oom score
> > and kills it.
> > 
> > This behavior doesn't suit well the system with many running
> > containers. There are two main issues:
> > 
> > 1) There is no fairness between containers. A small container with
> > few large processes will be chosen over a large one with huge
> > number of small processes.
> > 
> 
> Yes, the original motivation was to limit killing to a single process, if 
> possible.  To do that, we kill the process with the largest rss to free 
> the most memory and rely on the user to configure /proc/pid/oom_score_adj 
> if something else should be prioritized.
> 
> With containerization and overcommit of system memory, we concur that 
> killing the single largest process isn't always preferable and neglects 
> the priority of its memcg.  Your motivation seems to be to provide 
> fairness between one memcg with a large process and one memcg with a large 
> number of small processes; I'm curious if you are concerned about the 
> priority of a memcg hierarchy (how important that "job" is) or whether you 
> are strictly concerned with "largeness" of memcgs relative to each other.

I'm pretty sure we should provide some way to prioritize some cgroups
over other (in terms of oom killer preferences), but I'm not 100% sure yet,
what's the best way to do it. I've suggested something similar to the existing
oom_score_adj for tasks, mostly to folow the existing design.

One of the questions to answer in priority-based model is
how to compare tasks in the root cgroup with cgroups?

> > ...
> > By default, it will look for the biggest leaf cgroup, and kill
> > the largest task inside.
> > 
> > But a user can change this behavior by enabling the per-cgroup
> > oom_kill_all_tasks option. If set, it causes the OOM killer treat
> > the whole cgroup as an indivisible memory consumer. In case if it's
> > selected as on OOM victim, all belonging tasks will be killed.
> > 
> 
> These are two different things, right?  We can adjust how the system oom 
> killer chooses victims when memcg hierarchies overcommit the system to not 
> strictly prefer the single process with the largest rss without killing 
> everything attached to the memcg.

They are different, and I thought about providing two independent knobs.
But after all I haven't found enough real life examples, where it can be useful.
Can you provide something here?

Also, they are different only for non-leaf cgroups; leaf cgroups
are always treated as indivisible memory consumers during victim selection.

I assume, that containerized systems will always set oom_kill_all_tasks for
top-level container memory cgroups. By default it's turned off
to provide backward compatibility with current behavior and avoid
excessive kills and support oom_score_adj==-1000 (I've added this to v4,
will post soon).

> Separately: do you not intend to support memcg priorities at all, but 
> rather strictly consider the "largeness" of a memcg versus other memcgs?

Answered upper.

> In our methodology, each memcg is assigned a priority value and the 
> iteration of the hierarchy simply compares and visits the memcg with the 
> lowest priority at each level and then selects the largest process to 
> kill.  This could also support a "kill-all" knob.
> 
> 	struct mem_cgroup *memcg = root_mem_cgroup;
> 	struct mem_cgroup *low_memcg;
> 	unsigned long low_priority;
> 
> next:
> 	low_memcg = NULL;
> 	low_priority = ULONG_MAX;
> 	for_each_child_of_memcg(memcg) {
> 		unsigned long prio = memcg_oom_priority(memcg);
> 
> 		if (prio < low_priority) {
> 			low_memcg = memcg;
> 			low_priority = prio;
> 		}		
> 	}
> 	if (low_memcg)
> 		goto next;
> 	oom_kill_process_from_memcg(memcg);
> 
> So this is a priority based model that is different than your aggregate 
> usage model but I think it allows userspace to define a more powerful 
> policy.  We certainly may want to kill from a memcg with a single large 
> process, or we may want to kill from a memcg with several small processes, 
> it depends on the importance of that job.

I believe, that both models have some advantages.
Priority-based model is more powerful, but requires support from the userspace
to set up these priorities (and, probably, adjust them dynamically).
Size-based model is limited, but provides reasonable behavior
without any additional configuration.

I will agree here with Michal Hocko, that bpf like mechanism can be used
here to provide an option for writing some custom oom policies. After we will
have necessary infrastructure to iterate over cgroup tree, select a cgroup
with largest oom score, and kill a biggest task/all the tasks there,
we can add an ability to customize the cgroup (and maybe tasks) evaluation.

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
