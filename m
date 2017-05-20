Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 407B1280753
	for <linux-mm@kvack.org>; Sat, 20 May 2017 14:37:41 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m96so5849996lfi.6
        for <linux-mm@kvack.org>; Sat, 20 May 2017 11:37:41 -0700 (PDT)
Received: from smtp44.i.mail.ru (smtp44.i.mail.ru. [94.100.177.104])
        by mx.google.com with ESMTPS id s74si4774255lfi.312.2017.05.20.11.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 May 2017 11:37:39 -0700 (PDT)
Date: Sat, 20 May 2017 21:37:29 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170520183729.GA3195@esperanza>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495124884-28974-1-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Roman,

On Thu, May 18, 2017 at 05:28:04PM +0100, Roman Gushchin wrote:
...
> +5-2-4. Cgroup-aware OOM Killer
> +
> +Cgroup v2 memory controller implements a cgroup-aware OOM killer.
> +It means that it treats memory cgroups as memory consumers
> +rather then individual processes. Under the OOM conditions it tries
> +to find an elegible leaf memory cgroup, and kill all processes
> +in this cgroup. If it's not possible (e.g. all processes belong
> +to the root cgroup), it falls back to the traditional per-process
> +behaviour.

I agree that the current OOM victim selection algorithm is totally
unfair in a system using containers and it has been crying for rework
for the last few years now, so it's great to see this finally coming.

However, I don't reckon that killing a whole leaf cgroup is always the
best practice. It does make sense when cgroups are used for
containerizing services or applications, because a service is unlikely
to remain operational after one of its processes is gone, but one can
also use cgroups to containerize processes started by a user. Kicking a
user out for one of her process has gone mad doesn't sound right to me.

Another example when the policy you're suggesting fails in my opinion is
in case a service (cgroup) consists of sub-services (sub-cgroups) that
run processes. The main service may stop working normally if one of its
sub-services is killed. So it might make sense to kill not just an
individual process or a leaf cgroup, but the whole main service with all
its sub-services.

And both kinds of workloads (services/applications and individual
processes run by users) can co-exist on the same host - consider the
default systemd setup, for instance.

IMHO it would be better to give users a choice regarding what they
really want for a particular cgroup in case of OOM - killing the whole
cgroup or one of its descendants. For example, we could introduce a
per-cgroup flag that would tell the kernel whether the cgroup can
tolerate killing a descendant or not. If it can, the kernel will pick
the fattest sub-cgroup or process and check it. If it cannot, it will
kill the whole cgroup and all its processes and sub-cgroups.

> +
> +The memory controller tries to make the best choise of a victim cgroup.
> +In general, it tries to select the largest cgroup, matching given
> +node/zone requirements, but the concrete algorithm is not defined,
> +and may be changed later.
> +
> +This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
> +the memory controller considers only cgroups belonging to a sub-tree
> +of the OOM-ing cgroup, including itself.
...
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c131f7e..8d07481 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2625,6 +2625,75 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
>  	return ret;
>  }
>  
> +bool mem_cgroup_select_oom_victim(struct oom_control *oc)
> +{
> +	struct mem_cgroup *iter;
> +	unsigned long chosen_memcg_points;
> +
> +	oc->chosen_memcg = NULL;
> +
> +	if (mem_cgroup_disabled())
> +		return false;
> +
> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> +		return false;
> +
> +	pr_info("Choosing a victim memcg because of %s",
> +		oc->memcg ?
> +		"memory limit reached of cgroup " :
> +		"out of memory\n");
> +	if (oc->memcg) {
> +		pr_cont_cgroup_path(oc->memcg->css.cgroup);
> +		pr_cont("\n");
> +	}
> +
> +	chosen_memcg_points = 0;
> +
> +	for_each_mem_cgroup_tree(iter, oc->memcg) {
> +		unsigned long points;
> +		int nid;
> +
> +		if (mem_cgroup_is_root(iter))
> +			continue;
> +
> +		if (memcg_has_children(iter))
> +			continue;
> +
> +		points = 0;
> +		for_each_node_state(nid, N_MEMORY) {
> +			if (oc->nodemask && !node_isset(nid, *oc->nodemask))
> +				continue;
> +			points += mem_cgroup_node_nr_lru_pages(iter, nid,
> +					LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> +		}
> +		points += mem_cgroup_get_nr_swap_pages(iter);

I guess we should also take into account kmem as well (unreclaimable
slabs, kernel stacks, socket buffers).

> +
> +		pr_info("Memcg ");
> +		pr_cont_cgroup_path(iter->css.cgroup);
> +		pr_cont(": %lu\n", points);
> +
> +		if (points > chosen_memcg_points) {
> +			if (oc->chosen_memcg)
> +				css_put(&oc->chosen_memcg->css);
> +
> +			oc->chosen_memcg = iter;
> +			css_get(&iter->css);
> +
> +			chosen_memcg_points = points;
> +		}
> +	}
> +
> +	if (oc->chosen_memcg) {
> +		pr_info("Kill memcg ");
> +		pr_cont_cgroup_path(oc->chosen_memcg->css.cgroup);
> +		pr_cont(" (%lu)\n", chosen_memcg_points);
> +	} else {
> +		pr_info("No elegible memory cgroup found\n");
> +	}
> +
> +	return !!oc->chosen_memcg;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
