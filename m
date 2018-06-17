Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCED76B0288
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:17 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x32-v6so7696132pld.16
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r85-v6si11575632pfa.259.2018.06.16.19.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:14 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 04/74] xarray: Replace exceptional entries
Date: Sat, 16 Jun 2018 18:59:42 -0700
Message-Id: <20180617020052.4759-5-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Introduce xarray value entries to replace the radix tree exceptional
entry code.  This is a slight change in encoding to allow the use of an
extra bit (we can now store BITS_PER_LONG - 1 bits in a value entry).
It is also a change in emphasis; exceptional entries are intimidating
and different.  As the comment explains, you can choose to store values
or pointers in the xarray and they are both first-class citizens.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Josef Bacik <jbacik@fb.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |   4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h |   4 +-
 drivers/gpu/drm/i915/i915_gem.c              |  17 ++-
 fs/btrfs/compression.c                       |   2 +-
 fs/dax.c                                     | 114 +++++++++----------
 fs/proc/task_mmu.c                           |   2 +-
 include/linux/radix-tree.h                   |  36 ++----
 include/linux/swapops.h                      |  19 ++--
 include/linux/xarray.h                       |  54 +++++++++
 lib/idr.c                                    |  60 ++++------
 lib/radix-tree.c                             |  21 ++--
 mm/filemap.c                                 |  10 +-
 mm/khugepaged.c                              |   2 +-
 mm/madvise.c                                 |   2 +-
 mm/memcontrol.c                              |   2 +-
 mm/mincore.c                                 |   2 +-
 mm/readahead.c                               |   2 +-
 mm/shmem.c                                   |  10 +-
 mm/swap.c                                    |   2 +-
 mm/truncate.c                                |  12 +-
 mm/workingset.c                              |  12 +-
 tools/testing/radix-tree/idr-test.c          |   6 +-
 tools/testing/radix-tree/linux/radix-tree.h  |   1 -
 tools/testing/radix-tree/linux/xarray.h      |   2 +
 tools/testing/radix-tree/multiorder.c        |  47 ++++----
 tools/testing/radix-tree/test.c              |   2 +-
 26 files changed, 226 insertions(+), 221 deletions(-)
 create mode 100644 tools/testing/radix-tree/linux/xarray.h

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 63cee159022b..6b17ddc070fc 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -703,9 +703,7 @@ static inline bool pte_user(pte_t pte)
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
index dd0c7236208f..6752636bc457 100644
--- a/arch/powerpc/include/asm/nohash/64/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/64/pgtable.h
@@ -322,9 +322,7 @@ static inline void __ptep_set_access_flags(struct vm_area_struct *vma,
 #define MAX_SWAPFILES_CHECK() do { \
 	BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS); \
 	} while (0)
