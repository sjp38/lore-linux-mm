Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 854DB6B0074
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 09:15:37 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id x48so607389wes.10
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 06:15:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ev4si2128243wib.66.2014.02.28.06.15.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 06:15:34 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 6/6] mm: use atomic bit operations in set_pageblock_flags_group()
Date: Fri, 28 Feb 2014 15:15:04 +0100
Message-Id: <1393596904-16537-7-git-send-email-vbabka@suse.cz>
In-Reply-To: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
References: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

set_pageblock_flags_group() is used to set either migratetype or skip bit of a
pageblock. Setting migratetype is done under zone->lock (except from __init
code), however changing the skip bits is not protected and the pageblock flags
bitmap packs migratetype and skip bits together and uses non-atomic bit ops.
Therefore, races between setting migratetype and skip bit are possible and the
non-atomic read-modify-update of the skip bit may cause lost updates to
migratetype bits, resulting in invalid migratetype values, which are in turn
used to e.g. index free_list array.

The race has been observed to happen and cause panics, albeit during
development of series that increases frequency of migratetype changes through
{start,undo}_isolate_page_range() calls.

Two possible solutions were investigated: 1) using zone->lock for changing
pageblock_skip bit and 2) changing the bitmap operations to be atomic. The
problem of 1) is that zone->lock is already contended and almost never held in
the compaction code that updates pageblock_skip bits. Solution 2) should scale
better, but adds atomic operations also to migratype changes which are already
protected by zone->lock.

Using mmtests' stress-highalloc benchmark, little difference was found between
the two solutions. The base is 3.13 with recent compaction series by myself and
Joonsoo Kim applied.

                3.13        3.13        3.13
                base     2)atomic     1)lock
User         6103.92     6072.09     6178.79
System       1039.68     1033.96     1042.92
Elapsed      2114.27     2090.20     2110.23

For 1) stats show how many times the compaction code had to lock zone->lock
during the benchmark, or failed due to contention.

update_pageblock_skip stats:

mig scanner already locked        0
mig scanner had to lock           172985
mig scanner skip bit already set  1
mig scanner failed to lock        43
free scanner already locked       42
free scanner had to lock          499631
free scanner skip bit already set 87
free scanner failed to lock       79

For 2) Profiling found no measurable increase of time spent in the pageblock
update operations.

Therefore, solution 2) was selected as implemented by this patch. To minimize
dirty cachelines and amount of atomic ops, the bitmap bits are only changed
when needed. For migratetype, this is not racy thanks to zone->lock protection.
For pageblock_skip bits, this raciness is not an issue as the bits
are just a heuristic for memory compaction.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fd6a64c..050bf5e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6085,11 +6085,15 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
 	bitidx = pfn_to_bitidx(zone, pfn);
 	VM_BUG_ON_PAGE(!zone_spans_pfn(zone, pfn), page);
 
-	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
-		if (flags & value)
-			__set_bit(bitidx + start_bitidx, bitmap);
-		else
-			__clear_bit(bitidx + start_bitidx, bitmap);
+	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1) {
+		int oldbit = test_bit(bitidx + start_bitidx, bitmap);
+		unsigned long newbit = flags & value;
+
+		if (!oldbit && newbit)
+			set_bit(bitidx + start_bitidx, bitmap);
+		else if (oldbit && !newbit)
+			clear_bit(bitidx + start_bitidx, bitmap);
+	}
 }
 
 /*
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
