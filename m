Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57F696B05D5
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 04:31:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d5so185009083pfg.3
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 01:31:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b25si16044414pgf.52.2017.07.31.01.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 01:31:17 -0700 (PDT)
Date: Mon, 31 Jul 2017 10:31:11 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/3] mm/sched: memdelay: memory health interface for
 systems and workloads
Message-ID: <20170731083111.tgjgkwge5dgt5m2e@hirez.programming.kicks-ass.net>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
 <20170727153010.23347-4-hannes@cmpxchg.org>
 <20170729091055.GA6524@worktop.programming.kicks-ass.net>
 <20170730152813.GA26672@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170730152813.GA26672@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sun, Jul 30, 2017 at 11:28:13AM -0400, Johannes Weiner wrote:
> On Sat, Jul 29, 2017 at 11:10:55AM +0200, Peter Zijlstra wrote:
> > On Thu, Jul 27, 2017 at 11:30:10AM -0400, Johannes Weiner wrote:
> > > +static void domain_cpu_update(struct memdelay_domain *md, int cpu,
> > > +			      int old, int new)
> > > +{
> > > +	enum memdelay_domain_state state;
> > > +	struct memdelay_domain_cpu *mdc;
> > > +	unsigned long now, delta;
> > > +	unsigned long flags;
> > > +
> > > +	mdc = per_cpu_ptr(md->mdcs, cpu);
> > > +	spin_lock_irqsave(&mdc->lock, flags);
> > 
> > Afaict this is inside scheduler locks, this cannot be a spinlock. Also,
> > do we really want to add more atomics there?
> 
> I think we should be able to get away without an additional lock and
> rely on the rq lock instead. schedule, enqueue, dequeue already hold
> it, memdelay_enter/leave could be added. I need to think about what to
> do with try_to_wake_up in order to get the cpu move accounting inside
> the locked section of ttwu_queue(), but that should be doable too.

So could you start by describing what actual statistics we need? Because
as is the scheduler already does a gazillion stats and why can't re
repurpose some of those?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
