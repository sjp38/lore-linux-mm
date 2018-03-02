Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 348CB6B0003
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 06:01:50 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id s82so7324199qke.1
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 03:01:50 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x13si59696qta.408.2018.03.02.03.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 03:01:49 -0800 (PST)
From: Daniel Vacek <neelx@redhat.com>
Subject: [PATCH v2] mm/page_alloc: fix memmap_init_zone pageblock alignment
Date: Fri,  2 Mar 2018 12:01:37 +0100
Message-Id: <1519988497-28941-1-git-send-email-neelx@redhat.com>
In-Reply-To: <1519908465-12328-1-git-send-email-neelx@redhat.com>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, Daniel Vacek <neelx@redhat.com>, stable@vger.kernel.org

BUG at mm/page_alloc.c:1913

>	VM_BUG_ON(page_zone(start_page) != page_zone(end_page));

Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
where possible") introduced a bug where move_freepages() triggers a
VM_BUG_ON() on uninitialized page structure due to pageblock alignment.
To fix this, simply align the skipped pfns in memmap_init_zone()
the same way as in move_freepages_block().

Fixes: b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns where possible")
Signed-off-by: Daniel Vacek <neelx@redhat.com>
Cc: stable@vger.kernel.org
---
 mm/memblock.c   | 13 ++++++-------
 mm/page_alloc.c |  9 +++++++--
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 5a9ca2a1751b..2a5facd236bb 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1101,13 +1101,12 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
 		*out_nid = r->nid;
 }
 
-unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
-						      unsigned long max_pfn)
+unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
 {
 	struct memblock_type *type = &memblock.memory;
 	unsigned int right = type->cnt;
 	unsigned int mid, left = 0;
-	phys_addr_t addr = PFN_PHYS(pfn + 1);
+	phys_addr_t addr = PFN_PHYS(++pfn);
 
 	do {
 		mid = (right + left) / 2;
@@ -1118,15 +1117,15 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
 				  type->regions[mid].size))
 			left = mid + 1;
 		else {
-			/* addr is within the region, so pfn + 1 is valid */
-			return min(pfn + 1, max_pfn);
+			/* addr is within the region, so pfn is valid */
+			return pfn;
 		}
 	} while (left < right);
 
 	if (right == type->cnt)
-		return max_pfn;
+		return -1UL;
 	else
-		return min(PHYS_PFN(type->regions[right].base), max_pfn);
+		return PHYS_PFN(type->regions[right].base);
 }
 
 /**
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cb416723538f..eb27ccb50928 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5359,9 +5359,14 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			/*
 			 * Skip to the pfn preceding the next valid one (or
 			 * end_pfn), such that we hit a valid pfn (or end_pfn)
-			 * on our next iteration of the loop.
+			 * on our next iteration of the loop. Note that it needs
+			 * to be pageblock aligned even when the region itself
+			 * is not as move_freepages_block() can shift ahead of
+			 * the valid region but still depends on correct page
+			 * metadata.
 			 */
-			pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
+			pfn = (memblock_next_valid_pfn(pfn) &
+					~(pageblock_nr_pages-1)) - 1;
 #endif
 			continue;
 		}
-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
