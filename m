Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA256B04CB
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 16:38:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v102so48133407wrb.2
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 13:38:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p63si7961926edb.459.2017.07.31.13.38.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 31 Jul 2017 13:38:54 -0700 (PDT)
Date: Mon, 31 Jul 2017 16:38:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm/sched: memdelay: memory health interface for
 systems and workloads
Message-ID: <20170731203839.GA5162@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
 <20170727153010.23347-4-hannes@cmpxchg.org>
 <20170729091055.GA6524@worktop.programming.kicks-ass.net>
 <20170730152813.GA26672@cmpxchg.org>
 <20170731083111.tgjgkwge5dgt5m2e@hirez.programming.kicks-ass.net>
 <20170731184142.GA30943@cmpxchg.org>
 <1501530579.9118.43.camel@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1501530579.9118.43.camel@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jul 31, 2017 at 09:49:39PM +0200, Mike Galbraith wrote:
> On Mon, 2017-07-31 at 14:41 -0400, Johannes Weiner wrote:
> > 
> > Adding an rq counter for tasks inside memdelay sections should be
> > straight-forward as well (except for maybe the migration cost of that
> > state between CPUs in ttwu that Mike pointed out).
> 
> What I pointed out should be easily eliminated (zero use case).

How so?

> > That leaves the question of how to track these numbers per cgroup at
> > an acceptable cost. The idea for a tree of cgroups is that walltime
> > impact of delays at each level is reported for all tasks at or below
> > that level. E.g. a leave group aggregates the state of its own tasks,
> > the root/system aggregates the state of all tasks in the system; hence
> > the propagation of the task state counters up the hierarchy.
> 
> The crux of the biscuit is where exactly the investment return lies.
>  Gathering of these numbers ain't gonna be free, no matter how hard you
> try, and you're plugging into paths where every cycle added is made of
> userspace hide.

Right. But how to implement it sanely and optimize for cycles, and
whether we want to default-enable this interface are two separate
conversations.

It makes sense to me to first make the implementation as lightweight
on cycles and maintainability as possible, and then worry about the
cost / benefit defaults of the shipped Linux kernel afterwards.

That goes for the purely informative userspace interface, anyway. The
easily-provoked thrashing livelock I have described in the email to
Andrew is a different matter. If the OOM killer requires hooking up to
this metric to fix it, it won't be optional. But the OOM code isn't
part of this series yet, so again a conversation best had later, IMO.

PS: I'm stealing the "made of userspace hide" thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
