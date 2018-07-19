Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 436D16B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 13:51:22 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id w3-v6so4740641ybp.2
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 10:51:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 130-v6sor1988319ybt.54.2018.07.19.10.51.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 10:51:18 -0700 (PDT)
Date: Thu, 19 Jul 2018 13:54:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180719175405.GA19230@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180718120318.GC2476@hirez.programming.kicks-ass.net>
 <CA+55aFw7t++BzEy-XsatNcauw3Wn22SSXfd3iTYECi4fJ97CCg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw7t++BzEy-XsatNcauw3Wn22SSXfd3iTYECi4fJ97CCg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, surenb@google.com, Vinayak Menon <vinmenon@codeaurora.org>, Christoph Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, shakeelb@google.com, linux-mm <linux-mm@kvack.org>, cgroups <cgroups@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Thu, Jul 19, 2018 at 08:08:20AM -0700, Linus Torvalds wrote:
> On Wed, Jul 18, 2018 at 5:03 AM Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > And as said before, we can compress the state from 12 bytes, to 6 bits
> > (or 1 byte), giving another 11 bytes for 59 bytes free.
> >
> > Leaving us just 5 bytes short of needing a single cacheline :/
> 
> Do you actually need 64 bits for the times?
> 
> That's the big cost. And it seems ridiculous, if you actually care about size.
> 
> You already have a 64-bit start time. Everything else is some
> cumulative relative time. Do those really need 64-bit and nanosecond
> resolution?
> 
> Maybe a 32-bit microsecond would be ok - would you ever account more
> than 35 minutes of anything without starting anew?

D'oh, you're right, the per-cpu buckets don't need to be this big at
all. In fact, we flush those deltas out every 2 seconds when there is
activity to maintain the running averages. Since we get 4.2s worth of
nanoseconds into a u32, we don't even need to divide in the hotpath.

Something along the lines of this here should work:

static void psi_group_change(struct psi_group *group, int cpu, u64 now,
			     unsigned int clear, unsigned int set)
{
	struct psi_group_cpu *groupc;
	unsigned int *tasks;
	unsigned int t;
	u32 delta;

	groupc = per_cpu_ptr(group->cpus, cpu);
	tasks = groupc->tasks;

	/* Time since last task change on this runqueue */
	delta = now - groupc->last_time;
	groupc->last_time = now;

	/* Tasks waited for IO? */
	if (tasks[NR_IOWAIT]) {
		if (!tasks[NR_RUNNING])
			groupc->full_time[PSI_IO] += delta;
		else
			groupc->some_time[PSI_IO] += delta;
	}

	/* Tasks waited for memory? */
	if (tasks[NR_MEMSTALL]) {
		if (!tasks[NR_RUNNING] ||
		    (cpu_curr(cpu)->flags & PF_MEMSTALL))
			groupc->full_time[PSI_MEM] += delta;
		else
			groupc->some_time[PSI_MEM] += delta;
	}

	/* Tasks waited for the CPU? */
	if (tasks[NR_RUNNING] > 1)
		groupc->some_time[PSI_CPU] += delta;

	/* Tasks were generally non-idle? To weigh the CPU in summaries */
	if (tasks[NR_RUNNING] || tasks[NR_IOWAIT] || tasks[NR_MEMSTALL])
		groupc->nonidle_time += delta;

	/* Update task counts according to the set/clear bitmasks */
	for (t = 0; clear; clear &= ~(1 << t), t++)
		if (clear & (1 << t))
			groupc->tasks[t]--;
	for (t = 0; set; set &= ~(1 << t), t++)
		if (set & (1 << t))
			groupc->tasks[t]++;

	/* Kick the stats aggregation worker if it's gone to sleep */
	if (!delayed_work_pending(&group->clock_work))
		schedule_delayed_work(&group->clock_work, PSI_FREQ);
}

And then we can pack it down to one cacheline:

struct psi_group_cpu {
	/* States of the tasks belonging to this group */
	unsigned int tasks[NR_PSI_TASK_COUNTS]; // 3

	/* Time sampling bucket for pressure states - no FULL for CPU */
	u32 some_time[NR_PSI_RESOURCES];
	u32 full_time[NR_PSI_RESOURCES - 1];

	/* Time sampling bucket for non-idle state (ns) */
	u32 nonidle_time;

	/* Time of last task change in this group (rq_clock) */
	u64 last_time;
};

I'm going to go test with this.

Thanks
