Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 512A06B0268
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 14:40:00 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 70so10404654pgf.5
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 11:40:00 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d127si8917677pgc.372.2017.11.20.11.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 11:39:59 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/1] mm/cma: fix alloc_contig_range ret code/potential leak
Date: Mon, 20 Nov 2017 11:39:29 -0800
Message-Id: <20171120193930.23428-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

In an attempt to make contiguous allocation routines more available to
drivers, I have been experimenting with code similar to that used by
alloc_gigantic_page().  While stressing this code with many other
allocations and frees in progress, I would sometimes notice large 'leaks'
of page ranges.

I traced this down to the routine alloc_contig_range() itself.  In commit
8ef5849fa8a2 the code was changed so that an -EBUSY returned by
__alloc_contig_migrate_range() would not immediately return to the caller.
Rather, processing continues so that test_pages_isolated() is eventually
called.  This is done because test_pages_isolated() has a tracepoint to
identify the busy pages.

However, it is possible (observed in my testing) that pages which were
busy when __alloc_contig_migrate_range was called may become available
by the time test_pages_isolated is called.  Further, it is possible that
the entire range can actually be allocated.  Unfortunately, in this case
the return code originally set by __alloc_contig_migrate_range (-EBUSY)
is returned to the calller.  Therefore, the caller assumes the range was
not allocated and the pages are essentially leaked.

The following patch simply updates the return code based on the value
returned from test_pages_isolated.

It is unlikely that we will hit this issue today based on the limited
number of callers to alloc_contig_range.  However, I have Cc'ed stable
because if we do hit this issue it has the potential to leak a large
number of pages.

Mike Kravetz (1):
  mm/cma: fix alloc_contig_range ret code/potential leak

 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
