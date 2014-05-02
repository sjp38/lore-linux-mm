Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD166B005A
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:53:12 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id j107so4764250qga.14
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:11 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id i96si14180244qge.103.2014.05.02.06.53.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:53:11 -0700 (PDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so292324qgd.15
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:11 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 08/11] hmm: support for migrate file backed pages to remote memory
Date: Fri,  2 May 2014 09:52:07 -0400
Message-Id: <1399038730-25641-9-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Motivation:

Same as for migrating anonymous private memory ie device local memory has
higher bandwidth and lower latency.

Implementation:

Migrated range are tracked exactly as private anonymous memory refer to
the commit adding support for migrating private anonymous memory.

Migrating file backed page is more complex than private anonymous memory
as those pages might be involved in various filesystem event from write
back to splice or truncation.

This patchset use a special hmm swap value that it store inside the radix
tree for page that are migrated to remote memory. Any code that need to do
radix tree lookup is updated to understand those special hmm swap entry
and to call hmm helper function to perform the appropriate operation.

For most operations (file read, splice, truncate, ...) the end result is
simply to migrate back to local memory. It is expected that user of hmm
will do not perform such operation on file back memory that was migrated
to remote memory.

Write back is different as we preserve the capabilities of doing dirtied
memory write back from remote memory (using local system memory as a bounce
buffer).

Each filesystem code must be modified to support hmm. This patchset only
modify common helper code and add the core set of helpers needed for this
feature.

Issues:

The big issue here is how to handle failure to migrate the remote memory back
to local memory. Should all the process trying further access to the file get
SIGBUS ? Should only the process that migrated memory to remote memory get
SIGBUS ? ...

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 fs/aio.c             |    9 +
 fs/buffer.c          |    3 +
 fs/splice.c          |   38 +-
 include/linux/fs.h   |    4 +
 include/linux/hmm.h  |   72 +++-
 include/linux/rmap.h |    1 +
 mm/filemap.c         |   99 ++++-
 mm/hmm.c             | 1094 ++++++++++++++++++++++++++++++++++++++++++++++++--
 mm/madvise.c         |    4 +
 mm/mincore.c         |   11 +
 mm/page-writeback.c  |  131 ++++--
 mm/rmap.c            |   17 +-
 mm/swap.c            |    9 +
 mm/truncate.c        |  103 ++++-
 14 files changed, 1524 insertions(+), 71 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 0bf693f..0ec9f16 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -40,6 +40,7 @@
 #include <linux/ramfs.h>
 #include <linux/percpu-refcount.h>
 #include <linux/mount.h>
+#include <linux/hmm.h>
 
 #include <asm/kmap_types.h>
 #include <asm/uaccess.h>
@@ -405,10 +406,18 @@ static int aio_setup_ring(struct kioctx *ctx)
 
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page;
+
+	repeat:
 		page = find_or_create_page(file->f_inode->i_mapping,
 					   i, GFP_HIGHUSER | __GFP_ZERO);
 		if (!page)
 			break;
+		if (radix_tree_exceptional_entry(page)) {
+			swp_entry_t swap = radix_to_swp_entry(page);
+
+			hmm_pagecache_migrate(file->f_inode->i_mapping, swap);
+			goto repeat;
+		}
 		pr_debug("pid(%d) page[%d]->count=%d\n",
 			 current->pid, i, page_count(page));
 		SetPageUptodate(page);
diff --git a/fs/buffer.c b/fs/buffer.c
index e33f8d5..2be2a04 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -40,6 +40,7 @@
 #include <linux/cpu.h>
 #include <linux/bitops.h>
 #include <linux/mpage.h>
+#include <linux/hmm.h>
 #include <linux/bit_spinlock.h>
 #include <trace/events/block.h>
 
@@ -1023,6 +1024,8 @@ grow_dev_page(struct block_device *bdev, sector_t block,
 	if (!page)
 		return ret;
 
+	/* This can not happen ! */
+	BUG_ON(radix_tree_exceptional_entry(page));
 	BUG_ON(!PageLocked(page));
 
 	if (page_has_buffers(page)) {
diff --git a/fs/splice.c b/fs/splice.c
index 9dc23de..175f80c 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -33,6 +33,7 @@
 #include <linux/socket.h>
 #include <linux/compat.h>
 #include <linux/aio.h>
+#include <linux/hmm.h>
 #include "internal.h"
 
 /*
@@ -334,6 +335,20 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 	 * Lookup the (hopefully) full range of pages we need.
 	 */
 	spd.nr_pages = find_get_pages_contig(mapping, index, nr_pages, spd.pages);
+	/* Handle hmm entry, ie migrate remote memory back to local memory. */
+	for (page_nr = 0; page_nr < spd.nr_pages;) {
+		page = spd.pages[page_nr];
+		if (radix_tree_exceptional_entry(page)) {
+			swp_entry_t swap = radix_to_swp_entry(page);
+
+			/* FIXME How to handle hmm migration failure ? */
+			hmm_pagecache_migrate(mapping, swap);
+			spd.pages[page_nr] = find_get_page(mapping, index + page_nr);
+			continue;
+		} else {
+			page_nr++;
+		}
+	}
 	index += spd.nr_pages;
 
 	/*
@@ -351,6 +366,14 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 		 * the first hole.
 		 */
 		page = find_get_page(mapping, index);
+
+		if (radix_tree_exceptional_entry(page)) {
+			swp_entry_t swap = radix_to_swp_entry(page);
+
+			/* FIXME How to handle hmm migration failure ? */
+			hmm_pagecache_migrate(mapping, swap);
+			continue;
+		}
 		if (!page) {
 			/*
 			 * page didn't exist, allocate one.
@@ -373,7 +396,6 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 			 */
 			unlock_page(page);
 		}
-
 		spd.pages[spd.nr_pages++] = page;
 		index++;
 	}
@@ -415,6 +437,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 			 */
 			if (!page->mapping) {
 				unlock_page(page);
+retry:
 				page = find_or_create_page(mapping, index,
 						mapping_gfp_mask(mapping));
 
@@ -422,8 +445,17 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 					error = -ENOMEM;
 					break;
 				}
-				page_cache_release(spd.pages[page_nr]);
-				spd.pages[page_nr] = page;
+				/* At this point it can not be an exceptional hmm entry. */
+				if (radix_tree_exceptional_entry(page)) {
+					swp_entry_t swap = radix_to_swp_entry(page);
+
+					/* FIXME How to handle hmm migration failure ? */
+					hmm_pagecache_migrate(mapping, swap);
+					goto retry;
+				} else {
+					page_cache_release(spd.pages[page_nr]);
+					spd.pages[page_nr] = page;
+				}
 			}
 			/*
 			 * page was already under io and is now done, great
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 4e92d55..149a73e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -366,8 +366,12 @@ struct address_space_operations {
 	int (*swap_activate)(struct swap_info_struct *sis, struct file *file,
 				sector_t *span);
 	void (*swap_deactivate)(struct file *file);
+
+	int features;
 };
 
+#define AOPS_FEATURE_HMM	(1 << 0)
+
 extern const struct address_space_operations empty_aops;
 
 /*
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 96f41c4..9d232c1 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -53,7 +53,6 @@
 #include <linux/swapops.h>
 #include <linux/mman.h>
 
-
 struct hmm_device;
 struct hmm_device_ops;
 struct hmm_mirror;
@@ -75,6 +74,14 @@ struct hmm;
  *   HMM_PFN_LOCK is only set while the rmem object is under going migration.
  *   HMM_PFN_LMEM_UPTODATE the page that is in the rmem pfn array has uptodate.
  *   HMM_PFN_RMEM_UPTODATE the rmem copy of the page is uptodate.
+ *   HMM_PFN_FILE is set for page part of pagecache.
+ *   HMM_PFN_WRITEBACK is set when page is under going writeback, this means
+ *     that the page is lock and all device mapping to rmem for this page are
+ *     set to read only. It will only be clear if device do write fault on the
+ *     page or on migration back to lmem.
+ *   HMM_PFN_FS_WRITEABLE the rmem can be written to without calling mkwrite.
+ *     This is for hmm internal use only to know if hmm needs to call the fs
+ *     mkwrite callback or not.
  *
  * Device driver only need to worry about :
  *   HMM_PFN_VALID_PAGE
@@ -95,6 +102,9 @@ struct hmm;
 #define HMM_PFN_LOCK		(4UL)
 #define HMM_PFN_LMEM_UPTODATE	(5UL)
 #define HMM_PFN_RMEM_UPTODATE	(6UL)
+#define HMM_PFN_FILE		(7UL)
+#define HMM_PFN_WRITEBACK	(8UL)
+#define HMM_PFN_FS_WRITEABLE	(9UL)
 
 static inline struct page *hmm_pfn_to_page(unsigned long pfn)
 {
@@ -170,6 +180,7 @@ enum hmm_etype {
 	HMM_UNMAP,
 	HMM_MIGRATE_TO_LMEM,
 	HMM_MIGRATE_TO_RMEM,
+	HMM_WRITEBACK,
 };
 
 struct hmm_fence {
@@ -628,6 +639,7 @@ struct hmm_device *hmm_device_unref(struct hmm_device *device);
  *
  * @kref:           Reference count.
  * @device:         The hmm device the remote memory is allocated on.
+ * @mapping:        If rmem backing shared mapping.
  * @event:          The event currently associated with the rmem.
  * @lock:           Lock protecting the ranges list and event field.
  * @ranges:         The list of address ranges that point to this rmem.
@@ -646,6 +658,7 @@ struct hmm_device *hmm_device_unref(struct hmm_device *device);
 struct hmm_rmem {
 	struct kref		kref;
 	struct hmm_device	*device;
+	struct address_space	*mapping;
 	struct hmm_event	*event;
 	spinlock_t		lock;
 	struct list_head	ranges;
@@ -913,6 +926,42 @@ int hmm_mm_fault(struct mm_struct *mm,
 		 unsigned int fault_flags,
 		 pte_t orig_pte);
 
+/* hmm_pagecache_migrate - migrate remote memory to local memory.
+ *
+ * @mapping:    The address space into which the rmem was found.
+ * @swap:       The hmm special swap entry that needs to be migrated.
+ *
+ * When the fs code need to migrate remote memory to local memory it calls this
+ * function. From caller point of view this function can not fail. If it does
+ * then it will trigger SIGBUS if process that were using rmem try accessing
+ * the failed migration page. Other process will just get that lastest content
+ * we had for the page. Hence from pagecache point of view it never fails.
+ */
+void hmm_pagecache_migrate(struct address_space *mapping,
+			   swp_entry_t swap);
+
+/* hmm_pagecache_writeback - temporaty copy of rmem for writeback.
+ *
+ * @mapping:    The address space into which the rmem was found.
+ * @swap:       The hmm special swap entry that needs temporary copy.
+ * Return:      Page pointer or NULL on failure.
+ *
+ * When the fs code need to writeback remote memory to backing storage it calls
+ * this function. The function return pointer to temporary page into which the
+ * lastest copy of the remote memory is. The remote memory will be mark as read
+ * only for the duration of the writeback.
+ *
+ * On failure this will return NULL and will poison any mapping of the process
+ * that was responsible for the remote memory thus triggering a SIGBUS for this
+ * process. It will as well kill the mirror that was using this remote memory.
+ *
+ * When NULL is returned the caller should perform a new radix tree lookup.
+ */
+struct page *hmm_pagecache_writeback(struct address_space *mapping,
+				     swp_entry_t swap);
+struct page *hmm_pagecache_page(struct address_space *mapping,
+				swp_entry_t swap);
+
 #else /* !CONFIG_HMM */
 
 static inline void hmm_destroy(struct mm_struct *mm)
