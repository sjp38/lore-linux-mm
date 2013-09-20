Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B06226B0031
	for <linux-mm@kvack.org>; Fri, 20 Sep 2013 05:55:38 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so190423pdj.21
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 02:55:38 -0700 (PDT)
Date: Fri, 20 Sep 2013 11:55:26 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 46/50] sched: numa: Prevent parallel updates to group
 stats during placement
Message-ID: <20130920095526.GT9326@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-47-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378805550-29949-47-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 10, 2013 at 10:32:26AM +0100, Mel Gorman wrote:
> Having multiple tasks in a group go through task_numa_placement
> simultaneously can lead to a task picking a wrong node to run on, because
> the group stats may be in the middle of an update. This patch avoids
> parallel updates by holding the numa_group lock during placement
> decisions.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  kernel/sched/fair.c | 35 +++++++++++++++++++++++------------
>  1 file changed, 23 insertions(+), 12 deletions(-)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 3a92c58..4653f71 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -1231,6 +1231,7 @@ static void task_numa_placement(struct task_struct *p)
>  {
>  	int seq, nid, max_nid = -1, max_group_nid = -1;
>  	unsigned long max_faults = 0, max_group_faults = 0;
> +	spinlock_t *group_lock = NULL;
>  
>  	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
>  	if (p->numa_scan_seq == seq)
> @@ -1239,6 +1240,12 @@ static void task_numa_placement(struct task_struct *p)
>  	p->numa_migrate_seq++;
>  	p->numa_scan_period_max = task_scan_max(p);
>  
> +	/* If the task is part of a group prevent parallel updates to group stats */
> +	if (p->numa_group) {
> +		group_lock = &p->numa_group->lock;
> +		spin_lock(group_lock);
> +	}
> +
>  	/* Find the node with the highest number of faults */
>  	for_each_online_node(nid) {
>  		unsigned long faults = 0, group_faults = 0;
> @@ -1277,20 +1284,24 @@ static void task_numa_placement(struct task_struct *p)
>  		}
>  	}
>  
> +	if (p->numa_group) {
> +		/*
> +		 * If the preferred task and group nids are different, 
> +		 * iterate over the nodes again to find the best place.
> +		 */
> +		if (max_nid != max_group_nid) {
> +			unsigned long weight, max_weight = 0;
> +
> +			for_each_online_node(nid) {
> +				weight = task_weight(p, nid) + group_weight(p, nid);
> +				if (weight > max_weight) {
> +					max_weight = weight;
> +					max_nid = nid;
> +				}
>  			}
>  		}
> +
> +		spin_unlock(group_lock);
>  	}
>  
>  	/* Preferred node as the node with the most faults */

If you're going to hold locks you can also do away with all that
atomic_long_*() nonsense :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
