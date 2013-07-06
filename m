Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 4BFE26B0033
	for <linux-mm@kvack.org>; Sat,  6 Jul 2013 06:46:54 -0400 (EDT)
Date: Sat, 6 Jul 2013 12:46:14 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 14/15] sched: Account for the number of preferred tasks
 running on a node when selecting a preferred node
Message-ID: <20130706104614.GT18898@dyad.programming.kicks-ass.net>
References: <1373065742-9753-1-git-send-email-mgorman@suse.de>
 <1373065742-9753-15-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373065742-9753-15-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Jul 06, 2013 at 12:09:01AM +0100, Mel Gorman wrote:
> +/* Returns true if the given node is compute overloaded */
> +static bool sched_numa_overloaded(int nid)
> +{
> +	int nr_cpus = 0;
> +	int nr_preferred = 0;
> +	int i;
> +
> +	for_each_cpu(i, cpumask_of_node(nid)) {
> +		nr_cpus++;
> +		nr_preferred += cpu_rq(i)->nr_preferred_running;
> +	}
> +
> +	return nr_preferred >= nr_cpus << 1;
> +}
> +
>  static void task_numa_placement(struct task_struct *p)
>  {
>  	int seq, nid, max_nid = 0;
> @@ -908,7 +935,7 @@ static void task_numa_placement(struct task_struct *p)
>  
>  		/* Find maximum private faults */
>  		faults = p->numa_faults[task_faults_idx(nid, 1)];
> -		if (faults > max_faults) {
> +		if (faults > max_faults && !sched_numa_overloaded(nid)) {
>  			max_faults = faults;
>  			max_nid = nid;
>  		}

This again very explicitly breaks for overloaded scenarios.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
