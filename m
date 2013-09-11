Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 6F2076B0031
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 23:11:05 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id eo20so6950554lab.17
        for <linux-mm@kvack.org>; Tue, 10 Sep 2013 20:11:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378805550-29949-2-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
	<1378805550-29949-2-git-send-email-mgorman@suse.de>
Date: Wed, 11 Sep 2013 11:11:03 +0800
Message-ID: <CAJd=RBDBoJ42OkrqsD787O2ZYt9iPvwJo6DubDcVuS0tKRv9ng@mail.gmail.com>
Subject: Re: [PATCH 01/50] sched: monolithic code dump of what is being pushed upstream
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 10, 2013 at 5:31 PM, Mel Gorman <mgorman@suse.de> wrote:
> @@ -5045,15 +5038,50 @@ static int need_active_balance(struct lb_env *env)
>
>  static int active_load_balance_cpu_stop(void *data);
>
> +static int should_we_balance(struct lb_env *env)
> +{
> +       struct sched_group *sg = env->sd->groups;
> +       struct cpumask *sg_cpus, *sg_mask;
> +       int cpu, balance_cpu = -1;
> +
> +       /*
> +        * In the newly idle case, we will allow all the cpu's
> +        * to do the newly idle load balance.
> +        */
> +       if (env->idle == CPU_NEWLY_IDLE)
> +               return 1;
> +
> +       sg_cpus = sched_group_cpus(sg);
> +       sg_mask = sched_group_mask(sg);
> +       /* Try to find first idle cpu */
> +       for_each_cpu_and(cpu, sg_cpus, env->cpus) {
> +               if (!cpumask_test_cpu(cpu, sg_mask) || !idle_cpu(cpu))
> +                       continue;
> +
> +               balance_cpu = cpu;
> +               break;
> +       }
> +
> +       if (balance_cpu == -1)
> +               balance_cpu = group_balance_cpu(sg);
> +
> +       /*
> +        * First idle cpu or the first cpu(busiest) in this sched group
> +        * is eligible for doing load balancing at this and above domains.
> +        */
> +       return balance_cpu != env->dst_cpu;

FYI: Here is a bug reported by Dave Chinner.
https://lkml.org/lkml/2013/9/10/1

And lets see if any changes in your SpecJBB results without it.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
