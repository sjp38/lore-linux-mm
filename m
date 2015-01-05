Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 709C86B0071
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 12:18:11 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id z11so17941371lbi.38
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 09:18:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wo6si50802649wjc.129.2015.01.05.09.18.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 09:18:02 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V4 0/4] Reducing parameters of alloc_pages* family of functions
Date: Mon,  5 Jan 2015 18:17:39 +0100
Message-Id: <1420478263-25207-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Changes since v3:
o Moved struct alloc_context definition to mm/internal.h
o Rebased on latest -next and re-measured. Sadly, the code/stack size
  improvements are smaller with the new baseline.

The possibility of replacing the numerous parameters of alloc_pages* functions
with a single structure has been discussed when Minchan proposed to expand the
x86 kernel stack [1]. This series implements the change, along with few more
cleanups/microoptimizations.

The series is based on next-20150105 and I used gcc 4.8.3 20140627 on openSUSE
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

add/remove: 0/1 grow/shrink: 1/3 up/down: 1587/-1941 (-354)
function                                     old     new   delta
__alloc_pages_nodemask                       589    2176   +1587
nr_free_zone_pages                           129     115     -14
__alloc_pages_direct_compact                 329     256     -73
get_page_from_freelist                      2670    2576     -94
__alloc_pages_slowpath                      1760       -   -1760
try_to_compact_pages                         582     579      -3

Overal bloat-o-meter with forced inline in baseline, for fair comparison:

add/remove: 0/0 grow/shrink: 0/4 up/down: 0/-512 (-512)
function                                     old     new   delta
nr_free_zone_pages                           129     115     -14
__alloc_pages_direct_compact                 329     256     -73
get_page_from_freelist                      2670    2576     -94
__alloc_pages_nodemask                      2507    2176    -331
try_to_compact_pages                         582     579      -3

Overall stack sizes per ./scripts/checkstack.pl:

                          old   new delta
__alloc_pages_slowpath    152     -  -152
get_page_from_freelist:   184   184     0
__alloc_pages_nodemask    120   184   +64
__alloc_pages_direct_c     40    40   -40  
try_to_compact_pages       72    72     0
                                     -128

Again with forced inline on baseline:

                          old   new delta
get_page_from_freelist:   184   184     0
__alloc_pages_nodemask    216   184   -32
__alloc_pages_direct_c     40     -   -40  
try_to_compact_pages       72    72     0
                                      -72

[1] http://marc.info/?l=linux-mm&m=140142462528257&w=2

Vlastimil Babka (4):
  mm: set page->pfmemalloc in prep_new_page()
  mm, page_alloc: reduce number of alloc_pages* functions' parameters
  mm: reduce try_to_compact_pages parameters
  mm: microoptimize zonelist operations

 include/linux/compaction.h |  17 ++--
 include/linux/mmzone.h     |  13 +--
 mm/compaction.c            |  23 ++---
 mm/internal.h              |  14 +++
 mm/mmzone.c                |   4 +-
 mm/page_alloc.c            | 245 +++++++++++++++++++--------------------------
 6 files changed, 144 insertions(+), 172 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
