Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1AB8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:12:13 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v11so9934618ply.4
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 22:12:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor19296713pls.69.2018.12.10.22.12.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 22:12:11 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv3] mm/pageblock: throw compiling time error if pageblock_bits can not hold MIGRATE_TYPES
Date: Tue, 11 Dec 2018 14:11:49 +0800
Message-Id: <1544508709-11358-1-git-send-email-kernelfans@gmail.com>
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
v2->v3:
 using '>' instead of "==" option since NR_PAGEBLOCK_BITS allows wasted bits
 include/linux/pageblock-flags.h | 3 ++-
 mm/page_alloc.c                 | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index 9132c5c..06a6632 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -25,10 +25,11 @@
 
 #include <linux/types.h>
 
+#define PB_migratetype_bits 3
 /* Bit indices that affect a whole block of pages */
 enum pageblock_bits {
 	PB_migrate,
-	PB_migrate_end = PB_migrate + 3 - 1,
+	PB_migrate_end = PB_migrate + PB_migratetype_bits - 1,
 			/* 3 bits required for migrate types */
 	PB_migrate_skip,/* If set the block is skipped by compaction */
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc4..29ee87e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -426,6 +426,7 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 	unsigned long old_word, word;
 
 	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
+	BUILD_BUG_ON(MIGRATE_TYPES > (1 << PB_migratetype_bits));
 
 	bitmap = get_pageblock_bitmap(page, pfn);
 	bitidx = pfn_to_bitidx(page, pfn);
-- 
2.7.4
