Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 87C186B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 07:50:42 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p5so22329066pgn.7
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 04:50:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l124si9646849pgl.128.2017.10.03.04.50.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 04:50:41 -0700 (PDT)
Date: Tue, 3 Oct 2017 13:50:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v9 4/5] mm, oom: add cgroup v2 mount option for cgroup-aware
 OOM killer
Message-ID: <20171003115036.3zzydsiiz7hbx4jg@dhcp22.suse.cz>
References: <20170927130936.8601-1-guro@fb.com>
 <20170927130936.8601-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927130936.8601-5-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 27-09-17 14:09:35, Roman Gushchin wrote:
> Add a "groupoom" cgroup v2 mount option to enable the cgroup-aware
> OOM killer. If not set, the OOM selection is performed in
> a "traditional" per-process way.
> 
> The behavior can be changed dynamically by remounting the cgroupfs.

I do not have a strong preference about this. I would just be worried
that it is usually systemd which tries to own the whole hierarchy and it
has no idea what is the proper oom behavior because that highly depends
on the specific workload so a global sysctl/kernel command line argument
would fit better IMHO.

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
> index 353bb590713e..3f82b6f22d63 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2852,6 +2852,9 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
>  	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
>  		return false;
>  
> +	if (!(cgrp_dfl_root.flags & CGRP_GROUP_OOM))
> +		return false;
> +
>  	if (oc->memcg)
>  		root = oc->memcg;
>  	else
> -- 
> 2.13.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
