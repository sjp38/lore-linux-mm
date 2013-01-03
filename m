Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id DA97F6B0078
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 23:28:15 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 7/8] add volatile page discard hook to kswapd
Date: Thu,  3 Jan 2013 13:28:05 +0900
Message-Id: <1357187286-18759-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1357187286-18759-1-git-send-email-minchan@kernel.org>
References: <1357187286-18759-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

This patch adds volatile page discard hook to kswapd for
minimizing eviction of working set and enable discarding
volatile page although we don't turn on swap.

This patch is copied heavily from THP.

Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mvolatile.h |   13 ++
 include/linux/sched.h     |    1 +
 kernel/fork.c             |    2 +
 mm/internal.h             |    2 +
 mm/mvolatile.c            |  314 +++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c               |   44 ++++++-
 6 files changed, 374 insertions(+), 2 deletions(-)

diff --git a/include/linux/mvolatile.h b/include/linux/mvolatile.h
index eb07761..9276022 100644
--- a/include/linux/mvolatile.h
+++ b/include/linux/mvolatile.h
@@ -23,6 +23,9 @@ static inline void vma_purge_copy(struct vm_area_struct *dst,
 }
 
 int discard_volatile_page(struct page *page, enum ttu_flags ttu_flags);
+unsigned int discard_volatile_pages(struct zone *zone, unsigned int nr_pages);
+void mvolatile_exit(struct mm_struct *mm);
+
 #else
 static inline bool vma_purged(struct vm_area_struct *vma)
 {
@@ -45,6 +48,16 @@ static inline bool is_volatile_vma(struct vm_area_struct *vma)
 {
 	return false;
 }
+
+static inline unsigned int discard_volatile_pages(struct zone *zone,
+							unsigned int nr_pages)
+{
+	return 0;
+}
+
+static inline void mvolatile_exit(struct mm_struct *mm)
+{
+}
 #endif
 #endif
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0dd42a0..7ae95df 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -408,6 +408,7 @@ extern int get_dumpable(struct mm_struct *mm);
 
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
+#define MMF_VM_VOLATILE		21	/* set when VM_VOLATILE is set on vma */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 8b20ab7..9d7d218 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -70,6 +70,7 @@
 #include <linux/khugepaged.h>
 #include <linux/signalfd.h>
 #include <linux/uprobes.h>
+#include <linux/mvolatile.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -612,6 +613,7 @@ void mmput(struct mm_struct *mm)
 		uprobe_clear_state(mm);
 		exit_aio(mm);
 		ksm_exit(mm);
+		mvolatile_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
 		exit_mmap(mm);
 		set_mm_exe_file(mm, NULL);
diff --git a/mm/internal.h b/mm/internal.h
index a4fa284..e595224 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -351,6 +351,8 @@ extern unsigned long vm_mmap_pgoff(struct file *, unsigned long,
         unsigned long, unsigned long);
 
 extern void set_pageblock_order(void);
+unsigned long discard_volatile_page_list(struct zone *zone,
+					    struct list_head *page_list);
 unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 					    struct list_head *page_list);
 /* The ALLOC_WMARK bits are used as an index to zone->watermark */
diff --git a/mm/mvolatile.c b/mm/mvolatile.c
index c66c3bc..1c7bf5a 100644
--- a/mm/mvolatile.c
+++ b/mm/mvolatile.c
@@ -16,6 +16,8 @@
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
 #include <linux/mmu_notifier.h>
+#include <linux/migrate.h>
+#include "internal.h"
 
 #ifndef CONFIG_VOLATILE_PAGE
 SYSCALL_DEFINE2(mnovolatile, unsigned long, start, size_t, len)
@@ -29,6 +31,49 @@ SYSCALL_DEFINE2(mvolatile, unsigned long, start, size_t, len)
 }
 #else
 
