Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 850536B0006
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 07:03:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o5-v6so799972edq.15
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 04:03:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i26-v6si941120eds.215.2018.07.03.04.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 04:03:44 -0700 (PDT)
Date: Tue, 3 Jul 2018 13:03:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v11 1/2] Refactor part of the oom report in dump_header
Message-ID: <20180703110335.GH16767@dhcp22.suse.cz>
References: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
 <20180702101732.GD19043@dhcp22.suse.cz>
 <CAHCio2h1G5UDRv_veWbzRAMtM+NheyVfsghoC3G80BJgOtuW7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2h1G5UDRv_veWbzRAMtM+NheyVfsghoC3G80BJgOtuW7g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Tue 03-07-18 18:57:14, c|1e??e?(R) wrote:
> Hi Michal
> cpuset_print_current_mems_allowed is also invoked by
> warn_alloc(page_alloc.c). So, can I remove the current->comm output in
> the pr_info ?
> 
> diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
> index d8b12e0d39cd..09b8ef6186c6 100644
> --- a/kernel/cgroup/cpuset.c
> +++ b/kernel/cgroup/cpuset.c
> @@ -2666,9 +2666,9 @@ void cpuset_print_current_mems_allowed(void)
>         rcu_read_lock();
> 
>         cgrp = task_cs(current)->css.cgroup;
> -       pr_info("%s cpuset=", current->comm);
> +       pr_info(",cpuset=");
>         pr_cont_cgroup_name(cgrp);
> -       pr_cont(" mems_allowed=%*pbl\n",
> +       pr_cont(",mems_allowed=%*pbl",
>                 nodemask_pr_args(&current->mems_allowed));

Yes, I think so. Just jam the cpuset info to the allocation context
warning like this

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1521100f1e63..6bc7d5d4007a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3416,12 +3416,13 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	va_start(args, fmt);
 	vaf.fmt = fmt;
 	vaf.va = &args;
-	pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=%*pbl\n",
+	pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=%*pbl",
 			current->comm, &vaf, gfp_mask, &gfp_mask,
 			nodemask_pr_args(nodemask));
 	va_end(args);
 
 	cpuset_print_current_mems_allowed();
+	pr_cont("\n");
 
 	dump_stack();
 	warn_alloc_show_mem(gfp_mask, nodemask);
-- 
Michal Hocko
SUSE Labs
