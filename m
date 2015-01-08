Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id E525D6B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:33:26 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so2300744wid.5
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:33:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si39435709wia.0.2015.01.08.02.33.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 02:33:25 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V5 0/4] Reducing parameters of alloc_pages* family of functions
Date: Thu,  8 Jan 2015 11:33:07 +0100
Message-Id: <1420713191-17509-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Changes since v4:
o Documented where struct alloc_context fields change per Michal's suggestion.
o Rebased on next-20150108. Relative improvements went down for code again,
  but up for stack. And finally I didn't have to mess with _slowpath inlining
  anymore for the comparison as it was already being inlined in the baseline.

Changes since v3:
o Moved struct alloc_context definition to mm/internal.h
o Rebased on latest -next and re-measured. Sadly, the code/stack size
  improvements are smaller with the new baseline.

The possibility of replacing the numerous parameters of alloc_pages* functions
with a single structure has been discussed when Minchan proposed to expand the
x86 kernel stack [1]. This series implements the change, along with few more
cleanups/microoptimizations.

The series is based on next-20150108 and I used gcc 4.8.3 20140627 on openSUSE
13.2 for compiling. Config includess NUMA and COMPACTION.

The core change is the introduction of a new struct alloc_context, which looks
like this:

struct alloc_context {
        struct zonelist *zonelist;
        nodemask_t *nodemask;
        struct zone *preferred_zone;
        int classzone_idx;
        int migratetype;
        enum zone_type high_zoneidx;
};

All the contents is mostly constant, except that __alloc_pages_slowpath()
changes preferred_zone, classzone_idx and potentially zonelist. But that's not
a problem in case control returns to retry_cpuset: in __alloc_pages_nodemask(),
those will be reset to initial values again (although it's a bit subtle).
On the other hand, gfp_flags and alloc_info mutate so much that it doesn't
make sense to put them into alloc_context. Still, the result is one parameter
instead of up to 7. This is all in Patch 2.

Patch 3 is a step to expand alloc_context usage out of page_alloc.c itself.
The function try_to_compact_pages() can also much benefit from the parameter
reduction, but it means the struct definition has to be moved to a shared
header.

Patch 1 should IMHO be included even if the rest is deemed not useful enough.
It improves maintainability and also has some code/stack reduction. Patch 4
is OTOH a tiny optimization.

Overall bloat-o-meter results:

add/remove: 0/0 grow/shrink: 0/4 up/down: 0/-460 (-460)
function                                     old     new   delta
nr_free_zone_pages                           129     115     -14
__alloc_pages_direct_compact                 329     256     -73
get_page_from_freelist                      2670    2576     -94
__alloc_pages_nodemask                      2564    2285    -279
try_to_compact_pages                         582     579      -3

Overall stack sizes per ./scripts/checkstack.pl:

                          old   new delta
get_page_from_freelist:   184   184     0
__alloc_pages_nodemask    248   200   -48
__alloc_pages_direct_c     40     -   -40  
try_to_compact_pages       72    72     0
                                      -88

[1] http://marc.info/?l=linux-mm&m=140142462528257&w=2

Vlastimil Babka (4):
  mm: set page->pfmemalloc in prep_new_page()
  mm, page_alloc: reduce number of alloc_pages* functions' parameters
  mm: reduce try_to_compact_pages parameters
  mm: microoptimize zonelist operations

 include/linux/compaction.h |  17 ++--
 include/linux/mmzone.h     |  13 +--
 mm/compaction.c            |  23 ++---
 mm/internal.h              |  22 ++++
 mm/mmzone.c                |   4 +-
 mm/page_alloc.c            | 245 +++++++++++++++++++--------------------------
 6 files changed, 152 insertions(+), 172 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
