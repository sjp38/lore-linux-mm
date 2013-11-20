Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id F39E26B0039
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:51:38 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id n15so2681670ead.8
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:51:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s8si18108416eeh.257.2013.11.20.09.51.37
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:51:37 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/8] mm: hugetlbfs: fix hugetlbfs optimization v3
Date: Wed, 20 Nov 2013 18:51:08 +0100
Message-Id: <1384969876-6374-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

Changes since v2:

1) optimize away a few more locked ops in the get_page/put_page
   hugetlbfs and slab paths (see 3/8 and 4/8).

   3/8 is the least trivial addition to the series as we now are
   running PageSlab and PageHeadHuge on random page structure without
   holding any reference count on this. A smp_rmb() if any of the two
   checks succeeds is what is supposed to make it safe doing so and
   it's lighter weight than get_page_unless_zero (hence the supposed
   optimization out of it). 3/8 makes no difference whatsoever to the
   speed of the THP case. It's unclear if 3/8 is worth it but it seems
   every bit is affecting performance for directio over hugetlbfs with
   >8GB/sec storage devices so I thought of trying it. 4/8 is quite
   self explanatory and it removes some smp_rmb which is not needed
   with the current layout of the struct page.

2) two nice cleanups from Andrew

3) Removed the PageHeadHuge export as it's not needed right now

Andrea Arcangeli (6):
  mm: hugetlbfs: fix hugetlbfs optimization
  mm: hugetlb: use get_page_foll in follow_hugetlb_page
  mm: hugetlbfs: move the put/get_page slab and hugetlbfs optimization
    in a faster path
  mm: thp: optimize compound_trans_huge
  mm: tail page refcounting optimization for slab and hugetlbfs
  mm/hugetlb.c: defer PageHeadHuge() symbol export

Andrew Morton (2):
  mm/hugetlb.c: simplify PageHeadHuge() and PageHuge()
  mm/swap.c: reorganize put_compound_page()

 include/linux/huge_mm.h |  23 ++++
 include/linux/mm.h      |  32 +++++-
 mm/hugetlb.c            |  20 +++-
 mm/internal.h           |   3 +-
 mm/swap.c               | 284 +++++++++++++++++++++++++++++-------------------
 5 files changed, 240 insertions(+), 122 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
