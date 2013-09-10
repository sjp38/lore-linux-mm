Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 857A56B0073
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 14:57:33 -0400 (EDT)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [PATCH] Have __free_pages_memory() free in larger chunks.
Date: Tue, 10 Sep 2013 13:57:24 -0500
Message-Id: <1378839444-196190-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org, hpa@zytor.com
Cc: Robin Holt <robin.m.holt@gmail.com>, Nathan Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>

From: Robin Holt <robin.m.holt@gmail.com>

On large memory machines it can take a few minutes to get through
free_all_bootmem().

Currently, when free_all_bootmem() calls __free_pages_memory(), the
number of contiguous pages that __free_pages_memory() passes to the
buddy allocator is limited to BITS_PER_LONG.  BITS_PER_LONG was originally
chosen to keep things similar to mm/nobootmem.c.  But it is more
efficient to limit it to MAX_ORDER.

       base   new  change
8TB    202s  172s   30s
16TB   401s  351s   50s

That is around 1%-3% improvement on total boot time.

This patch was spun off from the boot time rfc Robin and I had been
working on.

Signed-off-by: Robin Holt <robin.m.holt@gmail.com>
Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
To: "H. Peter Anvin" <hpa@zytor.com>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>
Cc: Rob Landley <rob@landley.net>
Cc: Mike Travis <travis@sgi.com>
Cc: Daniel J Blueman <daniel@numascale-asia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
---
 mm/nobootmem.c | 25 ++++++++-----------------
 1 file changed, 8 insertions(+), 17 deletions(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 61107cf..2c254d3 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -82,27 +82,18 @@ void __init free_bootmem_late(unsigned long addr, unsigned long size)
 
 static void __init __free_pages_memory(unsigned long start, unsigned long end)
 {
-	unsigned long i, start_aligned, end_aligned;
-	int order = ilog2(BITS_PER_LONG);
+	int order;
 
-	start_aligned = (start + (BITS_PER_LONG - 1)) & ~(BITS_PER_LONG - 1);
-	end_aligned = end & ~(BITS_PER_LONG - 1);
+	while (start < end) {
+		order = min(MAX_ORDER - 1UL, __ffs(start));
 
-	if (end_aligned <= start_aligned) {
-		for (i = start; i < end; i++)
-			__free_pages_bootmem(pfn_to_page(i), 0);
+		while (start + (1UL << order) > end)
+			order--;
 
-		return;
-	}
-
-	for (i = start; i < start_aligned; i++)
-		__free_pages_bootmem(pfn_to_page(i), 0);
+		__free_pages_bootmem(pfn_to_page(start), order);
 
-	for (i = start_aligned; i < end_aligned; i += BITS_PER_LONG)
-		__free_pages_bootmem(pfn_to_page(i), order);
-
-	for (i = end_aligned; i < end; i++)
-		__free_pages_bootmem(pfn_to_page(i), 0);
+		start += (1UL << order);
+	}
 }
 
 static unsigned long __init __free_memory_core(phys_addr_t start,
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
