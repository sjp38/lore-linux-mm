Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 79D6D6B7C6C
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 23:53:31 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id k125so1771128pga.5
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 20:53:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor3536961plf.73.2018.12.06.20.53.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 20:53:30 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv2] mm/pageblock: throw compiling time error if pageblock_bits can not hold MIGRATE_TYPES
Date: Fri,  7 Dec 2018 12:53:08 +0800
Message-Id: <1544158388-20832-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>

Currently, NR_PAGEBLOCK_BITS and MIGRATE_TYPES are not associated by code.
If someone adds extra migrate type, then he may forget to enlarge the
NR_PAGEBLOCK_BITS. Hence it requires some way to fix.
NR_PAGEBLOCK_BITS depends on MIGRATE_TYPES, while these macro
spread on two different .h file with reverse dependency, it is a little
hard to refer to MIGRATE_TYPES in pageblock-flag.h. This patch tries to
remind such relation in compiling-time.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/pageblock-flags.h | 5 +++--
 mm/page_alloc.c                 | 3 ++-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index 9132c5c..fe0aec4 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -25,11 +25,12 @@
 
 #include <linux/types.h>
 
+#define PB_migratetype_bits 3
 /* Bit indices that affect a whole block of pages */
 enum pageblock_bits {
 	PB_migrate,
-	PB_migrate_end = PB_migrate + 3 - 1,
-			/* 3 bits required for migrate types */
+	PB_migrate_end = PB_migrate + PB_migratetype_bits - 1,
+			/* n bits required for migrate types */
 	PB_migrate_skip,/* If set the block is skipped by compaction */
 
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc4..1a22d8d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -425,7 +425,8 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 	unsigned long bitidx, word_bitidx;
 	unsigned long old_word, word;
 
-	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
+	BUILD_BUG_ON(order_base_2(MIGRATE_TYPES)
+		!= (PB_migratetype_bits - 1));
 
 	bitmap = get_pageblock_bitmap(page, pfn);
 	bitidx = pfn_to_bitidx(page, pfn);
-- 
2.7.4
