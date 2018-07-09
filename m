Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 39EEC6B02BB
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 07:15:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x21-v6so3076989eds.2
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 04:15:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5-v6si2954765edl.95.2018.07.09.04.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 04:15:29 -0700 (PDT)
Date: Mon, 9 Jul 2018 13:15:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v12 1/2] Reorganize the oom report in dump_header
Message-ID: <20180709111527.GH22049@dhcp22.suse.cz>
References: <1530796829-4539-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530796829-4539-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

On Thu 05-07-18 21:20:28, ufo19890607@gmail.com wrote:
[...]
> @@ -421,15 +421,20 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  
>  static void dump_header(struct oom_control *oc, struct task_struct *p)
>  {
> -	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n",
> -		current->comm, oc->gfp_mask, &oc->gfp_mask,
> -		nodemask_pr_args(oc->nodemask), oc->order,
> +	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d, oom_score_adj=%hd\n",
> +		current->comm, oc->gfp_mask, &oc->gfp_mask, oc->order,
>  			current->signal->oom_score_adj);
>  	if (!IS_ENABLED(CONFIG_COMPACTION) && oc->order)
>  		pr_warn("COMPACTION is disabled!!!\n");
>  
> -	cpuset_print_current_mems_allowed();
>  	dump_stack();
> +
> +	/* one line summary of the oom killer context. */
> +	pr_info("oom-kill:constraint=%s,nodemask=%*pbl,task=%s,pid=%5d,uid=%5d",
> +			oom_constraint_text[oc->constraint],
> +			nodemask_pr_args(oc->nodemask),
> +			p->comm, p->pid, from_kuid(&init_user_ns, task_uid(p)));
> +	cpuset_print_current_mems_allowed();
>  	if (is_memcg_oom(oc))
>  		mem_cgroup_print_oom_info(oc->memcg, p);
>  	else {

Have you tested this patch at all? Because this doesn't match the new
format you are describing in the changelog.

oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0-1,task=panic,pid=10235,uid=    0

cpuset information clearly comes after oom victim comm, pid etc.
-- 
Michal Hocko
SUSE Labs
