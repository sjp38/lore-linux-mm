Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3DA6B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 10:11:13 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id d25-v6so9448991qkj.9
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 07:11:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v51-v6sor909622qtj.49.2018.07.20.07.11.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 07:11:07 -0700 (PDT)
Date: Fri, 20 Jul 2018 10:13:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180720141354.GA1729@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180717150142.GG2494@hirez.programming.kicks-ass.net>
 <20180718220623.GE2838@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718220623.GE2838@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Jul 18, 2018 at 06:06:23PM -0400, Johannes Weiner wrote:
> On Tue, Jul 17, 2018 at 05:01:42PM +0200, Peter Zijlstra wrote:
> > On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> > > +static bool psi_update_stats(struct psi_group *group)
> > > +{
> > > +	u64 some[NR_PSI_RESOURCES] = { 0, };
> > > +	u64 full[NR_PSI_RESOURCES] = { 0, };
> > > +	unsigned long nonidle_total = 0;
> > > +	unsigned long missed_periods;
> > > +	unsigned long expires;
> > > +	int cpu;
> > > +	int r;
> > > +
> > > +	mutex_lock(&group->stat_lock);
> > > +
> > > +	/*
> > > +	 * Collect the per-cpu time buckets and average them into a
> > > +	 * single time sample that is normalized to wallclock time.
> > > +	 *
> > > +	 * For averaging, each CPU is weighted by its non-idle time in
> > > +	 * the sampling period. This eliminates artifacts from uneven
> > > +	 * loading, or even entirely idle CPUs.
> > > +	 *
> > > +	 * We could pin the online CPUs here, but the noise introduced
> > > +	 * by missing up to one sample period from CPUs that are going
> > > +	 * away shouldn't matter in practice - just like the noise of
> > > +	 * previously offlined CPUs returning with a non-zero sample.
> > 
> > But why!? cpuu_read_lock() is neither expensive nor complicated. So why
> > try and avoid it?
> 
> Hm, I don't feel strongly about it either way. I'll add it.

Thinking more about it, this really doesn't buy anything. Whether a
CPU comes online or goes offline during the loop is no different than
that happening right before grabbing the cpus_read_lock(). If we see a
sample from a CPU, we incorporate it, if not we don't.

So it's not so much avoidance as it's lack of reason for synchronizing
against hotplugging in any fashion. The comment is wrong. This noise
it points to is there with and without the lock, and the only way to
avoid it would be to do either for_each_possible_cpu() in that loop or
having a hotplug callback that would flush the offlining CPU bucket
into a holding place for missed dead cpu samples that the aggregation
loop checks every time. Neither of these seem remotely worth the cost.

I'll fix the comment instead.
