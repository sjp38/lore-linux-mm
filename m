Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD4E66B000E
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 11:58:42 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id i77-v6so2442724ywe.19
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 08:58:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e59-v6sor2786552ybi.95.2018.07.24.08.58.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 08:58:37 -0700 (PDT)
Date: Tue, 24 Jul 2018 12:01:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180724160126.GC11598@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180718120318.GC2476@hirez.programming.kicks-ass.net>
 <20180719184740.GA26291@cmpxchg.org>
 <20180719203114.GL2494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719203114.GL2494@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 19, 2018 at 10:31:15PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 19, 2018 at 02:47:40PM -0400, Johannes Weiner wrote:
> > On Wed, Jul 18, 2018 at 02:03:18PM +0200, Peter Zijlstra wrote:
> > > On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> > > > +	/* Update task counts according to the set/clear bitmasks */
> > > > +	for (to = 0; (bo = ffs(clear)); to += bo, clear >>= bo) {
> > > > +		int idx = to + (bo - 1);
> > > > +
> > > > +		if (tasks[idx] == 0 && !psi_bug) {
> > > > +			printk_deferred(KERN_ERR "psi: task underflow! cpu=%d idx=%d tasks=[%u %u %u] clear=%x set=%x\n",
> > > > +					cpu, idx, tasks[0], tasks[1], tasks[2],
> > > > +					clear, set);
> > > > +			psi_bug = 1;
> > > > +		}
> > > 
> > > 		WARN_ONCE(!tasks[idx], ...);
> > 
> > It's just open-coded because of the printk_deferred, since this is
> > inside the scheduler.
> 
> Yeah, meh. There's ton of WARNs in the scheduler, WARNs should not
> trigger anyway.

This one in particular gave us quite a runaround. We had a subtle bug
in how psi processed task CPU migration that would only manifest with
hundreds of thousands of machine hours. When it triggered, instead of
the warning, we'd crash on a corrupted stack with a completely useless
crash dump - PC pointing to things that couldn't possibly trap etc.

So printk_deferred has been a lot more useful in those rare but
desparate cases ;-) Plus we keep the machine alive.
