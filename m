Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id AF2046B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:01:49 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id b35so47480771qge.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:01:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f89si9285882qga.111.2016.02.25.11.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 11:01:49 -0800 (PST)
Date: Thu, 25 Feb 2016 20:01:44 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160225190144.GE1180@redhat.com>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 25, 2016 at 05:12:19PM +0000, Mel Gorman wrote:
> some cases, this will reduce THP usage but the benefit of THP is hard to
> measure and not a universal win where as a stall to reclaim/compaction is

It depends on the workload: with virtual machines THP is essential
from the start without having to wait half a khugepaged cycle in
average, especially on large systems. We see this effect for example
in postcopy live migraiton where --postcopy-after-precopy is essential
to reach peak performance during database workloads in guest,
immediately after postcopy completes. With --postcopy-after-precopy
only those pages that may be triggering userfaults will need to be
collapsed with khugepaged and all the rest that was previously passed
over with precopy has an high probability to be immediately THP backed
also thanks to defrag/direct-compaction. Failing at starting
the destination node largely THP backed is very visible in benchmark
(even if a full precopy pass is done first). Later on the performance
increases again as khugepaged fixes things, but it takes some time.

So unless we've a very good kcompatd or a workqueue doing the job of
providing enough THP for page faults, I'm skeptical of this. If
something I'd rather set defrag to "madvise" as qemu and other loads
that critically need THP or they run literally half as slow (for
example with enterprise workloads in the guest) will still be able not
to rely solely on khugepaged which can takes some time to act. So your
benchmark would run the same but the VM could still start fully THP
backed.

Another problem is that khugepaged isn't able to collapse shared
readonly anon pages, mostly because of the rmap complexities.  I agree
with Kirill we should be looking into how make this work, although I
doubt the simpler refcounting is going to help much in this regard as
the problem is in dealing with rmap, not so much with refcounts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
