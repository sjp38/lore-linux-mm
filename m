Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 602356B003D
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:06:18 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so3127758pbc.22
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:06:18 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 18/22] truncate: support huge pages
Date: Mon, 23 Sep 2013 15:05:46 +0300
Message-Id: <1379937950-8411-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

truncate_inode_pages_range() drops whole huge page at once if it's fully
inside the range.

If a huge page is only partly in the range we zero out the part,
exactly like we do for partial small pages.

In some cases it worth to split the huge page instead, if we need to
truncate it partly and free some memory. But split_huge_page() now
truncates the file, so we need to break truncate<->split interdependency
at some point.

invalidate_mapping_pages() just skips huge pages if they are not fully
in the range.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/pagemap.h |   9 ++++
 mm/truncate.c           | 125 ++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 109 insertions(+), 25 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 967aadbc5e..8ce130fe56 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -580,4 +580,13 @@ static inline void clear_pagecache_page(struct page *page)
 		clear_highpage(page);
 }
 
+static inline void zero_pagecache_segment(struct page *page,
+		unsigned start, unsigned len)
+{
+	if (PageTransHugeCache(page))
+		zero_huge_user_segment(page, start, len);
+	else
+		zero_user_segment(page, start, len);
+}
+
 #endif /* _LINUX_PAGEMAP_H */
