Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CAF7D280290
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:24:18 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n187so15062874pfn.10
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:24:18 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h132si4433169pgc.309.2018.01.17.12.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:22:30 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 03/99] xarray: Replace exceptional entries
Date: Wed, 17 Jan 2018 12:20:27 -0800
Message-Id: <20180117202203.19756-4-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Introduce xarray value entries to replace the radix tree exceptional
entry code.  This is a slight change in encoding to allow the use of an
extra bit (we can now store BITS_PER_LONG - 1 bits in a value entry).
It is also a change in emphasis; exceptional entries are intimidating
and different.  As the comment explains, you can choose to store values
or pointers in the xarray and they are both first-class citizens.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h    |   4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h    |   4 +-
 drivers/gpu/drm/i915/i915_gem.c                 |  17 ++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c |   2 +-
 fs/btrfs/compression.c                          |   2 +-
 fs/btrfs/inode.c                                |   4 +-
 fs/dax.c                                        | 107 ++++++++++++------------
 fs/proc/task_mmu.c                              |   2 +-
 include/linux/fs.h                              |  48 +++++++----
 include/linux/radix-tree.h                      |  36 ++------
 include/linux/swapops.h                         |  19 ++---
 include/linux/xarray.h                          |  51 +++++++++++
 lib/idr.c                                       |  63 ++++++--------
 lib/radix-tree.c                                |  21 ++---
 mm/filemap.c                                    |  10 +--
 mm/khugepaged.c                                 |   2 +-
 mm/madvise.c                                    |   2 +-
 mm/memcontrol.c                                 |   2 +-
 mm/mincore.c                                    |   2 +-
 mm/readahead.c                                  |   2 +-
 mm/shmem.c                                      |  10 +--
 mm/swap.c                                       |   2 +-
 mm/truncate.c                                   |  12 +--
 mm/workingset.c                                 |  12 ++-
 tools/testing/radix-tree/idr-test.c             |   6 +-
 tools/testing/radix-tree/linux/radix-tree.h     |   1 +
 tools/testing/radix-tree/multiorder.c           |  47 +++++------
 tools/testing/radix-tree/test.c                 |   2 +-
 28 files changed, 256 insertions(+), 236 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 44697817ccc6..5025c26f1acd 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -649,9 +649,7 @@ static inline bool pte_user(pte_t pte)
 	BUILD_BUG_ON(_PAGE_HPTEFLAGS & (0x1f << _PAGE_BIT_SWAP_TYPE)); \
 	BUILD_BUG_ON(_PAGE_HPTEFLAGS & _PAGE_SWP_SOFT_DIRTY);	\
 	} while (0)
-/*
- * on pte we don't need handle RADIX_TREE_EXCEPTIONAL_SHIFT;
- */
+
 #define SWP_TYPE_BITS 5
 #define __swp_type(x)		(((x).val >> _PAGE_BIT_SWAP_TYPE) \
 				& ((1UL << SWP_TYPE_BITS) - 1))
diff --git a/arch/powerpc/include/asm/nohash/64/pgtable.h b/arch/powerpc/include/asm/nohash/64/pgtable.h
index abddf5830ad5..f711773568d7 100644
--- a/arch/powerpc/include/asm/nohash/64/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/64/pgtable.h
@@ -329,9 +329,7 @@ static inline void __ptep_set_access_flags(struct mm_struct *mm,
 	 */							\
 	BUILD_BUG_ON(_PAGE_HPTEFLAGS & (0x1f << _PAGE_BIT_SWAP_TYPE)); \
 	} while (0)
