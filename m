Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8716B0038
	for <linux-mm@kvack.org>; Fri, 10 Oct 2014 14:56:24 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id hn15so3890611igb.9
        for <linux-mm@kvack.org>; Fri, 10 Oct 2014 11:56:23 -0700 (PDT)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id o9si5332318igy.19.2014.10.10.11.56.23
        for <linux-mm@kvack.org>;
        Fri, 10 Oct 2014 11:56:23 -0700 (PDT)
Date: Fri, 10 Oct 2014 13:56:20 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [BUG] mm, thp: khugepaged can't allocate on requested node when
 confined to a cpuset
Message-ID: <20141010185620.GA3745@sgi.com>
References: <20141008191050.GK3778@sgi.com>
 <20141010092052.GU4750@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141010092052.GU4750@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Fri, Oct 10, 2014 at 11:20:52AM +0200, Peter Zijlstra wrote:
> So for the numa thing we do everything from the affected tasks context.
> There was a lot of arguments early on that that could never really work,
> but here we are.
>
> Should we convert khugepaged to the same? Drive the whole thing from
> task_work? That would make this issue naturally go away.

That seems like a reasonable idea to me, but that will change the way
that the compaction scans work right now, by quite a bit.  As I'm sure
you're aware, the way it works now is we tack our mm onto the
khugepagd_scan list in do_huge_pmd_anonymous_page (there might be some
other ways to get on there - I can't remember), then when khugepaged
wakes up it scans through each mm on the list until it hits the maximum
number of pages to scan on each pass.

If we move the compaction scan over to a task_work style function, we'll
only be able to scan the one task's mm at a time.  While the underlying
compaction infrastructure can function more or less the same, the timing
of when these scans occur, and exactly what the scans cover, will have
to change.  If we go for the most rudimentary approach, the scans will
occur each time a thread is about to return to userland after faulting
in a THP (we'll just replace the khugepaged_enter call with a
task_work_add), and will cover the mm for the current task.  A slightly
more advanced approach would involve a timer to ensure that scans don't
occur too often, as is currently handled by
khugepaged_scan_sleep_millisecs. In any case, I don't see a way around
the fact that we'll lose the multi-mm scanning functionality our
khugepaged_scan list provides, but maybe that's not a huge issue.

Before I run off and start writing patches, here's a brief summary of
what I think we could do here:

1) Dissolve the khugepaged thread and related structs/timers (I'm
   expecting some backlash on this one).
2) Replace khugepged_enter calls with calls to task_work_add(work,
   our_new_scan_function) - new scan function will look almost exactly
   like khugepaged_scan_mm_slot.
3) Set up a timer similar to khugepaged_scan_sleep_millisecs that gets
   checked during/before our_new_scan_function to ensure that we're not
   scanning more often than necessary.  Also, set up progress markers to
   limit the number of pages scanned in a single pass.

By doing this, scans will get triggered each time a thread that has
faulted THPs is about to return to userland execution, throttled by our
new timer/progress indicators.  The major benefit here is that scans
will now occur in the desired task's context.

Let me know if you anybody sees any major flaws in this approach.

Thanks a lot for your input, Peter!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