-/*
- * on pte we don't need handle RADIX_TREE_EXCEPTIONAL_SHIFT;
- */
+
 #define SWP_TYPE_BITS 5
 #define __swp_type(x)		(((x).val >> _PAGE_BIT_SWAP_TYPE) \
 				& ((1UL << SWP_TYPE_BITS) - 1))
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 3704f4c0c2c9..fd56eee4a790 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -5865,7 +5865,8 @@ i915_gem_object_get_sg(struct drm_i915_gem_object *obj,
 	count = __sg_page_count(sg);
 
 	while (idx + count <= n) {
-		unsigned long exception, i;
+		void *entry;
+		unsigned long i;
 		int ret;
 
 		/* If we cannot allocate and insert this entry, or the
@@ -5880,12 +5881,9 @@ i915_gem_object_get_sg(struct drm_i915_gem_object *obj,
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
@@ -5923,15 +5921,14 @@ i915_gem_object_get_sg(struct drm_i915_gem_object *obj,
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
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index d3e447b45bf7..8db29f791984 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -447,7 +447,7 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->i_pages, pg_index);
 		rcu_read_unlock();
-		if (page && !radix_tree_exceptional_entry(page)) {
+		if (page && !xa_is_value(page)) {
 			misses++;
 			if (misses > 4)
 				break;
diff --git a/fs/dax.c b/fs/dax.c
index c7917b46a75b..704059ecfa88 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -59,56 +59,57 @@ static int __init init_dax_wait_table(void)
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
+#define DAX_LOCKED	(1UL << 0)
+#define DAX_PMD		(1UL << 1)
+#define DAX_ZERO_PAGE	(1UL << 2)
+#define DAX_EMPTY	(1UL << 3)
 
 static unsigned long dax_radix_pfn(void *entry)
 {
-	return (unsigned long)entry >> RADIX_DAX_SHIFT;
+	return xa_to_value(entry) >> DAX_SHIFT;
 }
 
 static void *dax_radix_locked_entry(unsigned long pfn, unsigned long flags)
 {
-	return (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY | flags |
-			(pfn << RADIX_DAX_SHIFT) | RADIX_DAX_ENTRY_LOCK);
+	return xa_mk_value(flags | ((unsigned long)pfn << DAX_SHIFT) |
+			DAX_LOCKED);
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
@@ -186,9 +187,9 @@ static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
  */
 static inline int slot_locked(struct address_space *mapping, void **slot)
 {
-	unsigned long entry = (unsigned long)
-		radix_tree_deref_slot_protected(slot, &mapping->i_pages.xa_lock);
-	return entry & RADIX_DAX_ENTRY_LOCK;
+	unsigned long entry = xa_to_value(
+		radix_tree_deref_slot_protected(slot, &mapping->i_pages.xa_lock));
+	return entry & DAX_LOCKED;
 }
 
 /*
@@ -196,12 +197,11 @@ static inline int slot_locked(struct address_space *mapping, void **slot)
  */
 static inline void *lock_slot(struct address_space *mapping, void **slot)
 {
-	unsigned long entry = (unsigned long)
-		radix_tree_deref_slot_protected(slot, &mapping->i_pages.xa_lock);
-
-	entry |= RADIX_DAX_ENTRY_LOCK;
-	radix_tree_replace_slot(&mapping->i_pages, slot, (void *)entry);
-	return (void *)entry;
+	unsigned long v = xa_to_value(
+		radix_tree_deref_slot_protected(slot, &mapping->i_pages.xa_lock));
+	void *entry = xa_mk_value(v | DAX_LOCKED);
+	radix_tree_replace_slot(&mapping->i_pages, slot, entry);
+	return entry;
 }
 
 /*
@@ -209,17 +209,16 @@ static inline void *lock_slot(struct address_space *mapping, void **slot)
  */
 static inline void *unlock_slot(struct address_space *mapping, void **slot)
 {
-	unsigned long entry = (unsigned long)
-		radix_tree_deref_slot_protected(slot, &mapping->i_pages.xa_lock);
-
-	entry &= ~(unsigned long)RADIX_DAX_ENTRY_LOCK;
-	radix_tree_replace_slot(&mapping->i_pages, slot, (void *)entry);
-	return (void *)entry;
+	unsigned long v = xa_to_value(
+		radix_tree_deref_slot_protected(slot, &mapping->i_pages.xa_lock));
+	void *entry = xa_mk_value(v & ~DAX_LOCKED);
+	radix_tree_replace_slot(&mapping->i_pages, slot, entry);
+	return entry;
 }
 
 /*
  * Lookup entry in radix tree, wait for it to become unlocked if it is
- * exceptional entry and return it. The caller must call
+ * a DAX entry and return it. The caller must call
  * put_unlocked_mapping_entry() when he decided not to lock the entry or
  * put_locked_mapping_entry() when he locked the entry and now wants to
  * unlock it.
@@ -240,7 +239,7 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 		entry = __radix_tree_lookup(&mapping->i_pages, index, NULL,
 					  &slot);
 		if (!entry ||
-		    WARN_ON_ONCE(!radix_tree_exceptional_entry(entry)) ||
+		    WARN_ON_ONCE(!xa_is_value(entry)) ||
 		    !slot_locked(mapping, slot)) {
 			if (slotp)
 				*slotp = slot;
@@ -264,7 +263,7 @@ static void dax_unlock_mapping_entry(struct address_space *mapping,
 
 	xa_lock_irq(&mapping->i_pages);
 	entry = __radix_tree_lookup(&mapping->i_pages, index, NULL, &slot);
-	if (WARN_ON_ONCE(!entry || !radix_tree_exceptional_entry(entry) ||
+	if (WARN_ON_ONCE(!entry || !xa_is_value(entry) ||
 			 !slot_locked(mapping, slot))) {
 		xa_unlock_irq(&mapping->i_pages);
 		return;
@@ -414,8 +413,7 @@ struct page *dax_lock_page(unsigned long pfn)
 
 		entry = __radix_tree_lookup(&mapping->i_pages, index, NULL,
 				&slot);
-		if (!entry ||
-		    WARN_ON_ONCE(!radix_tree_exceptional_entry(entry))) {
+		if (!entry || WARN_ON_ONCE(!xa_is_value(entry))) {
 			xa_unlock_irq(&mapping->i_pages);
 			break;
 		} else if (!slot_locked(mapping, slot)) {
@@ -451,12 +449,11 @@ void dax_unlock_page(struct page *page)
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
@@ -486,13 +483,13 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 	xa_lock_irq(&mapping->i_pages);
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
@@ -563,7 +560,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 					true);
 		}
 
-		entry = dax_radix_locked_entry(0, size_flag | RADIX_DAX_EMPTY);
+		entry = dax_radix_locked_entry(0, size_flag | DAX_EMPTY);
 
 		err = __radix_tree_insert(&mapping->i_pages, index,
 				dax_radix_order(entry), entry);
@@ -652,7 +649,7 @@ struct page *dax_layout_busy_page(struct address_space *mapping)
 			if (index >= end)
 				break;
 
-			if (!radix_tree_exceptional_entry(pvec_ent))
+			if (!xa_is_value(pvec_ent))
 				continue;
 
 			xa_lock_irq(&mapping->i_pages);
@@ -684,7 +681,7 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 
 	xa_lock_irq(pages);
 	entry = get_unlocked_mapping_entry(mapping, index, NULL);
-	if (!entry || WARN_ON_ONCE(!radix_tree_exceptional_entry(entry)))
+	if (!entry || WARN_ON_ONCE(!xa_is_value(entry)))
 		goto out;
 	if (!trunc &&
 	    (radix_tree_tag_get(pages, index, PAGECACHE_TAG_DIRTY) ||
@@ -700,8 +697,8 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
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
@@ -711,7 +708,7 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 	 * This gets called from truncate / punch_hole path. As such, the caller
 	 * must hold locks protecting against concurrent modifications of the
 	 * radix tree (usually fs-private i_mmap_sem for writing). Since the
-	 * caller has seen exceptional entry for this index, we better find it
+	 * caller has seen a DAX entry for this index, we better find it
 	 * at that index as well...
 	 */
 	WARN_ON_ONCE(!ret);
@@ -719,7 +716,7 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 }
 
 /*
- * Invalidate exceptional DAX entry if it is clean.
+ * Invalidate DAX entry if it is clean.
  */
 int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
 				      pgoff_t index)
