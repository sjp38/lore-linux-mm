Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 226FA6B0617
	for <linux-mm@kvack.org>; Thu, 10 May 2018 10:22:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 44-v6so1525896wrt.9
        for <linux-mm@kvack.org>; Thu, 10 May 2018 07:22:53 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a1-v6si1105683edb.59.2018.05.10.07.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 May 2018 07:22:51 -0700 (PDT)
Date: Thu, 10 May 2018 10:24:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180510142442.GG19348@cmpxchg.org>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
 <20180509102100.GN12217@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509102100.GN12217@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Wed, May 09, 2018 at 12:21:00PM +0200, Peter Zijlstra wrote:
> On Mon, May 07, 2018 at 05:01:34PM -0400, Johannes Weiner wrote:
> > +	local_irq_disable();
> > +	rq = this_rq();
> > +	raw_spin_lock(&rq->lock);
> > +	rq_pin_lock(rq, &rf);
> 
> Given that churn in sched.h, you seen rq_lock() and friends.
> 
> Either write this like:
> 
> 	local_irq_disable();
> 	rq = this_rq();
> 	rq_lock(rq, &rf);
> 
> Or instroduce "rq = this_rq_lock_irq()", which we could also use in
> do_sched_yield().

Sounds good, I'll add that.

> > +	update_rq_clock(rq);
> > +
> > +	current->flags |= PF_MEMSTALL;
> > +	psi_task_change(current, rq_clock(rq), 0, TSK_MEMSTALL);
> > +
> > +	rq_unpin_lock(rq, &rf);
> > +	raw_spin_unlock(&rq->lock);
> > +	local_irq_enable();
> 
> That's called rq_unlock_irq().

I'll use that. This code was first written against a kernel that
didn't have 8a8c69c32778 ("sched/core: Add rq->lock wrappers.") yet ;)
