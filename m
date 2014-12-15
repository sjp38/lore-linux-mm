Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E00316B0038
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 02:46:16 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so11383635pad.29
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 23:46:16 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id hb2si12837936pac.58.2014.12.14.23.46.13
        for <linux-mm@kvack.org>;
        Sun, 14 Dec 2014 23:46:15 -0800 (PST)
Date: Mon, 15 Dec 2014 16:50:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 0/3] page stealing tweaks
Message-ID: <20141215075017.GB4898@js1304-P5Q-DELUXE>
References: <1418400085-3622-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1418400085-3622-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Fri, Dec 12, 2014 at 05:01:22PM +0100, Vlastimil Babka wrote:
> Changes since v1:
> o Reorder patch 2 and 3, Cc stable for patch 1
> o Fix tracepoint in patch 1 (Joonsoo Kim)
> o Cleanup in patch 2 (suggested by Minchan Kim)
> o Improved comments and changelogs per Minchan and Mel.
> o Considered /proc/pagetypeinfo in evaluation with 3.18 as baseline
> 
> When studying page stealing, I noticed some weird looking decisions in
> try_to_steal_freepages(). The first I assume is a bug (Patch 1), the following
> two patches were driven by evaluation.
> 
> Testing was done with stress-highalloc of mmtests, using the
> mm_page_alloc_extfrag tracepoint and postprocessing to get counts of how often
> page stealing occurs for individual migratetypes, and what migratetypes are
> used for fallbacks. Arguably, the worst case of page stealing is when
> UNMOVABLE allocation steals from MOVABLE pageblock. RECLAIMABLE allocation
> stealing from MOVABLE allocation is also not ideal, so the goal is to minimize
> these two cases.
> 
> For some reason, the first patch increased the number of page stealing events
> for MOVABLE allocations in the former evaluation with 3.17-rc7 + compaction
> patches. In theory these events are not as bad, and the second patch does more
> than just to correct this. In v2 evaluation based on 3.18, the weird result
> was gone completely.
> 
> In v2 I also checked if /proc/pagetypeinfo has shown an increase of the number
> of unmovable/reclaimable pageblocks during and after the test, and it didn't.
> The test was repeated 25 times with reboot only after each 5 to show
> longer-term differences in the state of the system, which also wasn't the case.
> 
> Extfrag events summed over first iteration after reboot (5 repeats)
>                                                         3.18            3.18            3.18            3.18
>                                                    0-nothp-1       1-nothp-1       2-nothp-1       3-nothp-1
> Page alloc extfrag event                                4547160     4593415     2343438     2198189
> Extfrag fragmenting                                     4546361     4592610     2342595     2196611
> Extfrag fragmenting for unmovable                          5725        9196        5720        1093
> Extfrag fragmenting unmovable placed with movable          3877        4091        1330         859
> Extfrag fragmenting for reclaimable                         770         628         511         616
> Extfrag fragmenting reclaimable placed with movable         679         520         407         492
> Extfrag fragmenting for movable                         4539866     4582786     2336364     2194902
> 
> Compared to v1 this looks like a regression for patch 1 wrt unmovable events,
> but I blame noise and less repeats (it was 10 in v1). On the other hand, the
> the mysterious increase in movable allocation events in v1 is gone (due to
> different baseline?)

Hmm... the result on patch 2 looks odd.
Because you reorder patches, patch 2 have some effects on unmovable
stealing and I expect that 'Extfrag fragmenting for unmovable' decreases.
But, the result looks not. Is there any reason you think?

And, could you share compaction success rate and allocation success
rate on each iteration? In fact, reducing Extfrag event isn't our goal.
It is natural result of this patchset because we steal pages more
aggressively. Our utimate goal is to make the system less fragmented
and to get more high order freepage, so I'd like to know this results.

Thanks.

> 
> Sum for second iterations since reboot:
>                                                          3.18            3.18            3.18            3.18
>                                                     0-nothp-2       1-nothp-2       2-nothp-2       3-nothp-2
> Page alloc extfrag event                                1960806     1682705      868136      602097
> Extfrag fragmenting                                     1960268     1682153      867624      601608
> Extfrag fragmenting for unmovable                         14373       13973       12275        2158
> Extfrag fragmenting unmovable placed with movable         10465        7233        8814        1821
> Extfrag fragmenting for reclaimable                        2268        1244        1122        1284
> Extfrag fragmenting reclaimable placed with movable        2092        1010         940        1033
> Extfrag fragmenting for movable                         1943627     1666936      854227      598166
> 
> Running stress-highalloc again without reboot is indeed different, and worse
> wrt unmovable allocations (also worse wrt high-order allocation success rates)
> but the patches improve it as well. Similar trend can be observed for further
> iterations after reboot.
> 
> 
> 
> 
> 
> 
> 
> Vlastimil Babka (3):
>   mm: when stealing freepages, also take pages created by splitting
>     buddy page
>   mm: always steal split buddies in fallback allocations
>   mm: more aggressive page stealing for UNMOVABLE allocations
> 
>  include/trace/events/kmem.h |  7 ++--
>  mm/page_alloc.c             | 78 ++++++++++++++++++++++++---------------------
>  2 files changed, 45 insertions(+), 40 deletions(-)
> 
> -- 
> 2.1.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
