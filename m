Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id DD79E6B0034
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 08:26:52 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 4 Jul 2013 06:26:52 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id B769D1FF0024
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 06:21:32 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r64CQnlH119392
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 06:26:49 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r64CQn9L011926
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 06:26:49 -0600
Date: Thu, 4 Jul 2013 17:56:44 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 06/13] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130704122644.GA29916@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-7-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1372861300-9973-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Mel Gorman <mgorman@suse.de> [2013-07-03 15:21:33]:

> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 2a0bbc2..b9139be 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -800,6 +800,37 @@ unsigned int sysctl_numa_balancing_scan_delay = 1000;
>   */
>  unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
> 
> +static unsigned long weighted_cpuload(const int cpu);
> +
> +static int
> +find_idlest_cpu_node(int this_cpu, int nid)
> +{
> +	unsigned long load, min_load = ULONG_MAX;
> +	int i, idlest_cpu = this_cpu;
> +
> +	BUG_ON(cpu_to_node(this_cpu) == nid);
> +
> +	for_each_cpu(i, cpumask_of_node(nid)) {
> +		load = weighted_cpuload(i);
> +
> +		if (load < min_load) {
> +			struct task_struct *p;
> +
> +			/* Do not preempt a task running on its preferred node */
> +			struct rq *rq = cpu_rq(i);
> +			raw_spin_lock_irq(&rq->lock);

Not sure why we need this spin_lock? Cant this be done in a rcu block
instead?


-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
