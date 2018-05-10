Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 700CD6B0612
	for <linux-mm@kvack.org>; Thu, 10 May 2018 10:08:53 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id d4-v6so1488263wrn.15
        for <linux-mm@kvack.org>; Thu, 10 May 2018 07:08:53 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i8-v6si1054480edg.49.2018.05.10.07.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 May 2018 07:08:52 -0700 (PDT)
Date: Thu, 10 May 2018 10:10:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180510141042.GD19348@cmpxchg.org>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
 <20180509100455.GK12217@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509100455.GK12217@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Wed, May 09, 2018 at 12:04:55PM +0200, Peter Zijlstra wrote:
> On Mon, May 07, 2018 at 05:01:34PM -0400, Johannes Weiner wrote:
> > +static void psi_clock(struct work_struct *work)
> > +{
> > +	u64 some[NR_PSI_RESOURCES] = { 0, };
> > +	u64 full[NR_PSI_RESOURCES] = { 0, };
> > +	unsigned long nonidle_total = 0;
> > +	unsigned long missed_periods;
> > +	struct delayed_work *dwork;
> > +	struct psi_group *group;
> > +	unsigned long expires;
> > +	int cpu;
> > +	int r;
> > +
> > +	dwork = to_delayed_work(work);
> > +	group = container_of(dwork, struct psi_group, clock_work);
> > +
> > +	/*
> > +	 * Calculate the sampling period. The clock might have been
> > +	 * stopped for a while.
> > +	 */
> > +	expires = group->period_expires;
> > +	missed_periods = (jiffies - expires) / MY_LOAD_FREQ;
> > +	group->period_expires = expires + ((1 + missed_periods) * MY_LOAD_FREQ);
> > +
> > +	/*
> > +	 * Aggregate the per-cpu state into a global state. Each CPU
> > +	 * is weighted by its non-idle time in the sampling period.
> > +	 */
> > +	for_each_online_cpu(cpu) {
> 
> Typically when using online CPU state, you also need hotplug notifiers
> to deal with changes in the online set.
> 
> You also typically need something like cpus_read_lock() around an
> iteration of online CPUs, to avoid the set changing while you're poking
> at them.
> 
> The lack for neither is evident or explained.

The per-cpu state we access is allocated for each possible CPU, so
that is safe (and state being all 0 is semantically sound, too). In a
race with onlining, we might miss some per-cpu samples, but would
catch them the next time. In a race with offlining, we may never
consider the final up to 2s state history of the disappearing CPU; we
could have an offlining callback to flush the state, but I'm not sure
this would be an actual problem in the real world since the error is
small (smallest averaging window is 5 sampling periods) and then would
age out quickly.

I can certainly add a comment explaining this at least.

> > +		struct psi_group_cpu *groupc = per_cpu_ptr(group->cpus, cpu);
> > +		unsigned long nonidle;
> > +
> > +		nonidle = nsecs_to_jiffies(groupc->nonidle_time);
> > +		groupc->nonidle_time = 0;
> > +		nonidle_total += nonidle;
> > +
> > +		for (r = 0; r < NR_PSI_RESOURCES; r++) {
> > +			struct psi_resource *res = &groupc->res[r];
> > +
> > +			some[r] += (res->times[0] + res->times[1]) * nonidle;
> > +			full[r] += res->times[1] * nonidle;
> > +
> > +			/* It's racy, but we can tolerate some error */
> > +			res->times[0] = 0;
> > +			res->times[1] = 0;
> > +		}
> > +	}
