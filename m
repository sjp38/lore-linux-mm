Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 519B96B0034
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 13:44:41 -0400 (EDT)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [RFC v2 2/5] Have __free_pages_memory() free in larger chunks.
Date: Fri,  2 Aug 2013 12:44:24 -0500
Message-Id: <1375465467-40488-3-git-send-email-nzimmer@sgi.com>
In-Reply-To: <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, mingo@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, holt@sgi.com, nzimmer@sgi.com, rob@landley.net, travis@sgi.com, daniel@numascale-asia.com, akpm@linux-foundation.org, gregkh@linuxfoundation.org, yinghai@kernel.org, mgorman@suse.de

From: Robin Holt <holt@sgi.com>

Currently, when free_all_bootmem() calls __free_pages_memory(), the
number of contiguous pages that __free_pages_memory() passes to the
buddy allocator is limited to BITS_PER_LONG.  In order to be able to
free only the first page of a 2MiB chunk, we need that to be increased.
We are increasing to the maximum size available.

Signed-off-by: Robin Holt <holt@sgi.com>
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
index bdd3fa2..2159e68 100644
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
+		order = min(MAX_ORDER - 1, __ffs(start));
 
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
