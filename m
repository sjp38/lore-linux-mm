Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C592D6B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 03:50:41 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kx10so2837950pab.23
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 00:50:41 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id sp2si21577230pac.210.2014.09.29.00.50.39
        for <linux-mm@kvack.org>;
        Mon, 29 Sep 2014 00:50:40 -0700 (PDT)
Date: Mon, 29 Sep 2014 16:50:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 05/13] mm, compaction: move pageblock checks up from
 isolate_migratepages_range()
Message-ID: <20140929075038.GC29310@js1304-P5Q-DELUXE>
References: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
 <1407142524-2025-6-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1407142524-2025-6-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Aug 04, 2014 at 10:55:16AM +0200, Vlastimil Babka wrote:
> isolate_migratepages_range() is the main function of the compaction scanner,
> called either on a single pageblock by isolate_migratepages() during regular
> compaction, or on an arbitrary range by CMA's __alloc_contig_migrate_range().
> It currently perfoms two pageblock-wide compaction suitability checks, and
> because of the CMA callpath, it tracks if it crossed a pageblock boundary in
> order to repeat those checks.
> 
> However, closer inspection shows that those checks are always true for CMA:
> - isolation_suitable() is true because CMA sets cc->ignore_skip_hint to true
> - migrate_async_suitable() check is skipped because CMA uses sync compaction
> 
> We can therefore move the compaction-specific checks to isolate_migratepages()
> and simplify isolate_migratepages_range(). Furthermore, we can mimic the
> freepage scanner family of functions, which has isolate_freepages_block()
> function called both by compaction from isolate_freepages() and by CMA from
> isolate_freepages_range(), where each use-case adds own specific glue code.
> This allows further code simplification.
> 
> Thus, we rename isolate_migratepages_range() to isolate_migratepages_block()
> and limit its functionality to a single pageblock (or its subset). For CMA,
> a new different isolate_migratepages_range() is created as a CMA-specific
> wrapper for the _block() function. The checks specific to compaction are moved
> to isolate_migratepages(). As part of the unification of these two families of
> functions, we remove the redundant zone parameter where applicable, since zone
> pointer is already passed in cc->zone.
> 
> Furthermore, going back to compact_zone() and compact_finished() when pageblock
> is found unsuitable (now by isolate_migratepages()) is wasteful - the checks
> are meant to skip pageblocks quickly. The patch therefore also introduces a
> simple loop into isolate_migratepages() so that it does not return immediately
> on failed pageblock checks, but keeps going until isolate_migratepages_range()
> gets called once. Similarily to isolate_freepages(), the function periodically
> checks if it needs to reschedule or abort async compaction.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  mm/compaction.c | 235 +++++++++++++++++++++++++++++++++-----------------------
>  mm/internal.h   |   4 +-
>  mm/page_alloc.c |   3 +-
>  3 files changed, 141 insertions(+), 101 deletions(-)
> 

Hello,

This patch needs one fix.
Please see below.

Thanks.

---------->8-------------
