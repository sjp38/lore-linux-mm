Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id A7A1D6B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 11:38:27 -0400 (EDT)
Date: Wed, 31 Jul 2013 17:38:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] sched, numa: Use {cpu, pid} to create task groups for
 shared faults
Message-ID: <20130731153821.GE3008@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130730113857.GR3008@twins.programming.kicks-ass.net>
 <20130731150751.GA15144@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130731150751.GA15144@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, riel@redhat.com

On Wed, Jul 31, 2013 at 05:07:51PM +0200, Peter Zijlstra wrote:
> @@ -1260,6 +1400,23 @@ void task_numa_fault(int last_cpupid, in
>  	}
>  
>  	/*
> +	 * First accesses are treated as private, otherwise consider accesses
> +	 * to be private if the accessing pid has not changed
> +	 */
> +	if (unlikely(last_cpupid == (-1 & LAST_CPUPID_MASK))) {
> +		priv = 1;
> +	} else {
> +		int cpu, pid;
> +
> +		cpu = cpupid_to_cpu(last_cpupid);
> +		pid = cpupid_to_pid(last_cpupid);
> +
> +		priv = (pid == (p->pid & LAST__PID_MASK));

So Rik just pointed out that this condition is likely to generate false
positives due to the birthday paradox. The problem with including
cpu/nid information is another kind of false positives.

We've no idea which is worse.. 

> +		if (!priv)
> +			task_numa_group(p, cpu, pid);
> +	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
