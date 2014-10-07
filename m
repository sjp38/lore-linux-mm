Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 475B76B0071
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 11:34:01 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id m15so9780487wgh.16
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 08:34:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hl16si13881519wib.5.2014.10.07.08.34.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 08:34:00 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/5] Further compaction tuning
Date: Tue,  7 Oct 2014 17:33:34 +0200
Message-Id: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>

Based on next-20141007. Patch 5 needs "mm: introduce single zone pcplists
drain" from https://lkml.org/lkml/2014/10/2/375

OK, time to reset the "days without a compaction series" counter back to 0.
This series is mostly what was postponed in the previous one (but sadly not
all of it), along with some smaller changes.

Patch 1 tries to solve the mismatch in watermark checking by compaction and
allocations by adding the missing pieces to compact_control. This mainly
allows simplifying deferred allocation handling by Patch 2. Change in Patch 2
was suggested by Joonsoo reviewing the previous series, but was not possible
without Patch 1. Patch 3 is a rather cosmetic change to deferred compaction.

Patch 4 removes probably the last occurence of compaction scanners rescanning
some pages when being restarted in the middle of the zone.

Patch 5 is a posthumous child of patch "mm, compaction: try to capture the
just-created high-order freepage" which was removed from the previous series.
Thanks to Joonsoo's objections we could find out that the improvements of the
capture patch was mainly due to better lru_add cache and pcplists draining.
The remaining delta wrt success rates between this patch and page capture was
due to different (questionable) watermark checking in the capture mechanism.
So this patch brings most of the improvements without the questionable parts
and complexity that capture had.

Vlastimil Babka (5):
  mm, compaction: pass classzone_idx and alloc_flags to watermark
    checking
  mm, compaction: simplify deferred compaction
  mm, compaction: defer only on COMPACT_COMPLETE
  mm, compaction: always update cached scanner positions
  mm, compaction: more focused lru and pcplists draining

 include/linux/compaction.h | 10 +++---
 mm/compaction.c            | 89 +++++++++++++++++++++++++++++-----------------
 mm/internal.h              |  7 ++--
 mm/page_alloc.c            | 15 +-------
 mm/vmscan.c                | 12 +++----
 5 files changed, 71 insertions(+), 62 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
