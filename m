Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C5D04831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 13:02:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c202so26324380wme.10
        for <linux-mm@kvack.org>; Mon, 22 May 2017 10:02:16 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id a66si14279614wrc.296.2017.05.22.10.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 10:02:15 -0700 (PDT)
Date: Mon, 22 May 2017 18:01:16 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170522170116.GB22625@castle>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
 <20170520183729.GA3195@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170520183729.GA3195@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, May 20, 2017 at 09:37:29PM +0300, Vladimir Davydov wrote:
> Hello Roman,

Hi Vladimir!

> 
> On Thu, May 18, 2017 at 05:28:04PM +0100, Roman Gushchin wrote:
> ...
> > +5-2-4. Cgroup-aware OOM Killer
> > +
> > +Cgroup v2 memory controller implements a cgroup-aware OOM killer.
> > +It means that it treats memory cgroups as memory consumers
> > +rather then individual processes. Under the OOM conditions it tries
> > +to find an elegible leaf memory cgroup, and kill all processes
> > +in this cgroup. If it's not possible (e.g. all processes belong
> > +to the root cgroup), it falls back to the traditional per-process
> > +behaviour.
> 
> I agree that the current OOM victim selection algorithm is totally
> unfair in a system using containers and it has been crying for rework
> for the last few years now, so it's great to see this finally coming.
> 
> However, I don't reckon that killing a whole leaf cgroup is always the
> best practice. It does make sense when cgroups are used for
> containerizing services or applications, because a service is unlikely
> to remain operational after one of its processes is gone, but one can
> also use cgroups to containerize processes started by a user. Kicking a
> user out for one of her process has gone mad doesn't sound right to me.

I agree, that it's not always a best practise, if you're not allowed
to change the cgroup configuration (e.g. create new cgroups).
IMHO, this case is mostly covered by using the v1 cgroup interface,
which remains unchanged.
If you do have control over cgroups, you can put processes into
separate cgroups, and obtain control over OOM victim selection and killing.

> Another example when the policy you're suggesting fails in my opinion is
> in case a service (cgroup) consists of sub-services (sub-cgroups) that
> run processes. The main service may stop working normally if one of its
> sub-services is killed. So it might make sense to kill not just an
> individual process or a leaf cgroup, but the whole main service with all
> its sub-services.

I agree, although I do not pretend for solving all possible
userspace problems caused by an OOM.

How to react on an OOM - is definitely a policy, which depends
on the workload. Nothing is changing here from how it's working now,
except now kernel will choose a victim cgroup, and kill the victim cgroup
rather than a process.

> And both kinds of workloads (services/applications and individual
> processes run by users) can co-exist on the same host - consider the
> default systemd setup, for instance.
> 
> IMHO it would be better to give users a choice regarding what they
> really want for a particular cgroup in case of OOM - killing the whole
> cgroup or one of its descendants. For example, we could introduce a
> per-cgroup flag that would tell the kernel whether the cgroup can
> tolerate killing a descendant or not. If it can, the kernel will pick
> the fattest sub-cgroup or process and check it. If it cannot, it will
> kill the whole cgroup and all its processes and sub-cgroups.

The last thing we want to do, is to compare processes with cgroups.
I agree, that we can have some option to disable the cgroup-aware OOM at all,
mostly for backward-compatibility. But I don't think it should be a
per-cgroup configuration option, which we will support forever.

> 
> > +
> > +The memory controller tries to make the best choise of a victim cgroup.
> > +In general, it tries to select the largest cgroup, matching given
> > +node/zone requirements, but the concrete algorithm is not defined,
> > +and may be changed later.
> > +
> > +This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
> > +the memory controller considers only cgroups belonging to a sub-tree
> > +of the OOM-ing cgroup, including itself.
> ...
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index c131f7e..8d07481 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2625,6 +2625,75 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
> >  	return ret;
> >  }
> >  
> > +bool mem_cgroup_select_oom_victim(struct oom_control *oc)
> > +{
> > +	struct mem_cgroup *iter;
> > +	unsigned long chosen_memcg_points;
> > +
> > +	oc->chosen_memcg = NULL;
> > +
> > +	if (mem_cgroup_disabled())
> > +		return false;
> > +
> > +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> > +		return false;
> > +
> > +	pr_info("Choosing a victim memcg because of %s",
> > +		oc->memcg ?
> > +		"memory limit reached of cgroup " :
> > +		"out of memory\n");
> > +	if (oc->memcg) {
> > +		pr_cont_cgroup_path(oc->memcg->css.cgroup);
> > +		pr_cont("\n");
> > +	}
> > +
> > +	chosen_memcg_points = 0;
> > +
> > +	for_each_mem_cgroup_tree(iter, oc->memcg) {
> > +		unsigned long points;
> > +		int nid;
> > +
> > +		if (mem_cgroup_is_root(iter))
> > +			continue;
> > +
> > +		if (memcg_has_children(iter))
> > +			continue;
> > +
> > +		points = 0;
> > +		for_each_node_state(nid, N_MEMORY) {
> > +			if (oc->nodemask && !node_isset(nid, *oc->nodemask))
> > +				continue;
> > +			points += mem_cgroup_node_nr_lru_pages(iter, nid,
> > +					LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> > +		}
> > +		points += mem_cgroup_get_nr_swap_pages(iter);
> 
> I guess we should also take into account kmem as well (unreclaimable
> slabs, kernel stacks, socket buffers).

Added to v2 (I'll post it soon).
Good idea, thanks!

--
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
