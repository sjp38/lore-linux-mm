Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 10482828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:16:32 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so59414574pac.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:16:32 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id f9si46789633pfa.18.2016.08.09.23.16.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 23:16:30 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id vy10so2244982pac.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:16:27 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 4/5] mm/page_ext: support extra space allocation by page_ext user
Date: Wed, 10 Aug 2016 15:16:23 +0900
Message-Id: <1470809784-11516-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Until now, if some page_ext users want to use it's own field on page_ext,
it should be defined in struct page_ext by hard-coding. It has a problem
that wastes memory in following situation.

struct page_ext {
 #ifdef CONFIG_A
	int a;
 #endif
 #ifdef CONFIG_B
	int b;
 #endif
};

Assume that kernel is built with both CONFIG_A and CONFIG_B.
Even if we enable feature A and doesn't enable feature B at runtime,
each entry of struct page_ext takes two int rather than one int.
It's undesirable result so this patch tries to fix it.

To solve above problem, this patch implements to support extra space
allocation at runtime. When need() callback returns true, it's extra
memory requirement is summed to entry size of page_ext. Also, offset
for each user's extra memory space is returned. With this offset,
user can use this extra space and there is no need to define needed
field on page_ext by hard-coding.

This patch only implements an infrastructure. Following patch will use it
for page_owner which is only user having it's own fields on page_ext.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/page_ext.h |  2 ++
 mm/page_alloc.c          |  2 +-
 mm/page_ext.c            | 41 +++++++++++++++++++++++++++++++----------
 3 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index 03f2a3e..179bdc4 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -7,6 +7,8 @@
 
 struct pglist_data;
 struct page_ext_operations {
+	size_t offset;
+	size_t size;
 	bool (*need)(void);
 	void (*init)(void);
 };
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 45cb021..d2e365c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -688,7 +688,7 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
 		__mod_zone_freepage_state(zone, (1 << order), migratetype);
 }
 #else
-struct page_ext_operations debug_guardpage_ops = { NULL, };
+struct page_ext_operations debug_guardpage_ops;
 static inline bool set_page_guard(struct zone *zone, struct page *page,
 			unsigned int order, int migratetype) { return false; }
 static inline void clear_page_guard(struct zone *zone, struct page *page,
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 44a4c02..4b7ca1f 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -42,6 +42,11 @@
  * and page extension core can skip to allocate memory. As result,
  * none of memory is wasted.
  *
+ * When need callback returns true, page_ext checks if there is a request for
+ * extra memory through size in struct page_ext_operations. If it is non-zero,
+ * extra space is allocated for each page_ext entry and offset is returned to
+ * user through offset in struct page_ext_operations.
+ *
  * The init callback is used to do proper initialization after page extension
  * is completely initialized. In sparse memory system, extra memory is
  * allocated some time later than memmap is allocated. In other words, lifetime
@@ -66,18 +71,24 @@ static struct page_ext_operations *page_ext_ops[] = {
 };
 
 static unsigned long total_usage;
+static unsigned long extra_mem;
 
 static bool __init invoke_need_callbacks(void)
 {
 	int i;
 	int entries = ARRAY_SIZE(page_ext_ops);
+	bool need = false;
 
 	for (i = 0; i < entries; i++) {
-		if (page_ext_ops[i]->need && page_ext_ops[i]->need())
-			return true;
+		if (page_ext_ops[i]->need && page_ext_ops[i]->need()) {
+			page_ext_ops[i]->offset = sizeof(struct page_ext) +
+						extra_mem;
+			extra_mem += page_ext_ops[i]->size;
+			need = true;
+		}
 	}
 
-	return false;
+	return need;
 }
 
 static void __init invoke_init_callbacks(void)
@@ -91,6 +102,16 @@ static void __init invoke_init_callbacks(void)
 	}
 }
 
+static unsigned long get_entry_size(void)
+{
+	return sizeof(struct page_ext) + extra_mem;
+}
+
+static inline struct page_ext *get_entry_base(void *base, unsigned long offset)
+{
+	return base + get_entry_size() * offset;
+}
+
 #if !defined(CONFIG_SPARSEMEM)
 
 
@@ -121,7 +142,7 @@ struct page_ext *lookup_page_ext(struct page *page)
 #endif
 	offset = pfn - round_down(node_start_pfn(page_to_nid(page)),
 					MAX_ORDER_NR_PAGES);
-	return base + offset;
+	return get_entry_base(base, offset);
 }
 
 static int __init alloc_node_page_ext(int nid)
@@ -143,7 +164,7 @@ static int __init alloc_node_page_ext(int nid)
 		!IS_ALIGNED(node_end_pfn(nid), MAX_ORDER_NR_PAGES))
 		nr_pages += MAX_ORDER_NR_PAGES;
 
-	table_size = sizeof(struct page_ext) * nr_pages;
+	table_size = get_entry_size() * nr_pages;
 
 	base = memblock_virt_alloc_try_nid_nopanic(
 			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
@@ -196,7 +217,7 @@ struct page_ext *lookup_page_ext(struct page *page)
 	if (!section->page_ext)
 		return NULL;
 #endif
-	return section->page_ext + pfn;
+	return get_entry_base(section->page_ext, pfn);
 }
 
 static void *__meminit alloc_page_ext(size_t size, int nid)
@@ -229,7 +250,7 @@ static int __meminit init_section_page_ext(unsigned long pfn, int nid)
 	if (section->page_ext)
 		return 0;
 
-	table_size = sizeof(struct page_ext) * PAGES_PER_SECTION;
+	table_size = get_entry_size() * PAGES_PER_SECTION;
 	base = alloc_page_ext(table_size, nid);
 
 	/*
@@ -249,7 +270,7 @@ static int __meminit init_section_page_ext(unsigned long pfn, int nid)
 	 * we need to apply a mask.
 	 */
 	pfn &= PAGE_SECTION_MASK;
-	section->page_ext = base - pfn;
+	section->page_ext = (void *)base - get_entry_size() * pfn;
 	total_usage += table_size;
 	return 0;
 }
@@ -262,7 +283,7 @@ static void free_page_ext(void *addr)
 		struct page *page = virt_to_page(addr);
 		size_t table_size;
 
-		table_size = sizeof(struct page_ext) * PAGES_PER_SECTION;
+		table_size = get_entry_size() * PAGES_PER_SECTION;
 
 		BUG_ON(PageReserved(page));
 		free_pages_exact(addr, table_size);
@@ -277,7 +298,7 @@ static void __free_page_ext(unsigned long pfn)
 	ms = __pfn_to_section(pfn);
 	if (!ms || !ms->page_ext)
 		return;
-	base = ms->page_ext + pfn;
+	base = get_entry_base(ms->page_ext, pfn);
 	free_page_ext(base);
 	ms->page_ext = NULL;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
