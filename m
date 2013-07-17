Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 26C4D6B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 06:50:45 -0400 (EDT)
Date: Wed, 17 Jul 2013 12:50:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 02/18] sched: Track NUMA hinting faults on per-node basis
Message-ID: <20130717105030.GB17211@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373901620-2021-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 15, 2013 at 04:20:04PM +0100, Mel Gorman wrote:
> index cc03cfd..c5f773d 100644
> --- a/kernel/sched/sched.h
> +++ b/kernel/sched/sched.h
> @@ -503,6 +503,17 @@ DECLARE_PER_CPU(struct rq, runqueues);
>  #define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
>  #define raw_rq()		(&__raw_get_cpu_var(runqueues))
>  
> +#ifdef CONFIG_NUMA_BALANCING
> +static inline void task_numa_free(struct task_struct *p)
> +{
> +	kfree(p->numa_faults);
> +}
> +#else /* CONFIG_NUMA_BALANCING */
> +static inline void task_numa_free(struct task_struct *p)
> +{
> +}
> +#endif /* CONFIG_NUMA_BALANCING */
> +
>  #ifdef CONFIG_SMP
>  
>  #define rcu_dereference_check_sched_domain(p) \


I also need the below hunk to make it compile:

--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -6,6 +6,7 @@
 #include <linux/spinlock.h>
 #include <linux/stop_machine.h>
 #include <linux/tick.h>
+#include <linux/slab.h>
 
 #include "cpupri.h"
 #include "cpuacct.h"



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
