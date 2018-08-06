Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B00306B0005
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 11:16:32 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u22-v6so13362088qkk.10
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 08:16:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c50-v6sor6375098qtk.126.2018.08.06.08.16.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 08:16:31 -0700 (PDT)
Date: Mon, 6 Aug 2018 11:19:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180806151928.GB9888@cmpxchg.org>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
 <20180801151958.32590-9-hannes@cmpxchg.org>
 <20180803165641.GA2476@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180803165641.GA2476@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Aug 03, 2018 at 06:56:41PM +0200, Peter Zijlstra wrote:
> On Wed, Aug 01, 2018 at 11:19:57AM -0400, Johannes Weiner wrote:
> > +static bool psi_update_stats(struct psi_group *group)
> > +{
> > +	u64 deltas[NR_PSI_STATES - 1] = { 0, };
> > +	unsigned long missed_periods = 0;
> > +	unsigned long nonidle_total = 0;
> > +	u64 now, expires, period;
> > +	int cpu;
> > +	int s;
> > +
> > +	mutex_lock(&group->stat_lock);
> > +
> > +	/*
> > +	 * Collect the per-cpu time buckets and average them into a
> > +	 * single time sample that is normalized to wallclock time.
> > +	 *
> > +	 * For averaging, each CPU is weighted by its non-idle time in
> > +	 * the sampling period. This eliminates artifacts from uneven
> > +	 * loading, or even entirely idle CPUs.
> > +	 *
> > +	 * We don't need to synchronize against CPU hotplugging. If we
> > +	 * see a CPU that's online and has samples, we incorporate it.
> > +	 */
> > +	for_each_online_cpu(cpu) {
> > +		struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
> > +		u32 uninitialized_var(nonidle);
> 
> urgh.. I can see why the compiler got confused. Dodgy :-)

:-) I think we can make this cleaner. Something like this (modulo the
READ_ONCE/WRITE_ONCE you pointed out in the other email)?

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index abccfddba5d5..ce6f02ada1cd 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -220,6 +220,49 @@ static bool test_state(unsigned int *tasks, enum psi_states state)
 	}
 }
 
+static u32 read_update_delta(struct psi_group_cpu *groupc,
+			     enum psi_states state, int cpu)
+{
+	u32 time, delta;
+
+	time = READ_ONCE(groupc->times[state]);
+	/*
+	 * In addition to already concluded states, we also
+	 * incorporate currently active states on the CPU, since
+	 * states may last for many sampling periods.
+	 *
+	 * This way we keep our delta sampling buckets small (u32) and
+	 * our reported pressure close to what's actually happening.
+	 */
+	if (test_state(groupc->tasks, state)) {
+		/*
+		 * We can race with a state change and need to make
+		 * sure the state_start update is ordered against the
+		 * updates to the live state and the time buckets
+		 * (groupc->times).
+		 *
+		 * 1. If we observe task state that needs to be
+		 * recorded, make sure we see state_start from when
+		 * that state went into effect or we'll count time
+		 * from the previous state.
+		 *
+		 * 2. If the time delta has already been added to the
+		 * bucket, make sure we don't see it in state_start or
+		 * we'll count it twice.
+		 *
+		 * If the time delta is out of state_start but not in
+		 * the time bucket yet, we'll miss it entirely and
+		 * handle it in the next period.
+		 */
+		smp_rmb();
+		time += cpu_clock(cpu) - groupc->state_start;
+	}
+	delta = time - groupc->times_prev[state];
+	groupc->times_prev[state] = time;
+
+	return delta;
+}
+
 static bool psi_update_stats(struct psi_group *group)
 {
 	u64 deltas[NR_PSI_STATES - 1] = { 0, };
@@ -244,60 +287,17 @@ static bool psi_update_stats(struct psi_group *group)
 	 */
 	for_each_online_cpu(cpu) {
 		struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
-		u32 uninitialized_var(nonidle);
-
-		BUILD_BUG_ON(PSI_NONIDLE != NR_PSI_STATES - 1);
-
-		for (s = PSI_NONIDLE; s >= 0; s--) {
-			u32 time, delta;
-
-			time = READ_ONCE(groupc->times[s]);
-			/*
-			 * In addition to already concluded states, we
-			 * also incorporate currently active states on
-			 * the CPU, since states may last for many
-			 * sampling periods.
-			 *
-			 * This way we keep our delta sampling buckets
-			 * small (u32) and our reported pressure close
-			 * to what's actually happening.
-			 */
-			if (test_state(groupc->tasks, cpu, s)) {
-				/*
-				 * We can race with a state change and
-				 * need to make sure the state_start
-				 * update is ordered against the
-				 * updates to the live state and the
-				 * time buckets (groupc->times).
-				 *
-				 * 1. If we observe task state that
-				 * needs to be recorded, make sure we
-				 * see state_start from when that
-				 * state went into effect or we'll
-				 * count time from the previous state.
-				 *
-				 * 2. If the time delta has already
-				 * been added to the bucket, make sure
-				 * we don't see it in state_start or
-				 * we'll count it twice.
-				 *
-				 * If the time delta is out of
-				 * state_start but not in the time
-				 * bucket yet, we'll miss it entirely
-				 * and handle it in the next period.
-				 */
-				smp_rmb();
-				time += cpu_clock(cpu) - groupc->state_start;
-			}
-			delta = time - groupc->times_prev[s];
-			groupc->times_prev[s] = time;
-
-			if (s == PSI_NONIDLE) {
-				nonidle = nsecs_to_jiffies(delta);
-				nonidle_total += nonidle;
-			} else {
-				deltas[s] += (u64)delta * nonidle;
-			}
+		u32 nonidle;
+
+		nonidle = read_update_delta(groupc, PSI_NONIDLE, cpu);
+		nonidle = nsecs_to_jiffies(nonidle);
+		nonidle_total += nonidle;
+
+		for (s = 0; s < PSI_NONIDLE; s++) {
+			u32 delta;
+
+			delta = read_update_delta(groupc, s, cpu);
+			deltas[s] += (u64)delta * nonidle;
 		}
 	}
 
