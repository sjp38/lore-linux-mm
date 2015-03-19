Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8ECA16B0074
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:08:47 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so81802958pdn.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:08:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fe5si4251976pdb.39.2015.03.19.10.08.42
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:08:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 16/16] mm: sanitize page->mapping for tail pages
Date: Thu, 19 Mar 2015 19:08:22 +0200
Message-Id: <1426784902-125149-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't define meaning of page->mapping for tail pages. Currently it's
always NULL, which can be inconsistent with head page and potentially
lead to problems.

Let's poison the pointer to catch all illigal uses.

page_rmapping() and page_mapping() are changed to look on head page.

The only illigal use I've catched so far is __GPF_COMP pages from sound
subsystem, mapped with PTEs. do_shared_fault() is changed to use
page_rmapping() instead of direct access to fault_page->mapping.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h     | 1 +
 include/linux/poison.h | 4 ++++
 mm/huge_memory.c       | 2 +-
 mm/memory.c            | 2 +-
 mm/page_alloc.c        | 7 +++++++
 mm/util.c              | 5 ++++-
 6 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bcf37dacbee3..4a3a38522ab4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -915,6 +915,7 @@ extern struct address_space *page_mapping(struct page *page);
 /* Neutral page->mapping pointer to address_space or anon_vma or other */
 static inline void *page_rmapping(struct page *page)
 {
+	page = compound_head(page);
 	return (void *)((unsigned long)page->mapping & ~PAGE_MAPPING_FLAGS);
 }
 
diff --git a/include/linux/poison.h b/include/linux/poison.h
index 2110a81c5e2a..7b2a7fcde6a3 100644
--- a/include/linux/poison.h
+++ b/include/linux/poison.h
@@ -32,6 +32,10 @@
 /********** mm/debug-pagealloc.c **********/
 #define PAGE_POISON 0xaa
 
+/********** mm/page_alloc.c ************/
+
+#define TAIL_MAPPING	((void *) 0x01014A11 + POISON_POINTER_DELTA)
+
 /********** mm/slab.c **********/
 /*
  * Magic nums for obj red zoning.
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3412cc8a4bd4..54d90ed2d31b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1739,7 +1739,7 @@ static void __split_huge_page_refcount(struct page *page,
 		*/
 		page_tail->_mapcount = page->_mapcount;
 
-		BUG_ON(page_tail->mapping);
+		BUG_ON(page_tail->mapping != TAIL_MAPPING);
 		page_tail->mapping = page->mapping;
 
 		page_tail->index = page->index + i;
diff --git a/mm/memory.c b/mm/memory.c
index 5ec794f13f8a..a76f61aa88da 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3033,7 +3033,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * pinned by vma->vm_file's reference.  We rely on unlock_page()'s
 	 * release semantics to prevent the compiler from undoing this copying.
 	 */
-	mapping = fault_page->mapping;
+	mapping = page_rmapping(fault_page);
 	unlock_page(fault_page);
 	if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
 		/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b849500640c..e73ecbbfa69f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -373,6 +373,7 @@ void prep_compound_page(struct page *page, unsigned long order)
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
 		set_page_count(p, 0);
+		p->mapping = TAIL_MAPPING;
 		p->first_page = page;
 		/* Make sure p->first_page is always valid for PageTail() */
 		smp_wmb();
@@ -765,6 +766,12 @@ static void free_one_page(struct zone *zone,
 
 static int free_tail_pages_check(struct page *head_page, struct page *page)
 {
+	if (page->mapping != TAIL_MAPPING) {
+		bad_page(page, "corrupted mapping in tail page", 0);
+		page->mapping = NULL;
+		return 1;
+	}
+	page->mapping = NULL;
 	if (!IS_ENABLED(CONFIG_DEBUG_VM))
 		return 0;
 	if (unlikely(!PageTail(page))) {
diff --git a/mm/util.c b/mm/util.c
index d68339206100..769a7a2870af 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -357,7 +357,10 @@ EXPORT_SYMBOL(kvfree);
 
 struct address_space *page_mapping(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping;
+
+	page = compound_head(page);
+	mapping = page->mapping;
 
 	/* This happens if someone calls flush_dcache_page on slab page */
 	if (unlikely(PageSlab(page)))
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
