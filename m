Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE61D6B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 18:34:05 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id a14-v6so3283953ybl.10
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 15:34:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 203-v6sor1254312ywz.107.2018.07.18.15.33.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 15:33:58 -0700 (PDT)
Date: Wed, 18 Jul 2018 18:36:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180718223644.GH2838@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180718120318.GC2476@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718120318.GC2476@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Jul 18, 2018 at 02:03:18PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> > +	/* Time in which tasks wait for the CPU */
> > +	state = PSI_NONE;
> > +	if (tasks[NR_RUNNING] > 1)
> > +		state = PSI_SOME;
> > +	time_state(&groupc->res[PSI_CPU], state, now);
> > +
> > +	/* Time in which tasks wait for memory */
> > +	state = PSI_NONE;
> > +	if (tasks[NR_MEMSTALL]) {
> > +		if (!tasks[NR_RUNNING] ||
> > +		    (cpu_curr(cpu)->flags & PF_MEMSTALL))
> 
> I'm confused, why do we care if the current tasks is MEMSTALL or not?

We want to know whether we're losing CPU potential because of a lack
of memory. That can happen when the task waits for refaults and the
CPU goes idle, but it can also happen when the CPU is performing
reclaim.

If the task waits for refaults and something else is runnable, we're
not losing CPU potential. But if the task performs reclaim and uses
the CPU, nothing else can do productive work on that CPU.