-/*
- * on pte we don't need handle RADIX_TREE_EXCEPTIONAL_SHIFT;
- */
+
 #define SWP_TYPE_BITS 5
 #define __swp_type(x)		(((x).val >> _PAGE_BIT_SWAP_TYPE) \
 				& ((1UL << SWP_TYPE_BITS) - 1))
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 5cfba89ed586..25ce7bcf9988 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -5369,7 +5369,8 @@ i915_gem_object_get_sg(struct drm_i915_gem_object *obj,
 	count = __sg_page_count(sg);
 
 	while (idx + count <= n) {
-		unsigned long exception, i;
+		void *entry;
+		unsigned long i;
 		int ret;
 
 		/* If we cannot allocate and insert this entry, or the
@@ -5384,12 +5385,9 @@ i915_gem_object_get_sg(struct drm_i915_gem_object *obj,
 		if (ret && ret != -EEXIST)
 			goto scan;
 
-		exception =
-			RADIX_TREE_EXCEPTIONAL_ENTRY |
-			idx << RADIX_TREE_EXCEPTIONAL_SHIFT;
+		entry = xa_mk_value(idx);
 		for (i = 1; i < count; i++) {
-			ret = radix_tree_insert(&iter->radix, idx + i,
-						(void *)exception);
+			ret = radix_tree_insert(&iter->radix, idx + i, entry);
 			if (ret && ret != -EEXIST)
 				goto scan;
 		}
@@ -5427,15 +5425,14 @@ i915_gem_object_get_sg(struct drm_i915_gem_object *obj,
 	GEM_BUG_ON(!sg);
 
 	/* If this index is in the middle of multi-page sg entry,
-	 * the radixtree will contain an exceptional entry that points
+	 * the radix tree will contain a value entry that points
 	 * to the start of that range. We will return the pointer to
 	 * the base page and the offset of this page within the
 	 * sg entry's range.
 	 */
 	*offset = 0;
-	if (unlikely(radix_tree_exception(sg))) {
-		unsigned long base =
-			(unsigned long)sg >> RADIX_TREE_EXCEPTIONAL_SHIFT;
+	if (unlikely(xa_is_value(sg))) {
+		unsigned long base = xa_to_value(sg);
 
 		sg = radix_tree_lookup(&iter->radix, base);
 		GEM_BUG_ON(!sg);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 45dcf9f958d4..2ec79a6b17da 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -940,7 +940,7 @@ static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
 	xa_lock_irq(&mapping->pages);
 	found = radix_tree_gang_lookup(&mapping->pages,
 				       (void **)&page, offset, 1);
-	if (found > 0 && !radix_tree_exceptional_entry(page)) {
+	if (found > 0 && !xa_is_value(page)) {
 		struct lu_dirpage *dp;
 
 		get_page(page);
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 280717b26224..e687d06cd97c 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -452,7 +452,7 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->pages, pg_index);
 		rcu_read_unlock();
-		if (page && !radix_tree_exceptional_entry(page)) {
+		if (page && !xa_is_value(page)) {
 			misses++;
 			if (misses > 4)
 				break;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 712ae1dd572b..dbdb5bf6bca1 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7578,8 +7578,8 @@ bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
 			}
 			/*
 			 * Otherwise, shmem/tmpfs must be storing a swap entry
-			 * here as an exceptional entry: so return it without
-			 * attempting to raise page count.
+			 * here so return it without attempting to raise page
+			 * count.
 			 */
 			page = NULL;
 			break; /* TODO: Is this relevant for this use case? */
diff --git a/fs/dax.c b/fs/dax.c
index 0f3844bcf881..5097a606da1a 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -58,57 +58,57 @@ static int __init init_dax_wait_table(void)
 fs_initcall(init_dax_wait_table);
 
 /*
- * We use lowest available bit in exceptional entry for locking, one bit for
- * the entry size (PMD) and two more to tell us if the entry is a zero page or
- * an empty entry that is just used for locking.  In total four special bits.
+ * DAX pagecache entries use XArray value entries so they can't be mistaken
+ * for pages.  We use one bit for locking, one bit for the entry size (PMD)
+ * and two more to tell us if the entry is a zero page or an empty entry that
+ * is just used for locking.  In total four special bits.
  *
  * If the PMD bit isn't set the entry has size PAGE_SIZE, and if the ZERO_PAGE
  * and EMPTY bits aren't set the entry is a normal DAX entry with a filesystem
  * block allocation.
  */
-#define RADIX_DAX_SHIFT		(RADIX_TREE_EXCEPTIONAL_SHIFT + 4)
-#define RADIX_DAX_ENTRY_LOCK	(1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
-#define RADIX_DAX_PMD		(1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
-#define RADIX_DAX_ZERO_PAGE	(1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
-#define RADIX_DAX_EMPTY		(1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 3))
+#define DAX_SHIFT	(4)
+#define DAX_ENTRY_LOCK	(1UL << 0)
+#define DAX_PMD		(1UL << 1)
+#define DAX_ZERO_PAGE	(1UL << 2)
+#define DAX_EMPTY	(1UL << 3)
 
 static unsigned long dax_radix_sector(void *entry)
 {
-	return (unsigned long)entry >> RADIX_DAX_SHIFT;
+	return xa_to_value(entry) >> DAX_SHIFT;
 }
 
 static void *dax_radix_locked_entry(sector_t sector, unsigned long flags)
 {
-	return (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY | flags |
-			((unsigned long)sector << RADIX_DAX_SHIFT) |
-			RADIX_DAX_ENTRY_LOCK);
+	return xa_mk_value(flags | ((unsigned long)sector << DAX_SHIFT) |
+			DAX_ENTRY_LOCK);
 }
 
 static unsigned int dax_radix_order(void *entry)
 {
-	if ((unsigned long)entry & RADIX_DAX_PMD)
+	if (xa_to_value(entry) & DAX_PMD)
 		return PMD_SHIFT - PAGE_SHIFT;
 	return 0;
 }
 
 static int dax_is_pmd_entry(void *entry)
 {
-	return (unsigned long)entry & RADIX_DAX_PMD;
+	return xa_to_value(entry) & DAX_PMD;
 }
 
 static int dax_is_pte_entry(void *entry)
 {
-	return !((unsigned long)entry & RADIX_DAX_PMD);
+	return !(xa_to_value(entry) & DAX_PMD);
 }
 
 static int dax_is_zero_entry(void *entry)
 {
-	return (unsigned long)entry & RADIX_DAX_ZERO_PAGE;
+	return xa_to_value(entry) & DAX_ZERO_PAGE;
 }
 
 static int dax_is_empty_entry(void *entry)
 {
-	return (unsigned long)entry & RADIX_DAX_EMPTY;
+	return xa_to_value(entry) & DAX_EMPTY;
 }
 
 /*
@@ -185,9 +185,9 @@ static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
  */
 static inline int slot_locked(struct address_space *mapping, void **slot)
 {
-	unsigned long entry = (unsigned long)
-		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock);
-	return entry & RADIX_DAX_ENTRY_LOCK;
+	unsigned long entry = xa_to_value(
+		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock));
+	return entry & DAX_ENTRY_LOCK;
 }
 
 /*
@@ -195,12 +195,11 @@ static inline int slot_locked(struct address_space *mapping, void **slot)
  */
 static inline void *lock_slot(struct address_space *mapping, void **slot)
 {
-	unsigned long entry = (unsigned long)
-		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock);
-
-	entry |= RADIX_DAX_ENTRY_LOCK;
-	radix_tree_replace_slot(&mapping->pages, slot, (void *)entry);
-	return (void *)entry;
+	unsigned long v = xa_to_value(
+		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock));
+	void *entry = xa_mk_value(v | DAX_ENTRY_LOCK);
+	radix_tree_replace_slot(&mapping->pages, slot, entry);
+	return entry;
 }
 
 /*
@@ -208,17 +207,16 @@ static inline void *lock_slot(struct address_space *mapping, void **slot)
  */
 static inline void *unlock_slot(struct address_space *mapping, void **slot)
 {
-	unsigned long entry = (unsigned long)
-		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock);
-
-	entry &= ~(unsigned long)RADIX_DAX_ENTRY_LOCK;
-	radix_tree_replace_slot(&mapping->pages, slot, (void *)entry);
-	return (void *)entry;
+	unsigned long v = xa_to_value(
+		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock));
+	void *entry = xa_mk_value(v & ~DAX_ENTRY_LOCK);
+	radix_tree_replace_slot(&mapping->pages, slot, entry);
+	return entry;
 }
 
 /*
  * Lookup entry in radix tree, wait for it to become unlocked if it is
- * exceptional entry and return it. The caller must call
+ * a DAX entry and return it. The caller must call
  * put_unlocked_mapping_entry() when he decided not to lock the entry or
  * put_locked_mapping_entry() when he locked the entry and now wants to
  * unlock it.
@@ -239,7 +237,7 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 		entry = __radix_tree_lookup(&mapping->pages, index, NULL,
 					  &slot);
 		if (!entry ||
-		    WARN_ON_ONCE(!radix_tree_exceptional_entry(entry)) ||
+		    WARN_ON_ONCE(!xa_is_value(entry)) ||
 		    !slot_locked(mapping, slot)) {
 			if (slotp)
 				*slotp = slot;
@@ -263,7 +261,7 @@ static void dax_unlock_mapping_entry(struct address_space *mapping,
 
 	xa_lock_irq(&mapping->pages);
 	entry = __radix_tree_lookup(&mapping->pages, index, NULL, &slot);
-	if (WARN_ON_ONCE(!entry || !radix_tree_exceptional_entry(entry) ||
+	if (WARN_ON_ONCE(!entry || !xa_is_value(entry) ||
 			 !slot_locked(mapping, slot))) {
 		xa_unlock_irq(&mapping->pages);
 		return;
@@ -294,12 +292,11 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
 }
 
 /*
- * Find radix tree entry at given index. If it points to an exceptional entry,
- * return it with the radix tree entry locked. If the radix tree doesn't
- * contain given index, create an empty exceptional entry for the index and
- * return with it locked.
+ * Find radix tree entry at given index. If it is a DAX entry, return it
+ * with the radix tree entry locked. If the radix tree doesn't contain the
+ * given index, create an empty entry for the index and return with it locked.
  *
- * When requesting an entry with size RADIX_DAX_PMD, grab_mapping_entry() will
+ * When requesting an entry with size DAX_PMD, grab_mapping_entry() will
  * either return that locked entry or will return an error.  This error will
  * happen if there are any 4k entries within the 2MiB range that we are
  * requesting.
@@ -329,13 +326,13 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 	xa_lock_irq(&mapping->pages);
 	entry = get_unlocked_mapping_entry(mapping, index, &slot);
 
-	if (WARN_ON_ONCE(entry && !radix_tree_exceptional_entry(entry))) {
+	if (WARN_ON_ONCE(entry && !xa_is_value(entry))) {
 		entry = ERR_PTR(-EIO);
 		goto out_unlock;
 	}
 
 	if (entry) {
-		if (size_flag & RADIX_DAX_PMD) {
+		if (size_flag & DAX_PMD) {
 			if (dax_is_pte_entry(entry)) {
 				put_unlocked_mapping_entry(mapping, index,
 						entry);
@@ -405,7 +402,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 					true);
 		}
 
-		entry = dax_radix_locked_entry(0, size_flag | RADIX_DAX_EMPTY);
+		entry = dax_radix_locked_entry(0, size_flag | DAX_EMPTY);
 
 		err = __radix_tree_insert(&mapping->pages, index,
 				dax_radix_order(entry), entry);
@@ -442,7 +439,7 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 
 	xa_lock_irq(&mapping->pages);
 	entry = get_unlocked_mapping_entry(mapping, index, NULL);
-	if (!entry || WARN_ON_ONCE(!radix_tree_exceptional_entry(entry)))
+	if (!entry || WARN_ON_ONCE(!xa_is_value(entry)))
 		goto out;
 	if (!trunc &&
 	    (radix_tree_tag_get(pages, index, PAGECACHE_TAG_DIRTY) ||
@@ -457,8 +454,8 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 	return ret;
 }
 /*
- * Delete exceptional DAX entry at @index from @mapping. Wait for radix tree
- * entry to get unlocked before deleting it.
+ * Delete DAX entry at @index from @mapping.  Wait for it
+ * to be unlocked before deleting it.
  */
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 {
@@ -468,7 +465,7 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 	 * This gets called from truncate / punch_hole path. As such, the caller
 	 * must hold locks protecting against concurrent modifications of the
 	 * radix tree (usually fs-private i_mmap_sem for writing). Since the
-	 * caller has seen exceptional entry for this index, we better find it
+	 * caller has seen a DAX entry for this index, we better find it
 	 * at that index as well...
 	 */
 	WARN_ON_ONCE(!ret);
@@ -476,7 +473,7 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 }
 
 /*
- * Invalidate exceptional DAX entry if it is clean.
+ * Invalidate DAX entry if it is clean.
  */
 int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
 				      pgoff_t index)