diff --git a/mm/truncate.c b/mm/truncate.c
index 353b683afd..ba62ab2168 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -203,10 +203,10 @@ int invalidate_inode_page(struct page *page)
 void truncate_inode_pages_range(struct address_space *mapping,
 				loff_t lstart, loff_t lend)
 {
+	struct inode	*inode = mapping->host;
 	pgoff_t		start;		/* inclusive */
 	pgoff_t		end;		/* exclusive */
-	unsigned int	partial_start;	/* inclusive */
-	unsigned int	partial_end;	/* exclusive */
+	bool		partial_start, partial_end;
 	struct pagevec	pvec;
 	pgoff_t		index;
 	int		i;
@@ -215,15 +215,13 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	if (mapping->nrpages == 0)
 		return;
 
-	/* Offsets within partial pages */
+	/* Whether we have to do partial truncate */
 	partial_start = lstart & (PAGE_CACHE_SIZE - 1);
 	partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
 
 	/*
 	 * 'start' and 'end' always covers the range of pages to be fully
-	 * truncated. Partial pages are covered with 'partial_start' at the
-	 * start of the range and 'partial_end' at the end of the range.
-	 * Note that 'end' is exclusive while 'lend' is inclusive.
+	 * truncated. Note that 'end' is exclusive while 'lend' is inclusive.
 	 */
 	start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (lend == -1)
@@ -236,10 +234,12 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	else
 		end = (lend + 1) >> PAGE_CACHE_SHIFT;
 
+	i_split_down_read(inode);
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index < end && pagevec_lookup(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
+		bool thp = false;
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
@@ -249,6 +249,23 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			if (index >= end)
 				break;
 
+			thp = PageTransHugeCache(page);
+			if (thp) {
+				/* the range starts in middle of huge page */
+			       if (index < start) {
+				       partial_start = true;
+				       start = index + HPAGE_CACHE_NR;
+				       break;
+			       }
+
+			       /* the range ends on huge page */
+			       if (index == (end & ~HPAGE_CACHE_INDEX_MASK)) {
+				       partial_end = true;
+				       end = index;
+				       break;
+			       }
+			}
+
 			if (!trylock_page(page))
 				continue;
 			WARN_ON(page->index != index);
@@ -258,54 +275,88 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			}
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
+			if (thp)
+				break;
 		}
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
-		index++;
+		if (thp)
+			index += HPAGE_CACHE_NR;
+		else
+			index++;
 	}
 
 	if (partial_start) {
-		struct page *page = find_lock_page(mapping, start - 1);
+		struct page *page;
+
+		page = find_get_page(mapping, start - 1);
 		if (page) {
-			unsigned int top = PAGE_CACHE_SIZE;
-			if (start > end) {
-				/* Truncation within a single page */
-				top = partial_end;
-				partial_end = 0;
+			pgoff_t index_mask;
+			loff_t page_cache_mask;
+			unsigned pstart, pend;
+
+			if (PageTransHugeCache(page)) {
+				index_mask = HPAGE_CACHE_INDEX_MASK;
+				page_cache_mask = HPAGE_PMD_MASK;
+			} else {
+				index_mask = 0UL;
+				page_cache_mask = PAGE_CACHE_MASK;
 			}
+
+			pstart = lstart & ~page_cache_mask;
+			if ((end & ~index_mask) == page->index) {
+				pend = (lend + 1) & ~page_cache_mask;
+				end = page->index;
+				partial_end = false; /* handled here */
+			} else
+				pend = PAGE_CACHE_SIZE << compound_order(page);
+
+			lock_page(page);
 			wait_on_page_writeback(page);
-			zero_user_segment(page, partial_start, top);
+			zero_pagecache_segment(page, pstart, pend);
 			cleancache_invalidate_page(mapping, page);
 			if (page_has_private(page))
-				do_invalidatepage(page, partial_start,
-						  top - partial_start);
+				do_invalidatepage(page, pstart,
+						pend - pstart);
 			unlock_page(page);
 			page_cache_release(page);
 		}
 	}
 	if (partial_end) {
-		struct page *page = find_lock_page(mapping, end);
+		struct page *page;
+
+		page = find_lock_page(mapping, end);
 		if (page) {
+			loff_t page_cache_mask;
+			unsigned pend;
+
+			if (PageTransHugeCache(page))
+				page_cache_mask = HPAGE_PMD_MASK;
+			else
+				page_cache_mask = PAGE_CACHE_MASK;
+			pend = (lend + 1) & ~page_cache_mask;
+			end = page->index;
 			wait_on_page_writeback(page);
-			zero_user_segment(page, 0, partial_end);
+			zero_pagecache_segment(page, 0, pend);
 			cleancache_invalidate_page(mapping, page);
 			if (page_has_private(page))
-				do_invalidatepage(page, 0,
-						  partial_end);
+				do_invalidatepage(page, 0, pend);
 			unlock_page(page);
 			page_cache_release(page);
 		}
 	}
 	/*
-	 * If the truncation happened within a single page no pages
-	 * will be released, just zeroed, so we can bail out now.
+	 * If the truncation happened within a single page no
+	 * pages will be released, just zeroed, so we can bail
+	 * out now.
 	 */
 	if (start >= end)
-		return;
+		goto out;
 
 	index = start;
 	for ( ; ; ) {
+		bool thp = false;
 		cond_resched();
 		if (!pagevec_lookup(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
@@ -327,16 +378,24 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			if (index >= end)
 				break;
 
+			thp = PageTransHugeCache(page);
 			lock_page(page);
 			WARN_ON(page->index != index);
 			wait_on_page_writeback(page);
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
+			if (thp)
+				break;
 		}
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
-		index++;
+		if (thp)
+			index += HPAGE_CACHE_NR;
+		else
+			index++;
 	}
+out:
+	i_split_up_read(inode);
 	cleancache_invalidate_inode(mapping);
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
@@ -375,6 +434,7 @@ EXPORT_SYMBOL(truncate_inode_pages);
 unsigned long invalidate_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t end)
 {
+	struct inode *inode = mapping->host;
 	struct pagevec pvec;
 	pgoff_t index = start;
 	unsigned long ret;
@@ -389,9 +449,11 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	 * (most pages are dirty), and already skips over any difficulties.
 	 */
 
+	i_split_down_read(inode);
 	pagevec_init(&pvec, 0);
 	while (index <= end && pagevec_lookup(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+		bool thp = false;
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
@@ -401,6 +463,15 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			if (index > end)
 				break;
 
+			/* skip huge page if it's not fully in the range */
+			thp = PageTransHugeCache(page);
+			if (thp) {
+			       if (index < start)
+				       break;
+			       if (index == (end & ~HPAGE_CACHE_INDEX_MASK))
+				       break;
+			}
+
 			if (!trylock_page(page))
 				continue;
 			WARN_ON(page->index != index);
@@ -417,8 +488,12 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
-		index++;
+		if (thp)
+			index += HPAGE_CACHE_NR;
+		else
+			index++;
 	}
+	i_split_up_read(inode);
 	return count;
 }
 EXPORT_SYMBOL(invalidate_mapping_pages);
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
