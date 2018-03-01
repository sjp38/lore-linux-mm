Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2406B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 06:42:08 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id j3so5592091itf.6
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 03:42:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p82sor2243531ioo.88.2018.03.01.03.42.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 03:42:06 -0800 (PST)
Date: Thu, 1 Mar 2018 03:42:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, compaction: drain pcps for zone when kcompactd fails
Message-ID: <alpine.DEB.2.20.1803010340100.88270@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

It's possible for buddy pages to become stranded on pcps that, if drained,
could be merged with other buddy pages on the zone's free area to form
large order pages, including up to MAX_ORDER.

Consider a verbose example using the tools/vm/page-types tool at the
beginning of a ZONE_NORMAL, where 'B' indicates a buddy page and 'S'
indicates a slab page, which the migration scanner is attempting to
defragment (and doing it well, absent coalescing up to cc.order):

109954  1       _______S________________________________________________________
109955  2       __________B_____________________________________________________
109957  1       ________________________________________________________________
109958  1       __________B_____________________________________________________
109959  7       ________________________________________________________________
109960  1       __________B_____________________________________________________
109961  9       ________________________________________________________________
10996a  1       __________B_____________________________________________________
10996b  3       ________________________________________________________________
10996e  1       __________B_____________________________________________________
10996f  1       ________________________________________________________________
109970  1       __________B_____________________________________________________
109971  f       ________________________________________________________________
...
109f88  1       __________B_____________________________________________________
109f89  3       ________________________________________________________________
109f8c  1       __________B_____________________________________________________
109f8d  2       ________________________________________________________________
109f8f  2       __________B_____________________________________________________
109f91  f       ________________________________________________________________
109fa0  1       __________B_____________________________________________________
109fa1  7       ________________________________________________________________
109fa8  1       __________B_____________________________________________________
109fa9  1       ________________________________________________________________
109faa  1       __________B_____________________________________________________
109fab  1       _______S________________________________________________________

These buddy pages, spanning 1,621 pages, could be coalesced and allow for
three transparent hugepages to be dynamically allocated.  Totaling all
hugepage length spans that could be coalesced, this could yield over 400
hugepages on the zone's free area when at the time this /proc/kpageflags
was collected, there was _no_ order-9 or order-10 pages available for
allocation even after triggering compaction through procfs.

When kcompactd fails to defragment memory such that a cc.order page can
be allocated, drain all pcps for the zone back to the buddy allocator so
this stranding cannot occur.  Compaction for that order will subsequently
be deferred, which acts as a ratelimit on this drain.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1987,6 +1987,14 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		if (status == COMPACT_SUCCESS) {
 			compaction_defer_reset(zone, cc.order, false);
 		} else if (status == COMPACT_PARTIAL_SKIPPED || status == COMPACT_COMPLETE) {
+			/*
+			 * Buddy pages may become stranded on pcps that could
+			 * otherwise coalesce on the zone's free area for
+			 * order >= cc.order.  This is ratelimited by the
+			 * upcoming deferral.
+			 */
+			drain_all_pages(zone);
+
 			/*
 			 * We use sync migration mode here, so we defer like
 			 * sync direct compaction does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
