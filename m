Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id C12466B0038
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 17:40:29 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id p61so1371237wes.41
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 14:40:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id gr7si2762430wib.56.2014.03.13.14.40.26
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 14:40:28 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/6] mm/memory-failure.c: report and recovery for memory error on dirty pagecache
Date: Thu, 13 Mar 2014 17:39:42 -0400
Message-Id: <1394746786-6397-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org

This patch implements dirty pagecache error handling with a new pagecache
tag, which is set on the error address in pagecache of the affected file.

Before this patch, memory errors on dirty pagecache were reported only
insufficiently due to non-stickiness of AS_EIO which is cleared once checked.
As a result, the newest data on dirty page might be lost. This could happen
even if the applications are well written to handle the error report because
accesses to the error address can happen concurrently. In addition to
stickiness, the granularity of error containment is also problematic.
AS_EIO is mapping wide flag, so a whole file is tainted by a single error,
which is not desirable. These problems are solved with a new pagecache tag.

In pagecache tag approach, we have to allocate another page and link it
to pagecache tree at the error address in order to keep radix_tree_node
for the address on memory, which makes code complex. But it helps us to
introduce error recovery with full page overwrite (added in later patch.)

Unifying error reporting between memory error and normal IO errors is ideal
in a long run, but at first let's solve it separately. I hope that some code
in this patch will be helpful when thinking of the unification.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/fs.h         |   3 +
 include/linux/pagemap.h    |  11 +++
 include/linux/radix-tree.h |   4 ++
 mm/filemap.c               |  14 ++++
 mm/memory-failure.c        | 170 +++++++++++++++++++++++++++++++++++----------
 5 files changed, 167 insertions(+), 35 deletions(-)

