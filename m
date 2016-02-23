Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF9982F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 22:51:06 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id y89so127791348qge.2
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 19:51:06 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id g131si32345238qkb.102.2016.02.22.19.51.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 Feb 2016 19:51:05 -0800 (PST)
Date: Mon, 22 Feb 2016 22:50:54 -0500
From: Rik van Riel <riel@surriel.com>
Subject: [PATCH] mm,vmscan: compact memory from kswapd when lots of memory
 free already
Message-ID: <20160222225054.1f6ab286@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, akpm@linux-foundation.org, mgorman@suse.de

If kswapd is woken up for a higher order allocation, for example
from alloc_skb, but the system already has lots of memory free,
kswapd_shrink_zone will rightfully decide kswapd should not free
any more memory.

However, at that point kswapd should proceed to compact memory, on
behalf of alloc_skb or others.

Currently kswapd will only compact memory if it first freed memory,
leading kswapd to never compact memory when there is already lots of
memory free.

On my home system, that lead to kswapd occasionally using up to 5%
CPU time, with many man wakeups from alloc_skb, and kswapd never
doing anything to relieve the situation that caused it to be woken
up.

Going ahead with compaction when kswapd did not attempt to reclaim
any memory, and as a consequence did not reclaim any memory, is the
right thing to do in this situation.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 71b1c29948db..9566a04b9759 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3343,7 +3343,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		 * Compact if necessary and kswapd is reclaiming at least the
 		 * high watermark number of pages as requsted
 		 */
-		if (pgdat_needs_compaction && sc.nr_reclaimed > nr_attempted)
+		if (pgdat_needs_compaction && sc.nr_reclaimed >= nr_attempted)
 			compact_pgdat(pgdat, order);
 
 		/*
-- 
-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
