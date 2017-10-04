Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 458136B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 16:04:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u78so11531353wmd.4
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 13:04:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l2si9065609edf.456.2017.10.04.13.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Oct 2017 13:04:57 -0700 (PDT)
Date: Wed, 4 Oct 2017 16:04:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [v10 5/6] mm, oom: add cgroup v2 mount option for cgroup-aware
 OOM killer
Message-ID: <20171004200453.GE1501@cmpxchg.org>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-6-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171004154638.710-6-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 04, 2017 at 04:46:37PM +0100, Roman Gushchin wrote:
> Add a "groupoom" cgroup v2 mount option to enable the cgroup-aware
> OOM killer. If not set, the OOM selection is performed in
> a "traditional" per-process way.
> 
> The behavior can be changed dynamically by remounting the cgroupfs.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
>  include/linux/cgroup-defs.h |  5 +++++
>  kernel/cgroup/cgroup.c      | 10 ++++++++++
>  mm/memcontrol.c             |  3 +++
>  3 files changed, 18 insertions(+)
> 
> diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
> index 3e55bbd31ad1..cae5343a8b21 100644
> --- a/include/linux/cgroup-defs.h
> +++ b/include/linux/cgroup-defs.h
> @@ -80,6 +80,11 @@ enum {
>  	 * Enable cpuset controller in v1 cgroup to use v2 behavior.
>  	 */
>  	CGRP_ROOT_CPUSET_V2_MODE = (1 << 4),
> +
> +	/*
> +	 * Enable cgroup-aware OOM killer.
> +	 */
> +	CGRP_GROUP_OOM = (1 << 5),
>  };
>  
>  /* cftype->flags */
> diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
> index c3421ee0d230..8d8aa46ff930 100644
> --- a/kernel/cgroup/cgroup.c
> +++ b/kernel/cgroup/cgroup.c
> @@ -1709,6 +1709,9 @@ static int parse_cgroup_root_flags(char *data, unsigned int *root_flags)
>  		if (!strcmp(token, "nsdelegate")) {
>  			*root_flags |= CGRP_ROOT_NS_DELEGATE;
>  			continue;
> +		} else if (!strcmp(token, "groupoom")) {
> +			*root_flags |= CGRP_GROUP_OOM;
> +			continue;
>  		}
>  
>  		pr_err("cgroup2: unknown option \"%s\"\n", token);
> @@ -1725,6 +1728,11 @@ static void apply_cgroup_root_flags(unsigned int root_flags)
>  			cgrp_dfl_root.flags |= CGRP_ROOT_NS_DELEGATE;
>  		else
>  			cgrp_dfl_root.flags &= ~CGRP_ROOT_NS_DELEGATE;
> +
> +		if (root_flags & CGRP_GROUP_OOM)
> +			cgrp_dfl_root.flags |= CGRP_GROUP_OOM;
> +		else
> +			cgrp_dfl_root.flags &= ~CGRP_GROUP_OOM;
>  	}
>  }
>  
> @@ -1732,6 +1740,8 @@ static int cgroup_show_options(struct seq_file *seq, struct kernfs_root *kf_root
>  {
>  	if (cgrp_dfl_root.flags & CGRP_ROOT_NS_DELEGATE)
>  		seq_puts(seq, ",nsdelegate");
> +	if (cgrp_dfl_root.flags & CGRP_GROUP_OOM)
> +		seq_puts(seq, ",groupoom");
>  	return 0;
>  }
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1fcd6cc353d5..2e82625bd354 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2865,6 +2865,9 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
>  	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
>  		return false;
>  
> +	if (!(cgrp_dfl_root.flags & CGRP_GROUP_OOM))
> +		return false;

That will silently ignore what the user writes to the memory.oom_group
control files across the system's cgroup tree.

We'll have a knob that lets the workload declare itself an indivisible
memory consumer, that it would like to get killed in one piece, and
it's silently ignored because of a mount option they forgot to pass.

That's not good from an interface perspective.

On the other hand, the only benefit of this patch is to shield users
from changes to the OOM killing heuristics. Yet, it's really hard to
imagine that modifying the victim selection process slightly could be
called a regression in any way. We have done that many times over,
without a second thought on backwards compatibility:

5e9d834a0e0c oom: sacrifice child with highest badness score for parent
a63d83f427fb oom: badness heuristic rewrite
778c14affaf9 mm, oom: base root bonus on current usage

Let's not make the userspace interface crap because of some misguided
idea that the OOM heuristic is a hard promise to userspace. It's never
been, and nobody has complained about changes in the past.

This case is doubly silly, as the behavior change only applies to
cgroup2, which doesn't exactly have a large base of legacy users yet.

Let's just drop this 5/6 patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
