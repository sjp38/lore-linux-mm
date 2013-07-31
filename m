Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id A2B096B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 11:45:21 -0400 (EDT)
Message-ID: <51F93105.8020503@hp.com>
Date: Wed, 31 Jul 2013 11:45:09 -0400
From: Don Morris <don.morris@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH] sched, numa: Use {cpu, pid} to create task groups for
 shared faults
References: <1373901620-2021-1-git-send-email-mgorman@suse.de> <20130730113857.GR3008@twins.programming.kicks-ass.net> <20130731150751.GA15144@twins.programming.kicks-ass.net>
In-Reply-To: <20130731150751.GA15144@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/31/2013 11:07 AM, Peter Zijlstra wrote:
> 
> New version that includes a final put for the numa_group struct and a
> few other modifications.
> 
> The new task_numa_free() completely blows though, far too expensive.
> Good ideas needed.
> 
> ---
> Subject: sched, numa: Use {cpu, pid} to create task groups for shared faults
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Tue Jul 30 10:40:20 CEST 2013
> 
> A very simple/straight forward shared fault task grouping
> implementation.
> 
> Concerns are that grouping on a single shared fault might be too
> aggressive -- this only works because Mel is excluding DSOs for faults,
> otherwise we'd have the world in a single group.
> 
> Future work could explore more complex means of picking groups. We
> could for example track one group for the entire scan (using something
> like PDM) and join it at the end of the scan if we deem it shared a
> sufficient amount of memory.
> 
> Another avenue to explore is that to do with tasks where private faults
> are predominant. Should we exclude them from the group or treat them as
> secondary, creating a graded group that tries hardest to collate shared
> tasks but also tries to move private tasks near when possible.
> 
> Also, the grouping information is completely unused, its up to future
> patches to do this.
> 
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> ---
>  include/linux/sched.h |    4 +
>  kernel/sched/core.c   |    4 +
>  kernel/sched/fair.c   |  177 +++++++++++++++++++++++++++++++++++++++++++++++---
>  kernel/sched/sched.h  |    5 -
>  4 files changed, 176 insertions(+), 14 deletions(-)

> +
> +static void task_numa_free(struct task_struct *p)
> +{
> +	kfree(p->numa_faults);
> +	if (p->numa_group) {
> +		struct numa_group *grp = p->numa_group;

See below.

> +		int i;
> +
> +		for (i = 0; i < 2*nr_node_ids; i++)
> +			atomic_long_sub(p->numa_faults[i], &grp->faults[i]);
> +
> +		spin_lock(&p->numa_lock);
> +		spin_lock(&group->lock);
> +		list_del(&p->numa_entry);
> +		spin_unlock(&group->lock);
> +		rcu_assign_pointer(p->numa_group, NULL);
> +		put_numa_group(grp);

So is the local variable group or grp here? Got to be one or the
other to compile...

Don

> +	}
> +}
> +
>  /*
>   * Got a PROT_NONE fault for a page on @node.
>   */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