@@ -774,7 +771,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 	if (dirty)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 
-	if (dax_is_zero_entry(entry) && !(flags & RADIX_DAX_ZERO_PAGE)) {
+	if (dax_is_zero_entry(entry) && !(flags & DAX_ZERO_PAGE)) {
 		/* we are replacing a zero page with block mapping */
 		if (dax_is_pmd_entry(entry))
 			unmap_mapping_pages(mapping, index & ~PG_PMD_COLOUR,
@@ -912,13 +909,13 @@ static int dax_writeback_one(struct dax_device *dax_dev,
 	 * A page got tagged dirty in DAX mapping? Something is seriously
 	 * wrong.
 	 */
-	if (WARN_ON(!radix_tree_exceptional_entry(entry)))
+	if (WARN_ON(!xa_is_value(entry)))
 		return -EIO;
 
 	xa_lock_irq(pages);
 	entry2 = get_unlocked_mapping_entry(mapping, index, &slot);
 	/* Entry got punched out / reallocated? */
-	if (!entry2 || WARN_ON_ONCE(!radix_tree_exceptional_entry(entry2)))
+	if (!entry2 || WARN_ON_ONCE(!xa_is_value(entry2)))
 		goto put_unlocked;
 	/*
 	 * Entry got reallocated elsewhere? No need to writeback. We have to
@@ -1096,8 +1093,9 @@ static vm_fault_t dax_load_hole(struct address_space *mapping, void *entry,
 	pfn_t pfn = pfn_to_pfn_t(my_zero_pfn(vaddr));
 	vm_fault_t ret;
 
-	dax_insert_mapping_entry(mapping, vmf, entry, pfn, RADIX_DAX_ZERO_PAGE,
-			false);
+	dax_insert_mapping_entry(mapping, vmf, entry, pfn,
+			DAX_ZERO_PAGE, false);
+
 	ret = vmf_insert_mixed(vmf->vma, vaddr, pfn);
 	trace_dax_load_hole(inode, vmf, ret);
 	return ret;
@@ -1490,7 +1488,7 @@ static vm_fault_t dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 
 	pfn = page_to_pfn_t(zero_page);
 	ret = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
-			RADIX_DAX_PMD | RADIX_DAX_ZERO_PAGE, false);
+			DAX_PMD | DAX_ZERO_PAGE, false);
 
 	ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
 	if (!pmd_none(*(vmf->pmd))) {
@@ -1573,7 +1571,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	 * is already in the tree, for instance), it will return -EEXIST and
 	 * we just fall back to 4k entries.
 	 */
-	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
+	entry = grab_mapping_entry(mapping, pgoff, DAX_PMD);
 	if (IS_ERR(entry))
 		goto fallback;
 
@@ -1611,7 +1609,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 			goto finish_iomap;
 
 		entry = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
-						RADIX_DAX_PMD, write && !sync);
+						DAX_PMD, write && !sync);
 
 		/*
 		 * If we are doing synchronous page fault and inode needs fsync,
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index e9679016271f..bfafafa94a84 100644
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
index 1d3877c39a00..9c0eb4d4f444 100644
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
index 9e4c86853fa4..e6ead6c81458 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -5,9 +5,63 @@
  * eXtensible Arrays
  * Copyright (c) 2017 Microsoft Corporation
  * Author: Matthew Wilcox <willy@infradead.org>
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
+ * Context: Any context.
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
+ * Context: Any context.
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
+ * Context: Any context.
+ * Return: True if the entry is a value, false if it is a pointer.
+ */
+static inline bool xa_is_value(const void *entry)
+{
+	return (unsigned long)entry & 1;
+}
 
 #define xa_trylock(xa)		spin_trylock(&(xa)->xa_lock)
 #define xa_lock(xa)		spin_lock(&(xa)->xa_lock)
diff --git a/lib/idr.c b/lib/idr.c
index ed9c169c12bd..3bdcb32760e3 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -348,11 +348,8 @@ EXPORT_SYMBOL(idr_replace);
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
@@ -394,12 +391,11 @@ int ida_get_new_above(struct ida *ida, int start, int *id)
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
@@ -414,25 +410,24 @@ int ida_get_new_above(struct ida *ida, int start, int *id)
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
-			bitmap->bitmap[0] = tmp >> RADIX_TREE_EXCEPTIONAL_SHIFT;
+			bitmap->bitmap[0] = tmp;
 			rcu_assign_pointer(*slot, bitmap);
 		}
 
@@ -453,18 +448,14 @@ int ida_get_new_above(struct ida *ida, int start, int *id)
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
+				__set_bit(bit, bitmap->bitmap);
 			}
