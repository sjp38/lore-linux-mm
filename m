Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B6DA76B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 14:40:24 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c4so318669610pfb.7
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 11:40:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y189si65627944pgb.131.2016.11.30.11.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 11:40:23 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAUJdrjm130204
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 14:40:23 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 27238s634x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 14:40:22 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 30 Nov 2016 12:40:22 -0700
Date: Wed, 30 Nov 2016 11:40:19 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161128110449.GK14788@dhcp22.suse.cz>
 <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
 <29196f89-c35e-f79d-8e4d-2bf73fe930df@molgen.mpg.de>
 <20161130110944.GD18432@dhcp22.suse.cz>
 <20161130115320.GO3924@linux.vnet.ibm.com>
 <20161130131910.GF18432@dhcp22.suse.cz>
 <20161130142955.GS3924@linux.vnet.ibm.com>
 <20161130163820.GQ3092@twins.programming.kicks-ass.net>
 <20161130170557.GK18432@dhcp22.suse.cz>
 <20161130175015.GR3092@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130175015.GR3092@twins.programming.kicks-ass.net>
Message-Id: <20161130194019.GF3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Wed, Nov 30, 2016 at 06:50:16PM +0100, Peter Zijlstra wrote:
> On Wed, Nov 30, 2016 at 06:05:57PM +0100, Michal Hocko wrote:
> > On Wed 30-11-16 17:38:20, Peter Zijlstra wrote:
> > > On Wed, Nov 30, 2016 at 06:29:55AM -0800, Paul E. McKenney wrote:
> > > > We can, and you are correct that cond_resched() does not unconditionally
> > > > supply RCU quiescent states, and never has.  Last time I tried to add
> > > > cond_resched_rcu_qs() semantics to cond_resched(), I got told "no",
> > > > but perhaps it is time to try again.
> > > 
> > > Well, you got told: "ARRGH my benchmark goes all regress", or something
> > > along those lines. Didn't we recently dig out those commits for some
> > > reason or other?
> > > 
> > > Finding out what benchmark that was and running it against this patch
> > > would make sense.
> 
> See commit:
> 
>   4a81e8328d37 ("rcu: Reduce overhead of cond_resched() checks for RCU")
> 
> Someone actually wrote down what the problem was.

Don't worry, it won't happen again.  ;-)

OK, so the regressions were in the "open1" test of Anton Blanchard's
"will it scale" suite, and were due to faster (and thus more) grace
periods rather than path length.

I could likely counter the grace-period speedup by regulating the rate
at which the grace-period machinery pays attention to the rcu_qs_ctr
per-CPU variable.  Actually, this looks pretty straightforward (famous
last words).  But see patch below, which is untested and probably
completely bogus.

> > > Also, I seem to have missed, why are we going through this again?
> > 
> > Well, the point I've brought that up is because having basically two
> > APIs for cond_resched is more than confusing. Basically all longer in
> > kernel loops do cond_resched() but it seems that this will not help the
> > silence RCU lockup detector in rare cases where nothing really wants to
> > schedule. I am really not sure whether we want to sprinkle
> > cond_resched_rcu_qs at random places just to silence RCU detector...
> 
> Right.. now, this is obviously all PREEMPT=n code, which therefore also
> implies this is rcu-sched.
> 
> Paul, now doesn't rcu-sched, when the grace-period has been long in
> coming, try and force it? And doesn't that forcing include prodding CPUs
> with resched_cpu() ?

It does in the v4.8.4 kernel that Boris is running.  It still does in my
-rcu tree, but only after an RCU CPU stall (something about people not
liking IPIs).  I may need to do a resched_cpu() halfway to stall-warning
time or some such.

> I'm thinking not, because if it did, that would make cond_resched()
> actually schedule, which would then call into rcu_note_context_switch()
> which would then make RCU progress, no?

Sounds plausible, but from what I can see some of the loops pointed
out by Boris's stall-warning messages don't have cond_resched().
There was another workload that apparently worked better when moved from
cond_resched() to cond_resched_rcu_qs(), but I don't know what kernel
version was running.

							Thanx, Paul

------------------------------------------------------------------------

