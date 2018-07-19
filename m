Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2A426B000C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:58:55 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w23-v6so2076594pgv.1
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:58:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p65-v6si6111560pga.401.2018.07.19.06.58.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Jul 2018 06:58:54 -0700 (PDT)
Date: Thu, 19 Jul 2018 15:58:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180719135846.GH2494@hirez.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180718120318.GC2476@hirez.programming.kicks-ass.net>
 <20180718223644.GH2838@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718223644.GH2838@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Jul 18, 2018 at 06:36:44PM -0400, Johannes Weiner wrote:
> On Wed, Jul 18, 2018 at 02:03:18PM +0200, Peter Zijlstra wrote:
> > On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> > > +	/* Time in which tasks wait for the CPU */
> > > +	state = PSI_NONE;
> > > +	if (tasks[NR_RUNNING] > 1)
> > > +		state = PSI_SOME;
> > > +	time_state(&groupc->res[PSI_CPU], state, now);
> > > +
> > > +	/* Time in which tasks wait for memory */
> > > +	state = PSI_NONE;
> > > +	if (tasks[NR_MEMSTALL]) {
> > > +		if (!tasks[NR_RUNNING] ||
> > > +		    (cpu_curr(cpu)->flags & PF_MEMSTALL))
> > 
> > I'm confused, why do we care if the current tasks is MEMSTALL or not?
> 
> We want to know whether we're losing CPU potential because of a lack
> of memory. That can happen when the task waits for refaults and the
> CPU goes idle, but it can also happen when the CPU is performing
> reclaim.
> 
> If the task waits for refaults and something else is runnable, we're
> not losing CPU potential. But if the task performs reclaim and uses
> the CPU, nothing else can do productive work on that CPU.

Right, this is because MEMSTALL is not just blocking (as per that other
sub-thread).

This is really unfortunate, because it means the state is not a simple
function of the task counts.
