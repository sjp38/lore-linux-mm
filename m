Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E07986B057E
	for <linux-mm@kvack.org>; Fri, 18 May 2018 02:22:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z7-v6so4666182wrg.11
        for <linux-mm@kvack.org>; Thu, 17 May 2018 23:22:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f15-v6si6276980eds.217.2018.05.17.23.22.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 May 2018 23:22:18 -0700 (PDT)
Date: Fri, 18 May 2018 08:22:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] Print the memcg's name when system-wide OOM happened
Message-ID: <20180518062213.GA21711@dhcp22.suse.cz>
References: <1526612834-8898-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1526612834-8898-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607 <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian <yuzhoujian@didichuxing.com>

On Fri 18-05-18 04:07:14, ufo19890607 wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> The dump_header does not print the memcg's name when the system
> oom happened. So users cannot locate the certain container which
> contains the task that has been killed by the oom killer. System
> oom report will contain the memcg's name after this patch.

It would be great to mention what you can the name for.

> Changes since v1:
> - replace adding mem_cgroup_print_oom_info with printing the memcg's
>   name only.
> 
> Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
> ---
>  mm/oom_kill.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 8ba6cb88cf58..b0abb5930232 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -433,6 +433,9 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>  	if (is_memcg_oom(oc))
>  		mem_cgroup_print_oom_info(oc->memcg, p);
>  	else {
> +		pr_info("Task in ");
> +		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
> +		pr_cont(" killed as a result of limit of ");
>  		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
>  		if (is_dump_unreclaim_slabs())
>  			dump_unreclaimable_slab();

I bet this doesn't compile with CONFIG_MEMCG=n. You either need to put
these pr_info lines inside ifdef CONFIG_MEMCG or add helper. The later
would reduce code duplication.
-- 
Michal Hocko
SUSE Labs
