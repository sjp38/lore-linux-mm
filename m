Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7332803BB
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:47:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p67so486793wrb.10
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 04:47:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 190si1487825wmt.171.2017.08.24.04.47.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 04:47:08 -0700 (PDT)
Date: Thu, 24 Aug 2017 13:47:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170824114706.GG5943@dhcp22.suse.cz>
References: <20170823165201.24086-1-guro@fb.com>
 <20170823165201.24086-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170823165201.24086-3-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

This doesn't apply on top of mmotm cleanly. You are missing
http://lkml.kernel.org/r/20170807113839.16695-3-mhocko@kernel.org

On Wed 23-08-17 17:51:59, Roman Gushchin wrote:
> Traditionally, the OOM killer is operating on a process level.
> Under oom conditions, it finds a process with the highest oom score
> and kills it.
> 
> This behavior doesn't suit well the system with many running
> containers:
> 
> 1) There is no fairness between containers. A small container with
> few large processes will be chosen over a large one with huge
> number of small processes.
> 
> 2) Containers often do not expect that some random process inside
> will be killed. In many cases much safer behavior is to kill
> all tasks in the container. Traditionally, this was implemented
> in userspace, but doing it in the kernel has some advantages,
> especially in a case of a system-wide OOM.
> 
> 3) Per-process oom_score_adj affects global OOM, so it's a breache
> in the isolation.

Please explain more. I guess you mean that an untrusted memcg could hide
itself from the global OOM killer by reducing the oom scores? Well you
need CAP_SYS_RESOURCE do reduce the current oom_score{_adj} as David has
already pointed out. I also agree that we absolutely must not kill an
oom disabled task. I am pretty sure somebody is using OOM_SCORE_ADJ_MIN
as a protection from an untrusted SIGKILL and inconsistent state as a
result. Those applications simply shouldn't behave differently in the
global and container contexts.

If nothing else we have to skip OOM_SCORE_ADJ_MIN tasks during the kill.

> To address these issues, cgroup-aware OOM killer is introduced.
> 
> Under OOM conditions, it tries to find the biggest memory consumer,
> and free memory by killing corresponding task(s). The difference
> the "traditional" OOM killer is that it can treat memory cgroups
> as memory consumers as well as single processes.
> 
> By default, it will look for the biggest leaf cgroup, and kill
> the largest task inside.

Why? I believe that the semantic should be as simple as kill the largest
oom killable entity. And the entity is either a process or a memcg which
is marked that way. Why should we mix things and select a memcg to kill
a process inside it? More on that below.

> But a user can change this behavior by enabling the per-cgroup
> oom_kill_all_tasks option. If set, it causes the OOM killer treat
> the whole cgroup as an indivisible memory consumer. In case if it's
> selected as on OOM victim, all belonging tasks will be killed.
> 
> Tasks in the root cgroup are treated as independent memory consumers,
> and are compared with other memory consumers (e.g. leaf cgroups).
> The root cgroup doesn't support the oom_kill_all_tasks feature.

If anything you wouldn't have to treat the root memcg any special. It
will be like any other memcg which doesn't have oom_kill_all_tasks...
 
[...]

> +static long memcg_oom_badness(struct mem_cgroup *memcg,
> +			      const nodemask_t *nodemask)
> +{
> +	long points = 0;
> +	int nid;
> +	pg_data_t *pgdat;
> +
> +	for_each_node_state(nid, N_MEMORY) {
> +		if (nodemask && !node_isset(nid, *nodemask))
> +			continue;
> +
> +		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> +				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> +
> +		pgdat = NODE_DATA(nid);
> +		points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
> +					    NR_SLAB_UNRECLAIMABLE);
> +	}
> +
> +	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
> +		(PAGE_SIZE / 1024);
> +	points += memcg_page_state(memcg, MEMCG_SOCK);
> +	points += memcg_page_state(memcg, MEMCG_SWAP);
> +
> +	return points;

I guess I have asked already and we haven't reached any consensus. I do
not like how you treat memcgs and tasks differently. Why cannot we have
a memcg score a sum of all its tasks? How do you want to compare memcg
score with tasks score? This just smells like the outcome of a weird
semantic that you try to select the largest group I have mentioned
above.

This is a rather fundamental concern and I believe we should find a
consensus on it before going any further. I believe that users shouldn't
see any difference in the OOM behavior when memcg v2 is used and there
is no kill-all memcg. If there is such a memcg then we should treat only
those specially. But you might have really strong usecases which haven't
been presented or I've missed their importance.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
