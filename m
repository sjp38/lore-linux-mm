Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id A5F7C6B0034
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 09:03:26 -0400 (EDT)
Date: Thu, 11 Jul 2013 14:03:22 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/16] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130711130322.GC2355@suse.de>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
 <1373536020-2799-9-git-send-email-mgorman@suse.de>
 <20130711123038.GH25631@dyad.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130711123038.GH25631@dyad.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 11, 2013 at 02:30:38PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 11, 2013 at 10:46:52AM +0100, Mel Gorman wrote:
> > @@ -829,10 +854,29 @@ static void task_numa_placement(struct task_struct *p)
> >  		}
> >  	}
> >  
> > -	/* Update the tasks preferred node if necessary */
> > +	/*
> > +	 * Record the preferred node as the node with the most faults,
> > +	 * requeue the task to be running on the idlest CPU on the
> > +	 * preferred node and reset the scanning rate to recheck
> > +	 * the working set placement.
> > +	 */
> >  	if (max_faults && max_nid != p->numa_preferred_nid) {
> > +		int preferred_cpu;
> > +
> > +		/*
> > +		 * If the task is not on the preferred node then find the most
> > +		 * idle CPU to migrate to.
> > +		 */
> > +		preferred_cpu = task_cpu(p);
> > +		if (cpu_to_node(preferred_cpu) != max_nid) {
> > +			preferred_cpu = find_idlest_cpu_node(preferred_cpu,
> > +							     max_nid);
> > +		}
> > +
> > +		/* Update the preferred nid and migrate task if possible */
> >  		p->numa_preferred_nid = max_nid;
> >  		p->numa_migrate_seq = 0;
> > +		migrate_task_to(p, preferred_cpu);
> >  	}
> >  }
> 
> Now what happens if the migrations fails? We set numa_preferred_nid to max_nid
> but then never re-try the migration. Should we not re-try the migration every
> so often, regardless of whether max_nid changed?

We do this

load_balance
-> active_load_balance_cpu_stop
  -> move_one_task
    -> can_migrate_task
      -> migrate_improves_locality

If the conditions are right then it'll move the task to the preferred node
for a number of PTE scans. Of course there is no guarantee that the necessary
conditions will occur but I was wary of taking more drastic steps in the
scheduler such as retrying on every fault until the migration succeeds.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
