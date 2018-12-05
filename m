Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 559056B7346
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 03:06:20 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h11so16184616pfj.13
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 00:06:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z197sor24137758pgz.64.2018.12.05.00.06.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 00:06:19 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCH] mm/pageblock: throw compiling time error if pageblock_bits can not hold MIGRATE_TYPES
Date: Wed,  5 Dec 2018 16:05:55 +0800
Message-Id: <1543997155-18344-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>

Currently, NR_PAGEBLOCK_BITS and MIGRATE_TYPES are not associated by code.
If someone adds extra migrate type, then he may forget to enlarge the
NR_PAGEBLOCK_BITS.
NR_PAGEBLOCK_BITS depends on MIGRATE_TYPES, while these macro
spread on two different .h file with reverse dependency, it is a little
hard to refer to MIGRATE_TYPES in pageblock-flag.h. This patch tries to
remind such relation in compiling-time.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
---
 include/linux/pageblock-flags.h | 5 +++--
 mm/page_alloc.c                 | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

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
index 2ec9cc4..537020f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -425,7 +425,7 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 	unsigned long bitidx, word_bitidx;
 	unsigned long old_word, word;
 
-	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
+	BUILD_BUG_ON(order_base_2(MIGRATE_TYPES) != PB_migratetype_bits);
 
 	bitmap = get_pageblock_bitmap(page, pfn);
 	bitidx = pfn_to_bitidx(page, pfn);
-- 
2.7.4
