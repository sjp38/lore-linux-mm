Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 074CF6B000E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 18:03:39 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id 133-v6so3355926ywq.4
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 15:03:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v139-v6sor1054717ywa.51.2018.07.18.15.03.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 15:03:38 -0700 (PDT)
Date: Wed, 18 Jul 2018 18:06:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180718220623.GE2838@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180717150142.GG2494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717150142.GG2494@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jul 17, 2018 at 05:01:42PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> > +static bool psi_update_stats(struct psi_group *group)
> > +{
> > +	u64 some[NR_PSI_RESOURCES] = { 0, };
> > +	u64 full[NR_PSI_RESOURCES] = { 0, };
> > +	unsigned long nonidle_total = 0;
> > +	unsigned long missed_periods;
> > +	unsigned long expires;
> > +	int cpu;
> > +	int r;
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
> > +	 * We could pin the online CPUs here, but the noise introduced
> > +	 * by missing up to one sample period from CPUs that are going
> > +	 * away shouldn't matter in practice - just like the noise of
> > +	 * previously offlined CPUs returning with a non-zero sample.
> 
> But why!? cpuu_read_lock() is neither expensive nor complicated. So why
> try and avoid it?

Hm, I don't feel strongly about it either way. I'll add it.

> > +	/* total= */
> > +	for (r = 0; r < NR_PSI_RESOURCES; r++) {
> > +		do_div(some[r], max(nonidle_total, 1UL));
> > +		do_div(full[r], max(nonidle_total, 1UL));
> > +
> > +		group->some[r] += some[r];
> > +		group->full[r] += full[r];
> 
> 		group->some[r] = div64_ul(some[r], max(nonidle_total, 1UL));
> 		group->full[r] = div64_ul(full[r], max(nonidle_total, 1UL));
> 
> Is easier to read imo.

Sounds good to me, I'll change that.
