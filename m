Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3A53F6B009C
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 11:13:43 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id a1so9583248wgh.9
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 08:13:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bc9si3088447wjb.90.2014.12.12.08.13.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Dec 2014 08:13:42 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V3 0/4] Reducing parameters of alloc_pages* family of functions
Date: Fri, 12 Dec 2014 17:13:21 +0100
Message-Id: <1418400805-4661-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Hey all,

this is a V3 of attempting something that has been discussed when Minchan
proposed to expand the x86 kernel stack [1], namely the reduction of huge
number of parameters that the alloc_pages* family and get_page_from_freelist()
functions have.

The result is this series, ordered in the subjective importance of the patches.

The series is based on mmotm-2014-12-02-15-55 and I use gcc 4.8.3 20140627 on
openSUSE 13.2. Config includess NUMA and COMPACTION. It also applies to
next-20141212.

Changes since v2:
o Per Linus's suggestion, removed order from alloc_context due to poor
  conceptual fit. Interestingly, this improved the stack/code size a bit.
o Attempted to merge migratetype into alloc_flags, but it was ugly and made
  things only worse. So I didn't even attempt to merge order there.

The core is a new struct alloc_context, which looks like this:

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

First, let's look at the code size savings by bloat-o-meter, as the patches
stack up:

Patch 1 (vs mmotm):

function                                     old     new   delta
get_page_from_freelist                      2554    2490     -64

Patch 2:

function                                     old     new   delta
__alloc_pages_nodemask                       571    2220   +1649
get_page_from_freelist                      2490    2560     +70
__alloc_pages_direct_compact                 332     302     -30
__alloc_pages_slowpath                      1878       -   -1878

Here gcc decided to inline _slowpath, so let's try comparing with Patch 1
plus forced inline of _slowpath:

add/remove: 0/0 grow/shrink: 1/2 up/down: 70/-428 (-358)
function                                     old     new   delta
get_page_from_freelist                      2490    2560     +70
__alloc_pages_direct_compact                 332     284     -48
__alloc_pages_nodemask                      2618    2194    -424

Looks like get_page_from_freelist() did benefit from getting the parameters
separately, but overal it's a win.

Patch 3:

__alloc_pages_direct_compact                 284     256     -28
try_to_compact_pages                         582     566     -16

A tiny overal win.

Patch 4:

function                                     old     new   delta
__alloc_pages_nodemask                      2194    2191      -3
nr_free_zone_pages                           129     115     -14
get_page_from_freelist                      2560    2505     -55
try_to_compact_pages                         566     579     +13

Small overal win. A few more object files should be also affected,
but were not tested.

Now stack sizes per ./scripts/checkstack.pl:

                        mmotm    P1   P2
__alloc_pages_slowpath    176   176    -
get_page_from_freelist:   160   152  160
__alloc_pages_nodemask    104   104  168 
__alloc_pages_direct_c     32    32   16

Patch 1 saves a bit, Patch 2 result muddled by inlining.
Again, let's use Patch 1 + forced inline as baseline for the rest:

                          P1i    P2    P3    P4
__alloc_pages_nodemask    240   168   168   168
get_page_from_freelist:   152   160   160   160
try_to_compact_pages       64    64    56    56
__alloc_pages_direct_c     32    16     -     -

Again, Patch 2 bloats get_page_from_freelist(), but overal is a win. The
rest almost doesn't affect stack usage.

[1] http://marc.info/?l=linux-mm&m=140142462528257&w=2

Vlastimil Babka (4):
  mm: set page->pfmemalloc in prep_new_page()
  mm, page_alloc: reduce number of alloc_pages* functions' parameters
  mm: reduce try_to_compact_pages parameters
  mm: microoptimize zonelist operations

 include/linux/compaction.h |  15 ++-
 include/linux/mm.h         |  14 +++
 include/linux/mmzone.h     |  13 +--
 mm/compaction.c            |  23 ++---
 mm/mmzone.c                |   4 +-
 mm/page_alloc.c            | 250 +++++++++++++++++++--------------------------
 6 files changed, 144 insertions(+), 175 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
