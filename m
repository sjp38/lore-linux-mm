Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBCC6B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 14:44:56 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t10-v6so4867581ywc.7
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 11:44:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h22-v6sor1689111ybg.198.2018.07.19.11.44.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 11:44:52 -0700 (PDT)
Date: Thu, 19 Jul 2018 14:47:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180719184740.GA26291@cmpxchg.org>
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
> > +	/* Update task counts according to the set/clear bitmasks */
> > +	for (to = 0; (bo = ffs(clear)); to += bo, clear >>= bo) {
> > +		int idx = to + (bo - 1);
> > +
> > +		if (tasks[idx] == 0 && !psi_bug) {
> > +			printk_deferred(KERN_ERR "psi: task underflow! cpu=%d idx=%d tasks=[%u %u %u] clear=%x set=%x\n",
> > +					cpu, idx, tasks[0], tasks[1], tasks[2],
> > +					clear, set);
> > +			psi_bug = 1;
> > +		}
> 
> 		WARN_ONCE(!tasks[idx], ...);

It's just open-coded because of the printk_deferred, since this is
inside the scheduler.

It actually used to be a straight-up WARN_ONCE() in older
versions. Recursive scheduling bugs are no fun to debug ;)
