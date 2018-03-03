Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id F277B6B0006
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 19:12:47 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id z23so9045848qtg.13
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 16:12:47 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v1si5034324qtg.188.2018.03.02.16.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 16:12:47 -0800 (PST)
From: Daniel Vacek <neelx@redhat.com>
Subject: [PATCH v3 1/2] mm/memblock: hardcode the end_pfn being -1
Date: Sat,  3 Mar 2018 01:12:25 +0100
Message-Id: <1ca478d4269125a99bcfb1ca04d7b88ac1aee924.1520011944.git.neelx@redhat.com>
In-Reply-To: <cover.1520011944.git.neelx@redhat.com>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
 <cover.1520011944.git.neelx@redhat.com>
In-Reply-To: <cover.1520011944.git.neelx@redhat.com>
References: <cover.1520011944.git.neelx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, Daniel Vacek <neelx@redhat.com>, stable@vger.kernel.org

This is just a clean up. It aids preventing to handle the special end case
in the next commit.

Signed-off-by: Daniel Vacek <neelx@redhat.com>
Cc: stable@vger.kernel.org
---
 mm/memblock.c   | 13 ++++++-------
 mm/page_alloc.c |  2 +-
 2 files changed, 7 insertions(+), 8 deletions(-)

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
index cb416723538f..f2c57da5bbe5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5361,7 +5361,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			 * end_pfn), such that we hit a valid pfn (or end_pfn)
 			 * on our next iteration of the loop.
 			 */
-			pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
+			pfn = memblock_next_valid_pfn(pfn) - 1;
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
