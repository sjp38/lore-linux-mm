Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1321E6B0005
	for <linux-mm@kvack.org>; Sun,  3 Jun 2018 11:18:26 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id z16-v6so8368918pge.21
        for <linux-mm@kvack.org>; Sun, 03 Jun 2018 08:18:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id i26-v6si19765607pgn.433.2018.06.03.08.18.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jun 2018 08:18:24 -0700 (PDT)
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <abb05530-c259-1178-523a-4368e43f94cc@i-love.sakura.ne.jp>
Date: Sun, 3 Jun 2018 23:45:15 +0900
MIME-Version: 1.0
In-Reply-To: <1527940734-35161-2-git-send-email-ufo19890607@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian <yuzhoujian@didichuxing.com>

On 2018/06/02 20:58, yuzhoujian wrote:
> -void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> +void mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p,
> +			enum oom_constraint constraint, nodemask_t *nodemask)
>  {
> -	struct mem_cgroup *iter;
> -	unsigned int i;
> +	static char origin_memcg_name[NAME_MAX], kill_memcg_name[NAME_MAX];
> +	struct cgroup *origin_cgrp, *kill_cgrp;
>  
>  	rcu_read_lock();
> -
> -	if (p) {
> -		pr_info("Task in ");
> -		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
> -		pr_cont(" killed as a result of limit of ");
> -	} else {
> -		pr_info("Memory limit reached of cgroup ");
> +	if (memcg) {
> +		origin_cgrp = memcg->css.cgroup;
> +		cgroup_path(origin_cgrp, origin_memcg_name, NAME_MAX);
>  	}
> -
> -	pr_cont_cgroup_path(memcg->css.cgroup);
> -	pr_cont("\n");
> -
> +	kill_cgrp = task_cgroup(p, memory_cgrp_id);
> +	cgroup_path(kill_cgrp, kill_memcg_name, NAME_MAX);
> +
> +	if (p)
> +		pr_info("oom-kill:constraint=%s,nodemask=%*pbl,origin_memcg=%s,kill_memcg=%s,task=%s,pid=%5d,uid=%5d\n",
> +			oom_constraint_text[constraint], nodemask_pr_args(nodemask),
> +			strlen(origin_memcg_name) ? origin_memcg_name : "(null)",

Since origin_memcg_name is printed for both memcg OOM and !memcg OOM,
it is strange that origin_memcg_name is updated only when memcg != NULL.
Have you really tested !memcg OOM case?
