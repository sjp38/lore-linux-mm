Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB5D6B04E8
	for <linux-mm@kvack.org>; Wed,  9 May 2018 07:03:35 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 35-v6so3557612pla.18
        for <linux-mm@kvack.org>; Wed, 09 May 2018 04:03:35 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 9-v6si20003703ple.63.2018.05.09.04.03.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 04:03:34 -0700 (PDT)
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <87060553-2e09-2e2a-13a2-a91345d6df30@codeaurora.org>
Date: Wed, 9 May 2018 16:33:24 +0530
MIME-Version: 1.0
In-Reply-To: <20180507210135.1823-7-hannes@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com


On 5/8/2018 2:31 AM, Johannes Weiner wrote:
> +static void psi_group_update(struct psi_group *group, int cpu, u64 now,
> +			     unsigned int clear, unsigned int set)
> +{
> +	enum psi_state state = PSI_NONE;
> +	struct psi_group_cpu *groupc;
> +	unsigned int *tasks;
> +	unsigned int to, bo;
> +
> +	groupc = per_cpu_ptr(group->cpus, cpu);
> +	tasks = groupc->tasks;
> +
> +	/* Update task counts according to the set/clear bitmasks */
> +	for (to = 0; (bo = ffs(clear)); to += bo, clear >>= bo) {
> +		int idx = to + (bo - 1);
> +
> +		if (tasks[idx] == 0 && !psi_bug) {
> +			printk_deferred(KERN_ERR "psi: task underflow! cpu=%d idx=%d tasks=[%u %u %u %u]\n",
> +					cpu, idx, tasks[0], tasks[1],
> +					tasks[2], tasks[3]);
> +			psi_bug = 1;
> +		}
> +		tasks[idx]--;
> +	}
> +	for (to = 0; (bo = ffs(set)); to += bo, set >>= bo)
> +		tasks[to + (bo - 1)]++;
> +
> +	/* Time in which tasks wait for the CPU */
> +	state = PSI_NONE;
> +	if (tasks[NR_RUNNING] > 1)
> +		state = PSI_SOME;
> +	time_state(&groupc->res[PSI_CPU], state, now);
> +
> +	/* Time in which tasks wait for memory */
> +	state = PSI_NONE;
> +	if (tasks[NR_MEMSTALL]) {
> +		if (!tasks[NR_RUNNING] ||
> +		    (cpu_curr(cpu)->flags & PF_MEMSTALL))
> +			state = PSI_FULL;
> +		else
> +			state = PSI_SOME;
> +	}
> +	time_state(&groupc->res[PSI_MEM], state, now);
> +
> +	/* Time in which tasks wait for IO */
> +	state = PSI_NONE;
> +	if (tasks[NR_IOWAIT]) {
> +		if (!tasks[NR_RUNNING])
> +			state = PSI_FULL;
> +		else
> +			state = PSI_SOME;
> +	}
> +	time_state(&groupc->res[PSI_IO], state, now);
> +
> +	/* Time in which tasks are non-idle, to weigh the CPU in summaries */
> +	if (groupc->nonidle)
> +		groupc->nonidle_time += now - groupc->nonidle_start;
> +	groupc->nonidle = tasks[NR_RUNNING] ||
> +		tasks[NR_IOWAIT] || tasks[NR_MEMSTALL];
> +	if (groupc->nonidle)
> +		groupc->nonidle_start = now;
> +
> +	/* Kick the stats aggregation worker if it's gone to sleep */
> +	if (!delayed_work_pending(&group->clock_work))

This causes a crash when the work is scheduled before system_wq is up. In my case when the first
schedule was called from kthreadd. And I had to do this to make it work.
if (keventd_up() && !delayed_work_pending(&group->clock_work))

> +		schedule_delayed_work(&group->clock_work, MY_LOAD_FREQ);
> +}
> +
> +void psi_task_change(struct task_struct *task, u64 now, int clear, int set)
> +{
> +	struct cgroup *cgroup, *parent;

unused variables

Thanks,
Vinayak
