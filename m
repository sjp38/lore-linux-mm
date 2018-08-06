Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B6D2C6B026F
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 11:25:38 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b12-v6so8651386plr.17
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 08:25:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i3-v6si10253031pld.454.2018.08.06.08.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 Aug 2018 08:25:37 -0700 (PDT)
Date: Mon, 6 Aug 2018 17:25:28 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180806152528.GM2494@hirez.programming.kicks-ass.net>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
 <20180801151958.32590-9-hannes@cmpxchg.org>
 <20180803165641.GA2476@hirez.programming.kicks-ass.net>
 <20180806150550.GA9888@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806150550.GA9888@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Aug 06, 2018 at 11:05:50AM -0400, Johannes Weiner wrote:
> Argh, that's right. This needs an explicit count if we want to access
> it locklessly. And you already said you didn't like that this is the
> only state not derived purely from the task counters, so maybe this is
> the way to go after all.
> 
> How about something like this (untested)?


> +static inline void psi_switch(struct rq *rq, struct task_struct *prev,
> +			      struct task_struct *next)
> +{
> +	if (psi_disabled)
> +		return;
> +
> +	if (unlikely(prev->flags & PF_MEMSTALL))
> +		psi_task_change(prev, rq_clock(rq), TSK_RECLAIMING, 0);
> +	if (unlikely(next->flags & PF_MEMSTALL))
> +		psi_task_change(next, rq_clock(rq), 0, TSK_RECLAIMING);
> +}


Urgh... can't say I really like that.

I would really rather do that scheduler_tick() thing to avoid the remote
update. The tick is a lot less hot than the switch path and esp.
next->flags might be a cold line (prev->flags is typically the same line
as prev->state so we already have that, but I don't think anybody now
looks at next->flags or its line, so that'd be cold load).
