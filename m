Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 019A46B0256
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:56:17 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id g62so43027482wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:56:16 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id ha10si11589578wjc.117.2016.02.25.11.56.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Feb 2016 11:56:15 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 63D279909D
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 19:56:15 +0000 (UTC)
Date: Thu, 25 Feb 2016 19:56:13 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160225195613.GZ2854@techsingularity.net>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
 <20160225190144.GE1180@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160225190144.GE1180@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 25, 2016 at 08:01:44PM +0100, Andrea Arcangeli wrote:
> On Thu, Feb 25, 2016 at 05:12:19PM +0000, Mel Gorman wrote:
> > some cases, this will reduce THP usage but the benefit of THP is hard to
> > measure and not a universal win where as a stall to reclaim/compaction is
> 
> It depends on the workload: with virtual machines THP is essential
> from the start without having to wait half a khugepaged cycle in
> average, especially on large systems.

Which is a specialised case that does not apply to all users. Remember
that the data showed that a basic streaming write of an anon mapping on
a freshly booted NUMA system was enough to stall the process for long
periods of time.

Even in the specialised case, a single VM reaching its peak performance
may rely on getting THP but if that's at the cost of reclaiming other
pages that may be hot to a second VM then it's an overall loss.

Finally, for the specialised case, if it really is that critical then
pages could be freed preemptively from userspace before the VM starts.
For example, allocate and free X hugetlbfs pages before the migration.

Right now, there are numerous tuning guides out there that are suggest
disabling THP entirely due to the stalls. On my own desktop, I occasionally
see a new process halt the system for a few seconds and it was possible
to see that THP allocations were happening at the time.

> We see this effect for example
> in postcopy live migraiton where --postcopy-after-precopy is essential
> to reach peak performance during database workloads in guest,
> immediately after postcopy completes. With --postcopy-after-precopy
> only those pages that may be triggering userfaults will need to be
> collapsed with khugepaged and all the rest that was previously passed
> over with precopy has an high probability to be immediately THP backed
> also thanks to defrag/direct-compaction. Failing at starting
> the destination node largely THP backed is very visible in benchmark
> (even if a full precopy pass is done first). Later on the performance
> increases again as khugepaged fixes things, but it takes some time.
> 

If it's critical that the performance is identical then I would suggest
a pre-migration step of alloc/free of hugetlbfs pages to force the
defragmentation. Alternatively trigger compaction from proc and if
necessary use memhog to allocate/free the required memory followed by a
proc compaction. It's a little less tidy but it solves the corner case
while leaving the common case free of stalls.

> So unless we've a very good kcompatd or a workqueue doing the job of
> providing enough THP for page faults, I'm skeptical of this.

Unfortunately, it'll never be perfect. We went through a cycle of having
really high success rates of allocations in 3.0 days and the cost in
reclaim and disruption was way too high.

> Another problem is that khugepaged isn't able to collapse shared
> readonly anon pages, mostly because of the rmap complexities.  I agree
> with Kirill we should be looking into how make this work, although I
> doubt the simpler refcounting is going to help much in this regard as
> the problem is in dealing with rmap, not so much with refcounts.

I think that's important but I'm not seeing right now how it's related
to preventing processes stalling for long periods of time in direct
reclaim and compaction.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
