Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 1887F6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 07:24:47 -0400 (EDT)
Date: Thu, 11 Jul 2013 13:23:59 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 05/16] sched: Select a preferred node with the most numa
 hinting faults
Message-ID: <20130711112359.GG25631@dyad.programming.kicks-ass.net>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
 <1373536020-2799-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373536020-2799-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 11, 2013 at 10:46:49AM +0100, Mel Gorman wrote:
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -1593,6 +1593,7 @@ static void __sched_fork(struct task_struct *p)
>  	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
>  	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
>  	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
> +	p->numa_preferred_nid = -1;

(1)

>  	p->numa_work.next = &p->numa_work;
>  	p->numa_faults = NULL;
>  #endif /* CONFIG_NUMA_BALANCING */
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 904fd6f..c0bee41 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -793,7 +793,8 @@ unsigned int sysctl_numa_balancing_scan_delay = 1000;
>  
>  static void task_numa_placement(struct task_struct *p)
>  {
> -	int seq;
> +	int seq, nid, max_nid = 0;

Should you not start with max_nid = -1?

> +	unsigned long max_faults = 0;
>  
>  	if (!p->mm)	/* for example, ksmd faulting in a user's mm */
>  		return;
> @@ -802,7 +803,19 @@ static void task_numa_placement(struct task_struct *p)
>  		return;
>  	p->numa_scan_seq = seq;
>  
> -	/* FIXME: Scheduling placement policy hints go here */
> +	/* Find the node with the highest number of faults */
> +	for (nid = 0; nid < nr_node_ids; nid++) {
> +		unsigned long faults = p->numa_faults[nid];
> +		p->numa_faults[nid] >>= 1;
> +		if (faults > max_faults) {
> +			max_faults = faults;
> +			max_nid = nid;
> +		}
> +	}
> +

It is rather unlikely; but suppose the entire ->numa_faults[] array is 0, you'd
somehow end up selecting max_nid := 0. Which seems inconsistent with \1.

> +	/* Update the tasks preferred node if necessary */
> +	if (max_faults && max_nid != p->numa_preferred_nid)
> +		p->numa_preferred_nid = max_nid;
>  }
>  
>  /*
> -- 
> 1.8.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