@@ -530,7 +527,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 	if (dirty)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 
-	if (dax_is_zero_entry(entry) && !(flags & RADIX_DAX_ZERO_PAGE)) {
+	if (dax_is_zero_entry(entry) && !(flags & DAX_ZERO_PAGE)) {
 		/* we are replacing a zero page with block mapping */
 		if (dax_is_pmd_entry(entry))
 			unmap_mapping_range(mapping,
@@ -669,13 +666,13 @@ static int dax_writeback_one(struct block_device *bdev,
 	 * A page got tagged dirty in DAX mapping? Something is seriously
 	 * wrong.
 	 */
-	if (WARN_ON(!radix_tree_exceptional_entry(entry)))
+	if (WARN_ON(!xa_is_value(entry)))
 		return -EIO;
 
 	xa_lock_irq(&mapping->pages);
 	entry2 = get_unlocked_mapping_entry(mapping, index, &slot);
 	/* Entry got punched out / reallocated? */
-	if (!entry2 || WARN_ON_ONCE(!radix_tree_exceptional_entry(entry2)))
+	if (!entry2 || WARN_ON_ONCE(!xa_is_value(entry2)))
 		goto put_unlocked;
 	/*
 	 * Entry got reallocated elsewhere? No need to writeback. We have to
@@ -881,7 +878,7 @@ static int dax_load_hole(struct address_space *mapping, void *entry,
 	}
 
 	entry2 = dax_insert_mapping_entry(mapping, vmf, entry, 0,
-			RADIX_DAX_ZERO_PAGE, false);
+			DAX_ZERO_PAGE, false);
 	if (IS_ERR(entry2)) {
 		ret = VM_FAULT_SIGBUS;
 		goto out;
@@ -1287,7 +1284,7 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 		goto fallback;
 
 	ret = dax_insert_mapping_entry(mapping, vmf, entry, 0,
-			RADIX_DAX_PMD | RADIX_DAX_ZERO_PAGE, false);
+			DAX_PMD | DAX_ZERO_PAGE, false);
 	if (IS_ERR(ret))
 		goto fallback;
 
@@ -1372,7 +1369,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	 * is already in the tree, for instance), it will return -EEXIST and
 	 * we just fall back to 4k entries.
 	 */
-	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
+	entry = grab_mapping_entry(mapping, pgoff, DAX_PMD);
 	if (IS_ERR(entry))
 		goto fallback;
 
@@ -1411,7 +1408,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 
 		entry = dax_insert_mapping_entry(mapping, vmf, entry,
 						dax_iomap_sector(&iomap, pos),
-						RADIX_DAX_PMD, write && !sync);
+						DAX_PMD, write && !sync);
 		if (IS_ERR(entry))
 			goto finish_iomap;
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 339e4c1c044d..fadc6dbe17d6 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -553,7 +553,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 		if (!page)
 			return;
 
-		if (radix_tree_exceptional_entry(page))
+		if (xa_is_value(page))
 			mss->swap += PAGE_SIZE;
 		else
 			put_page(page);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c07169cfb44a..e4345c13e237 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -389,23 +389,41 @@ int pagecache_write_end(struct file *, struct address_space *mapping,
 				loff_t pos, unsigned len, unsigned copied,
 				struct page *page, void *fsdata);
 
+/**
+ * struct address_space - Contents of a cachable, mappable object
+ *
+ * @host: Owner, either the inode or the block_device
+ * @pages: Cached pages
+ * @gfp_mask: Memory allocation flags to use for allocating pages
+ * @i_mmap_writable: count VM_SHARED mappings
+ * @i_mmap: tree of private and shared mappings
+ * @i_mmap_rwsem: Protects @i_mmap and @i_mmap_writable
+ * @nrpages: Number of total pages, protected by pages.xa_lock
+ * @nrexceptional: Shadow or DAX entries, protected by pages.xa_lock
+ * @writeback_index: writeback starts here
+ * @a_ops: methods
+ * @flags: Error bits and flags (AS_*)
+ * @wb_err: The most recent error which has occurred
+ * @private_lock: For use by the owner of the address_space
+ * @private_list: For use by the owner of the address space
+ * @private_data: For use by the owner of the address space
+ */
 struct address_space {
-	struct inode		*host;		/* owner: inode, block_device */
-	struct radix_tree_root	pages;		/* cached pages */
-	gfp_t			gfp_mask;	/* for allocating pages */
-	atomic_t		i_mmap_writable;/* count VM_SHARED mappings */
-	struct rb_root_cached	i_mmap;		/* tree of private and shared mappings */
-	struct rw_semaphore	i_mmap_rwsem;	/* protect tree, count, list */
-	/* Protected by pages.xa_lock */
-	unsigned long		nrpages;	/* number of total pages */
-	unsigned long		nrexceptional;	/* shadow or DAX entries */
-	pgoff_t			writeback_index;/* writeback starts here */
-	const struct address_space_operations *a_ops;	/* methods */
-	unsigned long		flags;		/* error bits */
+	struct inode		*host;
+	struct radix_tree_root	pages;
+	gfp_t			gfp_mask;
+	atomic_t		i_mmap_writable;
+	struct rb_root_cached	i_mmap;
+	struct rw_semaphore	i_mmap_rwsem;
+	unsigned long		nrpages;
+	unsigned long		nrexceptional;
+	pgoff_t			writeback_index;
+	const struct address_space_operations *a_ops;
+	unsigned long		flags;
 	errseq_t		wb_err;
-	spinlock_t		private_lock;	/* for use by the address_space */
-	struct list_head	private_list;	/* ditto */
-	void			*private_data;	/* ditto */
+	spinlock_t		private_lock;
+	struct list_head	private_list;
+	void			*private_data;
 } __attribute__((aligned(sizeof(long)))) __randomize_layout;
 	/*
 	 * On most architectures that alignment is already the case; but
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 34149e8b5f73..87f35fe00e55 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -28,34 +28,26 @@
 #include <linux/rcupdate.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
+#include <linux/xarray.h>
 
 /*
  * The bottom two bits of the slot determine how the remaining bits in the
  * slot are interpreted:
  *
  * 00 - data pointer
- * 01 - internal entry
- * 10 - exceptional entry
- * 11 - this bit combination is currently unused/reserved
+ * 10 - internal entry
+ * x1 - value entry
  *
  * The internal entry may be a pointer to the next level in the tree, a
  * sibling entry, or an indicator that the entry in this slot has been moved
  * to another location in the tree and the lookup should be restarted.  While
  * NULL fits the 'data pointer' pattern, it means that there is no entry in
  * the tree for this index (no matter what level of the tree it is found at).
- * This means that you cannot store NULL in the tree as a value for the index.
+ * This means that storing a NULL entry in the tree is the same as deleting
+ * the entry from the tree.
  */
 #define RADIX_TREE_ENTRY_MASK		3UL
-#define RADIX_TREE_INTERNAL_NODE	1UL
-
-/*
- * Most users of the radix tree store pointers but shmem/tmpfs stores swap
- * entries in the same tree.  They are marked as exceptional entries to
- * distinguish them from pointers to struct page.
- * EXCEPTIONAL_ENTRY tests the bit, EXCEPTIONAL_SHIFT shifts content past it.
- */
-#define RADIX_TREE_EXCEPTIONAL_ENTRY	2
-#define RADIX_TREE_EXCEPTIONAL_SHIFT	2
+#define RADIX_TREE_INTERNAL_NODE	2UL
 
 static inline bool radix_tree_is_internal_node(void *ptr)
 {
@@ -83,11 +75,10 @@ static inline bool radix_tree_is_internal_node(void *ptr)
 
 /*
  * @count is the count of every non-NULL element in the ->slots array
- * whether that is an exceptional entry, a retry entry, a user pointer,
+ * whether that is a data entry, a retry entry, a user pointer,
  * a sibling entry or a pointer to the next level of the tree.
  * @exceptional is the count of every element in ->slots which is
- * either radix_tree_exceptional_entry() or is a sibling entry for an
- * exceptional entry.
+ * either a data entry or a sibling entry for data.
  */
 struct radix_tree_node {
 	unsigned char	shift;		/* Bits remaining in each slot */
@@ -268,17 +259,6 @@ static inline int radix_tree_deref_retry(void *arg)
 	return unlikely(radix_tree_is_internal_node(arg));
 }
 
-/**
- * radix_tree_exceptional_entry	- radix_tree_deref_slot gave exceptional entry?
- * @arg:	value returned by radix_tree_deref_slot
- * Returns:	0 if well-aligned pointer, non-0 if exceptional entry.
- */
-static inline int radix_tree_exceptional_entry(void *arg)
-{
-	/* Not unlikely because radix_tree_exception often tested first */
-	return (unsigned long)arg & RADIX_TREE_EXCEPTIONAL_ENTRY;
-}
-
 /**
  * radix_tree_exception	- radix_tree_deref_slot returned either exception?
  * @arg:	value returned by radix_tree_deref_slot
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 9c5a2628d6ce..5e93c7b500da 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -17,9 +17,8 @@
  *
  * swp_entry_t's are *never* stored anywhere in their arch-dependent format.
  */
-#define SWP_TYPE_SHIFT(e)	((sizeof(e.val) * 8) - \
-			(MAX_SWAPFILES_SHIFT + RADIX_TREE_EXCEPTIONAL_SHIFT))
-#define SWP_OFFSET_MASK(e)	((1UL << SWP_TYPE_SHIFT(e)) - 1)
+#define SWP_TYPE_SHIFT	(BITS_PER_XA_VALUE - MAX_SWAPFILES_SHIFT)
+#define SWP_OFFSET_MASK	((1UL << SWP_TYPE_SHIFT) - 1)
 
 /*
  * Store a type+offset into a swp_entry_t in an arch-independent format
@@ -28,8 +27,7 @@ static inline swp_entry_t swp_entry(unsigned long type, pgoff_t offset)
 {
 	swp_entry_t ret;
 
-	ret.val = (type << SWP_TYPE_SHIFT(ret)) |
-			(offset & SWP_OFFSET_MASK(ret));
+	ret.val = (type << SWP_TYPE_SHIFT) | (offset & SWP_OFFSET_MASK);
 	return ret;
 }
 
@@ -39,7 +37,7 @@ static inline swp_entry_t swp_entry(unsigned long type, pgoff_t offset)
  */
 static inline unsigned swp_type(swp_entry_t entry)
 {
-	return (entry.val >> SWP_TYPE_SHIFT(entry));
+	return (entry.val >> SWP_TYPE_SHIFT);
 }
 
 /*
@@ -48,7 +46,7 @@ static inline unsigned swp_type(swp_entry_t entry)
  */
 static inline pgoff_t swp_offset(swp_entry_t entry)
 {
-	return entry.val & SWP_OFFSET_MASK(entry);
+	return entry.val & SWP_OFFSET_MASK;
 }
 
 #ifdef CONFIG_MMU
@@ -89,16 +87,13 @@ static inline swp_entry_t radix_to_swp_entry(void *arg)
 {
 	swp_entry_t entry;
 
-	entry.val = (unsigned long)arg >> RADIX_TREE_EXCEPTIONAL_SHIFT;
+	entry.val = xa_to_value(arg);
 	return entry;
 }
 
 static inline void *swp_to_radix_entry(swp_entry_t entry)
 {
-	unsigned long value;
-
-	value = entry.val << RADIX_TREE_EXCEPTIONAL_SHIFT;
-	return (void *)(value | RADIX_TREE_EXCEPTIONAL_ENTRY);
+	return xa_mk_value(entry.val);
 }
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 2dfc8006fe64..1aa4ff0c19b6 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -5,9 +5,60 @@
  * eXtensible Arrays
  * Copyright (c) 2017 Microsoft Corporation
  * Author: Matthew Wilcox <mawilcox@microsoft.com>
+ *
+ * See Documentation/core-api/xarray.rst for how to use the XArray.
  */
 
+#include <linux/bug.h>
 #include <linux/spinlock.h>
+#include <linux/types.h>
+
+/*
+ * The bottom two bits of the entry determine how the XArray interprets
+ * the contents:
+ *
+ * 00: Pointer entry
+ * 10: Internal entry
+ * x1: Value entry
+ *
+ * Attempting to store internal entries in the XArray is a bug.
+ */
+
+#define BITS_PER_XA_VALUE	(BITS_PER_LONG - 1)
+
+/**
+ * xa_mk_value() - Create an XArray entry from an integer.
+ * @v: Value to store in XArray.
+ *
+ * Return: An entry suitable for storing in the XArray.
+ */
+static inline void *xa_mk_value(unsigned long v)
+{
+	WARN_ON((long)v < 0);
+	return (void *)((v << 1) | 1);
+}
+
+/**
+ * xa_to_value() - Get value stored in an XArray entry.
+ * @entry: XArray entry.
+ *
+ * Return: The value stored in the XArray entry.
+ */
+static inline unsigned long xa_to_value(const void *entry)
+{
+	return (unsigned long)entry >> 1;
+}
+
+/**
+ * xa_is_value() - Determine if an entry is a value.
+ * @entry: XArray entry.
+ *
+ * Return: True if the entry is a value, false if it is a pointer.
+ */
+static inline bool xa_is_value(const void *entry)
+{
+	return (unsigned long)entry & 1;
+}
 
 #define xa_trylock(xa)		spin_trylock(&(xa)->xa_lock)
 #define xa_lock(xa)		spin_lock(&(xa)->xa_lock)
diff --git a/lib/idr.c b/lib/idr.c
index 2cd9429e11e3..48c53890adc0 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -3,6 +3,7 @@
 #include <linux/idr.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/xarray.h>
 
 DEFINE_PER_CPU(struct ida_bitmap *, ida_bitmap);
 static DEFINE_SPINLOCK(simple_ida_lock);
@@ -273,11 +274,8 @@ EXPORT_SYMBOL(idr_replace);
  * by the number of bits in the leaf bitmap before doing a radix tree lookup.
  *
  * As an optimisation, if there are only a few low bits set in any given
- * leaf, instead of allocating a 128-byte bitmap, we use the 'exceptional
- * entry' functionality of the radix tree to store BITS_PER_LONG - 2 bits
- * directly in the entry.  By being really tricksy, we could store
- * BITS_PER_LONG - 1 bits, but there're diminishing returns after optimising
- * for 0-3 allocated IDs.
+ * leaf, instead of allocating a 128-byte bitmap, we store the bits
+ * directly in the entry.
  *
  * We allow the radix tree 'exceptional' count to get out of date.  Nothing
  * in the IDA nor the radix tree code checks it.  If it becomes important
@@ -319,12 +317,11 @@ int ida_get_new_above(struct ida *ida, int start, int *id)
 	struct radix_tree_iter iter;
 	struct ida_bitmap *bitmap;
 	unsigned long index;
-	unsigned bit, ebit;
+	unsigned bit;
 	int new;
 
 	index = start / IDA_BITMAP_BITS;
 	bit = start % IDA_BITMAP_BITS;
-	ebit = bit + RADIX_TREE_EXCEPTIONAL_SHIFT;
 
 	slot = radix_tree_iter_init(&iter, index);
 	for (;;) {
@@ -339,26 +336,25 @@ int ida_get_new_above(struct ida *ida, int start, int *id)
 				return PTR_ERR(slot);
 			}
 		}
-		if (iter.index > index) {
+		if (iter.index > index)
 			bit = 0;
-			ebit = RADIX_TREE_EXCEPTIONAL_SHIFT;
-		}
 		new = iter.index * IDA_BITMAP_BITS;
 		bitmap = rcu_dereference_raw(*slot);
-		if (radix_tree_exception(bitmap)) {
-			unsigned long tmp = (unsigned long)bitmap;
-			ebit = find_next_zero_bit(&tmp, BITS_PER_LONG, ebit);
-			if (ebit < BITS_PER_LONG) {
-				tmp |= 1UL << ebit;
-				rcu_assign_pointer(*slot, (void *)tmp);
-				*id = new + ebit - RADIX_TREE_EXCEPTIONAL_SHIFT;
+		if (xa_is_value(bitmap)) {
+			unsigned long tmp = xa_to_value(bitmap);
+			int vbit = find_next_zero_bit(&tmp, BITS_PER_XA_VALUE,
+							bit);
+			if (vbit < BITS_PER_XA_VALUE) {
+				tmp |= 1UL << vbit;
+				rcu_assign_pointer(*slot, xa_mk_value(tmp));
+				*id = new + vbit;
 				return 0;
 			}
 			bitmap = this_cpu_xchg(ida_bitmap, NULL);
 			if (!bitmap)
 				return -EAGAIN;
 			memset(bitmap, 0, sizeof(*bitmap));
-			bitmap->bitmap[0] = tmp >> RADIX_TREE_EXCEPTIONAL_SHIFT;
+			bitmap->bitmap[0] = tmp;
 			rcu_assign_pointer(*slot, bitmap);
 		}
 
@@ -379,19 +375,15 @@ int ida_get_new_above(struct ida *ida, int start, int *id)
 			new += bit;
 			if (new < 0)
 				return -ENOSPC;
-			if (ebit < BITS_PER_LONG) {
-				bitmap = (void *)((1UL << ebit) |
-						RADIX_TREE_EXCEPTIONAL_ENTRY);
-				radix_tree_iter_replace(root, &iter, slot,
-						bitmap);
-				*id = new;
-				return 0;
+			if (bit < BITS_PER_XA_VALUE) {
+				bitmap = xa_mk_value(1UL << bit);
+			} else {
+				bitmap = this_cpu_xchg(ida_bitmap, NULL);
+				if (!bitmap)
+					return -EAGAIN;
+				memset(bitmap, 0, sizeof(*bitmap));
+				__set_bit(bit, bitmap->bitmap);
 			}
-			bitmap = this_cpu_xchg(ida_bitmap, NULL);
-			if (!bitmap)
-				return -EAGAIN;
-			memset(bitmap, 0, sizeof(*bitmap));
-			__set_bit(bit, bitmap->bitmap);
 			radix_tree_iter_replace(root, &iter, slot, bitmap);
 		}
 
@@ -422,9 +414,9 @@ void ida_remove(struct ida *ida, int id)
 		goto err;
 
 	bitmap = rcu_dereference_raw(*slot);
-	if (radix_tree_exception(bitmap)) {
+	if (xa_is_value(bitmap)) {
 		btmp = (unsigned long *)slot;
-		offset += RADIX_TREE_EXCEPTIONAL_SHIFT;
+		offset += 1; /* Intimate knowledge of the xa_data encoding */
 		if (offset >= BITS_PER_LONG)
 			goto err;
 	} else {
@@ -435,9 +427,8 @@ void ida_remove(struct ida *ida, int id)
 
 	__clear_bit(offset, btmp);
 	radix_tree_iter_tag_set(&ida->ida_rt, &iter, IDR_FREE);
-	if (radix_tree_exception(bitmap)) {
-		if (rcu_dereference_raw(*slot) ==
-					(void *)RADIX_TREE_EXCEPTIONAL_ENTRY)
+	if (xa_is_value(bitmap)) {
+		if (xa_to_value(rcu_dereference_raw(*slot)) == 0)
 			radix_tree_iter_delete(&ida->ida_rt, &iter, slot);
 	} else if (bitmap_empty(btmp, IDA_BITMAP_BITS)) {
 		kfree(bitmap);
@@ -465,7 +456,7 @@ void ida_destroy(struct ida *ida)
 
 	radix_tree_for_each_slot(slot, &ida->ida_rt, &iter, 0) {
 		struct ida_bitmap *bitmap = rcu_dereference_raw(*slot);
-		if (!radix_tree_exception(bitmap))
+		if (!xa_is_value(bitmap))
 			kfree(bitmap);
 		radix_tree_iter_delete(&ida->ida_rt, &iter, slot);
 	}
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 8428cc8af3fc..012e4869f99b 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -339,14 +339,12 @@ static void dump_ida_node(void *entry, unsigned long index)
 		for (i = 0; i < RADIX_TREE_MAP_SIZE; i++)
 			dump_ida_node(node->slots[i],
 					index | (i << node->shift));
-	} else if (radix_tree_exceptional_entry(entry)) {
+	} else if (xa_is_value(entry)) {
 		pr_debug("ida excp: %p offset %d indices %lu-%lu data %lx\n",
 				entry, (int)(index & RADIX_TREE_MAP_MASK),
 				index * IDA_BITMAP_BITS,
-				index * IDA_BITMAP_BITS + BITS_PER_LONG -
-					RADIX_TREE_EXCEPTIONAL_SHIFT,
-				(unsigned long)entry >>
-					RADIX_TREE_EXCEPTIONAL_SHIFT);
+				index * IDA_BITMAP_BITS + BITS_PER_XA_VALUE,
+				xa_to_value(entry));
 	} else {
 		struct ida_bitmap *bitmap = entry;
 
@@ -655,7 +653,7 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 		BUG_ON(shift > BITS_PER_LONG);
 		if (radix_tree_is_internal_node(entry)) {
 			entry_to_node(entry)->parent = node;
-		} else if (radix_tree_exceptional_entry(entry)) {
+		} else if (xa_is_value(entry)) {
 			/* Moving an exceptional root->rnode to a node */
 			node->exceptional = 1;
 		}
@@ -946,12 +944,12 @@ static inline int insert_entries(struct radix_tree_node *node,
 					!is_sibling_entry(node, old) &&
 					(old != RADIX_TREE_RETRY))
 			radix_tree_free_nodes(old);
-		if (radix_tree_exceptional_entry(old))
+		if (xa_is_value(old))
 			node->exceptional--;
 	}
 	if (node) {
 		node->count += n;
-		if (radix_tree_exceptional_entry(item))
+		if (xa_is_value(item))
 			node->exceptional += n;
 	}
 	return n;
@@ -965,7 +963,7 @@ static inline int insert_entries(struct radix_tree_node *node,
 	rcu_assign_pointer(*slot, item);
 	if (node) {
 		node->count++;
-		if (radix_tree_exceptional_entry(item))
+		if (xa_is_value(item))
 			node->exceptional++;
 	}
 	return 1;
@@ -1182,8 +1180,7 @@ void __radix_tree_replace(struct radix_tree_root *root,
 			  radix_tree_update_node_t update_node)
 {
 	void *old = rcu_dereference_raw(*slot);
-	int exceptional = !!radix_tree_exceptional_entry(item) -
-				!!radix_tree_exceptional_entry(old);
+	int exceptional = !!xa_is_value(item) - !!xa_is_value(old);
 	int count = calculate_count(root, node, slot, item, old);
 
 	/*
@@ -1986,7 +1983,7 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
 				struct radix_tree_node *node, void __rcu **slot)
 {
 	void *old = rcu_dereference_raw(*slot);
-	int exceptional = radix_tree_exceptional_entry(old) ? -1 : 0;
+	int exceptional = xa_is_value(old) ? -1 : 0;
 	unsigned offset = get_slot_offset(node, slot);
 	int tag;
 
diff --git a/mm/filemap.c b/mm/filemap.c
index e9172cefeb36..309be963140c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -128,7 +128,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 
 		p = radix_tree_deref_slot_protected(slot,
 						    &mapping->pages.xa_lock);
-		if (!radix_tree_exceptional_entry(p))
+		if (!xa_is_value(p))
 			return -EEXIST;
 
 		mapping->nrexceptional--;
@@ -337,7 +337,7 @@ page_cache_tree_delete_batch(struct address_space *mapping,
 			break;
 		page = radix_tree_deref_slot_protected(slot,
 						       &mapping->pages.xa_lock);
-		if (radix_tree_exceptional_entry(page))
+		if (xa_is_value(page))
 			continue;
 		if (!tail_pages) {
 			/*
@@ -1356,7 +1356,7 @@ pgoff_t page_cache_next_hole(struct address_space *mapping,
 		struct page *page;
 
 		page = radix_tree_lookup(&mapping->pages, index);
-		if (!page || radix_tree_exceptional_entry(page))
+		if (!page || xa_is_value(page))
 			break;
 		index++;
 		if (index == 0)
@@ -1397,7 +1397,7 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
 		struct page *page;
 
 		page = radix_tree_lookup(&mapping->pages, index);
-		if (!page || radix_tree_exceptional_entry(page))
+		if (!page || xa_is_value(page))
 			break;
 		index--;
 		if (index == ULONG_MAX)
@@ -1540,7 +1540,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 
 repeat:
 	page = find_get_entry(mapping, offset);
-	if (radix_tree_exceptional_entry(page))
+	if (xa_is_value(page))
 		page = NULL;
 	if (!page)
 		goto no_page;
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index cb4d199bf328..55ade70c33bb 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1363,7 +1363,7 @@ static void collapse_shmem(struct mm_struct *mm,
 
 		page = radix_tree_deref_slot_protected(slot,
 				&mapping->pages.xa_lock);
-		if (radix_tree_exceptional_entry(page) || !PageUptodate(page)) {
+		if (xa_is_value(page) || !PageUptodate(page)) {
 			xa_unlock_irq(&mapping->pages);
 			/* swap in or instantiate fallocated page */
 			if (shmem_getpage(mapping->host, index, &page,
diff --git a/mm/madvise.c b/mm/madvise.c
index 751e97aa2210..83f8a1a8e6b5 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -251,7 +251,7 @@ static void force_shm_swapin_readahead(struct vm_area_struct *vma,
 		index = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
 		page = find_get_entry(mapping, index);
-		if (!radix_tree_exceptional_entry(page)) {
+		if (!xa_is_value(page)) {
 			if (page)
 				put_page(page);
 			continue;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1d4acb7f33e9..f25ef5367fe7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4526,7 +4526,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 	/* shmem/tmpfs may report page out on swap: account for that too. */
 	if (shmem_mapping(mapping)) {
 		page = find_get_entry(mapping, pgoff);
-		if (radix_tree_exceptional_entry(page)) {
+		if (xa_is_value(page)) {
 			swp_entry_t swp = radix_to_swp_entry(page);
 			if (do_memsw_account())
 				*entry = swp;
diff --git a/mm/mincore.c b/mm/mincore.c
index fc37afe226e6..4985965aa20a 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -66,7 +66,7 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 		 * shmem/tmpfs may return swap: account for swapcache
 		 * page too.
 		 */
-		if (radix_tree_exceptional_entry(page)) {
+		if (xa_is_value(page)) {
 			swp_entry_t swp = radix_to_swp_entry(page);
 			page = find_get_page(swap_address_space(swp),
 					     swp_offset(swp));
diff --git a/mm/readahead.c b/mm/readahead.c
index 514188fd2489..4851f002605f 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -177,7 +177,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->pages, page_offset);
 		rcu_read_unlock();
-		if (page && !radix_tree_exceptional_entry(page))
+		if (page && !xa_is_value(page))
 			continue;
 
 		page = __page_cache_alloc(gfp_mask);
diff --git a/mm/shmem.c b/mm/shmem.c
index 9b1766e7c8cf..c5731bb954a1 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -690,7 +690,7 @@ unsigned long shmem_partial_swap_usage(struct address_space *mapping,
 			continue;
 		}
 
-		if (radix_tree_exceptional_entry(page))
+		if (xa_is_value(page))
 			swapped++;
 
 		if (need_resched()) {
@@ -805,7 +805,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			if (index >= end)
 				break;
 
-			if (radix_tree_exceptional_entry(page)) {
+			if (xa_is_value(page)) {
 				if (unfalloc)
 					continue;
 				nr_swaps_freed += !shmem_free_swap(mapping,
@@ -902,7 +902,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			if (index >= end)
 				break;
 
-			if (radix_tree_exceptional_entry(page)) {
+			if (xa_is_value(page)) {
 				if (unfalloc)
 					continue;
 				if (shmem_free_swap(mapping, index, page)) {
@@ -1614,7 +1614,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 repeat:
 	swap.val = 0;
 	page = find_lock_entry(mapping, index);
-	if (radix_tree_exceptional_entry(page)) {
+	if (xa_is_value(page)) {
 		swap = radix_to_swp_entry(page);
 		page = NULL;
 	}
@@ -2547,7 +2547,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 				index = indices[i];
 			}
 			page = pvec.pages[i];
-			if (page && !radix_tree_exceptional_entry(page)) {
+			if (page && !xa_is_value(page)) {
 				if (!PageUptodate(page))
 					page = NULL;
 			}
diff --git a/mm/swap.c b/mm/swap.c
index 38e1b6374a97..8d7773cb2c3f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -953,7 +953,7 @@ void pagevec_remove_exceptionals(struct pagevec *pvec)
 
 	for (i = 0, j = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
-		if (!radix_tree_exceptional_entry(page))
+		if (!xa_is_value(page))
 			pvec->pages[j++] = page;
 	}
 	pvec->nr = j;
diff --git a/mm/truncate.c b/mm/truncate.c
index 094158f2e447..69bb743dd7e5 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -70,7 +70,7 @@ static void truncate_exceptional_pvec_entries(struct address_space *mapping,
 		return;
 
 	for (j = 0; j < pagevec_count(pvec); j++)
-		if (radix_tree_exceptional_entry(pvec->pages[j]))
+		if (xa_is_value(pvec->pages[j]))
 			break;
 
 	if (j == pagevec_count(pvec))
@@ -85,7 +85,7 @@ static void truncate_exceptional_pvec_entries(struct address_space *mapping,
 		struct page *page = pvec->pages[i];
 		pgoff_t index = indices[i];
 
-		if (!radix_tree_exceptional_entry(page)) {
+		if (!xa_is_value(page)) {
 			pvec->pages[j++] = page;
 			continue;
 		}
@@ -351,7 +351,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			if (index >= end)
 				break;
 
-			if (radix_tree_exceptional_entry(page))
+			if (xa_is_value(page))
 				continue;
 
 			if (!trylock_page(page))
@@ -446,7 +446,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				break;
 			}
 
-			if (radix_tree_exceptional_entry(page))
+			if (xa_is_value(page))
 				continue;
 
 			lock_page(page);
@@ -565,7 +565,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			if (index > end)
 				break;
 
-			if (radix_tree_exceptional_entry(page)) {
+			if (xa_is_value(page)) {
 				invalidate_exceptional_entry(mapping, index,
 							     page);
 				continue;
@@ -696,7 +696,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 			if (index > end)
 				break;
 
-			if (radix_tree_exceptional_entry(page)) {
+			if (xa_is_value(page)) {
 				if (!invalidate_exceptional_entry2(mapping,
 								   index, page))
 					ret = -EBUSY;
diff --git a/mm/workingset.c b/mm/workingset.c
index 3cb3586181e6..3afeb84720f4 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -155,8 +155,8 @@
  * refault distance will immediately activate the refaulting page.
  */
 
-#define EVICTION_SHIFT	(RADIX_TREE_EXCEPTIONAL_ENTRY + \
-			 NODES_SHIFT +	\
+#define EVICTION_SHIFT	((BITS_PER_LONG - BITS_PER_XA_VALUE) +	\
+			 NODES_SHIFT +				\
 			 MEM_CGROUP_ID_SHIFT)
 #define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
 
@@ -175,18 +175,16 @@ static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
 	eviction >>= bucket_order;
 	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
 	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
-	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
 
-	return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
+	return xa_mk_value(eviction);
 }
 
 static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
 			  unsigned long *evictionp)
 {
-	unsigned long entry = (unsigned long)shadow;
+	unsigned long entry = xa_to_value(shadow);
 	int memcgid, nid;
 
-	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
 	nid = entry & ((1UL << NODES_SHIFT) - 1);
 	entry >>= NODES_SHIFT;
 	memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
@@ -453,7 +451,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 		goto out_invalid;
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		if (node->slots[i]) {
-			if (WARN_ON_ONCE(!radix_tree_exceptional_entry(node->slots[i])))
+			if (WARN_ON_ONCE(!xa_is_value(node->slots[i])))
 				goto out_invalid;
 			if (WARN_ON_ONCE(!node->exceptional))
 				goto out_invalid;
diff --git a/tools/testing/radix-tree/idr-test.c b/tools/testing/radix-tree/idr-test.c
index 193450b29bf0..7499319e85f8 100644
--- a/tools/testing/radix-tree/idr-test.c
+++ b/tools/testing/radix-tree/idr-test.c
@@ -19,7 +19,7 @@
 
 #include "test.h"
 
-#define DUMMY_PTR	((void *)0x12)
+#define DUMMY_PTR	((void *)0x10)
 
 int item_idr_free(int id, void *p, void *data)
 {
@@ -320,11 +320,11 @@ void ida_check_conv(void)
 	for (i = 0; i < 1000000; i++) {
 		int err = ida_get_new(&ida, &id);
 		if (err == -EAGAIN) {
-			assert((i % IDA_BITMAP_BITS) == (BITS_PER_LONG - 2));
+			assert((i % IDA_BITMAP_BITS) == (BITS_PER_LONG - 1));
 			assert(ida_pre_get(&ida, GFP_KERNEL));
 			err = ida_get_new(&ida, &id);
 		} else {
-			assert((i % IDA_BITMAP_BITS) != (BITS_PER_LONG - 2));
+			assert((i % IDA_BITMAP_BITS) != (BITS_PER_LONG - 1));
 		}
 		assert(!err);
 		assert(id == i);
diff --git a/tools/testing/radix-tree/linux/radix-tree.h b/tools/testing/radix-tree/linux/radix-tree.h
index 36fb716d5557..40c9671ee365 100644
--- a/tools/testing/radix-tree/linux/radix-tree.h
+++ b/tools/testing/radix-tree/linux/radix-tree.h
@@ -5,6 +5,7 @@
 #include "generated/map-shift.h"
 #include "linux/bug.h"
 #include "../../../../include/linux/radix-tree.h"
+#include <linux/xarray.h>
 
 extern int kmalloc_verbose;
 extern int test_verbose;
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 59245b3d587c..684e76f79f4a 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -38,12 +38,11 @@ static void __multiorder_tag_test(int index, int order)
 
 	/*
 	 * Verify we get collisions for covered indices.  We try and fail to
-	 * insert an exceptional entry so we don't leak memory via
+	 * insert a data entry so we don't leak memory via
 	 * item_insert_order().
 	 */
 	for_each_index(i, base, order) {
-		err = __radix_tree_insert(&tree, i, order,
-				(void *)(0xA0 | RADIX_TREE_EXCEPTIONAL_ENTRY));
+		err = __radix_tree_insert(&tree, i, order, xa_mk_value(0xA0));
 		assert(err == -EEXIST);
 	}
 
@@ -379,8 +378,8 @@ static void multiorder_join1(unsigned long index,
 }
 
 /*
- * Check that the accounting of exceptional entries is handled correctly
- * by joining an exceptional entry to a normal pointer.
+ * Check that the accounting of inline data entries is handled correctly
+ * by joining a data entry to a normal pointer.
  */
 static void multiorder_join2(unsigned order1, unsigned order2)
 {
@@ -390,9 +389,9 @@ static void multiorder_join2(unsigned order1, unsigned order2)
 	void *item2;
 
 	item_insert_order(&tree, 0, order2);
-	radix_tree_insert(&tree, 1 << order2, (void *)0x12UL);
+	radix_tree_insert(&tree, 1 << order2, xa_mk_value(5));
 	item2 = __radix_tree_lookup(&tree, 1 << order2, &node, NULL);
-	assert(item2 == (void *)0x12UL);
+	assert(item2 == xa_mk_value(5));
 	assert(node->exceptional == 1);
 
 	item2 = radix_tree_lookup(&tree, 0);
@@ -406,7 +405,7 @@ static void multiorder_join2(unsigned order1, unsigned order2)
 }
 
 /*
- * This test revealed an accounting bug for exceptional entries at one point.
+ * This test revealed an accounting bug for inline data entries at one point.
  * Nodes were being freed back into the pool with an elevated exception count
  * by radix_tree_join() and then radix_tree_split() was failing to zero the
  * count of exceptional entries.
@@ -420,16 +419,16 @@ static void multiorder_join3(unsigned int order)
 	unsigned long i;
 
 	for (i = 0; i < (1 << order); i++) {
-		radix_tree_insert(&tree, i, (void *)0x12UL);
+		radix_tree_insert(&tree, i, xa_mk_value(5));
 	}
 
-	radix_tree_join(&tree, 0, order, (void *)0x16UL);
+	radix_tree_join(&tree, 0, order, xa_mk_value(7));
 	rcu_barrier();
 
 	radix_tree_split(&tree, 0, 0);
 
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
-		radix_tree_iter_replace(&tree, &iter, slot, (void *)0x12UL);
+		radix_tree_iter_replace(&tree, &iter, slot, xa_mk_value(5));
 	}
 
 	__radix_tree_lookup(&tree, 0, &node, NULL);
@@ -516,10 +515,10 @@ static void __multiorder_split2(int old_order, int new_order)
 	struct radix_tree_node *node;
 	void *item;
 
-	__radix_tree_insert(&tree, 0, old_order, (void *)0x12);
+	__radix_tree_insert(&tree, 0, old_order, xa_mk_value(5));
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item == (void *)0x12);
+	assert(item == xa_mk_value(5));
 	assert(node->exceptional > 0);
 
 	radix_tree_split(&tree, 0, new_order);
@@ -529,7 +528,7 @@ static void __multiorder_split2(int old_order, int new_order)
 	}
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item != (void *)0x12);
+	assert(item != xa_mk_value(5));
 	assert(node->exceptional == 0);
 
 	item_kill_tree(&tree);
@@ -543,40 +542,40 @@ static void __multiorder_split3(int old_order, int new_order)
 	struct radix_tree_node *node;
 	void *item;
 
-	__radix_tree_insert(&tree, 0, old_order, (void *)0x12);
+	__radix_tree_insert(&tree, 0, old_order, xa_mk_value(5));
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item == (void *)0x12);
+	assert(item == xa_mk_value(5));
 	assert(node->exceptional > 0);
 
 	radix_tree_split(&tree, 0, new_order);
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
-		radix_tree_iter_replace(&tree, &iter, slot, (void *)0x16);
+		radix_tree_iter_replace(&tree, &iter, slot, xa_mk_value(7));
 	}
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item == (void *)0x16);
+	assert(item == xa_mk_value(7));
 	assert(node->exceptional > 0);
 
 	item_kill_tree(&tree);
 
-	__radix_tree_insert(&tree, 0, old_order, (void *)0x12);
+	__radix_tree_insert(&tree, 0, old_order, xa_mk_value(5));
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item == (void *)0x12);
+	assert(item == xa_mk_value(5));
 	assert(node->exceptional > 0);
 
 	radix_tree_split(&tree, 0, new_order);
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
 		if (iter.index == (1 << new_order))
 			radix_tree_iter_replace(&tree, &iter, slot,
-						(void *)0x16);
+						xa_mk_value(7));
 		else
 			radix_tree_iter_replace(&tree, &iter, slot, NULL);
 	}
 
 	item = __radix_tree_lookup(&tree, 1 << new_order, &node, NULL);
-	assert(item == (void *)0x16);
+	assert(item == xa_mk_value(7));
 	assert(node->count == node->exceptional);
 	do {
 		node = node->parent;
@@ -609,13 +608,13 @@ static void multiorder_account(void)
 
 	item_insert_order(&tree, 0, 5);
 
-	__radix_tree_insert(&tree, 1 << 5, 5, (void *)0x12);
+	__radix_tree_insert(&tree, 1 << 5, 5, xa_mk_value(5));
 	__radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(node->count == node->exceptional * 2);
 	radix_tree_delete(&tree, 1 << 5);
 	assert(node->exceptional == 0);
 
-	__radix_tree_insert(&tree, 1 << 5, 5, (void *)0x12);
+	__radix_tree_insert(&tree, 1 << 5, 5, xa_mk_value(5));
 	__radix_tree_lookup(&tree, 1 << 5, &node, &slot);
 	assert(node->count == node->exceptional * 2);
 	__radix_tree_replace(&tree, node, slot, NULL, NULL);
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index 5978ab1f403d..0d69c49177c6 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -276,7 +276,7 @@ void item_kill_tree(struct radix_tree_root *root)
 	int nfound;
 
 	radix_tree_for_each_slot(slot, root, &iter, 0) {
-		if (radix_tree_exceptional_entry(*slot))
+		if (xa_is_value(*slot))
 			radix_tree_delete(root, iter.index);
 	}
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
