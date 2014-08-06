Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9592A6B0098
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 09:56:17 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id t60so2714830wes.34
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 06:56:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u2si1849610wjz.117.2014.08.06.06.56.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 06:56:14 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 0/4] Reducing parameters of alloc_pages* family of functions
Date: Wed,  6 Aug 2014 15:55:52 +0200
Message-Id: <1407333356-30928-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

Hey all,

I wanted a short break from compaction so I thought I would try something
that has been discussed when Minchan proposed to expand the x86 kernel
stack [1], namely the reduction of huge number of parameters that the
alloc_pages* family and get_page_from_freelist() functions have.

The result so far is this series, note that it's only build-tested and
considered RFC and not signed-off. Except Patch 1 which is trivial and I
didn't feel like sending that separately. I want some feedback if this is
worth finishing, and possibly testing with different configs/arches/gcc
versions. I also welcome feedback and suggestions on the evaluation
methodology as this probably doesn't tell the whole picture.
The series is based on next-20140806 and I use gcc 4.8.1 20130909 on
openSUSE 13.1. Config includes NUMA, COMPACTION, CMA, DEBUG_VM (but not
DEBUG_PAGEALLOC), I can post whole if anyone wants.

So, I created a struct alloc_info (maybe alloc_context would be better a name
in case this works out) and initially put everything there:

struct alloc_info {
       struct zonelist *zonelist;
       nodemask_t *nodemask;
       struct zone *preferred_zone;

       unsigned int order;
       gfp_t gfp_mask;
       int alloc_flags;
       int classzone_idx;
       int migratetype;
       enum zone_type high_zoneidx;
};

Mostly the stuff is constant, except alloc_flags and gfp_mask which I have to
save and restore in some cases. __alloc_pages_slowpath() will also change
preferred_zone and classzone_idx but that's not a problem as in case control
returns to retry_cpuset: in __alloc_pages_nodemask(), those will be reset to
initial values again (although it's subtle). Hmm I just realized it may also
change zonelist, so this is a known bug that would be easily fixed. But I
expected it to be worse.

The result is Patch 2, which does decrease __alloc_pages_nodemask stack
(details below) from 248 to 200, and code from 2691 to 2507 bytes. This being
a function that inlines all the family except __alloc_pages_direct_compact
(which is called at two places) and get_page_from_freelist() which has many
callsites. Unfortunately, get_page_from_freelist's stack is bloated by 24b,
which is not so bad as it AFAIK doesn't call anything heavy during its work.
But its code size went from 2842 to 3022 bytes, which probably sucks for the
fast path case.

The next thing I tried is to again separate the most volatile and used
parameters from alloc_info, in hope that passing them in registers and not
having to save/restore them will help. That's Patch 3 for alloc_flags and
Patch 4 for gfp_mask. Both were clear wins wrt code size and although Patch 3
increased stack by 8b, Patch 4 recovered that.

Interestingly, after Patch 4, gcc decided to stop inlining
__alloc_pages_slowpath() which didn't happen with previous tests that had
CONFIG_CMA disabled. For comparison I repeated the compilation with
__alloc_pages_slowpath() force inlined. This shows that the not-inlining by
itself saved 8b stack and 130b code. So removing the inline might be a change
to consider by itself, as it could make the fast path less heavy.

Unfortunately, even with Patch 4, get_page_from_freelist() stack remained
at +24b and code at +148b. Seems like it benefits from having as many arguments
in registers as possible.

[1] http://marc.info/?l=linux-mm&m=140142462528257&w=2

Stack sizes as determined by ./scripts/checkstack.pl:
('Patch 4i' is with forced inline of __alloc_pages_slowpath)

                        next-20140806   Patch 1   Patch 2   Patch 3   Patch 4   Patch 4i
get_page_from_freelist            160       160       184       184	  184        184
__alloc_pages_nodemask            248       248	      200       208        80        200
__alloc_pages_direct_compact       40        40	       16        16        16         16
__alloc_pages_slowpath              -         -         -         -       112          -


Results of ./scripts/bloat-o-meter with next-20140806 as 'old':

Patch 1:

add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-12 (-12)
function                                     old     new   delta
__alloc_pages_nodemask                      2691    2679     -12

Patch 2:

add/remove: 0/0 grow/shrink: 1/2 up/down: 180/-192 (-12)
function                                     old     new   delta
get_page_from_freelist                      2842    3022    +180
__alloc_pages_direct_compact                 409     401      -8
__alloc_pages_nodemask                      2691    2507    -184

Patch 3:

add/remove: 0/0 grow/shrink: 1/2 up/down: 180/-307 (-127)
function                                     old     new   delta
get_page_from_freelist                      2842    3022    +180
__alloc_pages_direct_compact                 409     379     -30
__alloc_pages_nodemask                      2691    2414    -277

Patch 4:

add/remove: 1/0 grow/shrink: 1/2 up/down: 1838/-2199 (-361)
function                                     old     new   delta
__alloc_pages_slowpath                         -    1690   +1690
get_page_from_freelist                      2842    2990    +148
__alloc_pages_direct_compact                 409     374     -35
__alloc_pages_nodemask                      2691     527   -2164

Patch 4 (forced inline for _slowpath):

add/remove: 0/0 grow/shrink: 1/2 up/down: 148/-387 (-239)
function                                     old     new   delta
get_page_from_freelist                      2842    2990    +148
__alloc_pages_direct_compact                 409     374     -35
__alloc_pages_nodemask                      2691    2339    -352

Vlastimil Babka (4):
  mm: page_alloc: determine migratetype only once
  mm, page_alloc: reduce number of alloc_pages* functions' parameters
  mm, page_alloc: make alloc_flags a separate parameter again
  mm, page_alloc: make gfp_mask a separate parameter again

 mm/page_alloc.c | 215 +++++++++++++++++++++++++-------------------------------
 1 file changed, 97 insertions(+), 118 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
