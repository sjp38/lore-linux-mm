Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id D43DC6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 10:09:17 -0400 (EDT)
Date: Thu, 11 Jul 2013 15:09:14 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/16] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130711140914.GE2355@suse.de>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
 <1373536020-2799-9-git-send-email-mgorman@suse.de>
 <20130711123038.GH25631@dyad.programming.kicks-ass.net>
 <20130711130322.GC2355@suse.de>
 <20130711131158.GJ25631@dyad.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130711131158.GJ25631@dyad.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 11, 2013 at 03:11:58PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 11, 2013 at 02:03:22PM +0100, Mel Gorman wrote:
> > On Thu, Jul 11, 2013 at 02:30:38PM +0200, Peter Zijlstra wrote:
> > > On Thu, Jul 11, 2013 at 10:46:52AM +0100, Mel Gorman wrote:
> > > > @@ -829,10 +854,29 @@ static void task_numa_placement(struct task_struct *p)
> > > >  		}
> > > >  	}
> > > >  
> > > > -	/* Update the tasks preferred node if necessary */
> > > > +	/*
> > > > +	 * Record the preferred node as the node with the most faults,
> > > > +	 * requeue the task to be running on the idlest CPU on the
> > > > +	 * preferred node and reset the scanning rate to recheck
> > > > +	 * the working set placement.
> > > > +	 */
> > > >  	if (max_faults && max_nid != p->numa_preferred_nid) {
> > > > +		int preferred_cpu;
> > > > +
> > > > +		/*
> > > > +		 * If the task is not on the preferred node then find the most
> > > > +		 * idle CPU to migrate to.
> > > > +		 */
> > > > +		preferred_cpu = task_cpu(p);
> > > > +		if (cpu_to_node(preferred_cpu) != max_nid) {
> > > > +			preferred_cpu = find_idlest_cpu_node(preferred_cpu,
> > > > +							     max_nid);
> > > > +		}
> > > > +
> > > > +		/* Update the preferred nid and migrate task if possible */
> > > >  		p->numa_preferred_nid = max_nid;
> > > >  		p->numa_migrate_seq = 0;
> > > > +		migrate_task_to(p, preferred_cpu);
> > > >  	}
> > > >  }
> > > 
> > > Now what happens if the migrations fails? We set numa_preferred_nid to max_nid
> > > but then never re-try the migration. Should we not re-try the migration every
> > > so often, regardless of whether max_nid changed?
> > 
> > We do this
> > 
> > load_balance
> > -> active_load_balance_cpu_stop
> 
> Note that active balance is rare to begin with.
> 

Yeah. I was not sure how rare exactly but it is what motivated the
introduction of migrate_task_to in the first place. I actually have no
idea how often the migration fails. I did not check for it.

> >   -> move_one_task
> >     -> can_migrate_task
> >       -> migrate_improves_locality
> > 
> > If the conditions are right then it'll move the task to the preferred node
> > for a number of PTE scans. Of course there is no guarantee that the necessary
> > conditions will occur but I was wary of taking more drastic steps in the
> > scheduler such as retrying on every fault until the migration succeeds.
> > 
> 
> Ah, so task_numa_placement() is only called every full scan, not every fault.
> Also one could throttle it.
> 
> So initially I did all the movement through the regular balancer, but Ingo
> found that when the machine grows it quickly becomes unlikely we hit the right
> conditions. Hence he also went to direct migrations in his series.
> 

I wanted to avoid aggressive scheduling decisions until after the false
share detection stuff was solid.

> Another thing we might consider is counting the number of migration attempts
> and settling for the n-th best node for the n'th attempt and giving up when n
> surpasses the quality of the node we're currently on.

That might be necessary when the machine is overloaded. As a
starting point the following should retry the migrate a number of times
until success. The retry is checked on every fault but should not fire
more than once every 100ms.

Compile tested only

diff --git a/include/linux/sched.h b/include/linux/sched.h
index d44fbc6..454ad2e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1505,6 +1505,7 @@ struct task_struct {
 	int numa_migrate_seq;
 	unsigned int numa_scan_period;
 	unsigned int numa_scan_period_max;
+	unsigned long numa_migrate_retry;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index f2b37e01..a5b6b01 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -934,6 +934,20 @@ static inline int task_faults_idx(int nid, int priv)
 	return 2 * nid + priv;
 }
 
+/* Attempt to migrate a task to a CPU on the preferred node */
+static void numa_migrate_preferred(struct task_struct *p)
+{
+	int preferred_cpu = task_cpu(p);
+
+	p->numa_migrate_retry = 0;
+	if (cpu_to_node(preferred_cpu) != p->numa_preferred_nid) {
+		preferred_cpu = task_numa_find_cpu(p, p->numa_preferred_nid);
+
+		if (!migrate_task_to(p, preferred_cpu))
+			p->numa_migrate_retry = jiffies + HZ/10;
+	}
+}
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq, nid, max_nid = -1;
@@ -975,21 +989,12 @@ static void task_numa_placement(struct task_struct *p)
 	 * the working set placement.
 	 */
 	if (max_faults && max_nid != p->numa_preferred_nid) {
-		int preferred_cpu;
 		int old_migrate_seq = p->numa_migrate_seq;
 
-		/*
-		 * If the task is not on the preferred node then find 
-		 * a suitable CPU to migrate to.
-		 */
-		preferred_cpu = task_cpu(p);
-		if (cpu_to_node(preferred_cpu) != max_nid)
-			preferred_cpu = task_numa_find_cpu(p, max_nid);
-
 		/* Update the preferred nid and migrate task if possible */
 		p->numa_preferred_nid = max_nid;
 		p->numa_migrate_seq = 0;
-		migrate_task_to(p, preferred_cpu);
+		numa_migrate_preferred(p);
 
 		/*
 		 * If preferred nodes changes frequently then the scan rate
@@ -1050,6 +1055,10 @@ void task_numa_fault(int last_nidpid, int node, int pages, bool migrated)
 
 	task_numa_placement(p);
 
+	/* Retry task to preferred node migration if it previously failed */
+	if (p->numa_migrate_retry && time_after(jiffies, p->numa_migrate_retry))
+		numa_migrate_preferred(p);
+
 	/* Record the fault, double the weight if pages were migrated */
 	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages << migrated;
 }

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
