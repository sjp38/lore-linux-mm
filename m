Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A9FF56B7EE3
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 10:54:07 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id r2-v6so5726133ybb.4
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 07:54:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d12-v6sor1576967ywe.45.2018.09.07.07.54.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 07:54:06 -0700 (PDT)
Date: Fri, 7 Sep 2018 10:54:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180907145404.GB11088@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180828172258.3185-9-hannes@cmpxchg.org>
 <20180907102458.GP24106@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180907102458.GP24106@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Sep 07, 2018 at 12:24:58PM +0200, Peter Zijlstra wrote:
> On Tue, Aug 28, 2018 at 01:22:57PM -0400, Johannes Weiner wrote:
> > +static void psi_clock(struct work_struct *work)
> > +{
> > +	struct delayed_work *dwork;
> > +	struct psi_group *group;
> > +	bool nonidle;
> > +
> > +	dwork = to_delayed_work(work);
> > +	group = container_of(dwork, struct psi_group, clock_work);
> > +
> > +	/*
> > +	 * If there is task activity, periodically fold the per-cpu
> > +	 * times and feed samples into the running averages. If things
> > +	 * are idle and there is no data to process, stop the clock.
> > +	 * Once restarted, we'll catch up the running averages in one
> > +	 * go - see calc_avgs() and missed_periods.
> > +	 */
> > +
> > +	nonidle = update_stats(group);
> > +
> > +	if (nonidle) {
> > +		unsigned long delay = 0;
> > +		u64 now;
> > +
> > +		now = sched_clock();
> > +		if (group->next_update > now)
> > +			delay = nsecs_to_jiffies(group->next_update - now) + 1;
> > +		schedule_delayed_work(dwork, delay);
> > +	}
> > +}
> 
> Just a little nit; I would expect a function called *clock() to return a
> time.

Fair enough, let's rename this. How about this on top?

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 92489e66840b..0f07749b60a4 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -154,7 +154,7 @@ static struct psi_group psi_system = {
 	.pcpu = &system_group_pcpu,
 };
 
-static void psi_clock(struct work_struct *work);
+static void psi_update_work(struct work_struct *work);
 
 static void group_init(struct psi_group *group)
 {
@@ -163,7 +163,7 @@ static void group_init(struct psi_group *group)
 	for_each_possible_cpu(cpu)
 		seqcount_init(&per_cpu_ptr(group->pcpu, cpu)->seq);
 	group->next_update = sched_clock() + psi_period;
-	INIT_DELAYED_WORK(&group->clock_work, psi_clock);
+	INIT_DELAYED_WORK(&group->clock_work, psi_update_work);
 	mutex_init(&group->stat_lock);
 }
 
@@ -347,7 +347,7 @@ static bool update_stats(struct psi_group *group)
 	return nonidle_total;
 }
 
-static void psi_clock(struct work_struct *work)
+static void psi_update_work(struct work_struct *work)
 {
 	struct delayed_work *dwork;
 	struct psi_group *group;
