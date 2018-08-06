Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10D2C6B0007
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 11:20:58 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id j11-v6so10858797qtp.0
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 08:20:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h188-v6sor5943436qkc.2.2018.08.06.08.20.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 08:20:57 -0700 (PDT)
Date: Mon, 6 Aug 2018 11:23:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180806152354.GC9888@cmpxchg.org>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
 <20180801151958.32590-9-hannes@cmpxchg.org>
 <20180803170733.GC2494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180803170733.GC2494@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Aug 03, 2018 at 07:07:33PM +0200, Peter Zijlstra wrote:
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
> 
> I'm still puzzled by this.. for 99% of the machines online == possible.
> Why not always iterate possible and leave it at that? This is hardly a
> fast path.

Hmm, you're right, that makes things much simpler. I guess I'm mostly
worried about the 1% where this significantly differs, but it looks
like we're smarter than simply doing CONFIG_NR_CPUS for the possible
map, and we can easily stomach a bit of discrepancy in this path.

I'll change that to possible and delete/update the third paragraph.

Thanks
