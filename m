Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 665B8828E1
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:10:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so13138295wmw.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:10:10 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id t5si49486819wjx.56.2016.04.15.02.10.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:10:09 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id CA1F32F80FF
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:10:08 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 25/28] mm, page_alloc: Inline pageblock lookup in page free fast paths
Date: Fri, 15 Apr 2016 10:07:52 +0100
Message-Id: <1460711275-1130-13-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The function call overhead of get_pfnblock_flags_mask() is measurable in
the page free paths. This patch uses an inlined version that is faster.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h |   7 --
 mm/page_alloc.c        | 188 ++++++++++++++++++++++++++-----------------------
 mm/page_owner.c        |   2 +-
 mm/vmstat.c            |   2 +-
 4 files changed, 102 insertions(+), 97 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bf153ed097d5..48ee8885aa74 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -85,13 +85,6 @@ extern int page_group_by_mobility_disabled;
 	get_pfnblock_flags_mask(page, page_to_pfn(page),		\
 			PB_migrate_end, MIGRATETYPE_MASK)
 
-static inline int get_pfnblock_migratetype(struct page *page, unsigned long pfn)
-{
-	BUILD_BUG_ON(PB_migrate_end - PB_migrate != 2);
-	return get_pfnblock_flags_mask(page, pfn, PB_migrate_end,
-					MIGRATETYPE_MASK);
-}
-
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bdcd4087553e..f038d06192c7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -352,6 +352,106 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 }
 #endif
 
