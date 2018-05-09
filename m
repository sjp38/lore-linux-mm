Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26B806B04E9
	for <linux-mm@kvack.org>; Wed,  9 May 2018 07:07:52 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x7-v6so3265120wrm.13
        for <linux-mm@kvack.org>; Wed, 09 May 2018 04:07:52 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p15-v6si2552886wrm.281.2018.05.09.04.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 04:07:50 -0700 (PDT)
Date: Wed, 9 May 2018 13:07:36 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 7/7] psi: cgroup support
Message-ID: <20180509110736.GR12217@hirez.programming.kicks-ass.net>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-8-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180507210135.1823-8-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Mon, May 07, 2018 at 05:01:35PM -0400, Johannes Weiner wrote:
> --- a/kernel/sched/psi.c
> +++ b/kernel/sched/psi.c
> @@ -260,6 +260,18 @@ void psi_task_change(struct task_struct *task, u64 now, int clear, int set)
>  	task->psi_flags |= set;
>  
>  	psi_group_update(&psi_system, cpu, now, clear, set);
> +
> +#ifdef CONFIG_CGROUPS
> +       cgroup = task->cgroups->dfl_cgrp;
> +       while (cgroup && (parent = cgroup_parent(cgroup))) {
> +               struct psi_group *group;
> +
> +               group = cgroup_psi(cgroup);
> +               psi_group_update(group, cpu, now, clear, set);
> +
> +               cgroup = parent;
> +       }
> +#endif
>  }

TJ fixed needing that for stats at some point, why can't you do the
same?
