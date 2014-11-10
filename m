Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D9F7E6B00BA
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 06:04:06 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id ex7so10020249wid.10
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 03:04:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jk7si16256631wid.59.2014.11.10.03.04.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 03:04:05 -0800 (PST)
Date: Mon, 10 Nov 2014 11:03:57 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Convert khugepaged to a task_work function
Message-ID: <20141110110357.GY21422@suse.de>
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
 <87lho0pf4l.fsf@tassilo.jf.intel.com>
 <544F9302.4010001@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <544F9302.4010001@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, Alex Thorlton <athorlton@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

On Tue, Oct 28, 2014 at 08:58:42AM -0400, Rik van Riel wrote:
> On 10/28/2014 08:12 AM, Andi Kleen wrote:
> > Alex Thorlton <athorlton@sgi.com> writes:
> > 
> >> Last week, while discussing possible fixes for some unexpected/unwanted behavior
> >> from khugepaged (see: https://lkml.org/lkml/2014/10/8/515) several people
> >> mentioned possibly changing changing khugepaged to work as a task_work function
> >> instead of a kernel thread.  This will give us finer grained control over the
> >> page collapse scans, eliminate some unnecessary scans since tasks that are
> >> relatively inactive will not be scanned often, and eliminate the unwanted
> >> behavior described in the email thread I mentioned.
> > 
> > With your change, what would happen in a single threaded case?
> > 
> > Previously one core would scan and another would run the workload.
> > With your change both scanning and running would be on the same
> > core.
> > 
> > Would seem like a step backwards to me.
> 

Only in the single-threaded, one process for the whole system case.
khugepaged can only scan one address space at a time and if processes
fail to allocate a huge page on fault then they must wait until
khugepaged gets to scan them. The wait time is not unbounded, but it
could be considerable.

As pointed out elsewhere, scanning from task-work context allows the
scan rate to adapt due to different inputs -- runtime on CPU probably
being the most relevant. Another scan factor could be NUMA sharing within
THP-boundaries in which case we don't want to either collapse or continue
scanning at the same rate.

> It's not just scanning, either.
> 
> Memory compaction can spend a lot of time waiting on
> locks. Not consuming CPU or anything, but just waiting.
> 

I did not pick apart the implementation closely as it's still RFC but
there is no requirement for the reclaim/compaction to take place from
task work context. That would likely cause user-visible stalls in any
number of situations can trigger bug reports.

One possibility would be to try allocate a THP GFP_ATOMIC from task_work
context and only start the scan if that allocation succeeds. Scan the
address space for a THP to collapse. If a collapse target it found and
the allocated THP is on the correct node then great -- use it. If not,
the first page should be freed and a second GFP_ATOMIC allocation
attempt made. 

If a THP allocation fails then wake we need something to try allocate the
page on the processes behalf. khugepaged could be repurposed to do the
reclaim/compaction step or kswapd could be woken up. Either option may
be tricky to get right as currently waking kswapd is avoided to prevent
excessive reclaim. khugepaged could do the work but would need similar
back-off logic in the event of failures. Workqueues could also be used
but I'd worry about controlling the number of active workqueue requests
and accounting for the reclaim/compaction work is tricker if workqueues
were used. 

> I am not convinced that moving all that waiting to task
> context is a good idea.
> 

It allows the scanning of page tables to be parallelised, moves the
work into the task context where it can be accounted for and the scan
rate can be adapted to prevent useless work. I think those are desirable
characteristics although there is no data on the expected gains of doing
something like this. It's the proper deferral of THP allocations that is
likely to cause the most headaches.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