@@ -930,6 +979,27 @@ static inline int hmm_mm_fault(struct mm_struct *mm,
 	return VM_FAULT_SIGBUS;
 }
 
+static inline void hmm_pagecache_migrate(struct address_space *mapping,
+					 swp_entry_t swap)
+{
+	/* This can not happen ! */
+	BUG();
+}
+
+static inline struct page *hmm_pagecache_writeback(struct address_space *mapping,
+						   swp_entry_t swap)
+{
+	BUG();
+	return NULL;
+}
+
+static inline struct page *hmm_pagecache_page(struct address_space *mapping,
+					      swp_entry_t swap)
+{
+	BUG();
+	return NULL;
+}
+
 #endif /* !CONFIG_HMM */
 
 #endif
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 575851f..0641ccf 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -76,6 +76,7 @@ enum ttu_flags {
 	TTU_POISON = 1,			/* unmap mode */
 	TTU_MIGRATION = 2,		/* migration mode */
 	TTU_MUNLOCK = 3,		/* munlock mode */
+	TTU_HMM = 4,			/* hmm mode */
 	TTU_ACTION_MASK = 0xff,
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
diff --git a/mm/filemap.c b/mm/filemap.c
index 067c3c0..686f46b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -34,6 +34,7 @@
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
 #include <linux/rmap.h>
+#include <linux/hmm.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -343,6 +344,7 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 {
 	pgoff_t index = start_byte >> PAGE_CACHE_SHIFT;
 	pgoff_t end = end_byte >> PAGE_CACHE_SHIFT;
+	pgoff_t last_index = index;
 	struct pagevec pvec;
 	int nr_pages;
 	int ret2, ret = 0;
@@ -360,6 +362,19 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				/* FIXME How to handle hmm migration failure ? */
+				hmm_pagecache_migrate(mapping, swap);
+				pvec.pages[i] = NULL;
+				/* Force to examine the range again in case the
+				 * the migration triggered page writeback.
+				 */
+				index = last_index;
+				continue;
+			}
+
 			/* until radix tree lookup accepts end_index */
 			if (page->index > end)
 				continue;
@@ -369,6 +384,7 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 				ret = -EIO;
 		}
 		pagevec_release(&pvec);
+		last_index = index;
 		cond_resched();
 	}
 out:
@@ -987,14 +1003,21 @@ EXPORT_SYMBOL(find_get_entry);
  * Looks up the page cache slot at @mapping & @offset.  If there is a
  * page cache page, it is returned with an increased refcount.
  *
+ * Note that this will also return hmm special entry.
+ *
  * Otherwise, %NULL is returned.
  */
 struct page *find_get_page(struct address_space *mapping, pgoff_t offset)
 {
 	struct page *page = find_get_entry(mapping, offset);
 
-	if (radix_tree_exceptional_entry(page))
-		page = NULL;
+	if (radix_tree_exceptional_entry(page)) {
+		swp_entry_t swap = radix_to_swp_entry(page);
+
+		if (!is_hmm_entry(swap)) {
+			page = NULL;
+		}
+	}
 	return page;
 }
 EXPORT_SYMBOL(find_get_page);
@@ -1044,6 +1067,8 @@ EXPORT_SYMBOL(find_lock_entry);
  * page cache page, it is returned locked and with an increased
  * refcount.
  *
+ * Note that this will also return hmm special entry.
+ *
  * Otherwise, %NULL is returned.
  *
  * find_lock_page() may sleep.
@@ -1052,8 +1077,13 @@ struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
 {
 	struct page *page = find_lock_entry(mapping, offset);
 
-	if (radix_tree_exceptional_entry(page))
-		page = NULL;
+	if (radix_tree_exceptional_entry(page)) {
+		swp_entry_t swap = radix_to_swp_entry(page);
+
+		if (!is_hmm_entry(swap)) {
+			page = NULL;
+		}
+	}
 	return page;
 }
 EXPORT_SYMBOL(find_lock_page);
@@ -1222,6 +1252,12 @@ repeat:
 				WARN_ON(iter.index);
 				goto restart;
 			}
+			if (is_hmm_entry(radix_to_swp_entry(page))) {
+				/* This is hmm special entry, page have been
+				 * migrated to some device memory.
+				 */
+				goto export;
+			}
 			/*
 			 * A shadow entry of a recently evicted page,
 			 * or a swap entry from shmem/tmpfs.  Skip
@@ -1239,6 +1275,7 @@ repeat:
 			goto repeat;
 		}
 
+export:
 		pages[ret] = page;
 		if (++ret == nr_pages)
 			break;
@@ -1289,6 +1326,12 @@ repeat:
 				 */
 				goto restart;
 			}
+			if (is_hmm_entry(radix_to_swp_entry(page))) {
+				/* This is hmm special entry, page have been
+				 * migrated to some device memory.
+				 */
+				goto export;
+			}
 			/*
 			 * A shadow entry of a recently evicted page,
 			 * or a swap entry from shmem/tmpfs.  Stop
@@ -1316,6 +1359,7 @@ repeat:
 			break;
 		}
 
+export:
 		pages[ret] = page;
 		if (++ret == nr_pages)
 			break;
@@ -1342,6 +1386,7 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 	struct radix_tree_iter iter;
 	void **slot;
 	unsigned ret = 0;
+	pgoff_t index_last = *index;
 
 	if (unlikely(!nr_pages))
 		return 0;
@@ -1365,6 +1410,12 @@ repeat:
 				 */
 				goto restart;
 			}
