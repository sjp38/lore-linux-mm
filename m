Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 04DC36B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 03:32:37 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN8WZxV026214
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 17:32:35 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D8D3345DE4E
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 17:32:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AE77345DD75
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 17:32:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D3FE1DB8038
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 17:32:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 372591DB803B
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 17:32:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] set_pgdat_percpu_threshold() don't use for_each_online_cpu
In-Reply-To: <20101116160720.5244ea22.akpm@linux-foundation.org>
References: <20101114163727.BEE0.A69D9226@jp.fujitsu.com> <20101116160720.5244ea22.akpm@linux-foundation.org>
Message-Id: <20101123172546.7BC5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Nov 2010 17:32:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

sorry for the delay.

> Well what's actually happening here?  Where is the alleged deadlock?
> 
> In the kernel_init() case we have a GFP_KERNEL allocation inside
> get_online_cpus().  In the other case we simply have kswapd calling
> get_online_cpus(), yes?

Yes.

> 
> Does lockdep consider all kswapd actions to be "in reclaim context"? 
> If so, why?

kswapd call lockdep_set_current_reclaim_state() at thread starting time.
see below.

----------------------------------------------------------------------
static int kswapd(void *p)
{
        unsigned long order;
        pg_data_t *pgdat = (pg_data_t*)p;
        struct task_struct *tsk = current;

        struct reclaim_state reclaim_state = {
                .reclaimed_slab = 0,
        };
        const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);

        lockdep_set_current_reclaim_state(GFP_KERNEL);
     ......
----------------------------------------------------------------------




> > I think we have two option 1) call lockdep_clear_current_reclaim_state()
> > every time 2) use for_each_possible_cpu instead for_each_online_cpu.
> > 
> > Following patch use (2) beucase removing get_online_cpus() makes good
> > side effect. It reduce potentially cpu-hotplug vs memory-shortage deadlock
> > risk. 
> 
> Well.  Being able to run for_each_online_cpu() is a pretty low-level
> and fundamental thing.  It's something we're likely to want to do more
> and more of as time passes.  It seems a bad thing to tell ourselves
> that we cannot use it in reclaim context.  That blots out large chunks
> of filesystem and IO-layer code as well!
> 
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -193,18 +193,16 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
> >  	int threshold;
> >  	int i;
> >  
> > -	get_online_cpus();
> >  	for (i = 0; i < pgdat->nr_zones; i++) {
> >  		zone = &pgdat->node_zones[i];
> >  		if (!zone->percpu_drift_mark)
> >  			continue;
> >  
> >  		threshold = (*calculate_pressure)(zone);
> > -		for_each_online_cpu(cpu)
> > +		for_each_possible_cpu(cpu)
> >  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> >  							= threshold;
> >  	}
> > -	put_online_cpus();
> >  }
> 
> That's a pretty sad change IMO, especially of num_possible_cpus is much
> larger than num_online_cpus.

As far as I know, CPU hotplug is used server area and almost server have
ACPI or similar flexible firmware interface. then, num_possible_cpus is
not so much big than actual numbers of socket.

IOW, I haven't hear embedded people use cpu hotplug. If you've hear, please
let me know.


> What do we need to do to make get_online_cpus() safe to use in reclaim
> context?  (And in kswapd context, if that's really equivalent to
> "reclaim context").

Hmm... It's too hard.
kmalloc() is called from everywhere and cpu hotplug is happen any time.
then, any lock design break your requested rule. ;)

And again, _now_ I don't think for_each_possible_cpu() is very costly.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
