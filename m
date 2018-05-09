Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39C0C6B04D1
	for <linux-mm@kvack.org>; Wed,  9 May 2018 06:05:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x23so18524973pfm.7
        for <linux-mm@kvack.org>; Wed, 09 May 2018 03:05:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l3-v6si25863196pld.96.2018.05.09.03.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 03:05:03 -0700 (PDT)
Date: Wed, 9 May 2018 12:04:55 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180509100455.GK12217@hirez.programming.kicks-ass.net>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180507210135.1823-7-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Mon, May 07, 2018 at 05:01:34PM -0400, Johannes Weiner wrote:
> +static void psi_clock(struct work_struct *work)
> +{
> +	u64 some[NR_PSI_RESOURCES] = { 0, };
> +	u64 full[NR_PSI_RESOURCES] = { 0, };
> +	unsigned long nonidle_total = 0;
> +	unsigned long missed_periods;
> +	struct delayed_work *dwork;
> +	struct psi_group *group;
> +	unsigned long expires;
> +	int cpu;
> +	int r;
> +
> +	dwork = to_delayed_work(work);
> +	group = container_of(dwork, struct psi_group, clock_work);
> +
> +	/*
> +	 * Calculate the sampling period. The clock might have been
> +	 * stopped for a while.
> +	 */
> +	expires = group->period_expires;
> +	missed_periods = (jiffies - expires) / MY_LOAD_FREQ;
> +	group->period_expires = expires + ((1 + missed_periods) * MY_LOAD_FREQ);
> +
> +	/*
> +	 * Aggregate the per-cpu state into a global state. Each CPU
> +	 * is weighted by its non-idle time in the sampling period.
> +	 */
> +	for_each_online_cpu(cpu) {

Typically when using online CPU state, you also need hotplug notifiers
to deal with changes in the online set.

You also typically need something like cpus_read_lock() around an
iteration of online CPUs, to avoid the set changing while you're poking
at them.

The lack for neither is evident or explained.

> +		struct psi_group_cpu *groupc = per_cpu_ptr(group->cpus, cpu);
> +		unsigned long nonidle;
> +
> +		nonidle = nsecs_to_jiffies(groupc->nonidle_time);
> +		groupc->nonidle_time = 0;
> +		nonidle_total += nonidle;
> +
> +		for (r = 0; r < NR_PSI_RESOURCES; r++) {
> +			struct psi_resource *res = &groupc->res[r];
> +
> +			some[r] += (res->times[0] + res->times[1]) * nonidle;
> +			full[r] += res->times[1] * nonidle;
> +
> +			/* It's racy, but we can tolerate some error */
> +			res->times[0] = 0;
> +			res->times[1] = 0;
> +		}
> +	}
> +
> +	for (r = 0; r < NR_PSI_RESOURCES; r++) {
> +		/* Finish the weighted aggregation */
> +		some[r] /= max(nonidle_total, 1UL);
> +		full[r] /= max(nonidle_total, 1UL);
> +
> +		/* Accumulate stall time */
> +		group->some[r] += some[r];
> +		group->full[r] += full[r];
> +
> +		/* Calculate recent pressure averages */
> +		calc_avgs(group->avg_some[r], some[r], missed_periods);
> +		calc_avgs(group->avg_full[r], full[r], missed_periods);
> +	}
> +
> +	/* Keep the clock ticking only when there is action */
> +	if (nonidle_total)
> +		schedule_delayed_work(dwork, MY_LOAD_FREQ);
> +}