diff --git v3.14-rc6.orig/include/linux/fs.h v3.14-rc6/include/linux/fs.h
index 60829565e552..1e8966919044 100644
--- v3.14-rc6.orig/include/linux/fs.h
+++ v3.14-rc6/include/linux/fs.h
@@ -475,6 +475,9 @@ struct block_device {
 #define PAGECACHE_TAG_DIRTY	0
 #define PAGECACHE_TAG_WRITEBACK	1
 #define PAGECACHE_TAG_TOWRITE	2
+#ifdef CONFIG_MEMORY_FAILURE
+#define PAGECACHE_TAG_HWPOISON	3
+#endif
 
 int mapping_tagged(struct address_space *mapping, int tag);
 
diff --git v3.14-rc6.orig/include/linux/pagemap.h v3.14-rc6/include/linux/pagemap.h
index 70adf09a4cfc..5e234d0d0baf 100644
--- v3.14-rc6.orig/include/linux/pagemap.h
+++ v3.14-rc6/include/linux/pagemap.h
@@ -586,4 +586,15 @@ static inline int add_to_page_cache(struct page *page,
 	return error;
 }
 
+#ifdef CONFIG_MEMORY_FAILURE
+bool mapping_hwpoisoned_range(struct address_space *mapping,
+				loff_t start_byte, loff_t end_byte);
+#else
+static inline bool mapping_hwpoisoned_range(struct address_space *mapping,
+				loff_t start_byte, loff_t end_byte)
+{
+	return false;
+}
+#endif /* CONFIG_MEMORY_FAILURE */
+
 #endif /* _LINUX_PAGEMAP_H */
diff --git v3.14-rc6.orig/include/linux/radix-tree.h v3.14-rc6/include/linux/radix-tree.h
index 6e14a8e06105..9bbc36eb5fc5 100644
--- v3.14-rc6.orig/include/linux/radix-tree.h
+++ v3.14-rc6/include/linux/radix-tree.h
@@ -58,7 +58,11 @@ static inline int radix_tree_is_indirect_ptr(void *ptr)
 
 /*** radix-tree API starts here ***/
 
+#ifdef CONFIG_MEMORY_FAILURE
+#define RADIX_TREE_MAX_TAGS 4
+#else
 #define RADIX_TREE_MAX_TAGS 3
+#endif
 
 /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
 struct radix_tree_root {
diff --git v3.14-rc6.orig/mm/filemap.c v3.14-rc6/mm/filemap.c
index 8c24eda539d8..887f2dfaf185 100644
--- v3.14-rc6.orig/mm/filemap.c
+++ v3.14-rc6/mm/filemap.c
@@ -285,6 +285,12 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 	if (end_byte < start_byte)
 		goto out;
 
+	if (unlikely(mapping_hwpoisoned_range(mapping, start_byte,
+					      end_byte + 1))) {
+		ret = -EHWPOISON;
+		goto out;
+	}
+
 	pagevec_init(&pvec, 0);
 	while ((index <= end) &&
 			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
@@ -1133,6 +1139,10 @@ static void do_generic_file_read(struct file *filp, loff_t *ppos,
 			if (unlikely(page == NULL))
 				goto no_cached_page;
 		}
+		if (unlikely(PageHWPoison(page))) {
+			error = -EHWPOISON;
+			goto readpage_error;
+		}
 		if (PageReadahead(page)) {
 			page_cache_async_readahead(mapping,
 					ra, filp, page,
@@ -2100,6 +2110,10 @@ inline int generic_write_checks(struct file *file, loff_t *pos, size_t *count, i
         if (unlikely(*pos < 0))
                 return -EINVAL;
 
+	if (unlikely(mapping_hwpoisoned_range(file->f_mapping, *pos,
+					      *pos + *count)))
+		return -EHWPOISON;
+
 	if (!isblk) {
 		/* FIXME: this is for backwards compatibility with 2.4 */
 		if (file->f_flags & O_APPEND)
diff --git v3.14-rc6.orig/mm/memory-failure.c v3.14-rc6/mm/memory-failure.c
index 1feeff9770cd..34f2c046af22 100644
--- v3.14-rc6.orig/mm/memory-failure.c
+++ v3.14-rc6/mm/memory-failure.c
@@ -55,6 +55,7 @@
 #include <linux/memory_hotplug.h>
 #include <linux/mm_inline.h>
 #include <linux/kfifo.h>
+#include <linux/pagevec.h>
 #include "internal.h"
 
 int sysctl_memory_failure_early_kill __read_mostly = 0;
@@ -611,55 +612,154 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 }
 
 /*
+ * Check PAGECACHE_TAG_HWPOISON within a given address range, and return
+ * true if we find at least one page with the tag set.
+ */
+bool mapping_hwpoisoned_range(struct address_space *mapping,
+				loff_t start_byte, loff_t end_byte)
+{
+	void **slot;
+	struct radix_tree_iter iter;
+	pgoff_t start_index;
+	pgoff_t end_index = 0;
+	bool hwpoisoned = false;
+	if (!sysctl_memory_failure_recovery)
+		return false;
+	start_index = start_byte >> PAGE_CACHE_SHIFT;
+	if (end_byte > 0)
+		end_index = (end_byte - 1) >> PAGE_CACHE_SHIFT;
+	rcu_read_lock();
+	radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter,
+			start_index, end_index, PAGECACHE_TAG_HWPOISON) {
+		hwpoisoned = true;
+		break;
+	}
+	rcu_read_unlock();
+	return hwpoisoned;
+}
+
+static bool get_pagecache_tag_hwpoison(struct address_space *mapping,
+					pgoff_t index)
+{
+	bool tag;
+	rcu_read_lock();
+	tag = radix_tree_tag_get(&mapping->page_tree, index,
+				 PAGECACHE_TAG_HWPOISON);
+	rcu_read_unlock();
+	return tag;
+}
+
+static void set_pagecache_tag_hwpoison(struct address_space *mapping,
+					pgoff_t idx)
+{
+	spin_lock_irq(&mapping->tree_lock);
+	radix_tree_tag_set(&mapping->page_tree, idx, PAGECACHE_TAG_HWPOISON);
+	spin_unlock_irq(&mapping->tree_lock);
+}
+
+static void clear_pagecache_tag_hwpoison(struct address_space *mapping,
+					pgoff_t idx)
+{
+	spin_lock_irq(&mapping->tree_lock);
+	radix_tree_tag_clear(&mapping->page_tree, idx, PAGECACHE_TAG_HWPOISON);
+	spin_unlock_irq(&mapping->tree_lock);
+}
+
+/*
  * Dirty pagecache page
+ *
+ * Memory error reporting (important especially on dirty pagecache error
+ * because dirty data is lost) with AS_EIO flag has some problems:
+ *  1) AS_EIO is not sticky, so when a thread received an error report and
+ *     failed to take proper actions with it, the error flag will be lost
+ *     and other threads read/write with old data from storage and use it
+ *     as if no memory error happens.
+ *  2) mapping->flags is file-wide information, while the memory error is an
+ *     event on a single page. So we lose the info about where in the file
+ *     was corrupted.
+ *  3) Even dirty pagecache error can be recoverable if there is a copy data
+ *     of the newest version in user processes' buffers, but with AS_EIO
+ *     we can't handle that case.
+ *
+ * To solve these, we handle dirty pagecache errors by replacing the error
+ * page with alternative one which has PAGECACHE_TAG_HWPOISON at the page
+ * index on mapping->page_tree set. Although setting PAGECACHE_TAG_HWPOISON
+ * is enough for its purpose, we also set PG_HWPoison for users to find the
+ * page easily (for example with tools/vm/page-types.c.) The page looks
+ * similar to a normal hwpoisoned page, but it's not isolated (connected to
+ * pagecache), or the memory at the physical address is not really corrupted.
+ *
+ * This quasi-hwpoisoned page works to keep reporting the error for all
+ * processes which try to access to the error address until it is resolved
+ * or the system reboots.
+ *
  * Issues: when the error hit a hole page the error is not properly
  * propagated.
  */
 static int me_pagecache_dirty(struct page *p, unsigned long pfn)
 {
+	int ret;
 	struct address_space *mapping = page_mapping(p);
+	pgoff_t index;
+	struct inode *inode = NULL;
+	struct page *new;
 
 	SetPageError(p);
-	/* TBD: print more information about the file. */
 	if (mapping) {
+		index = page_index(p);
+		/*
+		 * we take inode refcount to keep it's pagecache or mapping
+		 * on the memory until the error is resolved.
+		 */
+		inode = igrab(mapping->host);
+		pr_info("MCE %#lx: memory error on dirty pagecache (page offset:%lu, inode:%lu, dev:%s)\n",
+			page_to_pfn(p), index, inode->i_ino, inode->i_sb->s_id);
+	}
+
+	ret = me_pagecache_clean(p, pfn);
+
+	if (inode) {
+		/*
+		 * There's a potential race where some other thread can
+		 * allocate another page and add it at the error address of
+		 * the mapping, before the below code adds an alternative
+		 * (quasi-hwpoisoned) page. In such case, we detect it by
+		 * the failure of add_to_page_cache_lru(), and we give up
+		 * doing error containment (fallback to old the AS_EIO things).
+		 */
+		new = page_cache_alloc_cold(mapping);
+		if (!new)
+			goto out_iput;
+		ret = add_to_page_cache_lru(new, mapping, page_index(p),
+					    GFP_KERNEL);
+		if (ret)
+			goto out_put_page;
 		/*
-		 * IO error will be reported by write(), fsync(), etc.
-		 * who check the mapping.
-		 * This way the application knows that something went
-		 * wrong with its dirty file data.
-		 *
-		 * There's one open issue:
-		 *
-		 * The EIO will be only reported on the next IO
-		 * operation and then cleared through the IO map.
-		 * Normally Linux has two mechanisms to pass IO error
-		 * first through the AS_EIO flag in the address space
-		 * and then through the PageError flag in the page.
-		 * Since we drop pages on memory failure handling the
-		 * only mechanism open to use is through AS_AIO.
-		 *
-		 * This has the disadvantage that it gets cleared on
-		 * the first operation that returns an error, while
-		 * the PageError bit is more sticky and only cleared
-		 * when the page is reread or dropped.  If an
-		 * application assumes it will always get error on
-		 * fsync, but does other operations on the fd before
-		 * and the page is dropped between then the error
-		 * will not be properly reported.
-		 *
-		 * This can already happen even without hwpoisoned
-		 * pages: first on metadata IO errors (which only
-		 * report through AS_EIO) or when the page is dropped
-		 * at the wrong time.
-		 *
-		 * So right now we assume that the application DTRT on
-		 * the first EIO, but we're not worse than other parts
-		 * of the kernel.
+		 * Newly allocated page can remain on pagevec, so without
+		 * draining it subsequent isolation doesn't work.
 		 */
-		mapping_set_error(mapping, EIO);
+		lru_add_drain_all();
+		if (isolate_lru_page(new))
+			goto out;
+		inc_zone_page_state(new, NR_ISOLATED_ANON +
+				    page_is_file_cache(new));
+		SetPageHWPoison(new);
+		page_cache_release(new);
+		set_pagecache_tag_hwpoison(mapping, page_index(p));
+		unlock_page(new);
+		ret = RECOVERED;
 	}
+	return ret;
 
-	return me_pagecache_clean(p, pfn);
+out:
+	delete_from_page_cache(new);
+	unlock_page(new);
+out_put_page:
+	page_cache_release(new);
+out_iput:
+	iput(mapping->host);
+	mapping_set_error(mapping, EIO);
+	return FAILED;
 }
 
 /*
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
