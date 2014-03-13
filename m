Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
	by kanga.kvack.org (Postfix) with ESMTP id E01FC6B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 18:24:47 -0400 (EDT)
Received: by mail-ea0-f175.google.com with SMTP id d10so752439eaj.6
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 15:24:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z42si200856eel.302.2014.03.13.15.24.44
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 15:24:45 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/6] mm/memory-failure.c: add code to resolve quasi-hwpoisoned page
Date: Thu, 13 Mar 2014 17:39:43 -0400
Message-Id: <1394746786-6397-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org

This patch introduces three ways to resolve quasi-hwpoisoned pages:
 1. unpoison: this is a test feature, but if users accept data lost (then
    continue with rereading old data from storage,) this could be tolerable.
 2. truncate: if discarding a part of a file which includes a memory error
    is OK for your applications, this could be reasonable too.
 3. full page overwrite: if your application is prepared to dirty pagecache
    error and it has a copy data (or it can recreate the proper data,)
    the application can overwrite the page-sized address range on the error
    and continue to run without caring about the error.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/pagemap.h | 16 +++++++++++++
 mm/filemap.c            | 14 ++++++++---
 mm/memory-failure.c     | 62 ++++++++++++++++++++++++++++++++++++++++++++++++-
 mm/truncate.c           |  7 ++++++
 4 files changed, 95 insertions(+), 4 deletions(-)

