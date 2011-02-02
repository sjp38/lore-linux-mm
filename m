Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AEEC48D0039
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 19:07:54 -0500 (EST)
Date: Wed, 2 Feb 2011 01:07:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 0/6] more detailed per-process transparent
 hugepage statistics
Message-ID: <20110202000750.GC16981@random.random>
References: <20110201003357.D6F0BE0D@kernel>
 <20110201153857.GA18740@random.random>
 <1296580547.27022.3370.camel@nimitz>
 <20110201203936.GB16981@random.random>
 <1296593801.27022.3920.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1296593801.27022.3920.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 01, 2011 at 12:56:41PM -0800, Dave Hansen wrote:
> On Tue, 2011-02-01 at 21:39 +0100, Andrea Arcangeli wrote:
> > So now the speedup
> > from hugepages needs to also offset the cost of the more frequent
> > split/collapse events that didn't happen before.
> 
> My concern here is the downward slope.  I interpret that as saying that
> we'll eventually have _zero_ THPs.  Plus, the benefits are decreasing
> constantly, even though the scanning overhead is fixed (or increasing
> even).

It doesn't seem a downward slope, it seems to level out at 900000
pages. As shown by the other chart a faster khugepaged scan rate would
make it level out at an higher percentage of memory being huge with an
increased cost in khugepaged but it may very well payoff for the final
performance (especially on plenty-core).

> I guess we could also try and figure out whether the khugepaged CPU
> overhead really comes from the scanning or the collapsing operations
> themselves.  Should be as easy as some oprofiling.

Actually I already know, the scanning is super fast. So it's no real
big deal to increase the scanning. It's big deal only if there are
plenty more of collapse/split. Compared to the KSM scan, the
khugepaged scan costs nothing.

> If it really is the scanning, I bet we could be a lot more efficient
> with khugepaged as well.  In the case of KVM guests, we're going to have
> awfully fixed virtual addresses and processes where collapsing can take
> place.
> 
> It might make sense to just have split_huge_page() stick the vaddr and
> the mm in a queue.  khugepaged could scan those addresses first instead
> of just going after the system as a whole.

That would apply to KSM and swapping only though, not to all
split_huge_page. It may not be bad idea. But the scanning really is
fast. So it may not be necessary. Clearly the more memory you have,
the faster the scanning has to be to obtain the same percentage of
memory in hugepages in presence of KSM.

Also note: did you tune the ksmd scanning values? Or you only run echo
1 >run?  Clearly if you increased the ksmd scanning values decreasing
the scan_sleep_millisecs or increased the pages_scanned, you've to
increase the khugepaged scanning values too accordingly. Not saying
the current default is ok for such an huge system that you're
using. But I doubt the ksm default is ok either for such an huge
system. So if you go tweak ksmd at 100% cpu load (which will also
cause more false sharing as the interval between the cksum comparsion
before adding to unstable tree decreases significantly) and khugepaged
doesn't collapse the false-sharing regions, it's normal. (in that case
either slowdown ksm or speedup khugepaged would help, slowing down ksm
may actually lead to better performance and not much less memory used)

In fact the "keep track" of split_huge_page location for khugepaged,
may actually hide issues in KSM if there's a piece of memory flipped
twice fast but that stays at the same value all the time, then the
cksum heuristic that decides if the page is constant enough to be
added to the unstable tree, may get false positives from the cksum. If
we notice in KSM the page cows fast after after sharing it for a
couple of times we should stop merging it. It'd be better to improve
KSM intelligence to avoid false sharing in that case. Now I don't have
enough data (I don't even know what runs in guest) clearly to tell if
this could ever be because of 1) undetectable false sharing from KSM
through the cksum, 2) a too fast ksm scan invalidating the ckshm, 3)
or genuine khugepaged scan too slow not keeping up with KSM optimal
changes (which would be perfectly normal if ksmd scan rate has been
increased a lot but khugepaged wasn't accordingly).

In short I don't issues at the moment with this workload if increasing
khugepaged (or slowing down ksm) optimizes it.

> For cases where the page got split, but wasn't modified, should we have
> a non-copying, non-allocating fastpath to re-merge it?

Even if it's modified it's ok, as long as the pages are still
physically contiguous collapse can happen in place. I never dreamed to
attempt it only because of the increased complexity,
__split_huge_page_refcount is complex enough so because I could avoid
converting from regular page to hugepage in place I happily avoided it
;). That BUG_ON(page_mapcount != mapcount) I can have nightmares at
night with it, so I was pleased not to have more of those. Anyway I
think it's not important optimization we should spend more energy in
making sure split_huge_page is never called for nothing. However in
the mid term I'm not against it, it may always happen sometime that
the hugepage is splitted by memory pressure but then the subpages
aren't swapped out.

There's also one other thing to optimize that I think has more
priority (it's not going to benefit KVM though) that is to collapse
readonly shared anon pages, which currently it can't do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
