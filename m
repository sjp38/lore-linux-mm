Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1D83A6B034C
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 17:46:17 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so8674235pad.21
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:46:16 -0700 (PDT)
Received: from psmtp.com ([74.125.245.104])
        by mx.google.com with SMTP id w1si10212782pan.199.2013.10.21.14.46.15
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 14:46:16 -0700 (PDT)
Received: by mail-pb0-f47.google.com with SMTP id rq13so704149pbb.6
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:46:14 -0700 (PDT)
Date: Mon, 21 Oct 2013 14:46:10 -0700
From: Ning Qu <quning@gmail.com>
Subject: [PATCHv2 01/13] mm, thp: extract the common code from
 add_to_page_cache_locked
Message-ID: <20131021214610.GB29870@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>, Ning Qu <quning@gmail.com>

Extract the common code from add_to_page_cache_locked so that
it could be shared by shmem file system.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 include/linux/pagemap.h |  2 ++
 mm/filemap.c            | 91 ++++++++++++++++++++++++++++++++-----------------
 2 files changed, 61 insertions(+), 32 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 8ce130f..1887255 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -548,6 +548,8 @@ static inline int fault_in_multipages_readable(const char __user *uaddr,
 	return ret;
 }
 
+int __add_to_page_cache_locked(struct page *page, struct address_space *mapping,
+				pgoff_t index);
 int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
diff --git a/mm/filemap.c b/mm/filemap.c
index 313df6d..998ee40 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -459,42 +459,22 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 EXPORT_SYMBOL_GPL(replace_page_cache_page);
 
 /**
- * add_to_page_cache_locked - add a locked page to the pagecache
+ * __add_to_page_cache_locked - add a locked page to the pagecache
  * @page:	page to add
  * @mapping:	the page's address_space
  * @offset:	page index
- * @gfp_mask:	page allocation mode
  *
- * This function is used to add a page to the pagecache. It must be locked.
- * This function does not add the page to the LRU.  The caller must do that.
+ * This function is the common code used for adding a page to the pagecache.
+ * mapping->tree_lock has to be held by caller.
  */
-int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
-		pgoff_t offset, gfp_t gfp_mask)
+int __add_to_page_cache_locked(struct page *page, struct address_space *mapping,
+		pgoff_t offset)
 {
-	int error;
+	int error = 0;
 	int i, nr;
 
-	VM_BUG_ON(!PageLocked(page));
-	VM_BUG_ON(PageSwapBacked(page));
-
-	/* memory cgroup controller handles thp pages on its side */
-	error = mem_cgroup_cache_charge(page, current->mm,
-					gfp_mask & GFP_RECLAIM_MASK);
-	if (error)
-		return error;
-
-	if (PageTransHugeCache(page))
-		BUILD_BUG_ON(HPAGE_CACHE_NR > RADIX_TREE_PRELOAD_NR);
-
 	nr = hpagecache_nr_pages(page);
 
-	error = radix_tree_maybe_preload_contig(nr, gfp_mask & ~__GFP_HIGHMEM);
-	if (error) {
-		mem_cgroup_uncharge_cache_page(page);
-		return error;
-	}
-
-	spin_lock_irq(&mapping->tree_lock);
 	page_cache_get(page);
 	page->index = offset;
 	page->mapping = mapping;
@@ -511,16 +491,14 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 			goto err_insert;
 		}
 	}
-	radix_tree_preload_end();
 	mapping->nrpages += nr;
 	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
 	if (PageTransHuge(page))
 		__inc_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);
-	spin_unlock_irq(&mapping->tree_lock);
-	trace_mm_filemap_add_to_page_cache(page);
+
 	return 0;
+
 err_insert:
-	radix_tree_preload_end();
 	if (i != 0)
 		error = -ENOSPC; /* no space for a huge page */
 
@@ -529,9 +507,58 @@ err_insert:
 	for (; i >= 0; i--)
 		radix_tree_delete(&mapping->page_tree, offset + i);
 
+	return error;
+}
+EXPORT_SYMBOL(__add_to_page_cache_locked);
+
+/**
+ * add_to_page_cache_locked - add a locked page to the pagecache
+ * @page:	page to add
+ * @mapping:	the page's address_space
+ * @offset:	page index
+ * @gfp_mask:	page allocation mode
+ *
+ * This function is used to add a page to the pagecache. It must be locked.
+ * This function does not add the page to the LRU.  The caller must do that.
+ */
+int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
+		pgoff_t offset, gfp_t gfp_mask)
+{
+	int error;
+
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(PageSwapBacked(page));
+
+	/* memory cgroup controller handles thp pages on its side */
+	error = mem_cgroup_cache_charge(page, current->mm,
+					gfp_mask & GFP_RECLAIM_MASK);
+	if (error)
+		return error;
+
+	if (PageTransHugeCache(page))
+		BUILD_BUG_ON(HPAGE_CACHE_NR > RADIX_TREE_PRELOAD_NR);
+
+	error = radix_tree_maybe_preload_contig(hpagecache_nr_pages(page),
+						gfp_mask & ~__GFP_HIGHMEM);
+	if (error) {
+		mem_cgroup_uncharge_cache_page(page);
+		return error;
+	}
+
+	spin_lock_irq(&mapping->tree_lock);
+
+	error = __add_to_page_cache_locked(page, mapping, offset);
+
+	radix_tree_preload_end();
 	spin_unlock_irq(&mapping->tree_lock);
-	mem_cgroup_uncharge_cache_page(page);
-	page_cache_release(page);
+
+	if (!error)
+		trace_mm_filemap_add_to_page_cache(page);
+	else {
+		mem_cgroup_uncharge_cache_page(page);
+		page_cache_release(page);
+	}
+
 	return error;
 }
 EXPORT_SYMBOL(add_to_page_cache_locked);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