+/* Return a pointer to the bitmap storing bits affecting a block of pages */
+static inline unsigned long *get_pageblock_bitmap(struct page *page,
+							unsigned long pfn)
+{
+#ifdef CONFIG_SPARSEMEM
+	return __pfn_to_section(pfn)->pageblock_flags;
+#else
+	return page_zone(page)->pageblock_flags;
+#endif /* CONFIG_SPARSEMEM */
+}
+
+static inline int pfn_to_bitidx(struct page *page, unsigned long pfn)
+{
+#ifdef CONFIG_SPARSEMEM
+	pfn &= (PAGES_PER_SECTION-1);
+	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
+#else
+	pfn = pfn - round_down(page_zone(page)->zone_start_pfn, pageblock_nr_pages);
+	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
+#endif /* CONFIG_SPARSEMEM */
+}
+
+/**
+ * get_pfnblock_flags_mask - Return the requested group of flags for the pageblock_nr_pages block of pages
+ * @page: The page within the block of interest
+ * @pfn: The target page frame number
+ * @end_bitidx: The last bit of interest to retrieve
+ * @mask: mask of bits that the caller is interested in
+ *
+ * Return: pageblock_bits flags
+ */
+static __always_inline unsigned long __get_pfnblock_flags_mask(struct page *page,
+					unsigned long pfn,
+					unsigned long end_bitidx,
+					unsigned long mask)
+{
+	unsigned long *bitmap;
+	unsigned long bitidx, word_bitidx;
+	unsigned long word;
+
+	bitmap = get_pageblock_bitmap(page, pfn);
+	bitidx = pfn_to_bitidx(page, pfn);
+	word_bitidx = bitidx / BITS_PER_LONG;
+	bitidx &= (BITS_PER_LONG-1);
+
+	word = bitmap[word_bitidx];
+	bitidx += end_bitidx;
+	return (word >> (BITS_PER_LONG - bitidx - 1)) & mask;
+}
+
+unsigned long get_pfnblock_flags_mask(struct page *page, unsigned long pfn,
+					unsigned long end_bitidx,
+					unsigned long mask)
+{
+	return __get_pfnblock_flags_mask(page, pfn, end_bitidx, mask);
+}
+
+static __always_inline int get_pfnblock_migratetype(struct page *page, unsigned long pfn)
+{
+	return __get_pfnblock_flags_mask(page, pfn, PB_migrate_end, MIGRATETYPE_MASK);
+}
+
+/**
+ * set_pfnblock_flags_mask - Set the requested group of flags for a pageblock_nr_pages block of pages
+ * @page: The page within the block of interest
+ * @flags: The flags to set
+ * @pfn: The target page frame number
+ * @end_bitidx: The last bit of interest
+ * @mask: mask of bits that the caller is interested in
+ */
+void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
+					unsigned long pfn,
+					unsigned long end_bitidx,
+					unsigned long mask)
+{
+	unsigned long *bitmap;
+	unsigned long bitidx, word_bitidx;
+	unsigned long old_word, word;
+
+	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
+
+	bitmap = get_pageblock_bitmap(page, pfn);
+	bitidx = pfn_to_bitidx(page, pfn);
+	word_bitidx = bitidx / BITS_PER_LONG;
+	bitidx &= (BITS_PER_LONG-1);
+
+	VM_BUG_ON_PAGE(!zone_spans_pfn(page_zone(page), pfn), page);
+
+	bitidx += end_bitidx;
+	mask <<= (BITS_PER_LONG - bitidx - 1);
+	flags <<= (BITS_PER_LONG - bitidx - 1);
+
+	word = READ_ONCE(bitmap[word_bitidx]);
+	for (;;) {
+		old_word = cmpxchg(&bitmap[word_bitidx], word, (word & ~mask) | flags);
+		if (word == old_word)
+			break;
+		word = old_word;
+	}
+}
 
 void set_pageblock_migratetype(struct page *page, int migratetype)
 {
@@ -6801,94 +6901,6 @@ void *__init alloc_large_system_hash(const char *tablename,
 	return table;
 }
 
-/* Return a pointer to the bitmap storing bits affecting a block of pages */
-static inline unsigned long *get_pageblock_bitmap(struct page *page,
-							unsigned long pfn)
-{
-#ifdef CONFIG_SPARSEMEM
-	return __pfn_to_section(pfn)->pageblock_flags;
-#else
-	return page_zone(page)->pageblock_flags;
-#endif /* CONFIG_SPARSEMEM */
-}
-
-static inline int pfn_to_bitidx(struct page *page, unsigned long pfn)
-{
-#ifdef CONFIG_SPARSEMEM
-	pfn &= (PAGES_PER_SECTION-1);
-	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
-#else
-	pfn = pfn - round_down(page_zone(page)->zone_start_pfn, pageblock_nr_pages);
-	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
-#endif /* CONFIG_SPARSEMEM */
-}
-
-/**
- * get_pfnblock_flags_mask - Return the requested group of flags for the pageblock_nr_pages block of pages
- * @page: The page within the block of interest
- * @pfn: The target page frame number
- * @end_bitidx: The last bit of interest to retrieve
- * @mask: mask of bits that the caller is interested in
- *
- * Return: pageblock_bits flags
- */
-unsigned long get_pfnblock_flags_mask(struct page *page, unsigned long pfn,
-					unsigned long end_bitidx,
-					unsigned long mask)
-{
-	unsigned long *bitmap;
-	unsigned long bitidx, word_bitidx;
-	unsigned long word;
-
-	bitmap = get_pageblock_bitmap(page, pfn);
-	bitidx = pfn_to_bitidx(page, pfn);
-	word_bitidx = bitidx / BITS_PER_LONG;
-	bitidx &= (BITS_PER_LONG-1);
-
-	word = bitmap[word_bitidx];
-	bitidx += end_bitidx;
-	return (word >> (BITS_PER_LONG - bitidx - 1)) & mask;
-}
-
-/**
- * set_pfnblock_flags_mask - Set the requested group of flags for a pageblock_nr_pages block of pages
- * @page: The page within the block of interest
- * @flags: The flags to set
- * @pfn: The target page frame number
- * @end_bitidx: The last bit of interest
- * @mask: mask of bits that the caller is interested in
- */
-void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
-					unsigned long pfn,
-					unsigned long end_bitidx,
-					unsigned long mask)
-{
-	unsigned long *bitmap;
-	unsigned long bitidx, word_bitidx;
-	unsigned long old_word, word;
-
-	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
-
-	bitmap = get_pageblock_bitmap(page, pfn);
-	bitidx = pfn_to_bitidx(page, pfn);
-	word_bitidx = bitidx / BITS_PER_LONG;
-	bitidx &= (BITS_PER_LONG-1);
-
-	VM_BUG_ON_PAGE(!zone_spans_pfn(page_zone(page), pfn), page);
-
-	bitidx += end_bitidx;
-	mask <<= (BITS_PER_LONG - bitidx - 1);
-	flags <<= (BITS_PER_LONG - bitidx - 1);
-
-	word = READ_ONCE(bitmap[word_bitidx]);
-	for (;;) {
-		old_word = cmpxchg(&bitmap[word_bitidx], word, (word & ~mask) | flags);
-		if (word == old_word)
-			break;
-		word = old_word;
-	}
-}
-
 /*
  * This function checks whether pageblock includes unmovable pages or not.
  * If @count is not zero, it is okay to include less @count unmovable pages
diff --git a/mm/page_owner.c b/mm/page_owner.c
index ac3d8d129974..22630e75c192 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -143,7 +143,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		goto err;
 
 	/* Print information relevant to grouping pages by mobility */
-	pageblock_mt = get_pfnblock_migratetype(page, pfn);
+	pageblock_mt = get_pageblock_migratetype(page);
 	page_mt  = gfpflags_to_migratetype(page_ext->gfp_mask);
 	ret += snprintf(kbuf + ret, count - ret,
 			"PFN %lu type %s Block %lu type %s Flags %#lx(%pGp)\n",
diff --git a/mm/vmstat.c b/mm/vmstat.c
index a4bda11eac8d..20698fc82354 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1044,7 +1044,7 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
 		page = pfn_to_page(pfn);
-		pageblock_mt = get_pfnblock_migratetype(page, pfn);
+		pageblock_mt = get_pageblock_migratetype(page);
 
 		for (; pfn < block_end_pfn; pfn++) {
 			if (!pfn_valid_within(pfn))
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
