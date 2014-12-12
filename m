Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4382D6B0098
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 11:01:49 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so2976673wiw.1
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 08:01:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si3323879wic.38.2014.12.12.08.01.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Dec 2014 08:01:41 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 0/3] page stealing tweaks
Date: Fri, 12 Dec 2014 17:01:22 +0100
Message-Id: <1418400085-3622-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Changes since v1:
o Reorder patch 2 and 3, Cc stable for patch 1
o Fix tracepoint in patch 1 (Joonsoo Kim)
o Cleanup in patch 2 (suggested by Minchan Kim)
o Improved comments and changelogs per Minchan and Mel.
o Considered /proc/pagetypeinfo in evaluation with 3.18 as baseline

When studying page stealing, I noticed some weird looking decisions in
try_to_steal_freepages(). The first I assume is a bug (Patch 1), the following
two patches were driven by evaluation.

Testing was done with stress-highalloc of mmtests, using the
mm_page_alloc_extfrag tracepoint and postprocessing to get counts of how often
page stealing occurs for individual migratetypes, and what migratetypes are
used for fallbacks. Arguably, the worst case of page stealing is when
UNMOVABLE allocation steals from MOVABLE pageblock. RECLAIMABLE allocation
stealing from MOVABLE allocation is also not ideal, so the goal is to minimize
these two cases.

For some reason, the first patch increased the number of page stealing events
for MOVABLE allocations in the former evaluation with 3.17-rc7 + compaction
patches. In theory these events are not as bad, and the second patch does more
than just to correct this. In v2 evaluation based on 3.18, the weird result
was gone completely.

In v2 I also checked if /proc/pagetypeinfo has shown an increase of the number
of unmovable/reclaimable pageblocks during and after the test, and it didn't.
The test was repeated 25 times with reboot only after each 5 to show
longer-term differences in the state of the system, which also wasn't the case.

Extfrag events summed over first iteration after reboot (5 repeats)
                                                        3.18            3.18            3.18            3.18
                                                   0-nothp-1       1-nothp-1       2-nothp-1       3-nothp-1
Page alloc extfrag event                                4547160     4593415     2343438     2198189
Extfrag fragmenting                                     4546361     4592610     2342595     2196611
Extfrag fragmenting for unmovable                          5725        9196        5720        1093
Extfrag fragmenting unmovable placed with movable          3877        4091        1330         859
Extfrag fragmenting for reclaimable                         770         628         511         616
Extfrag fragmenting reclaimable placed with movable         679         520         407         492
Extfrag fragmenting for movable                         4539866     4582786     2336364     2194902

Compared to v1 this looks like a regression for patch 1 wrt unmovable events,
but I blame noise and less repeats (it was 10 in v1). On the other hand, the
the mysterious increase in movable allocation events in v1 is gone (due to
different baseline?)

Sum for second iterations since reboot:
                                                         3.18            3.18            3.18            3.18
                                                    0-nothp-2       1-nothp-2       2-nothp-2       3-nothp-2
Page alloc extfrag event                                1960806     1682705      868136      602097
Extfrag fragmenting                                     1960268     1682153      867624      601608
Extfrag fragmenting for unmovable                         14373       13973       12275        2158
Extfrag fragmenting unmovable placed with movable         10465        7233        8814        1821
Extfrag fragmenting for reclaimable                        2268        1244        1122        1284
Extfrag fragmenting reclaimable placed with movable        2092        1010         940        1033
Extfrag fragmenting for movable                         1943627     1666936      854227      598166

Running stress-highalloc again without reboot is indeed different, and worse
wrt unmovable allocations (also worse wrt high-order allocation success rates)
but the patches improve it as well. Similar trend can be observed for further
iterations after reboot.







Vlastimil Babka (3):
  mm: when stealing freepages, also take pages created by splitting
    buddy page
  mm: always steal split buddies in fallback allocations
  mm: more aggressive page stealing for UNMOVABLE allocations

 include/trace/events/kmem.h |  7 ++--
 mm/page_alloc.c             | 78 ++++++++++++++++++++++++---------------------
 2 files changed, 45 insertions(+), 40 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
