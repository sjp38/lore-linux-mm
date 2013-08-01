Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id D2CB26B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 00:48:24 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 31 Jul 2013 22:48:24 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id E48141FF001C
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 22:42:58 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r714mFvQ078186
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 22:48:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r714mDlF014007
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 22:48:15 -0600
Date: Thu, 1 Aug 2013 10:17:57 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 08/18] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130801044757.GA6151@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-9-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1373901620-2021-9-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Mel Gorman <mgorman@suse.de> [2013-07-15 16:20:10]:

> A preferred node is selected based on the node the most NUMA hinting
> faults was incurred on. There is no guarantee that the task is running
> on that node at the time so this patch rescheules the task to run on
> the most idle CPU of the selected node when selected. This avoids
> waiting for the balancer to make a decision.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  kernel/sched/core.c  | 17 +++++++++++++++++
>  kernel/sched/fair.c  | 46 +++++++++++++++++++++++++++++++++++++++++++++-
>  kernel/sched/sched.h |  1 +
>  3 files changed, 63 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 5e02507..b67a102 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -4856,6 +4856,23 @@ fail:
>  	return ret;
>  }
> 
> +#ifdef CONFIG_NUMA_BALANCING
> +/* Migrate current task p to target_cpu */
> +int migrate_task_to(struct task_struct *p, int target_cpu)
> +{
> +	struct migration_arg arg = { p, target_cpu };
> +	int curr_cpu = task_cpu(p);
> +
> +	if (curr_cpu == target_cpu)
> +		return 0;
> +
> +	if (!cpumask_test_cpu(target_cpu, tsk_cpus_allowed(p)))
> +		return -EINVAL;
> +
> +	return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);

As I had noted earlier, this upsets schedstats badly.
Can we add a TODO for this patch, which mentions that schedstats need to
taken care.

One alternative that I can think of is to have a per scheduling class
routine that gets called and does the needful.
for example: for fair share, it could update the schedstats as well as
check for cfs_throttling.

But I think its an issue that needs some fix or we should obsolete
schedstats.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
