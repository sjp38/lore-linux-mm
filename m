Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6911D6B0535
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:26:49 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z36so2068428wrb.13
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:26:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a8si19511991edl.470.2017.08.01.05.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 01 Aug 2017 05:26:48 -0700 (PDT)
Date: Tue, 1 Aug 2017 08:26:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm/sched: memdelay: memory health interface for
 systems and workloads
Message-ID: <20170801122634.GA7237@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
 <20170727153010.23347-4-hannes@cmpxchg.org>
 <20170729091055.GA6524@worktop.programming.kicks-ass.net>
 <20170730152813.GA26672@cmpxchg.org>
 <20170731083111.tgjgkwge5dgt5m2e@hirez.programming.kicks-ass.net>
 <20170731184142.GA30943@cmpxchg.org>
 <20170801075728.GE6524@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170801075728.GE6524@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Aug 01, 2017 at 09:57:28AM +0200, Peter Zijlstra wrote:
> On Mon, Jul 31, 2017 at 02:41:42PM -0400, Johannes Weiner wrote:
> > On Mon, Jul 31, 2017 at 10:31:11AM +0200, Peter Zijlstra wrote:
> 
> > > So could you start by describing what actual statistics we need? Because
> > > as is the scheduler already does a gazillion stats and why can't re
> > > repurpose some of those?
> > 
> > If that's possible, that would be great of course.
> > 
> > We want to be able to tell how many tasks in a domain (the system or a
> > memory cgroup) are inside a memdelay section as opposed to how many
> 
> And you haven't even defined wth a memdelay section is yet..

It's what a task is in after it calls memdelay_enter() and before it
calls memdelay_leave().

Tasks mark themselves to be in a memory section when they know to
perform work that is necessary due to a lack of memory, such as
waiting for a refault or a direct reclaim invocation.

>From the patch:

+/**
+ * memdelay_enter - mark the beginning of a memory delay section
+ * @flags: flags to handle nested memdelay sections
+ *
+ * Marks the calling task as being delayed due to a lack of memory,
+ * such as waiting for a workingset refault or performing reclaim.
+ */

+/**
+ * memdelay_leave - mark the end of a memory delay section
+ * @flags: flags to handle nested memdelay sections
+ *
+ * Marks the calling task as no longer delayed due to memory.
+ */

where a reclaim callsite looks like this (decluttered):

	memdelay_enter()
	nr_reclaimed = do_try_to_free_pages()
	memdelay_leave()

That's what defines the "unproductive due to lack of memory" state of
a task. Time spent in that state weighed against time spent while the
task is productive - runnable or in iowait while not in a memdelay
section - gives the memory health of the task. And the system and
cgroup states/health can be derived from task states as described:

> > are in a "productive" state such as runnable or iowait. Then derive
> > from that whether the domain as a whole is unproductive (all non-idle
> > tasks memdelayed), or partially unproductive (some delayed, but CPUs
> > are productive or there are iowait tasks). Then derive the percentages
> > of walltime the domain spends partially or fully unproductive.
> > 
> > For that we need per-domain counters for
> > 
> > 	1) nr of tasks in memdelay sections
> > 	2) nr of iowait or runnable/queued tasks that are NOT inside
> > 	   memdelay sections

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
