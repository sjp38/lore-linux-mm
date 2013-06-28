Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 158A86B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 02:33:46 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 07:33:45 +0100
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 0FA346E803A
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 02:33:39 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5S6WpmB328132
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 02:32:52 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5S6WnHY011296
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 00:32:51 -0600
Date: Fri, 28 Jun 2013 12:02:33 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/8] sched: Update NUMA hinting faults once per scan
Message-ID: <20130628063233.GC17195@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1372257487-9749-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Mel Gorman <mgorman@suse.de> [2013-06-26 15:38:03]:

> NUMA hinting faults counts and placement decisions are both recorded in the
> same array which distorts the samples in an unpredictable fashion. The values
> linearly accumulate during the scan and then decay creating a sawtooth-like
> pattern in the per-node counts. It also means that placement decisions are
> time sensitive. At best it means that it is very difficult to state that
> the buffer holds a decaying average of past faulting behaviour. At worst,
> it can confuse the load balancer if it sees one node with an artifically high
> count due to very recent faulting activity and may create a bouncing effect.
> 
> This patch adds a second array. numa_faults stores the historical data
> which is used for placement decisions. numa_faults_buffer holds the
> fault activity during the current scan window. When the scan completes,
> numa_faults decays and the values from numa_faults_buffer are copied
> across.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/sched.h | 13 +++++++++++++
>  kernel/sched/core.c   |  1 +
>  kernel/sched/fair.c   | 16 +++++++++++++---
>  3 files changed, 27 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index ba46a64..42f9818 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1506,7 +1506,20 @@ struct task_struct {
>  	u64 node_stamp;			/* migration stamp  */
>  	struct callback_head numa_work;
>  
> +	/*
> +	 * Exponential decaying average of faults on a per-node basis.
> +	 * Scheduling placement decisions are made based on the these counts.
> +	 * The values remain static for the duration of a PTE scan
> +	 */
>  	unsigned long *numa_faults;
> +
> +	/*
> +	 * numa_faults_buffer records faults per node during the current
> +	 * scan window. When the scan completes, the counts in numa_faults
> +	 * decay and these values are copied.
> +	 */
> +	unsigned long *numa_faults_buffer;
> +
>  	int numa_preferred_nid;
>  #endif /* CONFIG_NUMA_BALANCING */
>  
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 019baae..b00b81a 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -1596,6 +1596,7 @@ static void __sched_fork(struct task_struct *p)
>  	p->numa_preferred_nid = -1;
>  	p->numa_work.next = &p->numa_work;
>  	p->numa_faults = NULL;
> +	p->numa_faults_buffer = NULL;
>  #endif /* CONFIG_NUMA_BALANCING */
>  }
>  
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index f8c3f61..5893399 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -805,8 +805,14 @@ static void task_numa_placement(struct task_struct *p)
>  
>  	/* Find the node with the highest number of faults */
>  	for (nid = 0; nid < nr_node_ids; nid++) {
> -		unsigned long faults = p->numa_faults[nid];
> +		unsigned long faults;
> +
> +		/* Decay existing window and copy faults since last scan */
>  		p->numa_faults[nid] >>= 1;
> +		p->numa_faults[nid] += p->numa_faults_buffer[nid];
> +		p->numa_faults_buffer[nid] = 0;
> +
> +		faults = p->numa_faults[nid];
>  		if (faults > max_faults) {
>  			max_faults = faults;
>  			max_nid = nid;
> @@ -831,9 +837,13 @@ void task_numa_fault(int node, int pages, bool migrated)
>  	if (unlikely(!p->numa_faults)) {
>  		int size = sizeof(*p->numa_faults) * nr_node_ids;
>  
> -		p->numa_faults = kzalloc(size, GFP_KERNEL);
> +		/* numa_faults and numa_faults_buffer share the allocation */
> +		p->numa_faults = kzalloc(size * 2, GFP_KERNEL);

Instead of allocating buffer to hold the current faults, cant we pass
the nr of pages and node information (and probably migrate) to
task_numa_placement()?.

Why should task_struct be passed as an argument to  task_numa_placement().
It seems it always will be current.

>  		if (!p->numa_faults)
>  			return;
> +
> +		BUG_ON(p->numa_faults_buffer);
> +		p->numa_faults_buffer = p->numa_faults + nr_node_ids;
>  	}
>  
>  	/*
> @@ -847,7 +857,7 @@ void task_numa_fault(int node, int pages, bool migrated)
>  	task_numa_placement(p);
>  
>  	/* Record the fault, double the weight if pages were migrated */
> -	p->numa_faults[node] += pages << migrated;
> +	p->numa_faults_buffer[node] += pages << migrated;
>  }
>  
>  static void reset_ptenuma_scan(struct task_struct *p)
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
