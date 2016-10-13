Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 010FB6B0263
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:08:23 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id rz1so70768619pab.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:22 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id t5si9874696pgb.171.2016.10.13.01.08.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 01:08:22 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id r16so4544983pfg.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:22 -0700 (PDT)
From: js1304@gmail.com
Subject: [RFC PATCH 4/5] mm/page_alloc: add fixed migratetype pageblock infrastructure
Date: Thu, 13 Oct 2016 17:08:21 +0900
Message-Id: <1476346102-26928-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Following patch will support permanent migratetype pageblock by
kernel boot parameter. For preparation, this patch adds infrastructure
for it. Once fixed, migratetype cannot be changed anymore until power off.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/pageblock-flags.h |  3 ++-
 mm/page_alloc.c                 | 12 +++++++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index e942558..0cf2c1f 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -31,12 +31,13 @@ enum pageblock_bits {
 	PB_migrate_end = PB_migrate + 3 - 1,
 			/* 3 bits required for migrate types */
 	PB_migrate_skip,/* If set the block is skipped by compaction */
+	PB_migrate_fixed,
 
 	/*
 	 * Assume the bits will always align on a word. If this assumption
 	 * changes then get/set pageblock needs updating.
 	 */
-	NR_PAGEBLOCK_BITS
+	NR_PAGEBLOCK_BITS = 8,
 };
 
 #ifdef CONFIG_HUGETLB_PAGE
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a167754..6b60e26 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -427,7 +427,7 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 	unsigned long bitidx, word_bitidx;
 	unsigned long old_word, word;
 
-	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
+	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 8);
 
 	bitmap = get_pageblock_bitmap(page, pfn);
 	bitidx = pfn_to_bitidx(page, pfn);
@@ -451,10 +451,17 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 
 void set_pageblock_migratetype(struct page *page, int migratetype)
 {
+	int fixed;
+
 	if (unlikely(page_group_by_mobility_disabled &&
 		     migratetype < MIGRATE_PCPTYPES))
 		migratetype = MIGRATE_UNMOVABLE;
 
+	fixed = get_pageblock_flags_group(page,
+			PB_migrate_fixed, PB_migrate_fixed);
+	if (fixed)
+		return;
+
 	set_pageblock_flags_group(page, (unsigned long)migratetype,
 					PB_migrate, PB_migrate_end);
 }
@@ -2026,6 +2033,9 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 	int mt;
 	unsigned long max_managed, flags;
 
+	/* FIXME: disable highatomic pageblock reservation for test */
+	return;
+
 	/*
 	 * Limit the number reserved to 1 pageblock or roughly 1% of a zone.
 	 * Check is race-prone but harmless.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
