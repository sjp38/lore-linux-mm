Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8F16B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 19:56:04 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b1so1366390281pgc.5
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 16:56:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m129si70554648pgm.165.2017.01.03.16.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 16:56:03 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v040sdJT105945
	for <linux-mm@kvack.org>; Tue, 3 Jan 2017 19:56:03 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 27rmq7m5vk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Jan 2017 19:56:02 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 3 Jan 2017 17:56:02 -0700
Date: Tue, 3 Jan 2017 16:55:59 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Fw: [lkp-developer] [sched,rcu]  cf7a2dca60: [No primary change]
 +186% will-it-scale.time.involuntary_context_switches
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161213151408.GC3924@linux.vnet.ibm.com>
 <20161214095425.GE25573@dhcp22.suse.cz>
 <20161214110609.GK3924@linux.vnet.ibm.com>
 <20161214161540.GP25573@dhcp22.suse.cz>
 <20161214164827.GL3924@linux.vnet.ibm.com>
 <20161214173923.GA16763@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214173923.GA16763@dhcp22.suse.cz>
Message-Id: <20170104005559.GD3742@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org

On Wed, Dec 14, 2016 at 06:39:24PM +0100, Michal Hocko wrote:
> On Wed 14-12-16 08:48:27, Paul E. McKenney wrote:
> > On Wed, Dec 14, 2016 at 05:15:41PM +0100, Michal Hocko wrote:
> > > On Wed 14-12-16 03:06:09, Paul E. McKenney wrote:
> > > > On Wed, Dec 14, 2016 at 10:54:25AM +0100, Michal Hocko wrote:
> > > > > On Tue 13-12-16 07:14:08, Paul E. McKenney wrote:
> > > > > > Just FYI for the moment...
> > > > > > 
> > > > > > So even with the slowed-down checking, making cond_resched() do what
> > > > > > cond_resched_rcu_qs() does results in a smallish but quite measurable
> > > > > > degradation according to 0day.
> > > > > 
> > > > > So if I understand those results properly, the reason seems to be the
> > > > > increased involuntary context switches, right? Or am I misreading the
> > > > > data?
> > > > > I am looking at your "sched,rcu: Make cond_resched() provide RCU
> > > > > quiescent state" in linux-next and I am wondering whether rcu_all_qs has
> > > > > to be called unconditionally and not only when should_resched failed few
> > > > > times? I guess you have discussed that with Peter already but do not
> > > > > remember the outcome.
> > > > 
> > > > My first thought is to wait for the grace period to age further before
> > > > checking, the idea being to avoid increasing cond_resched() overhead
> > > > any further.  But if that doesn't work, then yes, I may have to look at
> > > > adding more checks to cond_resched().
> > > 
> > > This might be really naive but would something like the following work?
> > > The overhead should be pretty much negligible, I guess. Ideally the pcp
> > > variable could be set somewhere from check_cpu_stall() but I couldn't
> > > wrap my head around that code to see how exactly.
> > 
> > My concern (perhaps misplaced) with this approach is that there are
> > quite a few tight loops containing cond_resched().  So I would still
> > need to throttle the resulting grace-period acceleration to keep the
> > context switches down to a dull roar.
> 
> Yes, I see your point. Something based on the stall timeout would be
> much better of course. I just failed to come up with something that
> would make sense. This was more my lack of familiarity with the code so
> I hope you will be more successful ;)

Well, here is my current shot at this.  And so do I.  ;-)

So now it ignores cond_resched_rcu_qs() until at least
jiffies_till_sched_qs jiffies have elapsed since the start of the
grace period.  The jiffies_till_sched_qs variable defaults to HZ/20,
which should slow the checks down by about a factor of seven.  Plus I
don't see a problem with changing the default to (say) HZ/10 if needed.

Thoughts?

							Thanx, Paul

------------------------------------------------------------------------

commit 7acd02c9e62fb21e7466e7a99fc21bf6ed6cc3cf
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Tue Jan 3 16:49:46 2017 -0800

    squash! rcu: Check cond_resched_rcu_qs() state less often to reduce GP overhead
    
    Now polling only after jiffies_till_sched_qs jiffies have elapsed.

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 083cb8a6299c..0369e0e0fe00 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -1274,7 +1274,9 @@ static int dyntick_save_progress_counter(struct rcu_data *rdp,
 static int rcu_implicit_dynticks_qs(struct rcu_data *rdp,
 				    bool *isidle, unsigned long *maxj)
 {
+	unsigned long jtsq;
 	int *rcrmp;
+	unsigned long rjtsc;
 	struct rcu_node *rnp;
 
 	/*
@@ -1291,6 +1293,17 @@ static int rcu_implicit_dynticks_qs(struct rcu_data *rdp,
 		return 1;
 	}
 
+	/* Compute and saturate jiffies_till_sched_qs. */
+	jtsq = jiffies_till_sched_qs;
+	rjtsc = rcu_jiffies_till_stall_check();
+	if (jtsq > rjtsc / 2) {
+		WRITE_ONCE(jiffies_till_sched_qs, rjtsc);
+		jtsq = rjtsc / 2;
+	} else if (jtsq < 1) {
+		WRITE_ONCE(jiffies_till_sched_qs, 1);
+		jtsq = 1;
+	}
+
 	/*
 	 * Has this CPU encountered a cond_resched_rcu_qs() since the
 	 * beginning of the grace period?  For this to be the case,
@@ -1298,7 +1311,8 @@ static int rcu_implicit_dynticks_qs(struct rcu_data *rdp,
 	 * might not be the case for nohz_full CPUs looping in the kernel.
 	 */
 	rnp = rdp->mynode;
-	if (READ_ONCE(rdp->rcu_qs_ctr_snap) != per_cpu(rcu_qs_ctr, rdp->cpu) &&
+	if (time_after(jiffies, rdp->rsp->gp_start + jtsq) &&
+	    READ_ONCE(rdp->rcu_qs_ctr_snap) != per_cpu(rcu_qs_ctr, rdp->cpu) &&
 	    READ_ONCE(rdp->gpnum) == rnp->gpnum && !rdp->gpwrap) {
 		trace_rcu_fqs(rdp->rsp->name, rdp->gpnum, rdp->cpu, TPS("rqc"));
 		return 1;
@@ -1333,9 +1347,8 @@ static int rcu_implicit_dynticks_qs(struct rcu_data *rdp,
 	 * warning delay.
 	 */
 	rcrmp = &per_cpu(rcu_sched_qs_mask, rdp->cpu);
-	if (ULONG_CMP_GE(jiffies,
-			 rdp->rsp->gp_start + jiffies_till_sched_qs) ||
-	    ULONG_CMP_GE(jiffies, rdp->rsp->jiffies_resched)) {
+	if (time_after(jiffies, rdp->rsp->gp_start + jtsq) ||
+	    time_after(jiffies, rdp->rsp->jiffies_resched)) {
 		if (!(READ_ONCE(*rcrmp) & rdp->rsp->flavor_mask)) {
 			WRITE_ONCE(rdp->cond_resched_completed,
 				   READ_ONCE(rdp->mynode->completed));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
