Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 8B18F6B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 18:04:26 -0400 (EDT)
Message-ID: <4FFF4987.4050205@redhat.com>
Date: Thu, 12 Jul 2012 18:02:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 14/26] sched, numa: Numa balancer
References: <20120316144028.036474157@chello.nl> <20120316144241.012558280@chello.nl>
In-Reply-To: <20120316144241.012558280@chello.nl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/16/2012 10:40 AM, Peter Zijlstra wrote:

At LSF/MM, there was a presentation comparing Peter's
NUMA code with Andrea's NUMA code. I believe this is
the main reason why Andrea's code performed better in
that particular test...

> +		if (sched_feat(NUMA_BALANCE_FILTER)) {
> +			/*
> +			 * Avoid moving ne's when we create a larger imbalance
> +			 * on the other end.
> +			 */
> +			if ((imb->type & NUMA_BALANCE_CPU) &&
> +			    imb->cpu - cpu_moved < ne_cpu / 2)
> +				goto next;
> +
> +			/*
> +			 * Avoid migrating ne's when we'll know we'll push our
> +			 * node over the memory limit.
> +			 */
> +			if (max_mem_load &&
> +			    imb->mem_load + mem_moved + ne_mem > max_mem_load)
> +				goto next;
> +		}

IIRC the test consisted of a 16GB NUMA system with two 8GB nodes.
It was running 3 KVM guests, two guests of 3GB memory each, and
one guest of 6GB each.

With autonuma, the 6GB guest ended up on one node, and the
3GB guests on the other.

With sched numa, each node had a 3GB guest, and part of the 6GB guest.

There is a fundamental difference in the balancing between autonuma
and sched numa.

In sched numa, a process is moved over to the current node only if
the current node has space for it.

Autonuma, on the other hand, operates more of a a "hostage exchange"
policy, where a thread on one node is exchanged with a thread on
another node, if it looks like that will reduce the overall number
of cross-node NUMA faults in the system.

I am not sure how to do a "hostage exchange" algorithm with
sched numa, but it would seem like it could be necessary in order
for some workloads to converge on a sane configuration.

After all, with only about 2GB free on each node, you will never
get to move either a 3GB guest, or parts of a 6GB guest...

Any ideas?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
