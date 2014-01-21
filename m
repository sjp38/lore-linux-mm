Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id C05696B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 10:56:56 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so3813891eaj.35
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 07:56:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si10356458eem.216.2014.01.21.07.56.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 07:56:55 -0800 (PST)
Date: Tue, 21 Jan 2014 15:56:52 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/6] numa,sched: normalize faults_from stats and weigh by
 CPU use
Message-ID: <20140121155652.GL4963@suse.de>
References: <1390245667-24193-1-git-send-email-riel@redhat.com>
 <1390245667-24193-6-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390245667-24193-6-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Mon, Jan 20, 2014 at 02:21:06PM -0500, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> The tracepoint has made it abundantly clear that the naive
> implementation of the faults_from code has issues.
> 
> Specifically, the garbage collector in some workloads will
> access orders of magnitudes more memory than the threads
> that do all the active work. This resulted in the node with
> the garbage collector being marked the only active node in
> the group.
> 

Maybe I should have read this patch before getting into a twist about the
earlier patches in the series and the treatment of active_mask :(. On the
plus side, even without reading the code I can still see the motivation
for this paragraph.

> This issue is avoided if we weigh the statistics by CPU use
> of each task in the numa group, instead of by how many faults
> each thread has occurred.
> 

Bah, yes. Because in my earlier review I was worried about the faults
being missed. If the faults stats are scaled by the CPU statistics then it
is a very rough proxy measure for how heavily a particular node is being
referenced by a process.

> To achieve this, we normalize the number of faults to the
> fraction of faults that occurred on each node, and then
> multiply that fraction by the fraction of CPU time the
> task has used since the last time task_numa_placement was
> invoked.
> 
> This way the nodes in the active node mask will be the ones
> where the tasks from the numa group are most actively running,
> and the influence of eg. the garbage collector and other
> do-little threads is properly minimized.
> 
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Chegu Vinod <chegu_vinod@hp.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  kernel/sched/fair.c | 21 +++++++++++++++++++--
>  1 file changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index ea873b6..203877d 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -1426,6 +1426,8 @@ static void task_numa_placement(struct task_struct *p)
>  	int seq, nid, max_nid = -1, max_group_nid = -1;
>  	unsigned long max_faults = 0, max_group_faults = 0;
>  	unsigned long fault_types[2] = { 0, 0 };
> +	unsigned long total_faults;
> +	u64 runtime, period;
>  	spinlock_t *group_lock = NULL;
>  
>  	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
> @@ -1434,6 +1436,11 @@ static void task_numa_placement(struct task_struct *p)
>  	p->numa_scan_seq = seq;
>  	p->numa_scan_period_max = task_scan_max(p);
>  
> +	total_faults = p->numa_faults_locality[0] +
> +		       p->numa_faults_locality[1] + 1;

Depending on how you reacted to the review of other patches this may or
may not have a helper now.

> +	runtime = p->se.avg.runnable_avg_sum;
> +	period = p->se.avg.runnable_avg_period;
> +

Ok, IIRC these stats are based a decaying average based on recent
history so heavy activity followed by long periods of idle will not skew
the stats.

>  	/* If the task is part of a group prevent parallel updates to group stats */
>  	if (p->numa_group) {
>  		group_lock = &p->numa_group->lock;
> @@ -1446,7 +1453,7 @@ static void task_numa_placement(struct task_struct *p)
>  		int priv, i;
>  
>  		for (priv = 0; priv < 2; priv++) {
> -			long diff, f_diff;
> +			long diff, f_diff, f_weight;
>  
>  			i = task_faults_idx(nid, priv);
>  			diff = -p->numa_faults[i];
> @@ -1458,8 +1465,18 @@ static void task_numa_placement(struct task_struct *p)
>  			fault_types[priv] += p->numa_faults_buffer[i];
>  			p->numa_faults_buffer[i] = 0;
>  
> +			/*
> +			 * Normalize the faults_from, so all tasks in a group
> +			 * count according to CPU use, instead of by the raw
> +			 * number of faults. Tasks with little runtime have
> +			 * little over-all impact on throughput, and thus their
> +			 * faults are less important.
> +			 */
> +			f_weight = (16384 * runtime *
> +				   p->numa_faults_from_buffer[i]) /
> +				   (total_faults * period + 1);

Why 16384? It looks like a scaling factor to deal with integer approximations
but I'm not 100% sure and I do not see how you arrived at that value.

>  			p->numa_faults_from[i] >>= 1;
> -			p->numa_faults_from[i] += p->numa_faults_from_buffer[i];
> +			p->numa_faults_from[i] += f_weight;
>  			p->numa_faults_from_buffer[i] = 0;
>  

numa_faults_from needs a big comment that it's no longer about the
number of faults in it. It's the sum of faults measured by the group
weighted by the CPU

>  			faults += p->numa_faults[i];
> -- 
> 1.8.4.2
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