-			bitmap = this_cpu_xchg(ida_bitmap, NULL);
-			if (!bitmap)
-				return -EAGAIN;
-			__set_bit(bit, bitmap->bitmap);
 			radix_tree_iter_replace(root, &iter, slot, bitmap);
 		}
 
@@ -495,9 +486,9 @@ void ida_remove(struct ida *ida, int id)
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
@@ -508,9 +499,8 @@ void ida_remove(struct ida *ida, int id)
 
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
@@ -538,7 +528,7 @@ void ida_destroy(struct ida *ida)
 
 	radix_tree_for_each_slot(slot, &ida->ida_rt, &iter, 0) {
 		struct ida_bitmap *bitmap = rcu_dereference_raw(*slot);
-		if (!radix_tree_exception(bitmap))
+		if (!xa_is_value(bitmap))
 			kfree(bitmap);
 		radix_tree_iter_delete(&ida->ida_rt, &iter, slot);
 	}
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index a9e41aed6de4..fa43dcdc1f6a 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -340,14 +340,12 @@ static void dump_ida_node(void *entry, unsigned long index)
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
 
@@ -656,7 +654,7 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 		BUG_ON(shift > BITS_PER_LONG);
 		if (radix_tree_is_internal_node(entry)) {
 			entry_to_node(entry)->parent = node;
-		} else if (radix_tree_exceptional_entry(entry)) {
+		} else if (xa_is_value(entry)) {
 			/* Moving an exceptional root->rnode to a node */
 			node->exceptional = 1;
 		}
