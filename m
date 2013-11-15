Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3DA6B0038
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 12:48:43 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id rq2so1775529pbb.16
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 09:48:42 -0800 (PST)
Received: from psmtp.com ([74.125.245.127])
        by mx.google.com with SMTP id pk8si2652513pab.10.2013.11.15.09.48.10
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 09:48:10 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/3] mm: hugetlbfs: fix hugetlbfs optimization v2
Date: Fri, 15 Nov 2013 18:47:45 +0100
Message-Id: <1384537668-10283-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

Hi,

1/3 is a bugfix so it should be applied more urgently. 1/3 is not as
fast as the current upstream code in the hugetlbfs + directio extreme
8GB/sec benchmark (but 3/3 should fill the gap later). The code is
identical to the one I posted in v1 just rebased on upstream and was
developed in collaboration with Khalid who already tested it.

2/3 and 3/3 had very little testing yet, and they're incremental
optimization. 2/3 is minor and most certainly worth applying later.

3/3 instead complicates things a bit and adds more branches to the THP
fast paths, so it should only be applied if the benchmarks of
hugetlbfs + directio show that it is very worthwhile (that has not
been verified yet). If it's not worthwhile 3/3 should be dropped (and
the gap should be filled in some other way if the gap is not caused by
the _mapcount mangling as I guessed). Ideally this should bring even
more performance than current upstream code, as current upstream code
still increased the _mapcount in gup_fast by mistake, while this
eliminates the locked op on the tail page cacheline in gup_fast too
(which is required for correctness too).

As a side note: the _mapcount refcounting on tail pages is only needed
for THP as it is a fundamental information required for
split_huge_page_refcount to be able to distribute the head refcounts
during the split. And it is done on _mapcount instead of the _count,
because the _count would screwup badly with the get_page_unless_zero
speculative pagecache accesses.

Andrea Arcangeli (3):
  mm: hugetlbfs: fix hugetlbfs optimization
  mm: hugetlb: use get_page_foll in follow_hugetlb_page
  mm: tail page refcounting optimization for slab and hugetlbfs

 include/linux/mm.h |  30 ++++++++-
 mm/hugetlb.c       |  19 +++++-
 mm/internal.h      |   3 +-
 mm/swap.c          | 187 ++++++++++++++++++++++++++++++++++-------------------
 4 files changed, 170 insertions(+), 69 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
