Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 625766B0033
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 21:31:06 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id k7so1778298oag.9
        for <linux-mm@kvack.org>; Tue, 16 Jul 2013 18:31:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1373901620-2021-9-git-send-email-mgorman@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
	<1373901620-2021-9-git-send-email-mgorman@suse.de>
Date: Wed, 17 Jul 2013 09:31:05 +0800
Message-ID: <CAJd=RBB8rzy8bZ1JWkkmGBX2ucZ0kr9aOsiiwgV2s0y9_0z6fw@mail.gmail.com>
Subject: Re: [PATCH 08/18] sched: Reschedule task on preferred NUMA node once selected
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 15, 2013 at 11:20 PM, Mel Gorman <mgorman@suse.de> wrote:
> +static int
> +find_idlest_cpu_node(int this_cpu, int nid)
> +{
> +       unsigned long load, min_load = ULONG_MAX;
> +       int i, idlest_cpu = this_cpu;
> +
> +       BUG_ON(cpu_to_node(this_cpu) == nid);
> +
> +       rcu_read_lock();
> +       for_each_cpu(i, cpumask_of_node(nid)) {

Check allowed CPUs first if task is given?

> +               load = weighted_cpuload(i);
> +
> +               if (load < min_load) {
> +                       min_load = load;
> +                       idlest_cpu = i;
> +               }
> +       }
> +       rcu_read_unlock();
> +
> +       return idlest_cpu;
> +}
> +
[...]
> +       /*
> +        * Record the preferred node as the node with the most faults,
> +        * requeue the task to be running on the idlest CPU on the
> +        * preferred node and reset the scanning rate to recheck
> +        * the working set placement.
> +        */
>         if (max_faults && max_nid != p->numa_preferred_nid) {
> +               int preferred_cpu;
> +
> +               /*
> +                * If the task is not on the preferred node then find the most
> +                * idle CPU to migrate to.
> +                */
> +               preferred_cpu = task_cpu(p);
> +               if (cpu_to_node(preferred_cpu) != max_nid) {
> +                       preferred_cpu = find_idlest_cpu_node(preferred_cpu,
> +                                                            max_nid);
> +               }
> +
> +               /* Update the preferred nid and migrate task if possible */
>                 p->numa_preferred_nid = max_nid;
>                 p->numa_migrate_seq = 0;
> +               migrate_task_to(p, preferred_cpu);
>         }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
