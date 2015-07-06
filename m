Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5F43F2802AF
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 09:40:13 -0400 (EDT)
Received: by wguu7 with SMTP id u7so140862470wgu.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 06:40:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pd7si30909930wic.106.2015.07.06.06.40.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jul 2015 06:40:05 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/4] mm: Increase SWAP_CLUSTER_MAX to batch TLB flushes
Date: Mon,  6 Jul 2015 14:39:56 +0100
Message-Id: <1436189996-7220-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1436189996-7220-1-git-send-email-mgorman@suse.de>
References: <1436189996-7220-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Pages that are unmapped for reclaim must be flushed before being freed to
avoid corruption due to a page being freed and reallocated while a stale
TLB entry exists. When reclaiming mapped pages, the requires one IPI per
SWAP_CLUSTER_MAX. This patch increases SWAP_CLUSTER_MAX to 256 so more
pages can be flushed with a single IPI. This number was selected because
it reduced IPIs for TLB shootdowns by 40% on a workload that is dominated
by mapped pages.

Note that it is expected that doubling SWAP_CLUSTER_MAX would not always
halve the IPIs as it is workload dependent. Reclaim efficiency was not 100%
on this workload which was picked for being IPI-intensive and was closer to
35%. More importantly, reclaim does not always isolate in SWAP_CLUSTER_MAX
pages. The LRU lists for a zone may be small, the priority can be low
and even when reclaiming a lot of pages, the last isolation may not be
exactly SWAP_CLUSTER_MAX.

There are a few potential issues with increasing SWAP_CLUSTER_MAX.

1. LRU lock hold times increase slightly because more pages are being
   isolated.
2. There are slight timing changes due to more pages having to be
   processed before they are freed. There is a slight risk that more
   pages than are necessary get reclaimed.
3. There is a risk that too_many_isolated checks will be easier to
   trigger resulting in a HZ/10 stall.
4. The rotation rate of active->inactive is slightly faster but there
   should be fewer rotations before the lists get balanced so it
   shouldn't matter.
5. More pages are reclaimed in a single pass if zone_reclaim_mode is
   active but that thing sucks hard when it's enabled no matter what
6. More pages are isolated for compaction so page hold times there
   are longer while they are being copied

It's unlikely any of these will be problems but worth keeping in mind if
there are any reclaim-related bug reports in the near future.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/swap.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 38874729dc5f..89b648665877 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -154,7 +154,7 @@ enum {
 	SWP_SCANNING	= (1 << 10),	/* refcount in scan_swap_map */
 };
 
-#define SWAP_CLUSTER_MAX 32UL
+#define SWAP_CLUSTER_MAX 256UL
 #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
 
 /*
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