@@ -947,12 +945,12 @@ static inline int insert_entries(struct radix_tree_node *node,
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
@@ -966,7 +964,7 @@ static inline int insert_entries(struct radix_tree_node *node,
 	rcu_assign_pointer(*slot, item);
 	if (node) {
 		node->count++;
-		if (radix_tree_exceptional_entry(item))
+		if (xa_is_value(item))
 			node->exceptional++;
 	}
 	return 1;
@@ -1183,8 +1181,7 @@ void __radix_tree_replace(struct radix_tree_root *root,
 			  radix_tree_update_node_t update_node)
 {
 	void *old = rcu_dereference_raw(*slot);
-	int exceptional = !!radix_tree_exceptional_entry(item) -
-				!!radix_tree_exceptional_entry(old);
+	int exceptional = !!xa_is_value(item) - !!xa_is_value(old);
 	int count = calculate_count(root, node, slot, item, old);
 
 	/*
@@ -1985,7 +1982,7 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
 				struct radix_tree_node *node, void __rcu **slot)
 {
 	void *old = rcu_dereference_raw(*slot);
-	int exceptional = radix_tree_exceptional_entry(old) ? -1 : 0;
+	int exceptional = xa_is_value(old) ? -1 : 0;
 	unsigned offset = get_slot_offset(node, slot);
 	int tag;
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 52517f28e6f4..4de14e75c4ec 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -127,7 +127,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 
 		p = radix_tree_deref_slot_protected(slot,
 						    &mapping->i_pages.xa_lock);
-		if (!radix_tree_exceptional_entry(p))
+		if (!xa_is_value(p))
 			return -EEXIST;
 
 		mapping->nrexceptional--;
@@ -336,7 +336,7 @@ page_cache_tree_delete_batch(struct address_space *mapping,
 			break;
 		page = radix_tree_deref_slot_protected(slot,
 						       &mapping->i_pages.xa_lock);
-		if (radix_tree_exceptional_entry(page))
+		if (xa_is_value(page))
 			continue;
 		if (!tail_pages) {
 			/*
@@ -1355,7 +1355,7 @@ pgoff_t page_cache_next_hole(struct address_space *mapping,
 		struct page *page;
 
 		page = radix_tree_lookup(&mapping->i_pages, index);
-		if (!page || radix_tree_exceptional_entry(page))
+		if (!page || xa_is_value(page))
 			break;
 		index++;
 		if (index == 0)
@@ -1396,7 +1396,7 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
 		struct page *page;
 
 		page = radix_tree_lookup(&mapping->i_pages, index);
-		if (!page || radix_tree_exceptional_entry(page))
+		if (!page || xa_is_value(page))
 			break;
 		index--;
 		if (index == ULONG_MAX)
@@ -1539,7 +1539,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 
 repeat:
 	page = find_get_entry(mapping, offset);
-	if (radix_tree_exceptional_entry(page))
+	if (xa_is_value(page))
 		page = NULL;
 	if (!page)
 		goto no_page;
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7b2a4bf8671..d6992ba1f604 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1368,7 +1368,7 @@ static void collapse_shmem(struct mm_struct *mm,
 
 		page = radix_tree_deref_slot_protected(slot,
 				&mapping->i_pages.xa_lock);
-		if (radix_tree_exceptional_entry(page) || !PageUptodate(page)) {
+		if (xa_is_value(page) || !PageUptodate(page)) {
 			xa_unlock_irq(&mapping->i_pages);
 			/* swap in or instantiate fallocated page */
 			if (shmem_getpage(mapping->host, index, &page,
diff --git a/mm/madvise.c b/mm/madvise.c
index b731933dddae..6ed8cfe7f6de 100644
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
index 02e77c88967a..c3b5ba593e69 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4682,7 +4682,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 	/* shmem/tmpfs may report page out on swap: account for that too. */
 	if (shmem_mapping(mapping)) {
 		page = find_get_entry(mapping, pgoff);
-		if (radix_tree_exceptional_entry(page)) {
+		if (xa_is_value(page)) {
 			swp_entry_t swp = radix_to_swp_entry(page);
 			if (do_memsw_account())
 				*entry = swp;
diff --git a/mm/mincore.c b/mm/mincore.c
index a66f2052c7b1..aa0e542569f9 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -66,7 +66,7 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 		 * shmem/tmpfs may return swap: account for swapcache
 		 * page too.
 		 */
-		if (radix_tree_exceptional_entry(page)) {
+		if (xa_is_value(page)) {
 			swp_entry_t swp = radix_to_swp_entry(page);
 			struct swap_info_struct *si;
 
diff --git a/mm/readahead.c b/mm/readahead.c
index e273f0de3376..3757aa549709 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -177,7 +177,7 @@ unsigned int __do_page_cache_readahead(struct address_space *mapping,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->i_pages, page_offset);
 		rcu_read_unlock();
-		if (page && !radix_tree_exceptional_entry(page)) {
+		if (page && !xa_is_value(page)) {
 			/*
 			 * Page already present?  Kick off the current batch of
 			 * contiguous pages before continuing with the next
diff --git a/mm/shmem.c b/mm/shmem.c
index 2cab84403055..3b03ede3515c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -708,7 +708,7 @@ unsigned long shmem_partial_swap_usage(struct address_space *mapping,
 			continue;
 		}
 
-		if (radix_tree_exceptional_entry(page))
+		if (xa_is_value(page))
 			swapped++;
 
 		if (need_resched()) {
@@ -823,7 +823,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			if (index >= end)
 				break;
 
-			if (radix_tree_exceptional_entry(page)) {
+			if (xa_is_value(page)) {
 				if (unfalloc)
 					continue;
 				nr_swaps_freed += !shmem_free_swap(mapping,
@@ -920,7 +920,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			if (index >= end)
 				break;
 
-			if (radix_tree_exceptional_entry(page)) {
+			if (xa_is_value(page)) {
 				if (unfalloc)
 					continue;
 				if (shmem_free_swap(mapping, index, page)) {
@@ -1641,7 +1641,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 repeat:
 	swap.val = 0;
 	page = find_lock_entry(mapping, index);
-	if (radix_tree_exceptional_entry(page)) {
+	if (xa_is_value(page)) {
 		swap = radix_to_swp_entry(page);
 		page = NULL;
 	}
@@ -2574,7 +2574,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 				index = indices[i];
 			}
 			page = pvec.pages[i];
-			if (page && !radix_tree_exceptional_entry(page)) {
+			if (page && !xa_is_value(page)) {
 				if (!PageUptodate(page))
 					page = NULL;
 			}
diff --git a/mm/swap.c b/mm/swap.c
index 26fc9b5f1b6c..4c5c7fcc6e46 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -965,7 +965,7 @@ void pagevec_remove_exceptionals(struct pagevec *pvec)
 
 	for (i = 0, j = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
-		if (!radix_tree_exceptional_entry(page))
+		if (!xa_is_value(page))
 			pvec->pages[j++] = page;
 	}
 	pvec->nr = j;
diff --git a/mm/truncate.c b/mm/truncate.c
index 1d2fb2dca96f..ed778555c9f3 100644
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
@@ -347,7 +347,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			if (index >= end)
 				break;
 
-			if (radix_tree_exceptional_entry(page))
+			if (xa_is_value(page))
 				continue;
 
 			if (!trylock_page(page))
@@ -442,7 +442,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				break;
 			}
 
-			if (radix_tree_exceptional_entry(page))
+			if (xa_is_value(page))
 				continue;
 
 			lock_page(page);
@@ -561,7 +561,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			if (index > end)
 				break;
 
-			if (radix_tree_exceptional_entry(page)) {
+			if (xa_is_value(page)) {
 				invalidate_exceptional_entry(mapping, index,
 							     page);
 				continue;
@@ -692,7 +692,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 			if (index > end)
 				break;
 
-			if (radix_tree_exceptional_entry(page)) {
+			if (xa_is_value(page)) {
 				if (!invalidate_exceptional_entry2(mapping,
 								   index, page))
 					ret = -EBUSY;
diff --git a/mm/workingset.c b/mm/workingset.c
index 40ee02c83978..b5dd3936e697 100644
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
index ee820fcc29b0..46fc2f1142c3 100644
--- a/tools/testing/radix-tree/idr-test.c
+++ b/tools/testing/radix-tree/idr-test.c
@@ -19,7 +19,7 @@
 
 #include "test.h"
 
-#define DUMMY_PTR	((void *)0x12)
+#define DUMMY_PTR	((void *)0x10)
 
 int item_idr_free(int id, void *p, void *data)
 {
@@ -400,11 +400,11 @@ void ida_check_conv(void)
 	for (i = 0; i < 1000000; i++) {
 		int err = ida_get_new(&ida, &id);
 		if (err == -EAGAIN) {
-			assert((i % IDA_BITMAP_BITS) == (BITS_PER_LONG - 2));
+			assert((i % IDA_BITMAP_BITS) == BITS_PER_XA_VALUE);
 			assert(ida_pre_get(&ida, GFP_KERNEL));
 			err = ida_get_new(&ida, &id);
 		} else {
-			assert((i % IDA_BITMAP_BITS) != (BITS_PER_LONG - 2));
+			assert((i % IDA_BITMAP_BITS) != BITS_PER_XA_VALUE);
 		}
 		assert(!err);
 		assert(id == i);
diff --git a/tools/testing/radix-tree/linux/radix-tree.h b/tools/testing/radix-tree/linux/radix-tree.h
index 24f13d27a8da..d1635a5bef02 100644
--- a/tools/testing/radix-tree/linux/radix-tree.h
+++ b/tools/testing/radix-tree/linux/radix-tree.h
@@ -2,7 +2,6 @@
 #ifndef _TEST_RADIX_TREE_H
 #define _TEST_RADIX_TREE_H
 
-#include "generated/map-shift.h"
 #include "../../../../include/linux/radix-tree.h"
 
 extern int kmalloc_verbose;
diff --git a/tools/testing/radix-tree/linux/xarray.h b/tools/testing/radix-tree/linux/xarray.h
new file mode 100644
index 000000000000..df3812cda376
--- /dev/null
+++ b/tools/testing/radix-tree/linux/xarray.h
@@ -0,0 +1,2 @@
+#include "generated/map-shift.h"
+#include "../../../../include/linux/xarray.h"
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 7bf405638b0b..b8f7f53e368f 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -39,12 +39,11 @@ static void __multiorder_tag_test(int index, int order)
 
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
 
@@ -380,8 +379,8 @@ static void multiorder_join1(unsigned long index,
 }
 
 /*
- * Check that the accounting of exceptional entries is handled correctly
- * by joining an exceptional entry to a normal pointer.
+ * Check that the accounting of inline data entries is handled correctly
+ * by joining a data entry to a normal pointer.
  */
 static void multiorder_join2(unsigned order1, unsigned order2)
 {
@@ -391,9 +390,9 @@ static void multiorder_join2(unsigned order1, unsigned order2)
 	void *item2;
 
 	item_insert_order(&tree, 0, order2);
-	radix_tree_insert(&tree, 1 << order2, (void *)0x12UL);
+	radix_tree_insert(&tree, 1 << order2, xa_mk_value(5));
 	item2 = __radix_tree_lookup(&tree, 1 << order2, &node, NULL);
-	assert(item2 == (void *)0x12UL);
+	assert(item2 == xa_mk_value(5));
 	assert(node->exceptional == 1);
 
 	item2 = radix_tree_lookup(&tree, 0);
@@ -407,7 +406,7 @@ static void multiorder_join2(unsigned order1, unsigned order2)
 }
 
 /*
- * This test revealed an accounting bug for exceptional entries at one point.
+ * This test revealed an accounting bug for inline data entries at one point.
  * Nodes were being freed back into the pool with an elevated exception count
  * by radix_tree_join() and then radix_tree_split() was failing to zero the
  * count of exceptional entries.
@@ -421,16 +420,16 @@ static void multiorder_join3(unsigned int order)
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
@@ -517,10 +516,10 @@ static void __multiorder_split2(int old_order, int new_order)
 	struct radix_tree_node *node;
 	void *item;
 
-	__radix_tree_insert(&tree, 0, old_order, (void *)0x12);
+	__radix_tree_insert(&tree, 0, old_order, xa_mk_value(5));
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item == (void *)0x12);
+	assert(item == xa_mk_value(5));
 	assert(node->exceptional > 0);
 
 	radix_tree_split(&tree, 0, new_order);
@@ -530,7 +529,7 @@ static void __multiorder_split2(int old_order, int new_order)
 	}
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(item != (void *)0x12);
+	assert(item != xa_mk_value(5));
 	assert(node->exceptional == 0);
 
 	item_kill_tree(&tree);
@@ -544,40 +543,40 @@ static void __multiorder_split3(int old_order, int new_order)
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
@@ -610,13 +609,13 @@ static void multiorder_account(void)
 
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
index def6015570b2..62de66c314b7 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -295,7 +295,7 @@ void item_kill_tree(struct radix_tree_root *root)
 	int nfound;
 
 	radix_tree_for_each_slot(slot, root, &iter, 0) {
-		if (radix_tree_exceptional_entry(*slot))
+		if (xa_is_value(*slot))
 			radix_tree_delete(root, iter.index);
 	}
 
-- 
2.17.1
