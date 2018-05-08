Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B34446B000A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 20:43:22 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e10-v6so10491007itf.7
        for <linux-mm@kvack.org>; Mon, 07 May 2018 17:43:22 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f3-v6si8137469ioa.83.2018.05.07.17.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 May 2018 17:43:21 -0700 (PDT)
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <024fba07-eece-3878-0924-ea9fd601542d@infradead.org>
Date: Mon, 7 May 2018 17:42:36 -0700
MIME-Version: 1.0
In-Reply-To: <20180507210135.1823-7-hannes@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On 05/07/2018 02:01 PM, Johannes Weiner wrote:
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  Documentation/accounting/psi.txt |  73 ++++++
>  include/linux/psi.h              |  27 ++
>  include/linux/psi_types.h        |  84 ++++++
>  include/linux/sched.h            |  10 +
>  include/linux/sched/stat.h       |  10 +-
>  init/Kconfig                     |  16 ++
>  kernel/fork.c                    |   4 +
>  kernel/sched/Makefile            |   1 +
>  kernel/sched/core.c              |   3 +
>  kernel/sched/psi.c               | 424 +++++++++++++++++++++++++++++++
>  kernel/sched/sched.h             | 166 ++++++------
>  kernel/sched/stats.h             |  91 ++++++-
>  mm/compaction.c                  |   5 +
>  mm/filemap.c                     |  15 +-
>  mm/page_alloc.c                  |  10 +
>  mm/vmscan.c                      |  13 +
>  16 files changed, 859 insertions(+), 93 deletions(-)
>  create mode 100644 Documentation/accounting/psi.txt
>  create mode 100644 include/linux/psi.h
>  create mode 100644 include/linux/psi_types.h
>  create mode 100644 kernel/sched/psi.c
> 
> diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
> new file mode 100644
> index 000000000000..e051810d5127
> --- /dev/null
> +++ b/Documentation/accounting/psi.txt
> @@ -0,0 +1,73 @@

Looks good to me.


> diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
> new file mode 100644
> index 000000000000..052c529a053b
> --- /dev/null
> +++ b/kernel/sched/psi.c
> @@ -0,0 +1,424 @@
> +/*
> + * Measure workload productivity impact from overcommitting CPU, memory, IO
> + *
> + * Copyright (c) 2017 Facebook, Inc.
> + * Author: Johannes Weiner <hannes@cmpxchg.org>
> + *
> + * Implementation
> + *
> + * Task states -- running, iowait, memstall -- are tracked through the
> + * scheduler and aggregated into a system-wide productivity state. The
> + * ratio between the times spent in productive states and delays tells
> + * us the overall productivity of the workload.
> + *
> + * The ratio is tracked in decaying time averages over 10s, 1m, 5m
> + * windows. Cumluative stall times are tracked and exported as well to

               Cumulative

> + * allow detection of latency spikes and custom time averaging.
> + *
> + * Multiple CPUs
> + *
> + * To avoid cache contention, times are tracked local to the CPUs. To
> + * get a comprehensive view of a system or cgroup, we have to consider
> + * the fact that CPUs could be unevenly loaded or even entirely idle
> + * if the workload doesn't have enough threads. To avoid artifacts
> + * caused by that, when adding up the global pressure ratio, the
> + * CPU-local ratios are weighed according to their non-idle time:
> + *
> + *   Time the CPU had stalled tasks    Time the CPU was non-idle
> + *   ------------------------------ * ---------------------------
> + *                Walltime            Time all CPUs were non-idle
> + */


> +
> +/**
> + * psi_memstall_leave - mark the end of an memory stall section

                                    end of a memory

> + * @flags: flags to handle nested memdelay sections
> + *
> + * Marks the calling task as no longer stalled due to lack of memory.
> + */
> +void psi_memstall_leave(unsigned long *flags)
> +{



-- 
~Randy
