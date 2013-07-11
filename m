Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 70EB76B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 08:31:32 -0400 (EDT)
Date: Thu, 11 Jul 2013 14:30:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/16] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130711123038.GH25631@dyad.programming.kicks-ass.net>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
 <1373536020-2799-9-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373536020-2799-9-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 11, 2013 at 10:46:52AM +0100, Mel Gorman wrote:
> @@ -829,10 +854,29 @@ static void task_numa_placement(struct task_struct *p)
>  		}
>  	}
>  
> -	/* Update the tasks preferred node if necessary */
> +	/*
> +	 * Record the preferred node as the node with the most faults,
> +	 * requeue the task to be running on the idlest CPU on the
> +	 * preferred node and reset the scanning rate to recheck
> +	 * the working set placement.
> +	 */
>  	if (max_faults && max_nid != p->numa_preferred_nid) {
> +		int preferred_cpu;
> +
> +		/*
> +		 * If the task is not on the preferred node then find the most
> +		 * idle CPU to migrate to.
> +		 */
> +		preferred_cpu = task_cpu(p);
> +		if (cpu_to_node(preferred_cpu) != max_nid) {
> +			preferred_cpu = find_idlest_cpu_node(preferred_cpu,
> +							     max_nid);
> +		}
> +
> +		/* Update the preferred nid and migrate task if possible */
>  		p->numa_preferred_nid = max_nid;
>  		p->numa_migrate_seq = 0;
> +		migrate_task_to(p, preferred_cpu);
>  	}
>  }

Now what happens if the migrations fails? We set numa_preferred_nid to max_nid
but then never re-try the migration. Should we not re-try the migration every
so often, regardless of whether max_nid changed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
