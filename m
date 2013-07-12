Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 8E0B26B0034
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 22:04:10 -0400 (EDT)
From: Robin Holt <holt@sgi.com>
Subject: [RFC 2/4] Have __free_pages_memory() free in larger chunks.
Date: Thu, 11 Jul 2013 21:03:53 -0500
Message-Id: <1373594635-131067-3-git-send-email-holt@sgi.com>
In-Reply-To: <1373594635-131067-1-git-send-email-holt@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>
Cc: Robin Holt <holt@sgi.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>

Currently, when free_all_bootmem() calls __free_pages_memory(), the
number of contiguous pages that __free_pages_memory() passes to the
buddy allocator is limited to BITS_PER_LONG.  In order to be able to
free only the first page of a 2MiB chunk, we need that to be increased
to PTRS_PER_PMD.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Nate Zimmer <nzimmer@sgi.com>
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
 mm/nobootmem.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index bdd3fa2..3b512ca 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -83,10 +83,10 @@ void __init free_bootmem_late(unsigned long addr, unsigned long size)
 static void __init __free_pages_memory(unsigned long start, unsigned long end)
 {
 	unsigned long i, start_aligned, end_aligned;
-	int order = ilog2(BITS_PER_LONG);
+	int order = ilog2(max(BITS_PER_LONG, PTRS_PER_PMD));
 
-	start_aligned = (start + (BITS_PER_LONG - 1)) & ~(BITS_PER_LONG - 1);
-	end_aligned = end & ~(BITS_PER_LONG - 1);
+	start_aligned = (start + ((1UL << order) - 1)) & ~((1UL << order) - 1);
+	end_aligned = end & ~((1UL << order) - 1);
 
 	if (end_aligned <= start_aligned) {
 		for (i = start; i < end; i++)
@@ -98,7 +98,7 @@ static void __init __free_pages_memory(unsigned long start, unsigned long end)
 	for (i = start; i < start_aligned; i++)
 		__free_pages_bootmem(pfn_to_page(i), 0);
 
-	for (i = start_aligned; i < end_aligned; i += BITS_PER_LONG)
+	for (i = start_aligned; i < end_aligned; i += 1 << order)
 		__free_pages_bootmem(pfn_to_page(i), order);
 
 	for (i = end_aligned; i < end; i++)
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
