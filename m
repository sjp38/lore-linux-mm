Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id EF5C26B0089
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 14:34:36 -0400 (EDT)
Message-ID: <4FF9D29D.8030903@redhat.com>
Date: Sun, 08 Jul 2012 14:34:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 25/26] sched, numa: Only migrate long-running entities
References: <20120316144028.036474157@chello.nl> <20120316144241.749359061@chello.nl>
In-Reply-To: <20120316144241.749359061@chello.nl>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/16/2012 10:40 AM, Peter Zijlstra wrote:

> +static u64 process_cpu_runtime(struct numa_entity *ne)
> +{
> +	struct task_struct *p, *t;
> +	u64 runtime = 0;
> +
> +	rcu_read_lock();
> +	t = p = ne_owner(ne);
> +	if (p) do {
> +		runtime += t->se.sum_exec_runtime; // @#$#@ 32bit
> +	} while ((t = next_thread(t)) != p);
> +	rcu_read_unlock();
> +
> +	return runtime;
> +}

> +	/*
> +	 * Don't bother migrating memory if there's less than 1 second
> +	 * of runtime on the tasks.
> +	 */
> +	if (ne->nops->cpu_runtime(ne) < NSEC_PER_SEC)
> +		return false;

Do we really want to calculate the amount of CPU time used
by a process, and start migrating after just one second?

Or would it be ok to start migrating once a process has
been scanned once or twice by the NUMA code?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
