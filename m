Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 55B3E6B003D
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:14:14 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id wp18so1323442obc.20
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:14:14 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id go3si5026435obb.44.2014.07.11.08.14.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 08:14:12 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 11 Jul 2014 09:14:10 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 404E9C40002
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:14:07 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6BFCvGv60489892
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 17:12:57 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s6BFIA8h006049
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:18:12 -0600
Date: Fri, 11 Jul 2014 08:14:05 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 01/30] mm, kernel: Use cpu_to_mem()/numa_mem_id()
 to support memoryless node
Message-ID: <20140711151405.GK16041@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-2-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405064267-11678-2-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Dipankar Sarma <dipankar@in.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Jens Axboe <axboe@kernel.dk>, Frederic Weisbecker <fweisbec@gmail.com>, Jan Kara <jack@suse.cz>, Ingo Molnar <mingo@kernel.org>, Christoph Hellwig <hch@infradead.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Xie XiuQi <xiexiuqi@huawei.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 11, 2014 at 03:37:18PM +0800, Jiang Liu wrote:
> When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
> may return a node without memory, and later cause system failure/panic
> when calling kmalloc_node() and friends with returned node id.
> So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
> memory for the/current cpu.
> 
> If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
> is the same as cpu_to_node()/numa_node_id().
> 
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>

For the rcutorture piece:

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Or if you separate the kernel/rcu/rcutorture.c portion into a separate
patch, I will queue it separately.

							Thanx, Paul

> ---
>  kernel/rcu/rcutorture.c |    2 +-
>  kernel/smp.c            |    2 +-
>  kernel/smpboot.c        |    2 +-
>  kernel/taskstats.c      |    2 +-
>  kernel/timer.c          |    2 +-
>  5 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/kernel/rcu/rcutorture.c b/kernel/rcu/rcutorture.c
> index 7fa34f86e5ba..f593762d3214 100644
> --- a/kernel/rcu/rcutorture.c
> +++ b/kernel/rcu/rcutorture.c
> @@ -1209,7 +1209,7 @@ static int rcutorture_booster_init(int cpu)
>  	mutex_lock(&boost_mutex);
>  	VERBOSE_TOROUT_STRING("Creating rcu_torture_boost task");
>  	boost_tasks[cpu] = kthread_create_on_node(rcu_torture_boost, NULL,
> -						  cpu_to_node(cpu),
> +						  cpu_to_mem(cpu),
>  						  "rcu_torture_boost");
>  	if (IS_ERR(boost_tasks[cpu])) {
>  		retval = PTR_ERR(boost_tasks[cpu]);
> diff --git a/kernel/smp.c b/kernel/smp.c
> index 80c33f8de14f..2f3b84aef159 100644
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -41,7 +41,7 @@ hotplug_cfd(struct notifier_block *nfb, unsigned long action, void *hcpu)
>  	case CPU_UP_PREPARE:
>  	case CPU_UP_PREPARE_FROZEN:
>  		if (!zalloc_cpumask_var_node(&cfd->cpumask, GFP_KERNEL,
> -				cpu_to_node(cpu)))
> +				cpu_to_mem(cpu)))
>  			return notifier_from_errno(-ENOMEM);
>  		cfd->csd = alloc_percpu(struct call_single_data);
>  		if (!cfd->csd) {
> diff --git a/kernel/smpboot.c b/kernel/smpboot.c
> index eb89e1807408..9c08e68e48a9 100644
> --- a/kernel/smpboot.c
> +++ b/kernel/smpboot.c
> @@ -171,7 +171,7 @@ __smpboot_create_thread(struct smp_hotplug_thread *ht, unsigned int cpu)
>  	if (tsk)
>  		return 0;
> 
> -	td = kzalloc_node(sizeof(*td), GFP_KERNEL, cpu_to_node(cpu));
> +	td = kzalloc_node(sizeof(*td), GFP_KERNEL, cpu_to_mem(cpu));
>  	if (!td)
>  		return -ENOMEM;
>  	td->cpu = cpu;
> diff --git a/kernel/taskstats.c b/kernel/taskstats.c
> index 13d2f7cd65db..cf5cba1e7fbe 100644
> --- a/kernel/taskstats.c
> +++ b/kernel/taskstats.c
> @@ -304,7 +304,7 @@ static int add_del_listener(pid_t pid, const struct cpumask *mask, int isadd)
>  	if (isadd == REGISTER) {
>  		for_each_cpu(cpu, mask) {
>  			s = kmalloc_node(sizeof(struct listener),
> -					GFP_KERNEL, cpu_to_node(cpu));
> +					GFP_KERNEL, cpu_to_mem(cpu));
>  			if (!s) {
>  				ret = -ENOMEM;
>  				goto cleanup;
> diff --git a/kernel/timer.c b/kernel/timer.c
> index 3bb01a323b2a..5831a38b5681 100644
> --- a/kernel/timer.c
> +++ b/kernel/timer.c
> @@ -1546,7 +1546,7 @@ static int init_timers_cpu(int cpu)
>  			 * The APs use this path later in boot
>  			 */
>  			base = kzalloc_node(sizeof(*base), GFP_KERNEL,
> -					    cpu_to_node(cpu));
> +					    cpu_to_mem(cpu));
>  			if (!base)
>  				return -ENOMEM;
> 
> -- 
> 1.7.10.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
