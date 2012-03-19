Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 566806B00F0
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 08:16:24 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Mon, 19 Mar 2012 12:11:55 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2JCAD8u2797746
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 23:10:16 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2JCG826022320
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 23:16:09 +1100
Message-ID: <4F672384.7030500@linux.vnet.ibm.com>
Date: Mon, 19 Mar 2012 17:46:04 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 15/26] sched, numa: Implement hotplug hooks
References: <20120316144028.036474157@chello.nl> <20120316144241.074193109@chello.nl>
In-Reply-To: <20120316144241.074193109@chello.nl>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/16/2012 08:10 PM, Peter Zijlstra wrote:

> start/stop numa balance threads on-demand using cpu-hotlpug.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  kernel/sched/numa.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 55 insertions(+), 7 deletions(-)
> --- a/kernel/sched/numa.c
> +++ b/kernel/sched/numa.c
> @@ -596,31 +596,79 @@ static int numad_thread(void *data)
>  	return 0;
>  }
> 
> +static int __cpuinit
> +numa_hotplug(struct notifier_block *nb, unsigned long action, void *hcpu)
> +{
> +	int cpu = (long)hcpu;
> +	int node = cpu_to_node(cpu);
> +	struct node_queue *nq = nq_of(node);
> +	struct task_struct *numad;
> +	int err = 0;
> +
> +	switch (action & ~CPU_TASKS_FROZEN) {
> +	case CPU_UP_PREPARE:
> +		if (nq->numad)
> +			break;
> +
> +		numad = kthread_create_on_node(numad_thread,
> +				nq, node, "numad/%d", node);
> +		if (IS_ERR(numad)) {
> +			err = PTR_ERR(numad);
> +			break;
> +		}
> +
> +		nq->numad = numad;
> +		nq->next_schedule = jiffies + HZ; // XXX sync-up?
> +		break;
> +
> +	case CPU_ONLINE:
> +		wake_up_process(nq->numad);
> +		break;
> +
> +	case CPU_DEAD:
> +	case CPU_UP_CANCELED:
> +		if (!nq->numad)
> +			break;
> +
> +		if (cpumask_any_and(cpu_online_mask,
> +				    cpumask_of_node(node)) >= nr_cpu_ids) {
> +			kthread_stop(nq->numad);
> +			nq->numad = NULL;
> +		}
> +		break;
> +	}
> +
> +	return notifier_from_errno(err);
> +}
> +
>  static __init int numa_init(void)
>  {
> -	int node;
> +	int node, cpu, err;
> 
>  	nqs = kzalloc(sizeof(struct node_queue*) * nr_node_ids, GFP_KERNEL);
>  	BUG_ON(!nqs);
> 
> -	for_each_node(node) { // XXX hotplug
> +	for_each_node(node) {
>  		struct node_queue *nq = kmalloc_node(sizeof(*nq),
>  				GFP_KERNEL | __GFP_ZERO, node);
>  		BUG_ON(!nq);
> 
> -		nq->numad = kthread_create_on_node(numad_thread,
> -				nq, node, "numad/%d", node);
> -		BUG_ON(IS_ERR(nq->numad));
> -
>  		spin_lock_init(&nq->lock);
>  		INIT_LIST_HEAD(&nq->entity_list);
> 
>  		nq->next_schedule = jiffies + HZ;
>  		nq->node = node;
>  		nqs[node] = nq;
> +	}
> 
> -		wake_up_process(nq->numad);
> +	get_online_cpus();
> +	cpu_notifier(numa_hotplug, 0);


ABBA deadlock!

CPU 0						CPU1
				echo 0/1 > /sys/devices/.../cpu*/online

					acquire cpu_add_remove_lock

get_online_cpus()
	acquire cpu_hotplug lock
					
					Blocked on cpu hotplug lock

cpu_notifier()
	acquire cpu_add_remove_lock

ABBA DEADLOCK!

[cpu_maps_update_begin/done() deal with cpu_add_remove_lock].

So, basically, at the moment there is no way to register a CPU Hotplug notifier
and do setup for all currently online cpus in a totally race-free manner.

One approach to fix this is to audit whether register_cpu_notifier() really needs
to take cpu_add_remove_lock and if no, then acquire cpu hotplug lock instead.

The other approach is to keep the existing lock ordering as it is and yet provide
a race-free way to register, as I had posted some time ago (incomplete/untested):

http://thread.gmane.org/gmane.linux.kernel/1258880/focus=15826


> +	for_each_online_cpu(cpu) {
> +		err = numa_hotplug(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
> +		BUG_ON(notifier_to_errno(err));
> +		numa_hotplug(NULL, CPU_ONLINE, (void *)(long)cpu);
>  	}
> +	put_online_cpus();
> 
>  	return 0;
>  }
> 
> 

 
Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