+static DEFINE_SPINLOCK(mvolatile_mm_lock);
+
+#define MM_SLOTS_HASH_SHIFT 10
+#define MM_SLOTS_HASH_HEADS (1 << MM_SLOTS_HASH_SHIFT)
+
+struct mvolatile_scan {
+	struct list_head mm_head;
+	struct mm_slot *mm_slot;
+	unsigned long address;
+};
+
+static struct mvolatile_scan mvolatile_scan = {
+	.mm_head = LIST_HEAD_INIT(mvolatile_scan.mm_head),
+};
+
+static struct hlist_head mm_slots_hash[MM_SLOTS_HASH_HEADS];
+
+struct mm_slot {
+	struct hlist_node hash;
+	struct list_head mm_node;
+	struct mm_struct *mm;
+};
+
+static struct kmem_cache *mm_slot_cache __read_mostly;
+
+static int __init mvolatile_slab_init(void)
+{
+	mm_slot_cache = kmem_cache_create("mvolatile_mm_slot",
+			sizeof(struct mm_slot),
+			__alignof(struct mm_slot), 0, NULL);
+	if (!mm_slot_cache)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static int __init mvolatile_init(void)
+{
+	mvolatile_slab_init();
+	return 0;
+}
+module_init(mvolatile_init)
+
 /*
  * Check that @page is mapped at @address into @mm
  * The difference with __page_check_address is this function checks
@@ -209,6 +254,274 @@ int discard_volatile_page(struct page *page, enum ttu_flags ttu_flags)
 	return 0;
 }
 
+
+static inline struct mm_slot *alloc_mm_slot(void)
+{
+	if (!mm_slot_cache)
+		return NULL;
+	return kmem_cache_zalloc(mm_slot_cache, GFP_KERNEL);
+}
+
+static inline void free_mm_slot(struct mm_slot *mm_slot)
+{
+	kmem_cache_free(mm_slot_cache, mm_slot);
+}
+
+static struct mm_slot *get_mm_slot(struct mm_struct *mm)
+{
+	struct mm_slot *mm_slot;
+	struct hlist_head *bucket;
+	struct hlist_node *node;
+
+	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
+		% MM_SLOTS_HASH_HEADS];
+	hlist_for_each_entry(mm_slot, node, bucket, hash) {
+		if (mm == mm_slot->mm)
+			return mm_slot;
+	}
+	return NULL;
+
+}
+
+void insert_to_mm_slots_hash(struct mm_struct *mm, struct mm_slot *mm_slot)
+{
+	struct hlist_head *bucket;
+
+	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
+		% MM_SLOTS_HASH_HEADS];
+	mm_slot->mm = mm;
+	hlist_add_head(&mm_slot->hash, bucket);
+}
+
+int mvolatile_enter(struct vm_area_struct *vma)
+{
+	struct mm_slot *mm_slot;
+	struct mm_struct *mm = vma->vm_mm;
+
+	if (test_bit(MMF_VM_VOLATILE, &mm->flags))
+		return 0;
+
+	mm_slot = alloc_mm_slot();
+	if (!mm_slot)
+		return -ENOMEM;
+
+	if (unlikely(test_and_set_bit(MMF_VM_VOLATILE, &mm->flags))) {
+		free_mm_slot(mm_slot);
+		return 0;
+	}
+
+	spin_lock(&mvolatile_mm_lock);
+	insert_to_mm_slots_hash(mm, mm_slot);
+	list_add_tail(&mm_slot->mm_node, &mvolatile_scan.mm_head);
+	spin_unlock(&mvolatile_mm_lock);
+
+	atomic_inc(&mm->mm_count);
+	return 0;
+}
+
+void mvolatile_exit(struct mm_struct *mm)
+{
+	struct mm_slot *mm_slot;
+	bool free = false;
+
+	if (!test_bit(MMF_VM_VOLATILE, &mm->flags))
+		return;
+	/* TODO : revisit spin_lock vs spin_lock_irq */
+	spin_lock(&mvolatile_mm_lock);
+	mm_slot = get_mm_slot(mm);
+	/* TODO Consider current mm_slot we are scanning now */
+	if (mm_slot && mvolatile_scan.mm_slot != mm_slot) {
+		hlist_del(&mm_slot->hash);
+		list_del(&mm_slot->mm_node);
+		free = true;
+	}
+	spin_unlock(&mvolatile_mm_lock);
+	if (free) {
+		clear_bit(MMF_VM_VOLATILE, &mm->flags);
+		free_mm_slot(mm_slot);
+		mmdrop(mm);
+	} else if (mm_slot) {
+		down_write(&mm->mmap_sem);
+		up_write(&mm->mmap_sem);
+	}
+}
+
+static inline int mvolatile_test_exit(struct mm_struct *mm)
+{
+	return atomic_read(&mm->mm_users) == 0;
+}
+
+static void collect_mm_slot(struct mm_slot *mm_slot)
+{
+	struct mm_struct *mm = mm_slot->mm;
+
+	if (mvolatile_test_exit(mm)) {
+		hlist_del(&mm_slot->hash);
+		list_del(&mm_slot->mm_node);
+
+		free_mm_slot(mm_slot);
+		mmdrop(mm);
+	}
+}
+
+/* TODO: consider nr_pages */
+static unsigned int discard_vma_pages(struct zone *zone, struct mm_struct *mm,
+			struct vm_area_struct *vma, unsigned long address,
+			unsigned int nr_pages)
+{
+	LIST_HEAD(pagelist);
+	struct page *page;
+	int ret = 0;
+
+	for (; mvolatile_scan.address < vma->vm_end;
+			mvolatile_scan.address += PAGE_SIZE) {
+
+		if (mvolatile_test_exit(mm))
+			break;
+
+		/*
+		 * TODO : optimize page walking with the lock
+		 *        batch isolate_lru_page
+		 */
+		page = follow_page(vma, mvolatile_scan.address,
+				FOLL_GET|FOLL_SPLIT);
+		if (IS_ERR_OR_NULL(page)) {
+			cond_resched();
+			continue;
+		}
+
+		VM_BUG_ON(PageCompound(page));
+		BUG_ON(!PageAnon(page));
+		VM_BUG_ON(!PageSwapBacked(page));
+
+		/*
+		 * TODO : putback pages into tail of the zones.
+		 */
+		if (page_zone(page) != zone || isolate_lru_page(page)) {
+			put_page(page);
+			continue;
+		}
+
+		put_page(page);
+		list_add(&page->lru, &pagelist);
+		inc_zone_page_state(page, NR_ISOLATED_ANON + 0);
+	}
+
+	if (!list_empty(&pagelist))
+		ret = discard_volatile_page_list(zone, &pagelist);
+
+	/* TODO : putback pages into lru's tail */
+	putback_lru_pages(&pagelist);
+	return ret;
+}
+
+static unsigned int discard_mm_slot(struct zone *zone,
+		unsigned int nr_to_reclaim)
+{
+	struct mm_slot *mm_slot;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	unsigned int nr_discard = 0;
+
+	VM_BUG_ON(!nr_to_reclaim);
+	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&mvolatile_mm_lock));
+
+	if (mvolatile_scan.mm_slot)
+		mm_slot = mvolatile_scan.mm_slot;
+	else {
+		mm_slot = list_entry(mvolatile_scan.mm_head.next,
+				struct mm_slot, mm_node);
+		mvolatile_scan.address = 0;
+		mvolatile_scan.mm_slot = mm_slot;
+	}
+	spin_unlock(&mvolatile_mm_lock);
+
+	mm = mm_slot->mm;
+	if (!down_read_trylock(&mm->mmap_sem)) {
+		vma = NULL;
+		goto next_mm;
+	}
+
+	if (unlikely(mvolatile_test_exit(mm)))
+		vma = NULL;
+	else
+		vma = find_vma(mm, mvolatile_scan.address);
+
+	for (; vma; vma = vma->vm_next) {
+		cond_resched();
+
+		if (!(vma->vm_flags & VM_VOLATILE) || !vma->anon_vma) {
+			mvolatile_scan.address = vma->vm_end;
+			continue;
+		}
+
+		if (mvolatile_scan.address < vma->vm_start)
+			mvolatile_scan.address = vma->vm_start;
+
+		if (unlikely(mvolatile_test_exit(mm)))
+			break;
+
+		nr_discard += discard_vma_pages(zone, mm, vma,
+				mvolatile_scan.address,
+				nr_to_reclaim - nr_discard);
+
+		mvolatile_scan.address = vma->vm_end;
+		if (nr_discard >= nr_to_reclaim)
+			break;
+	}
+	up_read(&mm->mmap_sem);
+next_mm:
+	spin_lock(&mvolatile_mm_lock);
+	VM_BUG_ON(mvolatile_scan.mm_slot != mm_slot);
+
+	if (mvolatile_test_exit(mm) || !vma) {
+		if (mm_slot->mm_node.next != &mvolatile_scan.mm_head) {
+			mvolatile_scan.mm_slot = list_entry(
+					mm_slot->mm_node.next,
+					struct mm_slot, mm_node);
+			mvolatile_scan.address = 0;
+		} else {
+			mvolatile_scan.mm_slot = NULL;
+		}
+
+		collect_mm_slot(mm_slot);
+	}
+
+	return nr_discard;
+}
+
+
+#define MAX_NODISCARD_PROGRESS     (12)
+
+unsigned int discard_volatile_pages(struct zone *zone,
+		unsigned int nr_to_reclaim)
+{
+	unsigned int nr_discard = 0;
+	int nodiscard_progress = 0;
+
+	while (nr_discard < nr_to_reclaim) {
+		unsigned int ret;
+
+		cond_resched();
+
+		spin_lock(&mvolatile_mm_lock);
+		if (list_empty(&mvolatile_scan.mm_head)) {
+			spin_unlock(&mvolatile_mm_lock);
+			break;
+		}
+		ret = discard_mm_slot(zone, nr_to_reclaim);
+		if (!ret)
+			nodiscard_progress++;
+		spin_unlock(&mvolatile_mm_lock);
+		if (nodiscard_progress >= MAX_NODISCARD_PROGRESS)
+			break;
+		nr_to_reclaim -= ret;
+		nr_discard += ret;
+	}
+
+	return nr_discard;
+}
+
 #define NO_PURGED	0
 #define PURGED		1
 