diff --git v3.14-rc6.orig/include/linux/pagemap.h v3.14-rc6/include/linux/pagemap.h
index 5e234d0d0baf..715962f7ea7a 100644
--- v3.14-rc6.orig/include/linux/pagemap.h
+++ v3.14-rc6/include/linux/pagemap.h
@@ -589,12 +589,28 @@ static inline int add_to_page_cache(struct page *page,
 #ifdef CONFIG_MEMORY_FAILURE
 bool mapping_hwpoisoned_range(struct address_space *mapping,
 				loff_t start_byte, loff_t end_byte);
+bool page_quasi_hwpoisoned(struct address_space *mapping, struct page *page);
+void hwpoison_resolve_pagecache_error(struct address_space *mapping,
+				struct page *page, bool free);
+bool hwpoison_partial_overwrite(struct address_space *mapping,
+				loff_t pos, size_t count);
 #else
 static inline bool mapping_hwpoisoned_range(struct address_space *mapping,
 				loff_t start_byte, loff_t end_byte)
 {
 	return false;
 }
+static inline bool page_quasi_hwpoisoned(struct address_space *mapping,
+					struct page *page)
+{
+	return false;
+}
+#define hwpoison_resolve_pagecache_error(mapping, page, free) do {} while (0)
+static inline bool hwpoison_partial_overwrite(struct address_space *mapping,
+				loff_t pos, size_t count)
+{
+	return false;
+}
 #endif /* CONFIG_MEMORY_FAILURE */
 
 #endif /* _LINUX_PAGEMAP_H */
diff --git v3.14-rc6.orig/mm/filemap.c v3.14-rc6/mm/filemap.c
index 887f2dfaf185..f58b36e313ad 100644
--- v3.14-rc6.orig/mm/filemap.c
+++ v3.14-rc6/mm/filemap.c
@@ -2110,8 +2110,7 @@ inline int generic_write_checks(struct file *file, loff_t *pos, size_t *count, i
         if (unlikely(*pos < 0))
                 return -EINVAL;
 
-	if (unlikely(mapping_hwpoisoned_range(file->f_mapping, *pos,
-					      *pos + *count)))
+	if (unlikely(hwpoison_partial_overwrite(file->f_mapping, *pos, *count)))
 		return -EHWPOISON;
 
 	if (!isblk) {
@@ -2222,7 +2221,13 @@ generic_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	end = (pos + write_len - 1) >> PAGE_CACHE_SHIFT;
 
 	written = filemap_write_and_wait_range(mapping, pos, pos + write_len - 1);
-	if (written)
+	/*
+	 * When the write range includes hwpoisoned region (then written is
+	 * -EHWPOISON,) we already confirmed in generic_write_checks() that
+	 * it's full page overwrite and we can safely invalidate the error,
+	 * so the write doesn't have to fail.
+	 */
+	if (written && written != -EHWPOISON)
 		goto out;
 
 	/*
@@ -2362,6 +2367,9 @@ static ssize_t generic_perform_write(struct file *file,
 		if (mapping_writably_mapped(mapping))
 			flush_dcache_page(page);
 
+		if (page_quasi_hwpoisoned(mapping, page))
+			hwpoison_resolve_pagecache_error(mapping, page, false);
+
 		pagefault_disable();
 		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
 		pagefault_enable();
diff --git v3.14-rc6.orig/mm/memory-failure.c v3.14-rc6/mm/memory-failure.c
index 34f2c046af22..0eca5449d251 100644
--- v3.14-rc6.orig/mm/memory-failure.c
+++ v3.14-rc6/mm/memory-failure.c
@@ -665,6 +665,57 @@ static void clear_pagecache_tag_hwpoison(struct address_space *mapping,
 	spin_unlock_irq(&mapping->tree_lock);
 }
 
+inline bool page_quasi_hwpoisoned(struct address_space *mapping,
+					struct page *page)
+{
+	if (!sysctl_memory_failure_recovery)
+		return false;
+	return unlikely(get_pagecache_tag_hwpoison(mapping, page_index(page)));
+}
+
+/*
+ * This function clears a quasi-hwpoisoned page and turns it into a normal
+ * LRU page. Callers should check that @page is really quasi-hwpoisoned,
+ * and must not call this for real error pages.
+ */
+void hwpoison_resolve_pagecache_error(struct address_space *mapping,
+				      struct page *page, bool free)
+{
+	VM_BUG_ON(PageLRU(page));
+	VM_BUG_ON(!PageLocked(page));
+
+	ClearPageHWPoison(page);
+	clear_pagecache_tag_hwpoison(mapping, page_index(page));
+	dec_zone_page_state(page, NR_ISOLATED_ANON + page_is_file_cache(page));
+	putback_lru_page(page);
+	if (free) {
+		lru_add_drain_all();
+		delete_from_page_cache(page);
+	}
+	iput(mapping->host);
+}
+
+/*
+ * Return true if a given range [pos, pos+count) *partially* overlaps with
+ * hwpoisoned page. Effectively it checks only boundary pages' overlapness.
+ */
+bool hwpoison_partial_overwrite(struct address_space *mapping,
+				loff_t pos, size_t count)
+{
+	if (!sysctl_memory_failure_recovery)
+		return false;
+	if (!mapping_hwpoisoned_range(mapping, pos, pos + count))
+		return false;
+
+	if (!PAGE_ALIGNED(pos) &&
+	    get_pagecache_tag_hwpoison(mapping, pos >> PAGE_SHIFT))
+		return true;
+	if (!PAGE_ALIGNED(pos + count) &&
+	    get_pagecache_tag_hwpoison(mapping, (pos + count) >> PAGE_SHIFT))
+		return true;
+	return false;
+}
+
 /*
  * Dirty pagecache page
  *
@@ -691,7 +742,10 @@ static void clear_pagecache_tag_hwpoison(struct address_space *mapping,
  *
  * This quasi-hwpoisoned page works to keep reporting the error for all
  * processes which try to access to the error address until it is resolved
- * or the system reboots.
+ * or the system reboots. Quasi-hwpoisoned pages can be resolved by unpoison,
+ * truncate, and full page overwrite. In full page overwrite, the quasi-
+ * hwpoisoned pages safely turn into the normal LRU pages, so we expect
+ * userspace to do this when they received the error report if possible.
  *
  * Issues: when the error hit a hole page the error is not properly
  * propagated.
@@ -1496,12 +1550,18 @@ int unpoison_memory(unsigned long pfn)
 	 * the free buddy page pool.
 	 */
 	if (TestClearPageHWPoison(page)) {
+		struct address_space *mapping = page_mapping(page);
+		if (mapping && page_quasi_hwpoisoned(mapping, page)) {
+			hwpoison_resolve_pagecache_error(mapping, page, true);
+			goto unlock;
+		}
 		pr_info("MCE: Software-unpoisoned page %#lx\n", pfn);
 		atomic_long_sub(nr_pages, &num_poisoned_pages);
 		freeit = 1;
 		if (PageHuge(page))
 			clear_page_hwpoison_huge_page(page);
 	}
+unlock:
 	unlock_page(page);
 
 	put_page(page);
diff --git v3.14-rc6.orig/mm/truncate.c v3.14-rc6/mm/truncate.c
index 353b683afd6e..92d7097dfc6d 100644
--- v3.14-rc6.orig/mm/truncate.c
+++ v3.14-rc6/mm/truncate.c
@@ -103,6 +103,10 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
 	ClearPageMappedToDisk(page);
+
+	if (page_quasi_hwpoisoned(mapping, page))
+		hwpoison_resolve_pagecache_error(mapping, page, false);
+
 	delete_from_page_cache(page);
 	return 0;
 }
@@ -439,6 +443,9 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	if (page_has_private(page) && !try_to_release_page(page, GFP_KERNEL))
 		return 0;
 
+	if (page_quasi_hwpoisoned(mapping, page))
+		hwpoison_resolve_pagecache_error(mapping, page, false);
+
 	spin_lock_irq(&mapping->tree_lock);
 	if (PageDirty(page))
 		goto failed;
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
