Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E650D6B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 04:39:54 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n2-v6so326300edr.5
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 01:39:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r19-v6si3634362eda.307.2018.06.22.01.39.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 01:39:52 -0700 (PDT)
Date: Fri, 22 Jun 2018 10:39:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9] Refactor part of the oom report in dump_header
Message-ID: <20180622083949.GR10465@dhcp22.suse.cz>
References: <1529056341-16182-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529056341-16182-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

On Fri 15-06-18 17:52:21, ufo19890607@gmail.com wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> Some users complains that system-wide oom report does not print memcg's
> name which contains the task killed by the oom-killer. The current system
> wide oom report prints the task's command, gfp_mask, order ,oom_score_adj
> and shows the memory info, but misses some important information, etc. the
> memcg that has reached its limit and the memcg to which the killed process
> is attached.

We do not print the memcg which reached the limit in the global context
because that is irrelevant completely. I do agree that memcg of the
oom victim might be interesting and the changelog should explain why.

So what about the following wording instead:
"
The current system wide oom report prints information about the victim
and the allocation context and restrictions. It, however, doesn't
provide any information about memory cgroup the victim belongs to. This
information can be interesting for container users because they can find
the victim's container much more easily.
"
 
> I follow the advices of David Rientjes and Michal Hocko, and refactor
> part of the oom report. After this patch, users can get the memcg's
> path from the oom report and check the certain container more quickly.
> 
> The oom print info after this patch:
> oom-kill:constraint=<constraint>,nodemask=<nodemask>,origin_memcg=<memcg>,kill_memcg=<memcg>,task=<commm>,pid=<pid>,uid=<uid>
[...]
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 6adac113e96d..5bed78d4bfb8 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -15,6 +15,20 @@ struct notifier_block;
>  struct mem_cgroup;
>  struct task_struct;
>  
> +enum oom_constraint {
> +	CONSTRAINT_NONE,
> +	CONSTRAINT_CPUSET,
> +	CONSTRAINT_MEMORY_POLICY,
> +	CONSTRAINT_MEMCG,
> +};
> +
> +static const char * const oom_constraint_text[] = {
> +	[CONSTRAINT_NONE] = "CONSTRAINT_NONE",
> +	[CONSTRAINT_CPUSET] = "CONSTRAINT_CPUSET",
> +	[CONSTRAINT_MEMORY_POLICY] = "CONSTRAINT_MEMORY_POLICY",
> +	[CONSTRAINT_MEMCG] = "CONSTRAINT_MEMCG",
> +};

I've suggested that this should be a separate patch.

[...]
> -void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> +void mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p,
> +		enum oom_constraint constraint, nodemask_t *nodemask)
>  {
> -	struct mem_cgroup *iter;
> -	unsigned int i;
> +	struct cgroup *origin_cgrp, *kill_cgrp;
>  
>  	rcu_read_lock();
>  
> +	pr_info("oom-kill:constraint=%s,nodemask=%*pbl,origin_memcg=",
> +	    oom_constraint_text[constraint], nodemask_pr_args(nodemask));
> +
> +	if (memcg)
> +		pr_cont_cgroup_path(memcg->css.cgroup);
> +	else
> +		pr_cont("(null)");

I do not like this. What does origin_memcg=(null) tell you? You really
have to know the code to see this is a global oom killer actually.
Furthermore I would expect that origin_memcg is tasks' origin memcg
rather than oom's origin. So I think you want the following instead


	pr_info("oom-kill:constraint=%s,nodemask=%*pbl",
		oom_constraint_text[constraint], nodemask_pr_args(nodemask));
	if (memcg) {
		pr_cont(", oom_memcg=");
		pr_cont_cgroup_path(memcg->css.cgroup);
	}
	
	if (p) {
		pr_cont(", task_memcg=");
  		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
		pr_cont(", task=%s, pid=%5d, uid=%5d", p->comm, p->pid, from_kuid(&init_user_ns, task_uid(p)));
	}
  	pr_cont("\n");
-- 
Michal Hocko
SUSE Labs
