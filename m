Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9E226B7F91
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 13:50:23 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id 188-v6so6031876ybv.9
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 10:50:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w15-v6sor1711285ywg.334.2018.09.07.10.50.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 10:50:18 -0700 (PDT)
Date: Fri, 7 Sep 2018 13:50:15 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180907175015.GA8479@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180828172258.3185-9-hannes@cmpxchg.org>
 <20180907101634.GO24106@hirez.programming.kicks-ass.net>
 <20180907144422.GA11088@cmpxchg.org>
 <20180907145858.GK24106@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180907145858.GK24106@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Sep 07, 2018 at 04:58:58PM +0200, Peter Zijlstra wrote:
> On Fri, Sep 07, 2018 at 10:44:22AM -0400, Johannes Weiner wrote:
> 
> > > This does the whole seqcount thing 6x, which is a bit of a waste.
> > 
> > [...]
> > 
> > > It's a bit cumbersome, but that's because of C.
> > 
> > I was actually debating exactly this with Suren before, but since this
> > is a super cold path I went with readability. I was also thinking that
> > restarts could happen quite regularly under heavy scheduler load, and
> > so keeping the individual retry sections small could be helpful - but
> > I didn't instrument this in any way.
> 
> I was hoping going over the whole thing once would reduce the time we
> need to keep that line in shared mode and reduce traffic. And yes, this
> path is cold, but I was thinking about reducing the interference on the
> remote CPU.
> 
> Alternatively, we memcpy the whole line under the seqlock and then do
> everything later.
> 
> Also, this only has a single cpu_clock() invocation.

Good points.

How about the below? It's still pretty readable, and generates compact
code inside the now single retry section:

ffffffff81ed464f:       44 89 ff                mov    %r15d,%edi
ffffffff81ed4652:       e8 00 00 00 00          callq  ffffffff81ed4657 <update_stats+0xca>
                        ffffffff81ed4653: R_X86_64_PLT32        sched_clock_cpu-0x4
                memcpy(times, groupc->times, sizeof(groupc->times));
ffffffff81ed4657:       49 8b 14 24             mov    (%r12),%rdx
                state_start = groupc->state_start;
ffffffff81ed465b:       48 8b 4b 50             mov    0x50(%rbx),%rcx
                memcpy(times, groupc->times, sizeof(groupc->times));
ffffffff81ed465f:       48 89 54 24 30          mov    %rdx,0x30(%rsp)
ffffffff81ed4664:       49 8b 54 24 08          mov    0x8(%r12),%rdx
ffffffff81ed4669:       48 89 54 24 38          mov    %rdx,0x38(%rsp)
ffffffff81ed466e:       49 8b 54 24 10          mov    0x10(%r12),%rdx
ffffffff81ed4673:       48 89 54 24 40          mov    %rdx,0x40(%rsp)
                memcpy(tasks, groupc->tasks, sizeof(groupc->tasks));
ffffffff81ed4678:       49 8b 55 00             mov    0x0(%r13),%rdx
ffffffff81ed467c:       48 89 54 24 24          mov    %rdx,0x24(%rsp)
ffffffff81ed4681:       41 8b 55 08             mov    0x8(%r13),%edx
ffffffff81ed4685:       89 54 24 2c             mov    %edx,0x2c(%rsp)

---

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 0f07749b60a4..595414599b98 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -197,17 +197,26 @@ static bool test_state(unsigned int *tasks, enum psi_states state)
 	}
 }
 
-static u32 get_recent_time(struct psi_group *group, int cpu,
-			   enum psi_states state)
+static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
 {
 	struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
+	unsigned int tasks[NR_PSI_TASK_COUNTS];
+	u64 now, state_start;
 	unsigned int seq;
-	u32 time, delta;
+	int s;
 
+	/* Snapshot a coherent view of the CPU state */
 	do {
 		seq = read_seqcount_begin(&groupc->seq);
+		now = cpu_clock(cpu);
+		memcpy(times, groupc->times, sizeof(groupc->times));
+		memcpy(tasks, groupc->tasks, sizeof(groupc->tasks));
+		state_start = groupc->state_start;
+	} while (read_seqcount_retry(&groupc->seq, seq));
 
-		time = groupc->times[state];
+	/* Calculate state time deltas against the previous snapshot */
+	for (s = 0; s < NR_PSI_STATES; s++) {
+		u32 delta;
 		/*
 		 * In addition to already concluded states, we also
 		 * incorporate currently active states on the CPU,
@@ -217,14 +226,14 @@ static u32 get_recent_time(struct psi_group *group, int cpu,
 		 * (u32) and our reported pressure close to what's
 		 * actually happening.
 		 */
-		if (test_state(groupc->tasks, state))
-			time += cpu_clock(cpu) - groupc->state_start;
-	} while (read_seqcount_retry(&groupc->seq, seq));
+		if (test_state(tasks, s))
+			times[s] += now - state_start;
 
-	delta = time - groupc->times_prev[state];
-	groupc->times_prev[state] = time;
+		delta = times[s] - groupc->times_prev[s];
+		groupc->times_prev[s] = times[s];
 
-	return delta;
+		times[s] = delta;
+	}
 }
 
 static void calc_avgs(unsigned long avg[3], int missed_periods,
@@ -267,18 +276,16 @@ static bool update_stats(struct psi_group *group)
 	 * loading, or even entirely idle CPUs.
 	 */
 	for_each_possible_cpu(cpu) {
+		u32 times[NR_PSI_STATES];
 		u32 nonidle;
 
-		nonidle = get_recent_time(group, cpu, PSI_NONIDLE);
-		nonidle = nsecs_to_jiffies(nonidle);
-		nonidle_total += nonidle;
+		get_recent_times(group, cpu, times);
 
-		for (s = 0; s < PSI_NONIDLE; s++) {
-			u32 delta;
+		nonidle = nsecs_to_jiffies(times[PSI_NONIDLE]);
+		nonidle_total += nonidle;
 
-			delta = get_recent_time(group, cpu, s);
-			deltas[s] += (u64)delta * nonidle;
-		}
+		for (s = 0; s < PSI_NONIDLE; s++)
+			deltas[s] += (u64)times[s] * nonidle;
 	}
 
 	/*
