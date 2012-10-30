Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id C926F8D0003
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 15:20:50 -0400 (EDT)
Message-ID: <5090292A.3020605@redhat.com>
Date: Tue, 30 Oct 2012 15:23:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 26/31] sched, numa, mm: Add fault driven placement and
 migration policy
References: <20121025121617.617683848@chello.nl> <20121025124834.467791319@chello.nl>
In-Reply-To: <20121025124834.467791319@chello.nl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On 10/25/2012 08:16 AM, Peter Zijlstra wrote:
> +/*
> + * Drive the periodic memory faults..
> + */
> +void task_tick_numa(struct rq *rq, struct task_struct *curr)
> +{
> +	struct callback_head *work = &curr->numa_work;
> +	u64 period, now;
> +
> +	/*
> +	 * We don't care about NUMA placement if we don't have memory.
> +	 */
> +	if (!curr->mm || (curr->flags & PF_EXITING) || work->next != work)
> +		return;

We should probably skip the whole unmap-and-refault
business if we are running on a system that is not
NUMA.  Ie. a system with just one node...

> +	/*
> +	 * Using runtime rather than walltime has the dual advantage that
> +	 * we (mostly) drive the selection from busy threads and that the
> +	 * task needs to have done some actual work before we bother with
> +	 * NUMA placement.
> +	 */
> +	now = curr->se.sum_exec_runtime;
> +	period = (u64)curr->numa_scan_period * NSEC_PER_MSEC;
> +


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
