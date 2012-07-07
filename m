Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id D0DA56B0074
	for <linux-mm@kvack.org>; Sat,  7 Jul 2012 14:27:17 -0400 (EDT)
Message-ID: <4FF87F5F.30106@redhat.com>
Date: Sat, 07 Jul 2012 14:26:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 14/26] sched, numa: Numa balancer
References: <20120316144028.036474157@chello.nl> <20120316144241.012558280@chello.nl>
In-Reply-To: <20120316144241.012558280@chello.nl>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/16/2012 10:40 AM, Peter Zijlstra wrote:

> +/*
> + * Assumes symmetric NUMA -- that is, each node is of equal size.
> + */
> +static void set_max_mem_load(unsigned long load)
> +{
> +	unsigned long old_load;
> +
> +	spin_lock(&max_mem_load.lock);
> +	old_load = max_mem_load.load;
> +	if (!old_load)
> +		old_load = load;
> +	max_mem_load.load = (old_load + load) >> 1;
> +	spin_unlock(&max_mem_load.lock);
> +}

The above in your patch kind of conflicts with this bit
from patch 6/26:

+	/*
+	 * Migration allocates pages in the highest zone. If we cannot
+	 * do so then migration (at least from node to node) is not
+	 * possible.
+	 */
+	if (vma->vm_file &&
+		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
+								< policy_zone)
+			return 0;

Looking at how the memory load code is used, I wonder
if it would make sense to count "zone size - free - inactive
file" pages instead?

> +			/*
> +			 * Avoid migrating ne's when we'll know we'll push our
> +			 * node over the memory limit.
> +			 */
> +			if (max_mem_load &&
> +			    imb->mem_load + mem_moved + ne_mem > max_mem_load)
> +				goto next;

> +static void numa_balance(struct node_queue *this_nq)
> +{
> +	struct numa_imbalance imb;
> +	int busiest;
> +
> +	busiest = find_busiest_node(this_nq->node, &imb);
> +	if (busiest == -1)
> +		return;
> +
> +	if (imb.cpu <= 0 && imb.mem <= 0)
> +		return;
> +
> +	move_processes(nq_of(busiest), this_nq, &imb);
> +}

You asked how and why Andrea's algorithm converges.
After looking at both patch sets for a while, and asking
for clarification, I think I can see how his code converges.

It is not yet clear to me how and why your code converges.

I see some dual bin packing (CPU & memory) heuristics, but
it is not at all clear to me how they interact, especially
when workloads are going active and idle on a regular basis.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
