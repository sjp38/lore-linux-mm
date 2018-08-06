Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id EEAB66B000D
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 11:37:56 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j11-v6so10899624qtp.0
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 08:37:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j129-v6sor6125020qkc.52.2018.08.06.08.37.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 08:37:54 -0700 (PDT)
Date: Mon, 6 Aug 2018 11:40:51 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180806154051.GA14209@cmpxchg.org>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
 <20180801151958.32590-9-hannes@cmpxchg.org>
 <20180803165641.GA2476@hirez.programming.kicks-ass.net>
 <20180806150550.GA9888@cmpxchg.org>
 <20180806152528.GM2494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806152528.GM2494@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Aug 06, 2018 at 05:25:28PM +0200, Peter Zijlstra wrote:
> On Mon, Aug 06, 2018 at 11:05:50AM -0400, Johannes Weiner wrote:
> > Argh, that's right. This needs an explicit count if we want to access
> > it locklessly. And you already said you didn't like that this is the
> > only state not derived purely from the task counters, so maybe this is
> > the way to go after all.
> > 
> > How about something like this (untested)?
> 
> 
> > +static inline void psi_switch(struct rq *rq, struct task_struct *prev,
> > +			      struct task_struct *next)
> > +{
> > +	if (psi_disabled)
> > +		return;
> > +
> > +	if (unlikely(prev->flags & PF_MEMSTALL))
> > +		psi_task_change(prev, rq_clock(rq), TSK_RECLAIMING, 0);
> > +	if (unlikely(next->flags & PF_MEMSTALL))
> > +		psi_task_change(next, rq_clock(rq), 0, TSK_RECLAIMING);
> > +}
> 
> 
> Urgh... can't say I really like that.
> 
> I would really rather do that scheduler_tick() thing to avoid the remote
> update. The tick is a lot less hot than the switch path and esp.
> next->flags might be a cold line (prev->flags is typically the same line
> as prev->state so we already have that, but I don't think anybody now
> looks at next->flags or its line, so that'd be cold load).

Okay, the tick updater sounds like a much better option then. HZ
frequency should produce more than recent enough data.

That means we will retain the not-so-nice PF_MEMSTALL flag test under
rq lock, but it'll eliminate most of that memory ordering headache.

I'll do that. Thanks!
