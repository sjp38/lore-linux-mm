Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57CAC44084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 19:05:52 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 125so131462595pgi.2
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 16:05:52 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id p91si9773181plb.278.2017.07.10.16.05.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 16:05:51 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id c73so57061837pfk.2
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 16:05:51 -0700 (PDT)
Date: Mon, 10 Jul 2017 16:05:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v3 2/6] mm, oom: cgroup-aware OOM killer
In-Reply-To: <1498079956-24467-3-git-send-email-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1707101547010.116811@chino.kir.corp.google.com>
References: <1498079956-24467-1-git-send-email-guro@fb.com> <1498079956-24467-3-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 21 Jun 2017, Roman Gushchin wrote:

> Traditionally, the OOM killer is operating on a process level.
> Under oom conditions, it finds a process with the highest oom score
> and kills it.
> 
> This behavior doesn't suit well the system with many running
> containers. There are two main issues:
> 
> 1) There is no fairness between containers. A small container with
> few large processes will be chosen over a large one with huge
> number of small processes.
> 

Yes, the original motivation was to limit killing to a single process, if 
possible.  To do that, we kill the process with the largest rss to free 
the most memory and rely on the user to configure /proc/pid/oom_score_adj 
if something else should be prioritized.

With containerization and overcommit of system memory, we concur that 
killing the single largest process isn't always preferable and neglects 
the priority of its memcg.  Your motivation seems to be to provide 
fairness between one memcg with a large process and one memcg with a large 
number of small processes; I'm curious if you are concerned about the 
priority of a memcg hierarchy (how important that "job" is) or whether you 
are strictly concerned with "largeness" of memcgs relative to each other.

> 2) Containers often do not expect that some random process inside
> will be killed. In many cases much more safer behavior is to kill
> all tasks in the container. Traditionally, this was implemented
> in userspace, but doing it in the kernel has some advantages,
> especially in a case of a system-wide OOM.
> 

We agree.

> 3) Per-process oom_score_adj affects global OOM, so it's a breache
> in the isolation.
> 

This should only be a consequence of overcommiting memcgs at the top level 
so the system oom killer is actually ever invoked, otherwise per-process 
oom_score_adj works well for memcg oom killing.

> To address these issues, cgroup-aware OOM killer is introduced.
> 
> Under OOM conditions, it tries to find the biggest memory consumer,
> and free memory by killing corresponding task(s). The difference
> the "traditional" OOM killer is that it can treat memory cgroups
> as memory consumers as well as single processes.
> 
> By default, it will look for the biggest leaf cgroup, and kill
> the largest task inside.
> 
> But a user can change this behavior by enabling the per-cgroup
> oom_kill_all_tasks option. If set, it causes the OOM killer treat
> the whole cgroup as an indivisible memory consumer. In case if it's
> selected as on OOM victim, all belonging tasks will be killed.
> 

These are two different things, right?  We can adjust how the system oom 
killer chooses victims when memcg hierarchies overcommit the system to not 
strictly prefer the single process with the largest rss without killing 
everything attached to the memcg.

Separately: do you not intend to support memcg priorities at all, but 
rather strictly consider the "largeness" of a memcg versus other memcgs?

In our methodology, each memcg is assigned a priority value and the 
iteration of the hierarchy simply compares and visits the memcg with the 
lowest priority at each level and then selects the largest process to 
kill.  This could also support a "kill-all" knob.

	struct mem_cgroup *memcg = root_mem_cgroup;
	struct mem_cgroup *low_memcg;
	unsigned long low_priority;

next:
	low_memcg = NULL;
	low_priority = ULONG_MAX;
	for_each_child_of_memcg(memcg) {
		unsigned long prio = memcg_oom_priority(memcg);

		if (prio < low_priority) {
			low_memcg = memcg;
			low_priority = prio;
		}		
	}
	if (low_memcg)
		goto next;
	oom_kill_process_from_memcg(memcg);

So this is a priority based model that is different than your aggregate 
usage model but I think it allows userspace to define a more powerful 
policy.  We certainly may want to kill from a memcg with a single large 
process, or we may want to kill from a memcg with several small processes, 
it depends on the importance of that job.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
