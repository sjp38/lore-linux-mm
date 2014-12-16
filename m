Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3502D6B006E
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:39:39 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id x12so17176470wgg.24
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 05:39:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cu6si22001931wib.36.2014.12.16.05.39.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 05:39:38 -0800 (PST)
Date: Tue, 16 Dec 2014 14:39:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: Provide knob for force OOM into the memcg
Message-ID: <20141216133935.GK22914@dhcp22.suse.cz>
References: <1418736335-30915-1-git-send-email-cpandya@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1418736335-30915-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 16-12-14 18:55:35, Chintan Pandya wrote:
> We may want to use memcg to limit the total memory
> footprint of all the processes within the one group.
> This may lead to a situation where any arbitrary
> process cannot get migrated to that one  memcg
> because its limits will be breached. Or, process can
> get migrated but even being most recently used
> process, it can get killed by in-cgroup OOM. To
> avoid such scenarios, provide a convenient knob
> by which we can forcefully trigger OOM and make
> a room for upcoming process.
> 
> To trigger force OOM,
> $ echo 1 > /<memcg_path>/memory.force_oom

What would prevent another task deplete that memory shortly after you
triggered OOM and end up in the same situation? E.g. while the moving
task is migrating its charges to the new group...

Why cannot you simply disable OOM killer in that memcg and handle it
from userspace properly?

> Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
> ---
>  mm/memcontrol.c | 29 +++++++++++++++++++++++++++++
>  1 file changed, 29 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ef91e85..4c68aa7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3305,6 +3305,30 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>  	return 0;
>  }
>  
> +static int mem_cgroup_force_oom(struct cgroup *cont, unsigned int event)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	int ret;
> +
> +	if (mem_cgroup_is_root(memcg))
> +		return -EINVAL;
> +
> +	css_get(&memcg->css);
> +	ret = mem_cgroup_handle_oom(memcg, GFP_KERNEL, 0);
> +	css_put(&memcg->css);
> +
> +	return ret;
> +}
> +
> +static int mem_cgroup_force_oom_write(struct cgroup *cgrp,
> +				struct cftype *cft, u64 val)
> +{
> +	if (val > 1 || val < 1)
> +		return -EINVAL;
> +
> +	return mem_cgroup_force_oom(cgrp, 0);
> +}
> +
>  static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
>  					    char *buf, size_t nbytes,
>  					    loff_t off)
> @@ -4442,6 +4466,11 @@ static struct cftype mem_cgroup_files[] = {
>  		.write = mem_cgroup_force_empty_write,
>  	},
>  	{
> +		.name = "force_oom",
> +		.trigger = mem_cgroup_force_oom,
> +		.write_u64 = mem_cgroup_force_oom_write,
> +	},
> +	{
>  		.name = "use_hierarchy",
>  		.write_u64 = mem_cgroup_hierarchy_write,
>  		.read_u64 = mem_cgroup_hierarchy_read,
> -- 
> Chintan Pandya
> 
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> member of the Code Aurora Forum, hosted by The Linux Foundation
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
