Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6CF88E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:51:55 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id l45so35123592edb.1
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:51:55 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id j8si668671edh.289.2019.01.04.04.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:51:54 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 015471C1E3F
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:51:54 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 09/25] mm, compaction: Use the page allocator bulk-free helper for lists of pages
Date: Fri,  4 Jan 2019 12:49:55 +0000
Message-Id: <20190104125011.16071-10-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

release_pages() is a simpler version of free_unref_page_list() but it
tracks the highest PFN for caching the restart point of the compaction
free scanner. This patch optionally tracks the highest PFN in the core
helper and converts compaction to use it. The performance impact is
limited but it should reduce lock contention slightly in some cases.
The main benefit is removing some partially duplicated code.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/gfp.h |  7 ++++++-
 mm/compaction.c     | 12 +++---------
 mm/page_alloc.c     | 10 +++++++++-
 3 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 5f5e25fd6149..9e58799b730f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -543,7 +543,12 @@ void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_unref_page(struct page *page);
-extern void free_unref_page_list(struct list_head *list);
+extern void __free_page_list(struct list_head *list, bool dropref, unsigned long *highest_pfn);
+
+static inline void free_unref_page_list(struct list_head *list)
+{
+	return __free_page_list(list, false, NULL);
+}
 
 struct page_frag_cache;
 extern void __page_frag_cache_drain(struct page *page, unsigned int count);
diff --git a/mm/compaction.c b/mm/compaction.c
index 8bf2090231a3..8f0ce44dba41 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -52,16 +52,10 @@ static inline void count_compact_events(enum vm_event_item item, long delta)
 
 static unsigned long release_freepages(struct list_head *freelist)
 {
-	struct page *page, *next;
-	unsigned long high_pfn = 0;
+	unsigned long high_pfn;
 
-	list_for_each_entry_safe(page, next, freelist, lru) {
-		unsigned long pfn = page_to_pfn(page);
-		list_del(&page->lru);
-		__free_page(page);
-		if (pfn > high_pfn)
-			high_pfn = pfn;
-	}
+	__free_page_list(freelist, true, &high_pfn);
+	INIT_LIST_HEAD(freelist);
 
 	return high_pfn;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cde5dac6229a..57ba9d1da519 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2876,18 +2876,26 @@ void free_unref_page(struct page *page)
 /*
  * Free a list of 0-order pages
  */
-void free_unref_page_list(struct list_head *list)
+void __free_page_list(struct list_head *list, bool dropref,
+				unsigned long *highest_pfn)
 {
 	struct page *page, *next;
 	unsigned long flags, pfn;
 	int batch_count = 0;
 
+	if (highest_pfn)
+		*highest_pfn = 0;
+
 	/* Prepare pages for freeing */
 	list_for_each_entry_safe(page, next, list, lru) {
+		if (dropref)
+			WARN_ON_ONCE(!put_page_testzero(page));
 		pfn = page_to_pfn(page);
 		if (!free_unref_page_prepare(page, pfn))
 			list_del(&page->lru);
 		set_page_private(page, pfn);
+		if (highest_pfn && pfn > *highest_pfn)
+			*highest_pfn = pfn;
 	}
 
 	local_irq_save(flags);
-- 
2.16.4
