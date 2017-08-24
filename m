Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83B17440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 08:29:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n185so959911pga.11
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 05:29:13 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v186si2779319pfv.270.2017.08.24.05.29.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 05:29:12 -0700 (PDT)
Date: Thu, 24 Aug 2017 13:28:46 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v6 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170824122846.GA15916@castle.DHCP.thefacebook.com>
References: <20170823165201.24086-1-guro@fb.com>
 <20170823165201.24086-3-guro@fb.com>
 <20170824114706.GG5943@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170824114706.GG5943@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Michal!

On Thu, Aug 24, 2017 at 01:47:06PM +0200, Michal Hocko wrote:
> This doesn't apply on top of mmotm cleanly. You are missing
> http://lkml.kernel.org/r/20170807113839.16695-3-mhocko@kernel.org

I'll rebase. Thanks!

> 
> On Wed 23-08-17 17:51:59, Roman Gushchin wrote:
> > Traditionally, the OOM killer is operating on a process level.
> > Under oom conditions, it finds a process with the highest oom score
> > and kills it.
> > 
> > This behavior doesn't suit well the system with many running
> > containers:
> > 
> > 1) There is no fairness between containers. A small container with
> > few large processes will be chosen over a large one with huge
> > number of small processes.
> > 
> > 2) Containers often do not expect that some random process inside
> > will be killed. In many cases much safer behavior is to kill
> > all tasks in the container. Traditionally, this was implemented
> > in userspace, but doing it in the kernel has some advantages,
> > especially in a case of a system-wide OOM.
> > 
> > 3) Per-process oom_score_adj affects global OOM, so it's a breache
> > in the isolation.
> 
> Please explain more. I guess you mean that an untrusted memcg could hide
> itself from the global OOM killer by reducing the oom scores? Well you
> need CAP_SYS_RESOURCE do reduce the current oom_score{_adj} as David has
> already pointed out. I also agree that we absolutely must not kill an
> oom disabled task. I am pretty sure somebody is using OOM_SCORE_ADJ_MIN
> as a protection from an untrusted SIGKILL and inconsistent state as a
> result. Those applications simply shouldn't behave differently in the
> global and container contexts.

The main point of the kill_all option is to clean up the victim cgroup
_completely_. If some tasks can survive, that means userspace should
take care of them, look at the cgroup after oom, and kill the survivors
manually.

If you want to rely on OOM_SCORE_ADJ_MIN, don't set kill_all.
I really don't get the usecase for this "kill all, except this and that".

Also, it's really confusing to respect -1000 value, and completely ignore -999.

I believe that any complex userspace OOM handling should use memory.high
and handle memory shortage before an actual OOM.

> 
> If nothing else we have to skip OOM_SCORE_ADJ_MIN tasks during the kill.
> 
> > To address these issues, cgroup-aware OOM killer is introduced.
> > 
> > Under OOM conditions, it tries to find the biggest memory consumer,
> > and free memory by killing corresponding task(s). The difference
> > the "traditional" OOM killer is that it can treat memory cgroups
> > as memory consumers as well as single processes.
> > 
> > By default, it will look for the biggest leaf cgroup, and kill
> > the largest task inside.
> 
> Why? I believe that the semantic should be as simple as kill the largest
> oom killable entity. And the entity is either a process or a memcg which
> is marked that way.

So, you still need to compare memcgroups and processes.

In my case, it's more like an exception (only processes from root memcg,
and only if there are no eligible cgroups with lower oom_priority).
You suggest to rely on this comparison.

> Why should we mix things and select a memcg to kill
> a process inside it? More on that below.

To have some sort of "fairness" in a containerized environemnt.
Say, 1 cgroup with 1 big task, another cgroup with many smaller tasks.
It's not necessary true, that first one is a better victim.

> 
> > But a user can change this behavior by enabling the per-cgroup
> > oom_kill_all_tasks option. If set, it causes the OOM killer treat
> > the whole cgroup as an indivisible memory consumer. In case if it's
> > selected as on OOM victim, all belonging tasks will be killed.
> > 
> > Tasks in the root cgroup are treated as independent memory consumers,
> > and are compared with other memory consumers (e.g. leaf cgroups).
> > The root cgroup doesn't support the oom_kill_all_tasks feature.
> 
> If anything you wouldn't have to treat the root memcg any special. It
> will be like any other memcg which doesn't have oom_kill_all_tasks...
>  
> [...]
> 
> > +static long memcg_oom_badness(struct mem_cgroup *memcg,
> > +			      const nodemask_t *nodemask)
> > +{
> > +	long points = 0;
> > +	int nid;
> > +	pg_data_t *pgdat;
> > +
> > +	for_each_node_state(nid, N_MEMORY) {
> > +		if (nodemask && !node_isset(nid, *nodemask))
> > +			continue;
> > +
> > +		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> > +				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> > +
> > +		pgdat = NODE_DATA(nid);
> > +		points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
> > +					    NR_SLAB_UNRECLAIMABLE);
> > +	}
> > +
> > +	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
> > +		(PAGE_SIZE / 1024);
> > +	points += memcg_page_state(memcg, MEMCG_SOCK);
> > +	points += memcg_page_state(memcg, MEMCG_SWAP);
> > +
> > +	return points;
> 
> I guess I have asked already and we haven't reached any consensus. I do
> not like how you treat memcgs and tasks differently. Why cannot we have
> a memcg score a sum of all its tasks?

It sounds like a more expensive way to get almost the same with less accuracy.
Why it's better?

> How do you want to compare memcg score with tasks score?

I have to do it for tasks in root cgroups, but it shouldn't be a common case.

> This just smells like the outcome of a weird
> semantic that you try to select the largest group I have mentioned
> above.
> 
> This is a rather fundamental concern and I believe we should find a
> consensus on it before going any further. I believe that users shouldn't
> see any difference in the OOM behavior when memcg v2 is used and there
> is no kill-all memcg. If there is such a memcg then we should treat only
> those specially. But you might have really strong usecases which haven't
> been presented or I've missed their importance.

I'll answer in the reply for your comments to the next commit.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
