Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D99E68E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:30:09 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so7040297edq.4
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:30:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q19-v6si1846770ejt.57.2018.12.11.06.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 06:30:08 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 2/3] mm, page_alloc: reclaim for __GFP_NORETRY costly requests only when compaction was skipped
Date: Tue, 11 Dec 2018 15:29:40 +0100
Message-Id: <20181211142941.20500-3-vbabka@suse.cz>
In-Reply-To: <20181211142941.20500-1-vbabka@suse.cz>
References: <20181211142941.20500-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

For costly __GFP_NORETRY allocations (including THP's) we first do an initial
compaction attempt and if that fails, we proceed with reclaim and another
round of compaction, unless compaction was deferred due to earlier multiple
failures. Andrea proposed [1] that we count all compaction failures as the
defered case in try_to_compact_pages(), but I don't think that's a good idea
in general. Instead, change the __GFP_NORETRY specific condition so that it
only proceeds with further reclaim/compaction when the initial compaction
attempt was skipped due to lack of free base pages.

Note that the original condition probably never worked properly for THP's,
because compaction can only become deferred after a sync compaction failure,
and THP's only perform async compaction, except khugepaged, which is
infrequent, or madvised faults (until the previous patch restored __GFP_NORETRY
for those) which are not the default case. Deferring due to async compaction
failures should be however also beneficial and thus introduced in the next
patch.

Also note that due to how try_to_compact_pages() constructs its return value
from compaction attempts across the whole zonelist, returning COMPACT_SKIPPED
means that compaction was skipped for *all* attempted zones/nodes, which means
all zones/nodes are low on memory at the same moment. This is probably rare,
which would mean that the resulting 'goto nopage' would be very common, just
because e.g. a single zone had enough memory and compaction failed there, while
the rest of nodes could succeed after reclaim.  However, since THP faults use
__GFP_THISNODE, compaction is also attempted only for a single node, so in
practice there should be no significant loss of information when constructing
the return value, nor bias towards 'goto nopage' for THP faults.

[1] https://lkml.kernel.org/r/20181206005425.GB21159@redhat.com

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>
---
 mm/page_alloc.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc407216..3d83a6093ada 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4129,14 +4129,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 */
 		if (costly_order && (gfp_mask & __GFP_NORETRY)) {
 			/*
-			 * If compaction is deferred for high-order allocations,
-			 * it is because sync compaction recently failed. If
-			 * this is the case and the caller requested a THP
-			 * allocation, we do not want to heavily disrupt the
-			 * system, so we fail the allocation instead of entering
-			 * direct reclaim.
+			 * If compaction was skipped because of insufficient
+			 * free pages, proceed with reclaim and another
+			 * compaction attempt. If it failed for other reasons or
+			 * was deferred, do not reclaim and retry, as we do not
+			 * want to heavily disrupt the system for a costly
+			 * __GFP_NORETRY allocation such as THP.
 			 */
-			if (compact_result == COMPACT_DEFERRED)
+			if (compact_result != COMPACT_SKIPPED)
 				goto nopage;
 
 			/*
-- 
2.19.2
