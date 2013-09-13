Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 243936B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 04:11:20 -0400 (EDT)
Date: Fri, 13 Sep 2013 09:11:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 01/50] sched: monolithic code dump of what is being
 pushed upstream
Message-ID: <20130913081111.GV22421@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-2-git-send-email-mgorman@suse.de>
 <CAJd=RBDBoJ42OkrqsD787O2ZYt9iPvwJo6DubDcVuS0tKRv9ng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBDBoJ42OkrqsD787O2ZYt9iPvwJo6DubDcVuS0tKRv9ng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Sep 11, 2013 at 11:11:03AM +0800, Hillf Danton wrote:
> On Tue, Sep 10, 2013 at 5:31 PM, Mel Gorman <mgorman@suse.de> wrote:
> > @@ -5045,15 +5038,50 @@ static int need_active_balance(struct lb_env *env)
> >
> >  static int active_load_balance_cpu_stop(void *data);
> >
> > +static int should_we_balance(struct lb_env *env)
> > +{
> > +       struct sched_group *sg = env->sd->groups;
> > +       struct cpumask *sg_cpus, *sg_mask;
> > +       int cpu, balance_cpu = -1;
> > +
> > +       /*
> > +        * In the newly idle case, we will allow all the cpu's
> > +        * to do the newly idle load balance.
> > +        */
> > +       if (env->idle == CPU_NEWLY_IDLE)
> > +               return 1;
> > +
> > +       sg_cpus = sched_group_cpus(sg);
> > +       sg_mask = sched_group_mask(sg);
> > +       /* Try to find first idle cpu */
> > +       for_each_cpu_and(cpu, sg_cpus, env->cpus) {
> > +               if (!cpumask_test_cpu(cpu, sg_mask) || !idle_cpu(cpu))
> > +                       continue;
> > +
> > +               balance_cpu = cpu;
> > +               break;
> > +       }
> > +
> > +       if (balance_cpu == -1)
> > +               balance_cpu = group_balance_cpu(sg);
> > +
> > +       /*
> > +        * First idle cpu or the first cpu(busiest) in this sched group
> > +        * is eligible for doing load balancing at this and above domains.
> > +        */
> > +       return balance_cpu != env->dst_cpu;
> 
> FYI: Here is a bug reported by Dave Chinner.
> https://lkml.org/lkml/2013/9/10/1
> 
> And lets see if any changes in your SpecJBB results without it.
> 

Thanks for pointing that out. I've picked up the one-liner fix.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
