Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCBCC280300
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 09:44:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b9so4898291wra.3
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 06:44:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f128si357216wmd.63.2017.09.05.06.44.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Sep 2017 06:44:15 -0700 (PDT)
Date: Tue, 5 Sep 2017 15:44:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Message-ID: <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-6-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170904142108.7165-6-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

I will go and check patch 2 more deeply but this is something that I
wanted to sort out first.

On Mon 04-09-17 15:21:08, Roman Gushchin wrote:
> Introducing of cgroup-aware OOM killer changes the victim selection
> algorithm used by default: instead of picking the largest process,
> it will pick the largest memcg and then the largest process inside.
> 
> This affects only cgroup v2 users.
> 
> To provide a way to use cgroups v2 if the old OOM victim selection
> algorithm is preferred for some reason, the nogroupoom mount option
> is added.
> 
> If set, the OOM selection is performed in a "traditional" per-process
> way. Both oom_priority and oom_group memcg knobs are ignored.

Why is this an opt out rather than opt-in? IMHO the original oom logic
should be preserved by default and specific workloads should opt in for
the cgroup aware logic. Changing the global behavior depending on
whether cgroup v2 interface is in use is more than unexpected and IMHO
wrong approach to take. I think we should instead go with 
oom_strategy=[alloc_task,biggest_task,cgroup]

we currently have alloc_task (via sysctl_oom_kill_allocating_task) and
biggest_task which is the default. You are adding cgroup and the more I
think about the more I agree that it doesn't really make sense to try to
fit thew new semantic into the existing one (compare tasks to kill-all
memcgs). Just introduce a new strategy and define a new semantic from
scratch. Memcg priority and kill-all are a natural extension of this new
strategy. This will make the life easier and easier to understand by
users.

Does that make sense to you?

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
>  Documentation/admin-guide/kernel-parameters.txt | 1 +
>  mm/memcontrol.c                                 | 8 ++++++++
>  2 files changed, 9 insertions(+)
> 
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index 28f1a0f84456..07891f1030aa 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -489,6 +489,7 @@
>  			Format: <string>
>  			nosocket -- Disable socket memory accounting.
>  			nokmem -- Disable kernel memory accounting.
> +			nogroupoom -- Disable cgroup-aware OOM killer.
>  
>  	checkreqprot	[SELINUX] Set initial checkreqprot flag value.
>  			Format: { "0" | "1" }
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d7dd293897ca..6a8235dc41f6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -87,6 +87,9 @@ static bool cgroup_memory_nosocket;
>  /* Kernel memory accounting disabled? */
>  static bool cgroup_memory_nokmem;
>  
> +/* Cgroup-aware OOM  disabled? */
> +static bool cgroup_memory_nogroupoom;
> +
>  /* Whether the swap controller is active */
>  #ifdef CONFIG_MEMCG_SWAP
>  int do_swap_account __read_mostly;
> @@ -2822,6 +2825,9 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
>  	if (mem_cgroup_disabled())
>  		return false;
>  
> +	if (cgroup_memory_nogroupoom)
> +		return false;
> +
>  	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
>  		return false;
>  
> @@ -6188,6 +6194,8 @@ static int __init cgroup_memory(char *s)
>  			cgroup_memory_nosocket = true;
>  		if (!strcmp(token, "nokmem"))
>  			cgroup_memory_nokmem = true;
> +		if (!strcmp(token, "nogroupoom"))
> +			cgroup_memory_nogroupoom = true;
>  	}
>  	return 0;
>  }
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
