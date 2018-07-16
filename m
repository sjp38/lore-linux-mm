Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79B8E6B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 14:16:42 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y130-v6so46346116qka.1
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 11:16:42 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 41-v6si6000149qvc.142.2018.07.16.11.16.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 11:16:40 -0700 (PDT)
Date: Mon, 16 Jul 2018 11:16:17 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [patch v3 -mm 3/6] mm, memcg: add hierarchical usage oom policy
Message-ID: <20180716181613.GA28327@castle>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1803151351140.55261@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1803161405410.209509@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1803221451370.17056@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1807131604560.217600@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1807131605590.217600@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807131605590.217600@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 13, 2018 at 04:07:29PM -0700, David Rientjes wrote:
> One of the three significant concerns brought up about the cgroup aware
> oom killer is that its decisionmaking is completely evaded by creating
> subcontainers and attaching processes such that the ancestor's usage does
> not exceed another cgroup on the system.
> 
> Consider the example from the previous patch where "memory" is set in
> each mem cgroup's cgroup.controllers:
> 
> 	mem cgroup	cgroup.procs
> 	==========	============
> 	/cg1		1 process consuming 250MB
> 	/cg2		3 processes consuming 100MB each
> 	/cg3/cg31	2 processes consuming 100MB each
> 	/cg3/cg32	2 processes consuming 100MB each
> 
> If memory.oom_policy is "cgroup", a process from /cg2 is chosen because it
> is in the single indivisible memory consumer with the greatest usage.
> 
> The true usage of /cg3 is actually 400MB, but a process from /cg2 is
> chosen because cgroups are compared individually rather than
> hierarchically.
> 
> If a system is divided into two users, for example:
> 
> 	mem cgroup	memory.max
> 	==========	==========
> 	/userA		250MB
> 	/userB		250MB
> 
> If /userA runs all processes attached to the local mem cgroup, whereas
> /userB distributes their processes over a set of subcontainers under
> /userB, /userA will be unfairly penalized.
> 
> There is incentive with cgroup v2 to distribute processes over a set of
> subcontainers if those processes shall be constrained by other cgroup
> controllers; this is a direct result of mandating a single, unified
> hierarchy for cgroups.  A user may also reasonably do this for mem cgroup
> control or statistics.  And, a user may do this to evade the cgroup-aware
> oom killer selection logic.
> 
> This patch adds an oom policy, "tree", that accounts for hierarchical
> usage when comparing cgroups and the cgroup aware oom killer is enabled by
> an ancestor.  This allows administrators, for example, to require users in
> their own top-level mem cgroup subtree to be accounted for with
> hierarchical usage.  In other words, they can longer evade the oom killer
> by using other controllers or subcontainers.
> 
> If an oom policy of "tree" is in place for a subtree, such as /cg3 above,
> the hierarchical usage is used for comparisons with other cgroups if
> either "cgroup" or "tree" is the oom policy of the oom mem cgroup.  Thus,
> if /cg3/memory.oom_policy is "tree", one of the processes from /cg3's
> subcontainers is chosen for oom kill.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Documentation/admin-guide/cgroup-v2.rst | 17 ++++++++++++++---
>  include/linux/memcontrol.h              |  5 +++++
>  mm/memcontrol.c                         | 18 ++++++++++++------
>  3 files changed, 31 insertions(+), 9 deletions(-)
> 
> diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
> --- a/Documentation/admin-guide/cgroup-v2.rst
> +++ b/Documentation/admin-guide/cgroup-v2.rst
> @@ -1113,6 +1113,10 @@ PAGE_SIZE multiple when read back.
>  	memory consumers; that is, they will compare mem cgroup usage rather
>  	than process memory footprint.  See the "OOM Killer" section below.
>  
> +	If "tree", the OOM killer will compare mem cgroups and its subtree
> +	as a single indivisible memory consumer.  This policy cannot be set
> +	on the root mem cgroup.  See the "OOM Killer" section below.
> +
>  	When an OOM condition occurs, the policy is dictated by the mem
>  	cgroup that is OOM (the root mem cgroup for a system-wide OOM
>  	condition).  If a descendant mem cgroup has a policy of "none", for
> @@ -1120,6 +1124,10 @@ PAGE_SIZE multiple when read back.
>  	the heuristic will still compare mem cgroups as indivisible memory
>  	consumers.
>  
> +	When an OOM condition occurs in a mem cgroup with an OOM policy of
> +	"cgroup" or "tree", the OOM killer will compare mem cgroups with
> +	"cgroup" policy individually with "tree" policy subtrees.
> +
>    memory.events
>  	A read-only flat-keyed file which exists on non-root cgroups.
>  	The following entries are defined.  Unless specified
> @@ -1355,7 +1363,7 @@ out of memory, its memory.oom_policy will dictate how the OOM killer will
>  select a process, or cgroup, to kill.  Likewise, when the system is OOM,
>  the policy is dictated by the root mem cgroup.
>  
> -There are currently two available oom policies:
> +There are currently three available oom policies:
>  
>   - "none": default, choose the largest single memory hogging process to
>     oom kill, as traditionally the OOM killer has always done.
> @@ -1364,6 +1372,9 @@ There are currently two available oom policies:
>     subtree as an OOM victim and kill at least one process, depending on
>     memory.oom_group, from it.
>  
> + - "tree": choose the cgroup with the largest memory footprint considering
> +   itself and its subtree and kill at least one process.
> +
>  When selecting a cgroup as a victim, the OOM killer will kill the process
>  with the largest memory footprint.  A user can control this behavior by
>  enabling the per-cgroup memory.oom_group option.  If set, it causes the
> @@ -1382,8 +1393,8 @@ Please, note that memory charges are not migrating if tasks
>  are moved between different memory cgroups. Moving tasks with
>  significant memory footprint may affect OOM victim selection logic.
>  If it's a case, please, consider creating a common ancestor for
> -the source and destination memory cgroups and enabling oom_group
> -on ancestor layer.
> +the source and destination memory cgroups and setting a policy of "tree"
> +and enabling oom_group on an ancestor layer.
>  
>  
>  IO
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -77,6 +77,11 @@ enum memcg_oom_policy {
>  	 * mem cgroup as an indivisible consumer
>  	 */
>  	MEMCG_OOM_POLICY_CGROUP,
> +	/*
> +	 * Tree cgroup usage for all descendant memcg groups, treating each mem
> +	 * cgroup and its subtree as an indivisible consumer
> +	 */
> +	MEMCG_OOM_POLICY_TREE,
>  };
>  
>  struct mem_cgroup_reclaim_cookie {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2952,7 +2952,7 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
>  	/*
>  	 * The oom_score is calculated for leaf memory cgroups (including
>  	 * the root memcg).
> -	 * Non-leaf oom_group cgroups accumulating score of descendant
> +	 * Cgroups with oom policy of "tree" accumulate the score of descendant
>  	 * leaf memory cgroups.
>  	 */
>  	rcu_read_lock();
> @@ -2961,10 +2961,11 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
>  
>  		/*
>  		 * We don't consider non-leaf non-oom_group memory cgroups
> -		 * as OOM victims.
> +		 * without the oom policy of "tree" as OOM victims.
>  		 */
>  		if (memcg_has_children(iter) && iter != root_mem_cgroup &&
> -		    !mem_cgroup_oom_group(iter))
> +		    !mem_cgroup_oom_group(iter) &&
> +		    iter->oom_policy != MEMCG_OOM_POLICY_TREE)
>  			continue;

Hello, David!

I think that there is an inconsistency in the memory.oom_policy definition.
"none" and "cgroup" policies defining how the OOM scoped to this particular
memory cgroup (or system, if set on root) is handled. And all sub-tree
settings do not matter at all, right? Also, if a memory cgroup has no
memory.max set, there is no meaning in setting memory.oom_policy.

And "tree" is different. It actually changes how the selection algorithm works,
and sub-tree settings do matter in this case.

I find it very confusing.

Thanks!
