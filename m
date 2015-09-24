Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7D882F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:23 -0400 (EDT)
Received: by pacgz1 with SMTP id gz1so8606712pac.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:23 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id d10si18919416pas.77.2015.09.24.07.51.22
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:22 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 16/16] mm: sanitize page->mapping for tail pages
Date: Thu, 24 Sep 2015 17:51:04 +0300
Message-Id: <1443106264-78075-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't define meaning of page->mapping for tail pages.  Currently it's
always NULL, which can be inconsistent with head page and potentially lead
to problems.

Let's poison the pointer to catch all illigal uses.

page_rmapping(), page_mapping() and page_anon_vma() are changed to look on
head page.

The only illegal use I've caught so far is __GPF_COMP pages from sound
subsystem, mapped with PTEs.  do_shared_fault() is changed to use
page_rmapping() instead of direct access to fault_page->mapping.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/poison.h |  4 ++++
 mm/huge_memory.c       |  2 +-
 mm/memory.c            |  2 +-
 mm/page_alloc.c        |  6 ++++++
 mm/util.c              | 10 ++++++----
 5 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/linux/poison.h b/include/linux/poison.h
index 317e16de09e5..76c3b6c38c16 100644
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
index 244c852d565c..65ab7858bbcc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1836,7 +1836,7 @@ static void __split_huge_page_refcount(struct page *page,
 		*/
 		page_tail->_mapcount = page->_mapcount;
 
-		BUG_ON(page_tail->mapping);
+		BUG_ON(page_tail->mapping != TAIL_MAPPING);
 		page_tail->mapping = page->mapping;
 
 		page_tail->index = page->index + i;
diff --git a/mm/memory.c b/mm/memory.c
index caecc64301e9..3bd465a6fa0d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3087,7 +3087,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * pinned by vma->vm_file's reference.  We rely on unlock_page()'s
 	 * release semantics to prevent the compiler from undoing this copying.
 	 */
-	mapping = fault_page->mapping;
+	mapping = page_rmapping(fault_page);
 	unlock_page(fault_page);
 	if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
 		/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 321a91747949..9bcfd70b1eb8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -473,6 +473,7 @@ void prep_compound_page(struct page *page, unsigned int order)
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
 		set_page_count(p, 0);
+		p->mapping = TAIL_MAPPING;
 		set_compound_head(p, page);
 	}
 }
@@ -864,6 +865,10 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 		ret = 0;
 		goto out;
 	}
+	if (page->mapping != TAIL_MAPPING) {
+		bad_page(page, "corrupted mapping in tail page", 0);
+		goto out;
+	}
 	if (unlikely(!PageTail(page))) {
 		bad_page(page, "PageTail not set", 0);
 		goto out;
@@ -874,6 +879,7 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 	}
 	ret = 0;
 out:
+	page->mapping = NULL;
 	clear_compound_head(page);
 	return ret;
 }
diff --git a/mm/util.c b/mm/util.c
index 9af1c12b310c..902b65a43899 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -355,7 +355,9 @@ struct anon_vma *page_anon_vma(struct page *page)
 
 struct address_space *page_mapping(struct page *page)
 {
-	unsigned long mapping;
+	struct address_space *mapping;
+
+	page = compound_head(page);
 
 	/* This happens if someone calls flush_dcache_page on slab page */
 	if (unlikely(PageSlab(page)))
@@ -368,10 +370,10 @@ struct address_space *page_mapping(struct page *page)
 		return swap_address_space(entry);
 	}
 
-	mapping = (unsigned long)page->mapping;
-	if (mapping & PAGE_MAPPING_FLAGS)
+	mapping = page->mapping;
+	if ((unsigned long)mapping & PAGE_MAPPING_FLAGS)
 		return NULL;
-	return page->mapping;
+	return mapping;
 }
 
 int overcommit_ratio_handler(struct ctl_table *table, int write,
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
