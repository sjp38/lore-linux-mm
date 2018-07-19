Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 956A96B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 16:31:25 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id q12-v6so4358082pgp.6
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 13:31:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z2-v6si64268pfb.365.2018.07.19.13.31.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Jul 2018 13:31:24 -0700 (PDT)
Date: Thu, 19 Jul 2018 22:31:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180719203114.GL2494@hirez.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180718120318.GC2476@hirez.programming.kicks-ass.net>
 <20180719184740.GA26291@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719184740.GA26291@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 19, 2018 at 02:47:40PM -0400, Johannes Weiner wrote:
> On Wed, Jul 18, 2018 at 02:03:18PM +0200, Peter Zijlstra wrote:
> > On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> > > +	/* Update task counts according to the set/clear bitmasks */
> > > +	for (to = 0; (bo = ffs(clear)); to += bo, clear >>= bo) {
> > > +		int idx = to + (bo - 1);
> > > +
> > > +		if (tasks[idx] == 0 && !psi_bug) {
> > > +			printk_deferred(KERN_ERR "psi: task underflow! cpu=%d idx=%d tasks=[%u %u %u] clear=%x set=%x\n",
> > > +					cpu, idx, tasks[0], tasks[1], tasks[2],
> > > +					clear, set);
> > > +			psi_bug = 1;
> > > +		}
> > 
> > 		WARN_ONCE(!tasks[idx], ...);
> 
> It's just open-coded because of the printk_deferred, since this is
> inside the scheduler.

Yeah, meh. There's ton of WARNs in the scheduler, WARNs should not
trigger anyway. But yeah printk is crap, which is why I don't use printk
anymore:

  https://lkml.kernel.org/r/20170928121823.430053219@infradead.org