@@ -345,6 +658,7 @@ static int do_mvolatile(struct vm_area_struct *vma,
 	vma_lock_anon_vma(vma);
 	vma->vm_flags = new_flags;
 	vma_unlock_anon_vma(vma);
+	mvolatile_enter(vma);
 out:
 	return error;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 449ec95..c936880 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -977,6 +977,34 @@ keep:
 	return nr_reclaimed;
 }
 
+#ifdef CONFIG_VOLATILE_PAGE
+unsigned long discard_volatile_page_list(struct zone *zone,
+		struct list_head *page_list)
+{
+	unsigned long ret;
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.priority = DEF_PRIORITY,
+		.may_unmap = 1,
+		.may_swap = 1
+	};
+
+	unsigned long dummy1, dummy2;
+	struct page *page;
+
+	list_for_each_entry(page, page_list, lru) {
+		VM_BUG_ON(!PageAnon(page));
+		ClearPageActive(page);
+	}
+
+	ret = shrink_page_list(page_list, zone, &sc,
+			TTU_UNMAP|TTU_IGNORE_ACCESS,
+			&dummy1, &dummy2, false);
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -ret);
+	return ret;
+}
+#endif
+
 unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 					    struct list_head *page_list)
 {
@@ -2703,8 +2731,19 @@ loop_again:
 				testorder = 0;
 
 			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
-			    !zone_balanced(zone, testorder,
-					   balance_gap, end_zone)) {
+					!zone_balanced(zone, testorder,
+						balance_gap, end_zone)) {
+				unsigned int nr_discard;
+				if (testorder == 0) {
+					nr_discard = discard_volatile_pages(
+							zone,
+							SWAP_CLUSTER_MAX);
+					sc.nr_reclaimed += nr_discard;
+					if (zone_balanced(zone, testorder, 0,
+								end_zone))
+						goto zone_balanced;
+				}
+
 				shrink_zone(zone, &sc);
 
 				reclaim_state->reclaimed_slab = 0;
@@ -2742,6 +2781,7 @@ loop_again:
 					    min_wmark_pages(zone), end_zone, 0))
 					has_under_min_watermark_zone = 1;
 			} else {
+zone_balanced:
 				/*
 				 * If a zone reaches its high watermark,
 				 * consider it to be no longer congested. It's
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