+			if (is_hmm_entry(radix_to_swp_entry(page))) {
+				/* This is hmm special entry, page have been
+				 * migrated to some device memory.
+				 */
+				goto export;
+			}
 			/*
 			 * A shadow entry of a recently evicted page.
 			 *
@@ -1388,6 +1439,8 @@ repeat:
 			goto repeat;
 		}
 
+export:
+		index_last = iter.index;
 		pages[ret] = page;
 		if (++ret == nr_pages)
 			break;
@@ -1396,7 +1449,7 @@ repeat:
 	rcu_read_unlock();
 
 	if (ret)
-		*index = pages[ret - 1]->index + 1;
+		*index = index_last + 1;
 
 	return ret;
 }
@@ -1420,6 +1473,13 @@ grab_cache_page_nowait(struct address_space *mapping, pgoff_t index)
 {
 	struct page *page = find_get_page(mapping, index);
 
+	if (radix_tree_exceptional_entry(page)) {
+		/* Only happen is page is migrated to remote memory and the
+		 * fs code knows how to handle the case thus it is safe to
+		 * return the special entry.
+		 */
+		return page;
+	}
 	if (page) {
 		if (trylock_page(page))
 			return page;
@@ -1497,6 +1557,13 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 		cond_resched();
 find_page:
 		page = find_get_page(mapping, index);
+		if (radix_tree_exceptional_entry(page)) {
+			swp_entry_t swap = radix_to_swp_entry(page);
+
+			/* FIXME How to handle hmm migration failure ? */
+			hmm_pagecache_migrate(mapping, swap);
+			goto find_page;
+		}
 		if (!page) {
 			page_cache_sync_readahead(mapping,
 					ra, filp,
@@ -1879,7 +1946,15 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	/*
 	 * Do we have something in the page cache already?
 	 */
+find_page:
 	page = find_get_page(mapping, offset);
+	if (radix_tree_exceptional_entry(page)) {
+		swp_entry_t swap = radix_to_swp_entry(page);
+
+		/* FIXME How to handle hmm migration failure ? */
+		hmm_pagecache_migrate(mapping, swap);
+		goto find_page;
+	}
 	if (likely(page) && !(vmf->flags & FAULT_FLAG_TRIED)) {
 		/*
 		 * We found the page, so try async readahead before
@@ -2145,6 +2220,13 @@ static struct page *__read_cache_page(struct address_space *mapping,
 	int err;
 repeat:
 	page = find_get_page(mapping, index);
+	if (radix_tree_exceptional_entry(page)) {
+		swp_entry_t swap = radix_to_swp_entry(page);
+
+		/* FIXME How to handle hmm migration failure ? */
+		hmm_pagecache_migrate(mapping, swap);
+		goto repeat;
+	}
 	if (!page) {
 		page = __page_cache_alloc(gfp | __GFP_COLD);
 		if (!page)
@@ -2442,6 +2524,13 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 		gfp_notmask = __GFP_FS;
 repeat:
 	page = find_lock_page(mapping, index);
+	if (radix_tree_exceptional_entry(page)) {
+		swp_entry_t swap = radix_to_swp_entry(page);
+
+		/* FIXME How to handle hmm migration failure ? */
+		hmm_pagecache_migrate(mapping, swap);
+		goto repeat;
+	}
 	if (page)
 		goto found;
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 599d4f6..0d97762 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -61,6 +61,7 @@
 #include <linux/wait.h>
 #include <linux/interval_tree_generic.h>
 #include <linux/mman.h>
+#include <linux/buffer_head.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 #include <linux/delay.h>
@@ -656,6 +657,7 @@ static void hmm_rmem_init(struct hmm_rmem *rmem,
 {
 	kref_init(&rmem->kref);
 	rmem->device = device;
+	rmem->mapping = NULL;
 	rmem->fuid = 0;
 	rmem->luid = 0;
 	rmem->pfns = NULL;
@@ -923,9 +925,13 @@ static void hmm_rmem_clear_range(struct hmm_rmem *rmem,
 			sync_mm_rss(vma->vm_mm);
 		}
 
-		/* Properly uncharge memory. */
-		mem_cgroup_uncharge_mm(vma->vm_mm);
-		add_mm_counter(vma->vm_mm, MM_ANONPAGES, -1);
+		if (!test_bit(HMM_PFN_FILE, &rmem->pfns[idx])) {
+			/* Properly uncharge memory. */
+			mem_cgroup_uncharge_mm(vma->vm_mm);
+			add_mm_counter(vma->vm_mm, MM_ANONPAGES, -1);
+		} else {
+			add_mm_counter(vma->vm_mm, MM_FILEPAGES, -1);
+		}
 	}
 }
 
@@ -1064,8 +1070,10 @@ static int hmm_rmem_remap_page(struct hmm_rmem_mm *rmem_mm,
 			pte = pte_mkdirty(pte);
 		}
 		get_page(page);
-		/* Private anonymous page. */
-		page_add_anon_rmap(page, vma, addr);
+		if (!test_bit(HMM_PFN_FILE, &rmem->pfns[idx])) {
+			/* Private anonymous page. */
+			page_add_anon_rmap(page, vma, addr);
+		}
 		/* FIXME is this necessary ? I do not think so. */
 		if (!reuse_swap_page(page)) {
 			/* Page is still mapped in another process. */
@@ -1149,6 +1157,87 @@ static int hmm_rmem_remap_anon(struct hmm_rmem *rmem,
 	return ret;
 }
 
+static void hmm_rmem_remap_file_single_page(struct hmm_rmem *rmem,
+					    struct page *page)
+{
+	struct address_space *mapping = rmem->mapping;
+	void **slotp;
+
+	list_del_init(&page->lru);
+	spin_lock_irq(&mapping->tree_lock);
+	slotp = radix_tree_lookup_slot(&mapping->page_tree, page->index);
+	if (slotp) {
+		radix_tree_replace_slot(slotp, page);
+		get_page(page);
+	} else {
+		/* This should never happen. */
+		WARN_ONCE(1, "hmm: null slot while remapping !\n");
+	}
+	spin_unlock_irq(&mapping->tree_lock);
+
+	page->mapping = mapping;
+	unlock_page(page);
+	/* To balance putback_lru_page and isolate_lru_page. */
+	get_page(page);
+	putback_lru_page(page);
+	page_remove_rmap(page);
+	page_cache_release(page);
+}
+
+static void hmm_rmem_remap_file(struct hmm_rmem *rmem)
+{
+	struct address_space *mapping = rmem->mapping;
+	unsigned long i, index, uid;
+
+	/* This part is lot easier than the unmap one. */
+	uid = rmem->fuid;
+	index = rmem->pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	spin_lock_irq(&mapping->tree_lock);
+	for (i = 0; i < hmm_rmem_npages(rmem); ++i, ++uid, ++index) {
+		void *expected, *item, **slotp;
+		struct page *page;
+
+		page = hmm_pfn_to_page(rmem->pfns[i]);
+		if (!page || !test_bit(HMM_PFN_FILE, &rmem->pfns[i])) {
+			continue;
+		}
+		slotp = radix_tree_lookup_slot(&mapping->page_tree, index);
+		if (!slotp) {
+			/* This should never happen. */
+			WARN_ONCE(1, "hmm: null slot while remapping !\n");
+			continue;
+		}
+		item = radix_tree_deref_slot_protected(slotp,
+						       &mapping->tree_lock);
+		expected = swp_to_radix_entry(make_hmm_entry(uid));
+		if (item == expected) {
+			if (!test_bit(HMM_PFN_LMEM_UPTODATE, &rmem->pfns[i])) {
+				/* FIXME Something was wrong for read back. */
+				ClearPageUptodate(page);
+			}
+			page->mapping = mapping;
+			get_page(page);
+			radix_tree_replace_slot(slotp, page);
+		} else {
+			WARN_ONCE(1, "hmm: expect 0x%p got 0x%p\n",
+				  expected, item);
+		}
+	}
+	spin_unlock_irq(&mapping->tree_lock);
+
+	for (i = 0; i < hmm_rmem_npages(rmem); ++i, ++uid, ++index) {
+		struct page *page;
+
+		page = hmm_pfn_to_page(rmem->pfns[i]);
+		page->mapping = mapping;
+		if (test_bit(HMM_PFN_DIRTY, &rmem->pfns[i])) {
+			set_page_dirty(page);
+		}
+		unlock_page(page);
+		clear_bit(HMM_PFN_LOCK, &rmem->pfns[i]);
+	}
+}
+
 static int hmm_rmem_unmap_anon_page(struct hmm_rmem_mm *rmem_mm,
 				    unsigned long addr,
 				    pte_t *ptep,
@@ -1230,6 +1319,94 @@ static int hmm_rmem_unmap_anon_page(struct hmm_rmem_mm *rmem_mm,
 	return 0;
 }
 
+static int hmm_rmem_unmap_file_page(struct hmm_rmem_mm *rmem_mm,
+				    unsigned long addr,
+				    pte_t *ptep,
+				    pmd_t *pmdp)
+{
+	struct vm_area_struct *vma = rmem_mm->vma;
+	struct mm_struct *mm = vma->vm_mm;
+	struct hmm_rmem *rmem = rmem_mm->rmem;
+	unsigned long idx, uid;
+	struct page *page;
+	pte_t pte;
+
+	/* New pte value. */
+	uid = rmem_mm->fuid + ((addr - rmem_mm->faddr) >> PAGE_SHIFT);
+	idx = uid - rmem->fuid;
+	pte = ptep_get_and_clear_full(mm, addr, ptep, rmem_mm->tlb.fullmm);
+	tlb_remove_tlb_entry((&rmem_mm->tlb), ptep, addr);
+
+	if (pte_none(pte)) {
+		rmem_mm->laddr = addr + PAGE_SIZE;
+		return 0;
+	}
+	if (!pte_present(pte)) {
+		swp_entry_t entry;
+
+		if (pte_file(pte)) {
+			/* Definitly a fault as we do not support migrating non
+			 * linear vma to remote memory.
+			 */
+			WARN_ONCE(1, "hmm: was trying to migrate non linear vma.\n");
+			return -EBUSY;
+		}
+		entry = pte_to_swp_entry(pte);
+		if (unlikely(non_swap_entry(entry))) {
+			/* This can not happen ! At this point no other process
+			 * knows about this page or have pending operation on
+			 * it beside read operation.
+			 *
+			 * There can be no mm event happening (no migration or
+			 * anything else) that would set a special pte.
+			 */
+			WARN_ONCE(1, "hmm: unhandled pte value 0x%016llx.\n",
+				  (long long)pte_val(pte));
+			return -EBUSY;
+		}
+		/* FIXME free swap ? This was pointing to swap entry of shmem shared memory. */
+		return 0;
+	}
+
+	flush_cache_page(vma, addr, pte_pfn(pte));
+	page = pfn_to_page(pte_pfn(pte));
+	if (PageAnon(page)) {
+		page = hmm_pfn_to_page(rmem->pfns[idx]);
+		list_add_tail(&page->lru, &rmem_mm->remap_pages);
+		rmem->pfns[idx] = pte_pfn(pte);
+		set_bit(HMM_PFN_VALID_PAGE, &rmem->pfns[idx]);
+		set_bit(HMM_PFN_WRITE, &rmem->pfns[idx]);
+		if (pte_dirty(pte)) {
+			set_bit(HMM_PFN_DIRTY, &rmem->pfns[idx]);
+		}
+		page = pfn_to_page(pte_pfn(pte));
+		pte = swp_entry_to_pte(make_hmm_entry(uid));
+		set_pte_at(mm, addr, ptep, pte);
+		/* tlb_flush_mmu drop one ref so take an extra ref here. */
+		get_page(page);
+	} else {
+		VM_BUG_ON(page != hmm_pfn_to_page(rmem->pfns[idx]));
+		set_bit(HMM_PFN_VALID_PAGE, &rmem->pfns[idx]);
+		if (pte_write(pte)) {
+			set_bit(HMM_PFN_FS_WRITEABLE, &rmem->pfns[idx]);
+		}
+		if (pte_dirty(pte)) {
+			set_bit(HMM_PFN_DIRTY, &rmem->pfns[idx]);
+		}
+		set_bit(HMM_PFN_FILE, &rmem->pfns[idx]);
+		add_mm_counter(mm, MM_FILEPAGES, -1);
+		page_remove_rmap(page);
+		/* Unlike anonymous page do not take an extra reference as we
+		 * already holding one.
+		 */
+	}
+
+	rmem_mm->force_flush = !__tlb_remove_page(&rmem_mm->tlb, page);
+	rmem_mm->laddr = addr + PAGE_SIZE;
+
+	return 0;
+}
+
 static int hmm_rmem_unmap_pmd(pmd_t *pmdp,
 			      unsigned long addr,
 			      unsigned long next,
@@ -1262,15 +1439,29 @@ static int hmm_rmem_unmap_pmd(pmd_t *pmdp,
 again:
 	ptep = pte_offset_map_lock(vma->vm_mm, pmdp, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
-	for (; addr != next; ++ptep, addr += PAGE_SIZE) {
-		ret = hmm_rmem_unmap_anon_page(rmem_mm, addr,
-					       ptep, pmdp);
-		if (ret || rmem_mm->force_flush) {
-			/* Increment ptep so unlock works on correct
-			 * pte.
-			 */
-			ptep++;
-			break;
+	if (vma->vm_file) {
+		for (; addr != next; ++ptep, addr += PAGE_SIZE) {
+			ret = hmm_rmem_unmap_file_page(rmem_mm, addr,
+						       ptep, pmdp);
+			if (ret || rmem_mm->force_flush) {
+				/* Increment ptep so unlock works on correct
+				 * pte.
+				 */
+				ptep++;
+				break;
+			}
+		}
+	} else {
+		for (; addr != next; ++ptep, addr += PAGE_SIZE) {
+			ret = hmm_rmem_unmap_anon_page(rmem_mm, addr,
+						       ptep, pmdp);
+			if (ret || rmem_mm->force_flush) {
+				/* Increment ptep so unlock works on correct
+				 * pte.
+				 */
+				ptep++;
+				break;
+			}
 		}
 	}
 	arch_leave_lazy_mmu_mode();
@@ -1321,6 +1512,7 @@ static int hmm_rmem_unmap_anon(struct hmm_rmem *rmem,
 
 	npages = (laddr - faddr) >> PAGE_SHIFT;
 	rmem->pgoff = faddr;
+	rmem->mapping = NULL;
 	rmem_mm.vma = vma;
 	rmem_mm.rmem = rmem;
 	rmem_mm.faddr = faddr;
@@ -1362,13 +1554,433 @@ static int hmm_rmem_unmap_anon(struct hmm_rmem *rmem,
 	return ret;
 }
 
+static int hmm_rmem_unmap_file(struct hmm_rmem *rmem,
+			       struct vm_area_struct *vma,
+			       unsigned long faddr,
+			       unsigned long laddr)
+{
+	struct address_space *mapping;
+	struct hmm_rmem_mm rmem_mm;
+	struct mm_walk walk = {0};
+	unsigned long addr, i, index, npages, uid;
+	struct page *page, *tmp;
+	int ret;
+
+	npages = hmm_rmem_npages(rmem);
+	rmem->pgoff = vma->vm_pgoff + ((faddr - vma->vm_start) >> PAGE_SHIFT);
+	rmem->mapping = vma->vm_file->f_mapping;
+	rmem_mm.vma = vma;
+	rmem_mm.rmem = rmem;
+	rmem_mm.faddr = faddr;
+	rmem_mm.laddr = faddr;
+	rmem_mm.fuid = rmem->fuid;
+	INIT_LIST_HEAD(&rmem_mm.remap_pages);
+	memset(rmem->pfns, 0, sizeof(long) * npages);
+
+	i = 0;
+	uid = rmem->fuid;
+	addr = faddr;
+	index = rmem->pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	mapping = rmem->mapping;
+
+	/* Probably the most complex part of the code as it needs to serialize
+	 * againt various memory and filesystem event. The range we are trying
+	 * to migrate can be under going writeback, direct_IO, read, write or
+	 * simply mm event such as page reclaimation, page migration, ...
+	 *
+	 * We need to get exclusive access to all the page in the range so that
+	 * no other process access them or try to do anything with them. Trick
+	 * is to set the page->mapping to NULL so that anyone with reference
+	 * on the page will think that the page was either reclaim, migrated or
+	 * truncated. Any code that see that either skip the page or retry to
+	 * do a find_get_page which will result in getting the hmm special swap
+	 * value.
+	 *
+	 * This is a multistep process, first we update the pagecache to point
+	 * to special hmm swap entry so that any new event coming in sees that
+	 * and could block the migration. While updating the pagecache we also
+	 * make sure it is fully populated. We also try lock all page we can so
+	 * that no other process can lock them for write, direct_IO or anything
+	 * else that require the page lock.
+	 *
+	 * Once pagecache is updated we proceed to lock all the unlocked page
+	 * and to isolate them from the lru as we do not want any of them to
+	 * be reclaim while doing the migration. We also make sure the page is
+	 * Uptodate and read it back from the disk if not.
+	 *
+	 * Next step is to unmap the range from the process address for which
+	 * the migration is happening. We do so because we need to account all
+	 * the page against this process so that on migration back unaccounting
+	 * can be done consistently.
+	 *
+	 * Finaly the last step is to unmap for all other process after this
+	 * the only thing that can still be happening is that some page are
+	 * undergoing read or writeback, both of which are fine.
+	 *
+	 * To know up to which step exactly each page went we use various hmm
+	 * pfn flags so that error handling code can take proper action to
+	 * restore page into its original state.
+	 */
+
+retry:
+	if (rmem->event->backoff) {
+		npages = i;
+		ret = -EBUSY;
+		goto out;
+	}
+	spin_lock_irq(&mapping->tree_lock);
+	for (; i < npages; ++i, ++uid, ++index, addr += PAGE_SIZE){
+		void *item, **slotp;
+		int error;
+
+		slotp = radix_tree_lookup_slot(&mapping->page_tree, index);
+		if (!slotp) {
+			spin_unlock_irq(&mapping->tree_lock);
+			page = page_cache_alloc_cold(mapping);
+			if (!page) {
+				npages = i;
+				ret = -ENOMEM;
+				goto out;
+			}
+			ret = add_to_page_cache_lru(page, mapping,
+						    index, GFP_KERNEL);
+			if (ret) {
+				page_cache_release(page);
+				if (ret == -EEXIST) {
+					goto retry;
+				}
+				npages = i;
+				goto out;
+			}
+			/* A previous I/O error may have been due to temporary
+			 * failures, eg. multipath errors. PG_error will be set
+			 * again if readpage fails.
+			 *
+			 * FIXME i do not think this is necessary.
+			 */
+			ClearPageError(page);
+			/* Start the read. The read will unlock the page. */
+			error = mapping->a_ops->readpage(vma->vm_file, page);
+			page_cache_release(page);
+			if (error) {
+				npages = i;
+				ret = -EBUSY;
+				goto out;
+			}
+			goto retry;
+		}
+		item = radix_tree_deref_slot_protected(slotp,
+						       &mapping->tree_lock);
+		if (radix_tree_exceptional_entry(item)) {
+			swp_entry_t entry = radix_to_swp_entry(item);
+
+			/* The case of private mapping of a file make things
+			 * interestings as both shared and private anonymous
+			 * page can exist in such rmem object.
+			 *
+			 * For now we just force them to go back to lmem, to
+			 * supporting it require another level of indirection.
+			 */
+			if (!is_hmm_entry(entry)) {
+				spin_unlock_irq(&mapping->tree_lock);
+				npages = i;
+				ret = -EBUSY;
+				goto out;
+			}
+			/* FIXME handle shmem swap entry or some other device
+			 */
+			spin_unlock_irq(&mapping->tree_lock);
+			npages = i;
+			ret = -EBUSY;
+			goto out;
+		}
+		page = item;
+		if (unlikely(PageMlocked(page))) {
+			spin_unlock_irq(&mapping->tree_lock);
+			npages = i;
+			ret = -EBUSY;
+			goto out;
+		}
+		item = swp_to_radix_entry(make_hmm_entry(uid));
+		radix_tree_replace_slot(slotp, item);
+		rmem->pfns[i] = page_to_pfn(page) << HMM_PFN_SHIFT;
+		set_bit(HMM_PFN_VALID_PAGE, &rmem->pfns[i]);
+		set_bit(HMM_PFN_FILE, &rmem->pfns[i]);
+		rmem_mm.laddr = addr + PAGE_SIZE;
+
+		/* Pretend the page is being map make error code handling lot
+		 * simpler and cleaner.
+		 */
+		page_add_file_rmap(page);
+		add_mm_counter(vma->vm_mm, MM_FILEPAGES, 1);
+
+		if (trylock_page(page)) {
+			set_bit(HMM_PFN_LOCK, &rmem->pfns[i]);
+			if (page->mapping != mapping) {
+				/* Page have been truncated. */
+				spin_unlock_irq(&mapping->tree_lock);
+				npages = i;
+				ret = -EBUSY;
+				goto out;
+			}
+		}
+		if (PageWriteback(page)) {
+			set_bit(HMM_PFN_WRITEBACK, &rmem->pfns[i]);
+		}
+	}
+	spin_unlock_irq(&mapping->tree_lock);
+
+	/* At this point any unlocked page can still be referenced by various
+	 * file activities (read, write, splice, ...). But no new mapping can
+	 * be instanciated as the pagecache is now updated with special entry.
+	 */
+
+	if (rmem->event->backoff) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	for (i = 0; i < npages; ++i) {
+		page = hmm_pfn_to_page(rmem->pfns[i]);
+		ret = isolate_lru_page(page);
+		if (ret) {
+			goto out;
+		}
+		/* Isolate take an extra-ref which we do not want, as we are
+		 * already holding a reference on the page. Only holding one
+		 * reference  simplify error code path which then knows that
+		 * we are only holding one reference for each page, it does
+		 * not need to know wether we are holding and extra reference
+		 * or not from the isolate_lru_page.
+		 */
+		put_page(page);
+		if (!test_bit(HMM_PFN_LOCK, &rmem->pfns[i])) {
+			lock_page(page);
+			set_bit(HMM_PFN_LOCK, &rmem->pfns[i]);
+			/* Has the page been truncated ? */
+			if (page->mapping != mapping) {
+				ret = -EBUSY;
+				goto out;
+			}
+		}
+		if (unlikely(!PageUptodate(page))) {
+			int error;
+
+			/* A previous I/O error may have been due to temporary
+			 * failures, eg. multipath errors. PG_error will be set
+			 * again if readpage fails.
+			 */
+			ClearPageError(page);
+			/* The read will unlock the page which is ok because no
+			 * one else knows about this page at this point.
+			 */
+			error = mapping->a_ops->readpage(vma->vm_file, page);
+			if (error) {
+				ret = -EBUSY;
+				goto out;
+			}
+			lock_page(page);
+		}
+		set_bit(HMM_PFN_LMEM_UPTODATE, &rmem->pfns[i]);
+	}
+
+	/* At this point all page are lock which means that the page content is
+	 * stable. Because we will reset the page->mapping field we also know
+	 * that anyone holding a reference on the page will retry to find the
+	 * page or skip current operations.
+	 *
+	 * Also at this point no one can be unmapping those pages from the vma
+	 * as the hmm event prevent any mmu_notifier invalidation to proceed
+	 * until we are done.
+	 *
+	 * We need to unmap page from the vma ourself so we can properly update
+	 * the mm counter.
+	 */
+
+	if (rmem->event->backoff) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	if (current->mm == vma->vm_mm) {
+		sync_mm_rss(vma->vm_mm);
+	}
+	rmem_mm.force_flush = 0;
+	walk.pmd_entry = hmm_rmem_unmap_pmd;
+	walk.mm = vma->vm_mm;
+	walk.private = &rmem_mm;
+
+	mmu_notifier_invalidate_range_start(walk.mm,vma,faddr,laddr,MMU_HMM);
+	tlb_gather_mmu(&rmem_mm.tlb, walk.mm, faddr, laddr);
+	tlb_start_vma(&rmem_mm.tlb, rmem_mm->vma);
+	ret = walk_page_range(faddr, laddr, &walk);
+	tlb_end_vma(&rmem_mm.tlb, rmem_mm->vma);
+	tlb_finish_mmu(&rmem_mm.tlb, faddr, laddr);
+	mmu_notifier_invalidate_range_end(walk.mm, vma, faddr, laddr, MMU_HMM);
+
+	/* Remap any pages that were replaced by anonymous page. */
+	list_for_each_entry_safe (page, tmp, &rmem_mm.remap_pages, lru) {
+		hmm_rmem_remap_file_single_page(rmem, page);
+	}
+
+	if (ret) {
+		npages = (rmem_mm.laddr - rmem_mm.faddr) >> PAGE_SHIFT;
+		goto out;
+	}
+
+	/* Now unmap from all other process. */
+
+	if (rmem->event->backoff) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	for (i = 0, ret = 0; i < npages; ++i) {
+		page = hmm_pfn_to_page(rmem->pfns[i]);
+
+		if (!test_bit(HMM_PFN_FILE, &rmem->pfns[i])) {
+			continue;
+		}
+
+		/* Because we did call page_add_file_rmap then mapcount must be
+		 * at least one. This was done on to avoid page_remove_rmap to
+		 * update memcg and mm statistic.
+		 */
+		BUG_ON(page_mapcount(page) <= 0);
+		if (page_mapcount(page) > 1) {
+			try_to_unmap(page,
+					 TTU_HMM |
+					 TTU_IGNORE_MLOCK |
+					 TTU_IGNORE_ACCESS);
+			if (page_mapcount(page) > 1) {
+				ret = ret ? ret : -EBUSY;
+			} else {
+				/* Everyone will think page have been migrated,
+				 * truncated or reclaimed.
+				 */
+				page->mapping = NULL;
+			}
+		} else {
+			/* Everyone will think page have been migrated,
+			 * truncated or reclaimed.
+			 */
+			page->mapping = NULL;
+		}
+		/* At this point no one else can write to the page. Save dirty bit and check it when doing
+		 * fault.
+		 */
+		if (PageDirty(page)) {
+			set_bit(HMM_PFN_DIRTY, &rmem->pfns[i]);
+			ClearPageDirty(page);
+		}
+	}
+
+	/* This was a long journey but at this point hmm has exclusive owner
+	 * of all the pages and all of them are accounted against the process
+	 * mm as well as Uptodate and ready for to be copied to remote memory.
+	 */
+out:
+	if (ret) {
+		/* Unaccount any unmapped pages. */
+		for (i = 0; i < npages; ++i) {
+			if (test_bit(HMM_PFN_FILE, &rmem->pfns[i])) {
+				add_mm_counter(walk.mm, MM_FILEPAGES, -1);
+			}
+		}
+	}
+	return ret;
+}
+
+static int hmm_rmem_file_mkwrite(struct hmm_rmem *rmem,
+				 struct vm_area_struct *vma,
+				 unsigned long addr,
+				 unsigned long uid)
+{
+	struct vm_fault vmf;
+	unsigned long idx = uid - rmem->fuid;
+	struct page *page;
+	int r;
+
+	page = hmm_pfn_to_page(rmem->pfns[idx]);
+	if (test_bit(HMM_PFN_FS_WRITEABLE, &rmem->pfns[idx])) {
+		lock_page(page);
+		page->mapping = rmem->mapping;
+		goto release;
+	}
+
+	vmf.virtual_address = (void __user *)(addr & PAGE_MASK);
+	vmf.pgoff = page->index;
+	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
+	vmf.page = page;
+	page->mapping = rmem->mapping;
+	page_cache_get(page);
+
+	r = vma->vm_ops->page_mkwrite(vma, &vmf);
+	if (unlikely(r & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+		page_cache_release(page);
+		return -EFAULT;
+	}
+	if (unlikely(!(r & VM_FAULT_LOCKED))) {
+		lock_page(page);
+		if (!page->mapping) {
+
+			WARN_ONCE(1, "hmm: page can not be truncated while in rmem !\n");
+			unlock_page(page);
+			page_cache_release(page);
+			return -EFAULT;
+		}
+	}
+	set_bit(HMM_PFN_FS_WRITEABLE, &rmem->pfns[idx]);
+	/* Ok to put_page here as we hold another reference. */
+	page_cache_release(page);
+
+release:
+	/* We clear the write back now to forbid any new write back. The write
+	 * back code will need to go through its slow code path to set again
+	 * the writeback flags.
+	 */
+	clear_bit(HMM_PFN_WRITEBACK, &rmem->pfns[idx]);
+	/* Now wait for any in progress writeback. */
+	if (PageWriteback(page)) {
+		wait_on_page_writeback(page);
+	}
+	/* The page count is what we use to synchronize with write back. The
+	 * write back code take an extra reference on page before returning
+	 * them to the write back fs code and thus here at this point we see
+	 * that and forbid the change.
+	 *
+	 * However as we just waited for pending writeback above, in case the
+	 * writeback was already scheduled then at this point its done and it
+	 * should have drop the extra reference thus the rmem can be written
+	 * to again.
+	 */
+	if (page_count(page) > (1 + page_has_private(page))) {
+		page->mapping = NULL;
+		unlock_page(page);
+		return -EBUSY;
+	}
+	/* No body should have write to that page thus nobody should have set
+	 * the dirty bit.
+	 */
+	BUG_ON(PageDirty(page));
+
+	/* Restore page count. */
+	page->mapping = NULL;
+	clear_bit(HMM_PFN_LMEM_UPTODATE, &rmem->pfns[idx]);
+	/* Ok now device can write to rmem. */
+	set_bit(HMM_PFN_WRITE, &rmem->pfns[idx]);
+	unlock_page(page);
+
+	return 0;
+}
+
 static inline int hmm_rmem_unmap(struct hmm_rmem *rmem,
 				 struct vm_area_struct *vma,
 				 unsigned long faddr,
 				 unsigned long laddr)
 {
 	if (vma->vm_file) {
-		return -EBUSY;
+		return hmm_rmem_unmap_file(rmem, vma, faddr, laddr);
 	} else {
 		return hmm_rmem_unmap_anon(rmem, vma, faddr, laddr);
 	}
@@ -1402,6 +2014,34 @@ static int hmm_rmem_alloc_pages(struct hmm_rmem *rmem,
 			vma = mm ? find_vma(mm, addr) : NULL;
 		}
 
+		page = hmm_pfn_to_page(pfns[i]);
+		if (page && test_bit(HMM_PFN_VALID_PAGE, &pfns[i])) {
+			BUG_ON(test_bit(HMM_PFN_LOCK, &pfns[i]));
+			lock_page(page);
+			set_bit(HMM_PFN_LOCK, &pfns[i]);
+
+			/* Fake one mapping so that page_remove_rmap behave as
+			 * we want.
+			 */
+			BUG_ON(page_mapcount(page));
+			atomic_set(&page->_mapcount, 0);
+
+			spin_lock(&rmem->lock);
+			if (test_bit(HMM_PFN_WRITEBACK, &pfns[i])) {
+				/* Clear the bit first, it is fine because any
+				 * thread that will test the bit will first
+				 * check the rmem->event and at this point it
+				 * is set to the migration event.
+				 */
+				clear_bit(HMM_PFN_WRITEBACK, &pfns[i]);
+				spin_unlock(&rmem->lock);
+				wait_on_page_writeback(page);
+			} else {
+				spin_unlock(&rmem->lock);
+			}
+			continue;
+		}
+
 		/* No need to clear page they will be dma to of course this does
 		 * means we trust the device driver.
 		 */
@@ -1482,7 +2122,7 @@ int hmm_rmem_migrate_to_lmem(struct hmm_rmem *rmem,
 						 range->laddr,
 						 range->fuid,
 						 HMM_MIGRATE_TO_LMEM,
-						 false);
+						 !!(range->rmem->mapping));
 		if (IS_ERR(fence)) {
 			ret = PTR_ERR(fence);
 			goto error;
@@ -1517,6 +2157,19 @@ int hmm_rmem_migrate_to_lmem(struct hmm_rmem *rmem,
 		}
 	}
 
+	/* Sanity check the driver. */
+	for (i = 0; i < hmm_rmem_npages(rmem); ++i) {
+		if (!test_bit(HMM_PFN_LMEM_UPTODATE, &rmem->pfns[i])) {
+			WARN_ONCE(1, "hmm: driver failed to set HMM_PFN_LMEM_UPTODATE.\n");
+			ret = -EINVAL;
+			goto error;
+		}
+	}
+
+	if (rmem->mapping) {
+		hmm_rmem_remap_file(rmem);
+	}
+
 	/* Now the remote memory is officialy dead and nothing below can fails
 	 * badly.
 	 */
@@ -1526,6 +2179,13 @@ int hmm_rmem_migrate_to_lmem(struct hmm_rmem *rmem,
 	 * ranges list.
 	 */
 	list_for_each_entry_safe (range, next, &rmem->ranges, rlist) {
+		if (rmem->mapping) {
+			add_mm_counter(range->mirror->hmm->mm, MM_FILEPAGES,
+				       -hmm_range_npages(range));
+			hmm_range_fini(range);
+			continue;
+		}
+
 		VM_BUG_ON(!vma);
 		VM_BUG_ON(range->faddr < vma->vm_start);
 		VM_BUG_ON(range->laddr > vma->vm_end);
@@ -1544,8 +2204,20 @@ int hmm_rmem_migrate_to_lmem(struct hmm_rmem *rmem,
 	for (i = 0; i < hmm_rmem_npages(rmem); ++i) {
 		struct page *page = hmm_pfn_to_page(rmem->pfns[i]);
 
-		unlock_page(page);
-		mem_cgroup_transfer_charge_anon(page, mm);
+		/* The HMM_PFN_FILE bit is only set for page that are in the
+		 * pagecache and thus are already accounted properly. So when
+		 * unset this means this is a private anonymous page for which
+		 * we need to transfer charge.
+		 *
+		 * If remapping failed then below page_remove_rmap will update
+		 * the memcg and mm properly.
+		 */
+		if (mm && !test_bit(HMM_PFN_FILE, &rmem->pfns[i])) {
+			mem_cgroup_transfer_charge_anon(page, mm);
+		}
+		if (test_bit(HMM_PFN_LOCK, &rmem->pfns[i])) {
+			unlock_page(page);
+		}
 		page_remove_rmap(page);
 		page_cache_release(page);
 		rmem->pfns[i] = 0UL;
@@ -1563,6 +2235,19 @@ error:
 	 * (2) rmem is mirroring private memory, easy case poison all ranges
 	 *     referencing the rmem.
 	 */
+	if (rmem->mapping) {
+		/* No matter what try to copy back data, driver should be
+		 * clever and not copy over page with HMM_PFN_LMEM_UPTODATE
+		 * bit set.
+		 */
+		fence = device->ops->rmem_to_lmem(rmem, rmem->fuid, rmem->luid);
+		if (fence && !IS_ERR(fence)) {
+			INIT_LIST_HEAD(&fence->list);
+			ret = hmm_device_fence_wait(device, fence);
+		}
+		/* FIXME how to handle error ? Mark page with error ? */
+		hmm_rmem_remap_file(rmem);
+	}
 	for (i = 0; i < hmm_rmem_npages(rmem); ++i) {
 		struct page *page = hmm_pfn_to_page(rmem->pfns[i]);
 
@@ -1573,9 +2258,11 @@ error:
 			}
 			continue;
 		}
-		/* Properly uncharge memory. */
-		mem_cgroup_transfer_charge_anon(page, mm);
-		if (!test_bit(HMM_PFN_LOCK, &rmem->pfns[i])) {
+		if (!test_bit(HMM_PFN_FILE, &rmem->pfns[i])) {
+			/* Properly uncharge memory. */
+			mem_cgroup_transfer_charge_anon(page, mm);
+		}
+		if (test_bit(HMM_PFN_LOCK, &rmem->pfns[i])) {
 			unlock_page(page);
 		}
 		page_remove_rmap(page);
@@ -1583,6 +2270,15 @@ error:
 		rmem->pfns[i] = 0UL;
 	}
 	list_for_each_entry_safe (range, next, &rmem->ranges, rlist) {
+		/* FIXME Philosophical question Should we poison other process that access this shared file ? */
+		if (rmem->mapping) {
+			add_mm_counter(range->mirror->hmm->mm, MM_FILEPAGES,
+				       -hmm_range_npages(range));
+			/* Case (1) FIXME implement ! */
+			hmm_range_fini(range);
+			continue;
+		}
+
 		mm = range->mirror->hmm->mm;
 		hmm_rmem_poison_range(rmem, mm, NULL, range->faddr,
 				      range->laddr, range->fuid);
@@ -2063,6 +2759,268 @@ int hmm_mm_fault(struct mm_struct *mm,
 	return VM_FAULT_MAJOR;
 }
 
+/* see include/linux/hmm.h */
+void hmm_pagecache_migrate(struct address_space *mapping,
+			   swp_entry_t swap)
+{
+	struct hmm_rmem *rmem = NULL;
+	unsigned long fuid, luid, npages;
+
+	/* This can not happen ! */
+	VM_BUG_ON(!is_hmm_entry(swap));
+
+	fuid = hmm_entry_uid(swap);
+	VM_BUG_ON(!fuid);
+
+	rmem = hmm_rmem_find(fuid);
+	if (!rmem || rmem->dead) {
+		hmm_rmem_unref(rmem);
+		return;
+	}
+
+	/* FIXME use something else that 16 pages. Readahead ? Or just all range of dirty pages. */
+	npages = 16;
+	luid = min((fuid - rmem->fuid), (npages >> 2));
+	fuid = fuid - luid;
+	luid = min(fuid + npages, rmem->luid);
+
+	hmm_rmem_migrate_to_lmem(rmem, NULL, 0, fuid, luid, true);
+	hmm_rmem_unref(rmem);
+}
+EXPORT_SYMBOL(hmm_pagecache_migrate);
+
+/* see include/linux/hmm.h */
+struct page *hmm_pagecache_writeback(struct address_space *mapping,
+				     swp_entry_t swap)
+{
+	struct hmm_device *device;
+	struct hmm_range *range, *nrange;
+	struct hmm_fence *fence, *nfence;
+	struct hmm_event event;
+	struct hmm_rmem *rmem = NULL;
+	unsigned long i, uid, idx, npages;
+	/* FIXME hardcoded 16 */
+	struct page *pages[16];
+	bool dirty = false;
+	int ret;
+
+	/* Find the corresponding rmem. */
+	if (!is_hmm_entry(swap)) {
+		BUG();
+		return NULL;
+	}
+	uid = hmm_entry_uid(swap);
+	if (!uid) {
+		/* Poisonous hmm swap entry this can not happen. */
+		BUG();
+		return NULL;
+	}
+
+retry:
+	rmem = hmm_rmem_find(uid);
+	if (!rmem) {
+		/* Someone likely migrated it back to lmem by returning NULL
+		 * the caller will perform a new lookup.
+		 */
+		return NULL;
+	}
+
+	if (rmem->dead) {
+		/* When dead is set everything is done. */
+		hmm_rmem_unref(rmem);
+		return NULL;
+	}
+
+	idx = uid - rmem->fuid;
+	device = rmem->device;
+	spin_lock(&rmem->lock);
+	if (rmem->event) {
+		if (rmem->event->etype == HMM_MIGRATE_TO_RMEM) {
+			rmem->event->backoff = true;
+		}
+		spin_unlock(&rmem->lock);
+		wait_event(device->wait_queue, rmem->event!=NULL);
+		hmm_rmem_unref(rmem);
+		goto retry;
+	}
+	pages[0] =  hmm_pfn_to_page(rmem->pfns[idx]);
+	if (!pages[0]) {
+		spin_unlock(&rmem->lock);
+		hmm_rmem_unref(rmem);
+		goto retry;
+	}
+	get_page(pages[0]);
+	if (!trylock_page(pages[0])) {
+		unsigned long orig = rmem->pfns[idx];
+
+		spin_unlock(&rmem->lock);
+		lock_page(pages[0]);
+		spin_lock(&rmem->lock);
+		if (rmem->pfns[idx] != orig) {
+			spin_unlock(&rmem->lock);
+			unlock_page(pages[0]);
+			page_cache_release(pages[0]);
+			hmm_rmem_unref(rmem);
+			goto retry;
+		}
+	}
+	if (test_bit(HMM_PFN_LMEM_UPTODATE, &rmem->pfns[idx])) {
+		dirty = test_bit(HMM_PFN_DIRTY, &rmem->pfns[idx]);
+		set_bit(HMM_PFN_WRITEBACK, &rmem->pfns[idx]);
+		spin_unlock(&rmem->lock);
+		hmm_rmem_unref(rmem);
+		if (dirty) {
+			set_page_dirty(pages[0]);
+		}
+		return pages[0];
+	}
+
+	if (rmem->event) {
+		spin_unlock(&rmem->lock);
+		unlock_page(pages[0]);
+		page_cache_release(pages[0]);
+		wait_event(device->wait_queue, rmem->event!=NULL);
+		hmm_rmem_unref(rmem);
+		goto retry;
+	}
+
+	/* Try to batch few pages. */
+	/* FIXME use something else that 16 pages. Readahead ? Or just all range of dirty pages. */
+	npages = 16;
+	set_bit(HMM_PFN_WRITEBACK, &rmem->pfns[idx]);
+	for (i = 1; i < npages; ++i) {
+		pages[i] = hmm_pfn_to_page(rmem->pfns[idx + i]);
+		if (!trylock_page(pages[i])) {
+			npages = i;
+			break;
+		}
+		if (test_bit(HMM_PFN_LMEM_UPTODATE, &rmem->pfns[idx + i])) {
+			unlock_page(pages[i]);
+			npages = i;
+			break;
+		}
+		set_bit(HMM_PFN_WRITEBACK, &rmem->pfns[idx + i]);
+		get_page(pages[i]);
+	}
+
+	event.etype = HMM_WRITEBACK;
+	event.faddr = uid;
+	event.laddr = uid + npages;
+	rmem->event = &event;
+	INIT_LIST_HEAD(&event.ranges);
+	list_for_each_entry (range, &rmem->ranges, rlist) {
+		list_add_tail(&range->elist, &event.ranges);
+	}
+	spin_unlock(&rmem->lock);
+
+	list_for_each_entry (range, &event.ranges, elist) {
+		unsigned long fuid, faddr, laddr;
+
+		if (event.laddr <  hmm_range_fuid(range) ||
+		    event.faddr >= hmm_range_luid(range)) {
+			continue;
+		}
+		fuid  = max(event.faddr, hmm_range_fuid(range));
+		faddr = fuid - hmm_range_fuid(range);
+		laddr = min(event.laddr, hmm_range_luid(range)) - fuid;
+		faddr = range->faddr + (faddr << PAGE_SHIFT);
+		laddr = range->faddr + (laddr << PAGE_SHIFT);
+		ret = hmm_mirror_rmem_update(range->mirror, rmem, faddr,
+					     laddr, fuid, &event, true);
+		if (ret) {
+			goto error;
+		}
+	}
+
+	list_for_each_entry_safe (fence, nfence, &event.fences, list) {
+		hmm_device_fence_wait(device, fence);
+	}
+
+	/* Event faddr is fuid and laddr is luid. */
+	fence = device->ops->rmem_to_lmem(rmem, event.faddr, event.laddr);
+	if (IS_ERR(fence)) {
+		goto error;
+	}
+	INIT_LIST_HEAD(&fence->list);
+	ret = hmm_device_fence_wait(device, fence);
+	if (ret) {
+		goto error;
+	}
+
+	spin_lock(&rmem->lock);
+	if (test_bit(!HMM_PFN_LMEM_UPTODATE, &rmem->pfns[idx + i])) {
+		/* This should not happen the driver must set the bit. */
+		WARN_ONCE(1, "hmm: driver failed to set HMM_PFN_LMEM_UPTODATE.\n");
+		goto error;
+	}
+	rmem->event = NULL;
+	dirty = test_bit(HMM_PFN_DIRTY, &rmem->pfns[idx]);
+	list_for_each_entry_safe (range, nrange, &event.ranges, elist) {
+		list_del_init(&range->elist);
+	}
+	spin_unlock(&rmem->lock);
+	/* Do not unlock first page, return it locked. */
+	for (i = 1; i < npages; ++i) {
+		unlock_page(pages[i]);
+		page_cache_release(pages[i]);
+	}
+	wake_up(&device->wait_queue);
+	hmm_rmem_unref(rmem);
+	if (dirty) {
+		set_page_dirty(pages[0]);
+	}
+	return pages[0];
+
+error:
+	for (i = 0; i < npages; ++i) {
+		unlock_page(pages[i]);
+		page_cache_release(pages[i]);
+	}
+	spin_lock(&rmem->lock);
+	rmem->event = NULL;
+	list_for_each_entry_safe (range, nrange, &event.ranges, elist) {
+		list_del_init(&range->elist);
+	}
+	spin_unlock(&rmem->lock);
+	hmm_rmem_unref(rmem);
+	hmm_pagecache_migrate(mapping, swap);
+	return NULL;
+}
+EXPORT_SYMBOL(hmm_pagecache_writeback);
+
+struct page *hmm_pagecache_page(struct address_space *mapping,
+				swp_entry_t swap)
+{
+	struct hmm_rmem *rmem = NULL;
+	struct page *page;
+	unsigned long uid;
+
+	/* Find the corresponding rmem. */
+	if (!is_hmm_entry(swap)) {
+		BUG();
+		return NULL;
+	}
+	uid = hmm_entry_uid(swap);
+	if (!uid) {
+		/* Poisonous hmm swap entry this can not happen. */
+		BUG();
+		return NULL;
+	}
+
+	rmem = hmm_rmem_find(uid);
+	if (!rmem) {
+		/* Someone likely migrated it back to lmem by returning NULL
+		 * the caller will perform a new lookup.
+		 */
+		return NULL;
+	}
+
+	page = hmm_pfn_to_page(rmem->pfns[uid - rmem->fuid]);
+	get_page(page);
+	hmm_rmem_unref(rmem);
+	return page;
+}
+
 
 
 
@@ -2667,7 +3625,7 @@ static int hmm_mirror_rmem_fault(struct hmm_mirror *mirror,
 {
 	struct hmm_device *device = mirror->device;
 	struct hmm_rmem *rmem = range->rmem;
-	unsigned long fuid, luid, npages;
+	unsigned long i, fuid, luid, npages, uid;
 	int ret;
 
 	if (range->mirror != mirror) {
@@ -2679,6 +3637,77 @@ static int hmm_mirror_rmem_fault(struct hmm_mirror *mirror,
 	fuid = range->fuid + ((faddr - range->faddr) >> PAGE_SHIFT);
 	luid = fuid + npages;
 
+	/* The rmem might not be uptodate so synchronize again. The only way
+	 * this might be the case is if a previous mkwrite failed and the
+	 * device decided to use the local memory copy.
+	 */
+	i = fuid - rmem->fuid;
+	for (uid = fuid; uid < luid; ++uid, ++i) {
+		if (!test_bit(HMM_PFN_RMEM_UPTODATE, &rmem->pfns[i])) {
+			struct hmm_fence *fence, *nfence;
+			enum hmm_etype etype = event->etype;
+
+			event->etype = HMM_UNMAP;
+			ret = hmm_mirror_rmem_update(mirror, rmem, range->faddr,
+						     range->laddr, range->fuid,
+						     event, true);
+			event->etype = etype;
+			if (ret) {
+				return ret;
+			}
+			list_for_each_entry_safe (fence, nfence,
+						  &event->fences, list) {
+				hmm_device_fence_wait(device, fence);
+			}
+			fence = device->ops->lmem_to_rmem(rmem, range->fuid,
+							  hmm_range_luid(range));
+			if (IS_ERR(fence)) {
+				return PTR_ERR(fence);
+			}
+			ret = hmm_device_fence_wait(device, fence);
+			if (ret) {
+				return ret;
+			}
+			break;
+		}
+	}
+
+	if (write && rmem->mapping) {
+		unsigned long addr;
+
+		if (current->mm == vma->vm_mm) {
+			sync_mm_rss(vma->vm_mm);
+		}
+		i = fuid - rmem->fuid;
+		addr = faddr;
+		for (uid = fuid; uid < luid; ++uid, ++i, addr += PAGE_SIZE) {
+			if (test_bit(HMM_PFN_WRITE, &rmem->pfns[i])) {
+				continue;
+			}
+			if (vma->vm_flags & VM_SHARED) {
+				ret = hmm_rmem_file_mkwrite(rmem,vma,addr,uid);
+				if (ret && ret != -EBUSY) {
+					return ret;
+				}
+			} else {
+				struct mm_struct *mm = vma->vm_mm;
+				struct page *page;
+
+				/* COW */
+				if(mem_cgroup_charge_anon(NULL,mm,GFP_KERNEL)){
+					return -ENOMEM;
+				}
+				add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
+				spin_lock(&rmem->lock);
+				page = hmm_pfn_to_page(rmem->pfns[i]);
+				rmem->pfns[i] = 0;
+				set_bit(HMM_PFN_WRITE, &rmem->pfns[i]);
+				spin_unlock(&rmem->lock);
+				hmm_rmem_remap_file_single_page(rmem, page);
+			}
+		}
+	}
+
 	ret = device->ops->rmem_fault(mirror, rmem, faddr, laddr, fuid, fault);
 	return ret;
 }
@@ -2951,7 +3980,10 @@ static void hmm_migrate_abort(struct hmm_mirror *mirror,
 					      faddr, laddr, fuid);
 		}
 	} else {
-		BUG();
+		rmem.pgoff = vma->vm_pgoff;
+		rmem.pgoff += ((fault->faddr - vma->vm_start) >> PAGE_SHIFT);
+		rmem.mapping = vma->vm_file->f_mapping;
+		hmm_rmem_remap_file(&rmem);
 	}
 
 	/* Ok officialy dead. */
@@ -2977,6 +4009,15 @@ static void hmm_migrate_abort(struct hmm_mirror *mirror,
 			unlock_page(page);
 			clear_bit(HMM_PFN_LOCK, &pfns[i]);
 		}
+		if (test_bit(HMM_PFN_FILE, &pfns[i]) && !PageLRU(page)) {
+			/* To balance putback_lru_page and isolate_lru_page. As
+			 * a simplification we droped the extra reference taken
+			 * by isolate_lru_page. This is why we need to take an
+			 * extra reference here for putback_lru_page.
+			 */
+			get_page(page);
+			putback_lru_page(page);
+		}
 		page_remove_rmap(page);
 		page_cache_release(page);
 		pfns[i] = 0;
@@ -2988,6 +4029,7 @@ int hmm_migrate_lmem_to_rmem(struct hmm_fault *fault,
 			     struct hmm_mirror *mirror)
 {
 	struct vm_area_struct *vma;
+	struct address_space *mapping;
 	struct hmm_device *device;
 	struct hmm_range *range;
 	struct hmm_fence *fence;
@@ -3042,7 +4084,8 @@ int hmm_migrate_lmem_to_rmem(struct hmm_fault *fault,
 		ret = -EACCES;
 		goto out;
 	}
-	if (vma->vm_file) {
+	mapping = vma->vm_file ? vma->vm_file->f_mapping : NULL;
+	if (vma->vm_file && !(mapping->a_ops->features & AOPS_FEATURE_HMM)) {
 		kfree(range);
 		range = NULL;
 		ret = -EBUSY;
@@ -3053,6 +4096,7 @@ int hmm_migrate_lmem_to_rmem(struct hmm_fault *fault,
 	event->laddr  =fault->laddr = min(fault->laddr, vma->vm_end);
 	npages = (fault->laddr - fault->faddr) >> PAGE_SHIFT;
 	fault->vma = vma;
+	rmem.mapping = (vma->vm_flags & VM_SHARED) ? mapping : NULL;
 
 	ret = hmm_rmem_alloc(&rmem, npages);
 	if (ret) {
@@ -3100,6 +4144,7 @@ int hmm_migrate_lmem_to_rmem(struct hmm_fault *fault,
 	hmm_rmem_tree_insert(fault->rmem, &_hmm_rmems);
 	fault->rmem->pfns = rmem.pfns;
 	range->rmem = fault->rmem;
+	fault->rmem->mapping = rmem.mapping;
 	list_del_init(&range->rlist);
 	list_add_tail(&range->rlist, &fault->rmem->ranges);
 	rmem.event = NULL;
@@ -3128,7 +4173,6 @@ int hmm_migrate_lmem_to_rmem(struct hmm_fault *fault,
 		struct page *page = hmm_pfn_to_page(rmem.pfns[i]);
 
 		if (test_bit(HMM_PFN_VALID_ZERO, &rmem.pfns[i])) {
-			rmem.pfns[i] = rmem.pfns[i] & HMM_PFN_CLEAR;
 			continue;
 		}
 		/* We only decrement now the page count so that cow happen
diff --git a/mm/madvise.c b/mm/madvise.c
index 539eeb9..7c13f8d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -202,6 +202,10 @@ static void force_shm_swapin_readahead(struct vm_area_struct *vma,
 			continue;
 		}
 		swap = radix_to_swp_entry(page);
+		if (is_hmm_entry(swap)) {
+			/* FIXME start migration here ? */
+			continue;
+		}
 		page = read_swap_cache_async(swap, GFP_HIGHUSER_MOVABLE,
 								NULL, 0);
 		if (page)
diff --git a/mm/mincore.c b/mm/mincore.c
index 725c809..107b870 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -79,6 +79,10 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 		 */
 		if (radix_tree_exceptional_entry(page)) {
 			swp_entry_t swp = radix_to_swp_entry(page);
+
+			if (is_hmm_entry(swp)) {
+				return 1;
+			}
 			page = find_get_page(swap_address_space(swp), swp.val);
 		}
 	} else
@@ -86,6 +90,13 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 #else
 	page = find_get_page(mapping, pgoff);
 #endif
+	if (radix_tree_exceptional_entry(page)) {
+		swp_entry_t swap = radix_to_swp_entry(page);
+
+		if (is_hmm_entry(swap)) {
+			return 1;
+		}
+	}
 	if (page) {
 		present = PageUptodate(page);
 		page_cache_release(page);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 023cf08..b6dcf80 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -37,6 +37,7 @@
 #include <linux/timer.h>
 #include <linux/sched/rt.h>
 #include <linux/mm_inline.h>
+#include <linux/hmm.h>
 #include <trace/events/writeback.h>
 
 #include "internal.h"
@@ -1900,6 +1901,8 @@ retry:
 		tag_pages_for_writeback(mapping, index, end);
 	done_index = index;
 	while (!done && (index <= end)) {
+		pgoff_t save_index = index;
+		bool migrated = false;
 		int i;
 
 		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
@@ -1907,58 +1910,106 @@ retry:
 		if (nr_pages == 0)
 			break;
 
+		for (i = 0, migrated = false; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				/* This can not happen ! */
+				BUG_ON(!is_hmm_entry(swap));
+				page = hmm_pagecache_writeback(mapping, swap);
+				if (page == NULL) {
+					migrated = true;
+					pvec.pages[i] = NULL;
+				}
+			}
+		}
+
+		/* Some rmem was migrated we need to redo the page cache lookup. */
+		if (migrated) {
+			for (i = 0; i < nr_pages; i++) {
+				struct page *page = pvec.pages[i];
+
+				if (page && radix_tree_exceptional_entry(page)) {
+					swp_entry_t swap = radix_to_swp_entry(page);
+
+					page = hmm_pagecache_page(mapping, swap);
+					unlock_page(page);
+					page_cache_release(page);
+					pvec.pages[i] = page;
+				}
+			}
+			pagevec_release(&pvec);
+			cond_resched();
+			index = save_index;
+			goto retry;
+		}
+
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
-			/*
-			 * At this point, the page may be truncated or
-			 * invalidated (changing page->mapping to NULL), or
-			 * even swizzled back from swapper_space to tmpfs file
-			 * mapping. However, page->index will not change
-			 * because we have a reference on the page.
-			 */
-			if (page->index > end) {
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				pvec.pages[i] = page = hmm_pagecache_page(mapping, swap);
+				page_cache_release(page);
+				done_index = page->index;
+			} else {
 				/*
-				 * can't be range_cyclic (1st pass) because
-				 * end == -1 in that case.
+				 * At this point, the page may be truncated or
+				 * invalidated (changing page->mapping to NULL), or
+				 * even swizzled back from swapper_space to tmpfs file
+				 * mapping. However, page->index will not change
+				 * because we have a reference on the page.
 				 */
-				done = 1;
-				break;
-			}
+				if (page->index > end) {
+					/*
+					 * can't be range_cyclic (1st pass) because
+					 * end == -1 in that case.
+					 */
+					done = 1;
+					break;
+				}
 
-			done_index = page->index;
+				done_index = page->index;
 
-			lock_page(page);
+				lock_page(page);
 
-			/*
-			 * Page truncated or invalidated. We can freely skip it
-			 * then, even for data integrity operations: the page
-			 * has disappeared concurrently, so there could be no
-			 * real expectation of this data interity operation
-			 * even if there is now a new, dirty page at the same
-			 * pagecache address.
-			 */
-			if (unlikely(page->mapping != mapping)) {
-continue_unlock:
-				unlock_page(page);
-				continue;
+				/*
+				 * Page truncated or invalidated. We can freely skip it
+				 * then, even for data integrity operations: the page
+				 * has disappeared concurrently, so there could be no
+				 * real expectation of this data interity operation
+				 * even if there is now a new, dirty page at the same
+				 * pagecache address.
+				 */
+				if (unlikely(page->mapping != mapping)) {
+					unlock_page(page);
+					continue;
+				}
 			}
 
 			if (!PageDirty(page)) {
 				/* someone wrote it for us */
-				goto continue_unlock;
+				unlock_page(page);
+				continue;
 			}
 
 			if (PageWriteback(page)) {
-				if (wbc->sync_mode != WB_SYNC_NONE)
+				if (wbc->sync_mode != WB_SYNC_NONE) {
 					wait_on_page_writeback(page);
-				else
-					goto continue_unlock;
+				} else {
+					unlock_page(page);
+					continue;
+				}
 			}
 
 			BUG_ON(PageWriteback(page));
-			if (!clear_page_dirty_for_io(page))
-				goto continue_unlock;
+			if (!clear_page_dirty_for_io(page)) {
+				unlock_page(page);
+				continue;
+			}
 
 			trace_wbc_writepage(wbc, mapping->backing_dev_info);
 			ret = (*writepage)(page, wbc, data);
@@ -1994,6 +2045,20 @@ continue_unlock:
 				break;
 			}
 		}
+
+		/* Some entry of pvec might still be exceptional ! */
+		for (i = 0; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				page = hmm_pagecache_page(mapping, swap);
+				unlock_page(page);
+				page_cache_release(page);
+				pvec.pages[i] = page;
+			}
+		}
 		pagevec_release(&pvec);
 		cond_resched();
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index e07450c..3b7fbd3c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1132,6 +1132,9 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	case TTU_MUNLOCK:
 		action = MMU_MUNLOCK;
 		break;
+	case TTU_HMM:
+		action = MMU_HMM;
+		break;
 	default:
 		/* Please report this ! */
 		BUG();
@@ -1327,6 +1330,9 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	case TTU_MUNLOCK:
 		action = MMU_MUNLOCK;
 		break;
+	case TTU_HMM:
+		action = MMU_HMM;
+		break;
 	default:
 		/* Please report this ! */
 		BUG();
@@ -1426,7 +1432,12 @@ static int try_to_unmap_nonlinear(struct page *page,
 	unsigned long cursor;
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
-	unsigned int mapcount;
+	unsigned int mapcount, min_mapcount = 0;
+
+	/* The hmm code keep mapcount elevated to 1 to avoid updating mm and
+	 * memcg. If we are call on behalf of hmm just ignore this extra 1.
+	 */
+	min_mapcount = (TTU_ACTION((enum ttu_flags)arg) == TTU_HMM) ? 1 : 0;
 
 	list_for_each_entry(vma,
 		&mapping->i_mmap_nonlinear, shared.nonlinear) {
@@ -1449,8 +1460,10 @@ static int try_to_unmap_nonlinear(struct page *page,
 	 * just walk the nonlinear vmas trying to age and unmap some.
 	 * The mapcount of the page we came in with is irrelevant,
 	 * but even so use it as a guide to how hard we should try?
+	 *
+	 * See comment about hmm above for min_mapcount.
 	 */
-	mapcount = page_mapcount(page);
+	mapcount = page_mapcount(page) - min_mapcount;
 	if (!mapcount)
 		return ret;
 
diff --git a/mm/swap.c b/mm/swap.c
index c0ed4d6..426fede 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -839,6 +839,15 @@ void release_pages(struct page **pages, int nr, int cold)
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
+		if (!page) {
+			continue;
+		}
+		if (radix_tree_exceptional_entry(page)) {
+			/* This should really not happen tell us about it ! */
+			WARN_ONCE(1, "hmm exceptional entry left\n");
+			continue;
+		}
+
 		if (unlikely(PageCompound(page))) {
 			if (zone) {
 				spin_unlock_irqrestore(&zone->lru_lock, flags);
diff --git a/mm/truncate.c b/mm/truncate.c
index 6a78c81..c979fd6 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -20,6 +20,7 @@
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
 #include <linux/cleancache.h>
+#include <linux/hmm.h>
 #include "internal.h"
 
 static void clear_exceptional_entry(struct address_space *mapping,
@@ -281,6 +282,32 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE),
 			indices)) {
+		bool migrated = false;
+
+		for (i = 0; i < pagevec_count(&pvec); ++i) {
+			struct page *page = pvec.pages[i];
+
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				/* FIXME How to handle hmm migration failure ? */
+				hmm_pagecache_migrate(mapping, swap);
+				for (; i < pagevec_count(&pvec); ++i) {
+					if (radix_tree_exceptional_entry(page)) {
+						pvec.pages[i] = NULL;
+					}
+				}
+				migrated = true;
+				break;
+			}
+		}
+
+		if (migrated) {
+			pagevec_release(&pvec);
+			cond_resched();
+			continue;
+		}
+
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
@@ -313,7 +340,16 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	}
 
 	if (partial_start) {
-		struct page *page = find_lock_page(mapping, start - 1);
+		struct page *page;
+
+	repeat_start:
+		page = find_lock_page(mapping, start - 1);
+		if (radix_tree_exceptional_entry(page)) {
+			swp_entry_t swap = radix_to_swp_entry(page);
+
+			hmm_pagecache_migrate(mapping, swap);
+			goto repeat_start;
+		}
 		if (page) {
 			unsigned int top = PAGE_CACHE_SIZE;
 			if (start > end) {
@@ -332,7 +368,15 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		}
 	}
 	if (partial_end) {
-		struct page *page = find_lock_page(mapping, end);
+		struct page *page;
+	repeat_end:
+		page = find_lock_page(mapping, end);
+		if (radix_tree_exceptional_entry(page)) {
+			swp_entry_t swap = radix_to_swp_entry(page);
+
+			hmm_pagecache_migrate(mapping, swap);
+			goto repeat_end;
+		}
 		if (page) {
 			wait_on_page_writeback(page);
 			zero_user_segment(page, 0, partial_end);
@@ -371,6 +415,9 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
+			/* FIXME Find a way to block rmem migration on truncate. */
+			BUG_ON(radix_tree_exceptional_entry(page));
+
 			/* We rely upon deletion not changing page->index */
 			index = indices[i];
 			if (index >= end)
@@ -488,6 +535,32 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 			indices)) {
+		bool migrated = false;
+
+		for (i = 0; i < pagevec_count(&pvec); ++i) {
+			struct page *page = pvec.pages[i];
+
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				/* FIXME How to handle hmm migration failure ? */
+				hmm_pagecache_migrate(mapping, swap);
+				for (; i < pagevec_count(&pvec); ++i) {
+					if (radix_tree_exceptional_entry(page)) {
+						pvec.pages[i] = NULL;
+					}
+				}
+				migrated = true;
+				break;
+			}
+		}
+
+		if (migrated) {
+			pagevec_release(&pvec);
+			cond_resched();
+			continue;
+		}
+
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
@@ -597,6 +670,32 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 			indices)) {
+		bool migrated = false;
+
+		for (i = 0; i < pagevec_count(&pvec); ++i) {
+			struct page *page = pvec.pages[i];
+
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				/* FIXME How to handle hmm migration failure ? */
+				hmm_pagecache_migrate(mapping, swap);
+				for (; i < pagevec_count(&pvec); ++i) {
+					if (radix_tree_exceptional_entry(page)) {
+						pvec.pages[i] = NULL;
+					}
+				}
+				migrated = true;
+				break;
+			}
+		}
+
+		if (migrated) {
+			pagevec_release(&pvec);
+			cond_resched();
+			continue;
+		}
+
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
