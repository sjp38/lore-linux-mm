Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id BDF396B0034
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 08:48:31 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 4 Jul 2013 06:48:31 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id F05071FF001D
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 06:43:11 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r64CmS4H158894
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 06:48:29 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r64CmRc4003309
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 06:48:28 -0600
Date: Thu, 4 Jul 2013 18:18:23 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 11/13] sched: Check current->mm before allocating NUMA
 faults
Message-ID: <20130704124823.GB29916@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-12-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1372861300-9973-12-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Mel Gorman <mgorman@suse.de> [2013-07-03 15:21:38]:

> task_numa_placement checks current->mm but after buffers for faults
> have already been uselessly allocated. Move the check earlier.
> 
> [peterz@infradead.org: Identified the problem]
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  kernel/sched/fair.c | 22 ++++++++++++++--------
>  1 file changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 336074f..3c796b0 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -870,8 +870,6 @@ static void task_numa_placement(struct task_struct *p)
>  	int seq, nid, max_nid = 0;
>  	unsigned long max_faults = 0;
> 
> -	if (!p->mm)	/* for example, ksmd faulting in a user's mm */
> -		return;
>  	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
>  	if (p->numa_scan_seq == seq)
>  		return;
> @@ -945,6 +943,12 @@ void task_numa_fault(int last_nid, int node, int pages, bool migrated)
>  	if (!sched_feat_numa(NUMA))
>  		return;
> 
> +	/* for example, ksmd faulting in a user's mm */
> +	if (!p->mm) {
> +		p->numa_scan_period = sysctl_numa_balancing_scan_period_max;

Naive question:
Why are we resetting the scan_period?

> +		return;
> +	}
> +
>  	/* Allocate buffer to track faults on a per-node basis */
>  	if (unlikely(!p->numa_faults)) {
>  		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
> @@ -1072,16 +1076,18 @@ void task_numa_work(struct callback_head *work)
>  			end = ALIGN(start + (pages << PAGE_SHIFT), HPAGE_SIZE);
>  			end = min(end, vma->vm_end);
>  			nr_pte_updates += change_prot_numa(vma, start, end);
> -			pages -= (end - start) >> PAGE_SHIFT;
> -
> -			start = end;
> 
>  			/*
>  			 * Scan sysctl_numa_balancing_scan_size but ensure that
> -			 * least one PTE is updated so that unused virtual
> -			 * address space is quickly skipped
> +			 * at least one PTE is updated so that unused virtual
> +			 * address space is quickly skipped.
>  			 */
> -			if (pages <= 0 && nr_pte_updates)
> +			if (nr_pte_updates)
> +				pages -= (end - start) >> PAGE_SHIFT;
> +
> +			start = end;
> +
> +			if (pages <= 0)
>  				goto out;
>  		} while (end != vma->vm_end);
>  	}
> -- 
> 1.8.1.4
> 

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