commit 42b4ae9cb79479d2f922620fd696a0532019799c
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Wed Nov 30 11:21:21 2016 -0800

    rcu: Check cond_resched_rcu_qs() state less often to reduce GP overhead
    
    Commit 4a81e8328d37 ("rcu: Reduce overhead of cond_resched() checks
    for RCU") moved quiescent-state generation out of cond_resched()
    and commit bde6c3aa9930 ("rcu: Provide cond_resched_rcu_qs() to force
    quiescent states in long loops") introduced cond_resched_rcu_qs(), and
    commit 5cd37193ce85 ("rcu: Make cond_resched_rcu_qs() apply to normal RCU
    flavors") introduced the per-CPU rcu_qs_ctr variable, which is frequently
    polled by the RCU core state machine.
    
    This frequent polling can increase grace-period rate, which in turn
    increases grace-period overhead, which is visible in some benchmarks
    (for example, the "open1" benchmark in Anton Blanchard's "will it scale"
    suite).  This commit therefore reduces the rate at which rcu_qs_ctr
    is polled by moving that polling into the force-quiescent-state (FQS)
    machinery, and by further polling it only on the second and subsequent
    FQS passes of a given grace period.
    
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/include/trace/events/rcu.h b/include/trace/events/rcu.h
index 9d4f9b3a2b7b..e3facb356838 100644
--- a/include/trace/events/rcu.h
+++ b/include/trace/events/rcu.h
@@ -385,11 +385,11 @@ TRACE_EVENT(rcu_quiescent_state_report,
 
 /*
  * Tracepoint for quiescent states detected by force_quiescent_state().
- * These trace events include the type of RCU, the grace-period number
- * that was blocked by the CPU, the CPU itself, and the type of quiescent
- * state, which can be "dti" for dyntick-idle mode, "ofl" for CPU offline,
- * or "kick" when kicking a CPU that has been in dyntick-idle mode for
- * too long.
+ * These trace events include the type of RCU, the grace-period number that
+ * was blocked by the CPU, the CPU itself, and the type of quiescent state,
+ * which can be "dti" for dyntick-idle mode, "ofl" for CPU offline, "kick"
+ * when kicking a CPU that has been in dyntick-idle mode for too long, or
+ * "rqc" if the CPU got a quiescent state via its rcu_qs_ctr.
  */
 TRACE_EVENT(rcu_fqs,
 
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index b546c959c854..6745f1899ad9 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -1275,6 +1275,7 @@ static int rcu_implicit_dynticks_qs(struct rcu_data *rdp,
 				    bool *isidle, unsigned long *maxj)
 {
 	int *rcrmp;
+	struct rcu_node *rnp;
 
 	/*
 	 * If the CPU passed through or entered a dynticks idle phase with
@@ -1291,6 +1292,19 @@ static int rcu_implicit_dynticks_qs(struct rcu_data *rdp,
 	}
 
 	/*
+	 * Has this CPU encountered a cond_resched_rcu_qs() since the
+	 * beginning of the grace period?  For this to be the case,
+	 * the CPU has to have noticed the current grace period.  This
+	 * might not be the case for nohz_full CPUs looping in the kernel.
+	 */
+	rnp = rdp->mynode;
+	if (READ_ONCE(rdp->rcu_qs_ctr_snap) != __this_cpu_read(rcu_qs_ctr) &&
+	    READ_ONCE(rdp->gpnum) == rnp->gpnum && !rdp->gpwrap) {
+		trace_rcu_fqs(rdp->rsp->name, rdp->gpnum, rdp->cpu, TPS("rqc"));
+		return 1;
+	}
+
+	/*
 	 * Check for the CPU being offline, but only if the grace period
 	 * is old enough.  We don't need to worry about the CPU changing
 	 * state: If we see it offline even once, it has been through a
@@ -2588,10 +2602,8 @@ rcu_report_qs_rdp(int cpu, struct rcu_state *rsp, struct rcu_data *rdp)
 
 	rnp = rdp->mynode;
 	raw_spin_lock_irqsave_rcu_node(rnp, flags);
-	if ((rdp->cpu_no_qs.b.norm &&
-	     rdp->rcu_qs_ctr_snap == __this_cpu_read(rcu_qs_ctr)) ||
-	    rdp->gpnum != rnp->gpnum || rnp->completed == rnp->gpnum ||
-	    rdp->gpwrap) {
+	if (rdp->cpu_no_qs.b.norm || rdp->gpnum != rnp->gpnum ||
+	    rnp->completed == rnp->gpnum || rdp->gpwrap) {
 
 		/*
 		 * The grace period in which this quiescent state was
@@ -2646,8 +2658,7 @@ rcu_check_quiescent_state(struct rcu_state *rsp, struct rcu_data *rdp)
 	 * Was there a quiescent state since the beginning of the grace
 	 * period? If no, then exit and wait for the next call.
 	 */
-	if (rdp->cpu_no_qs.b.norm &&
-	    rdp->rcu_qs_ctr_snap == __this_cpu_read(rcu_qs_ctr))
+	if (rdp->cpu_no_qs.b.norm)
 		return;
 
 	/*
@@ -3625,9 +3636,7 @@ static int __rcu_pending(struct rcu_state *rsp, struct rcu_data *rdp)
 	    rdp->core_needs_qs && rdp->cpu_no_qs.b.norm &&
 	    rdp->rcu_qs_ctr_snap == __this_cpu_read(rcu_qs_ctr)) {
 		rdp->n_rp_core_needs_qs++;
-	} else if (rdp->core_needs_qs &&
-		   (!rdp->cpu_no_qs.b.norm ||
-		    rdp->rcu_qs_ctr_snap != __this_cpu_read(rcu_qs_ctr))) {
+	} else if (rdp->core_needs_qs && !rdp->cpu_no_qs.b.norm) {
 		rdp->n_rp_report_qs++;
 		return 1;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
