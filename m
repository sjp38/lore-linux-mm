Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 302776B005C
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:39:02 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v7 10/11] Purging vrange pages without swap
Date: Tue, 12 Mar 2013 16:38:34 +0900
Message-Id: <1363073915-25000-11-git-send-email-minchan@kernel.org>
In-Reply-To: <1363073915-25000-1-git-send-email-minchan@kernel.org>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

Now one of problem in vrange is VM reclaim anonymous pages if only
there is a swap system. This patch adds new hook in kswapd where
above scanning normal LRU pages.

This patch discards all of pages of vmas in vrange without
considering VRANGE_[FULL|PARTIAL]_MODE, which will be considered
in future work.

I should confess that I didn't spend enough time to investigate
where is good place for hook. Even, It might be better to add new
kvranged thread because there are a few bugs these days in kswapd,
which was very sensitive for a small change so adding new hooks
may make subtle another problem.

It could be better to move vrange code into kswapd after settle down
in kvrangd. Otherwise, we could leave at it is in kvranged.

Other issue is scanning cost of virtual address. We don't have any
information of rss in each VMA so kswapd can scan all address without
any gain. It can burn out CPU. I have a plan to account rss
by per-VMA at least, anonymous vma.

Any comment are welcome!

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h   |   3 +
 include/linux/vrange.h |   4 +-
 mm/vmscan.c            |  45 +++++++++-
 mm/vrange.c            | 239 +++++++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 279 insertions(+), 12 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 6432dfb..e822a30 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -83,6 +83,9 @@ enum ttu_flags {
 };
 
 #ifdef CONFIG_MMU
+unsigned long discard_vrange_page_list(struct zone *zone,
+		struct list_head *page_list);
+
 unsigned long vma_address(struct page *page, struct vm_area_struct *vma);
 
 static inline void get_anon_vma(struct anon_vma *anon_vma)
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 26db168..4bcec40 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -5,14 +5,12 @@
 #include <linux/interval_tree.h>
 #include <linux/mm.h>
 
-/* To protect race with forker */
-static DECLARE_RWSEM(vrange_fork_lock);
-
 struct vrange {
 	struct interval_tree_node node;
 	bool purged;
 	struct mm_struct *mm;
 	struct list_head lru; /* protected by lru_lock */
+	atomic_t refcount;
 };
 
 #define vrange_entry(ptr) \
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e36ee51..2220ce7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -683,7 +683,7 @@ static enum page_references page_check_references(struct page *page,
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
-static unsigned long shrink_page_list(struct list_head *page_list,
+unsigned long shrink_page_list(struct list_head *page_list,
 				      struct zone *zone,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
@@ -985,6 +985,35 @@ keep:
 	return nr_reclaimed;
 }
 
+
+unsigned long discard_vrange_page_list(struct zone *zone,
+		struct list_head *page_list)
+{
+	unsigned long ret;
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.priority = DEF_PRIORITY,
+		.may_unmap = 1,
+		.may_swap = 1,
+		.may_discard = 1
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
+	/* page_list have pages from multiple zones */
+	ret = shrink_page_list(page_list, NULL, &sc,
+			TTU_UNMAP|TTU_IGNORE_ACCESS,
+			&dummy1, &dummy2, false);
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -ret);
+	return ret;
+}
+
 unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 					    struct list_head *page_list)
 {
@@ -2781,6 +2810,16 @@ loop_again:
 			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
 			    !zone_balanced(zone, testorder,
 					   balance_gap, end_zone)) {
+
+				unsigned int nr_discard;
+				if (testorder == 0) {
+					nr_discard = discard_vrange_pages(zone,
+							SWAP_CLUSTER_MAX);
+					sc.nr_reclaimed += nr_discard;
+					if (zone_balanced(zone, testorder, 0,
+								end_zone))
+						goto zone_balanced;
+				}
 				shrink_zone(zone, &sc);
 
 				reclaim_state->reclaimed_slab = 0;
@@ -2805,7 +2844,8 @@ loop_again:
 				continue;
 			}
 
-			if (zone_balanced(zone, testorder, 0, end_zone))
+			if (zone_balanced(zone, testorder, 0, end_zone)) {
+zone_balanced:
 				/*
 				 * If a zone reaches its high watermark,
 				 * consider it to be no longer congested. It's
@@ -2814,6 +2854,7 @@ loop_again:
 				 * speculatively avoid congestion waits
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
+			}
 		}
 
 		/*
diff --git a/mm/vrange.c b/mm/vrange.c
index b9b1ffa..2f56d36 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -13,15 +13,29 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
+#include <linux/migrate.h>
+
+struct vrange_walker_private {
+	struct zone *zone;
+	struct vm_area_struct *vma;
+	struct list_head *pagelist;
+};
 
 static LIST_HEAD(lru_vrange);
 static DEFINE_SPINLOCK(lru_lock);
 
 static struct kmem_cache *vrange_cachep;
 
+static void vrange_ctor(void *data)
+{
+	struct vrange *vrange = data;
+	INIT_LIST_HEAD(&vrange->lru);
+}
+
 void __init vrange_init(void)
 {
-	vrange_cachep = KMEM_CACHE(vrange, SLAB_PANIC);
+	vrange_cachep = kmem_cache_create("vrange", sizeof(struct vrange),
+				0, SLAB_PANIC, vrange_ctor);
 }
 
 static inline void __set_vrange(struct vrange *range,
@@ -78,6 +92,7 @@ static void __add_range(struct vrange *range,
 	interval_tree_insert(&range->node, root);
 }
 
+/* remove range from interval tree */
 static void __remove_range(struct vrange *range,
 				struct rb_root *root)
 {
@@ -87,7 +102,8 @@ static void __remove_range(struct vrange *range,
 static struct vrange *alloc_vrange(void)
 {
 	struct vrange *vrange = kmem_cache_alloc(vrange_cachep, GFP_KERNEL);
-	INIT_LIST_HEAD(&vrange->lru);
+	if (vrange)
+		atomic_set(&vrange->refcount, 1);
 	return vrange;
 }
 
@@ -97,6 +113,13 @@ static void free_vrange(struct vrange *range)
 	kmem_cache_free(vrange_cachep, range);
 }
 
+static void put_vrange(struct vrange *range)
+{
+	WARN_ON(atomic_read(&range->refcount) < 0);
+	if (atomic_dec_and_test(&range->refcount))
+		free_vrange(range);
+}
+
 static inline void range_resize(struct rb_root *root,
 		struct vrange *range,
 		unsigned long start, unsigned long end,
@@ -127,7 +150,7 @@ int add_vrange(struct mm_struct *mm,
 
 		range = container_of(node, struct vrange, node);
 		if (node->start < start && node->last > end) {
-			free_vrange(new_range);
+			put_vrange(new_range);
 			goto out;
 		}
 
@@ -136,7 +159,7 @@ int add_vrange(struct mm_struct *mm,
 
 		purged |= range->purged;
 		__remove_range(range, root);
-		free_vrange(range);
+		put_vrange(range);
 
 		node = next;
 	}
@@ -174,7 +197,7 @@ int remove_vrange(struct mm_struct *mm,
 
 		if (start <= node->start && end >= node->last) {
 			__remove_range(range, root);
-			free_vrange(range);
+			put_vrange(range);
 		} else if (node->start >= start) {
 			range_resize(root, range, end, node->last, mm);
 		} else if (node->last <= end) {
@@ -194,7 +217,7 @@ int remove_vrange(struct mm_struct *mm,
 
 	vrange_unlock(mm);
 	if (!used_new)
-		free_vrange(new_range);
+		put_vrange(new_range);
 
 	return ret;
 }
@@ -209,7 +232,7 @@ void exit_vrange(struct mm_struct *mm)
 		range = vrange_entry(next);
 		next = rb_next(next);
 		__remove_range(range, &mm->v_rb);
-		free_vrange(range);
+		put_vrange(range);
 	}
 }
 
@@ -494,6 +517,7 @@ int discard_vpage(struct page *page)
 
 		if (page_freeze_refs(page, 1)) {
 			unlock_page(page);
+			dec_zone_page_state(page, NR_ISOLATED_ANON);
 			return 1;
 		}
 	}
@@ -518,3 +542,204 @@ bool is_purged_vrange(struct mm_struct *mm, unsigned long address)
 	vrange_unlock(mm);
 	return ret;
 }
+
+static void vrange_pte_entry(pte_t pteval, unsigned long address,
+			unsigned ptent_size, struct mm_walk *walk)
+{
+	struct page *page;
+	struct vrange_walker_private *vwp = walk->private;
+	struct vm_area_struct *vma = vwp->vma;
+	struct list_head *pagelist = vwp->pagelist;
+	struct zone *zone = vwp->zone;
+
+	if (pte_none(pteval))
+		return;
+
+	if (!pte_present(pteval))
+		return;
+
+	page = vm_normal_page(vma, address, pteval);
+	if (unlikely(!page))
+		return;
+
+	if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
+		return;
+
+	/* TODO : Support THP and HugeTLB */
+	if (unlikely(PageCompound(page)))
+		return;
+
+	if (zone_idx(page_zone(page)) > zone_idx(zone))
+		return;
+
+	if (isolate_lru_page(page))
+		return;
+
+	list_add(&page->lru, pagelist);
+	inc_zone_page_state(page, NR_ISOLATED_ANON);
+}
+
+static int vrange_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
+				struct mm_walk *walk)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE)
+		vrange_pte_entry(*pte, addr, PAGE_SIZE, walk);
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+	return 0;
+
+}
+
+unsigned int discard_vma_pages(struct zone *zone, struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long start,
+		unsigned long end, unsigned int nr_to_discard)
+{
+	LIST_HEAD(pagelist);
+	int ret = 0;
+	struct vrange_walker_private vwp;
+	struct mm_walk vrange_walk = {
+		.pmd_entry = vrange_pte_range,
+		.mm = vma->vm_mm,
+		.private = &vwp,
+	};
+
+	vwp.pagelist = &pagelist;
+	vwp.vma = vma;
+	vwp.zone = zone;
+
+	walk_page_range(start, end, &vrange_walk);
+
+	if (!list_empty(&pagelist))
+		ret = discard_vrange_page_list(zone, &pagelist);
+
+	putback_lru_pages(&pagelist);
+	return ret;
+}
+
+unsigned int discard_vrange(struct zone *zone, struct vrange *vrange,
+				int nr_to_discard)
+{
+	struct mm_struct *mm = vrange->mm;
+	unsigned long start = vrange->node.start;
+	unsigned long end = vrange->node.last;
+	struct vm_area_struct *vma;
+	unsigned int nr_discarded = 0;
+
+	if (!down_read_trylock(&mm->mmap_sem))
+		goto out;
+
+	vma = find_vma(mm, start);
+	if (!vma || (vma->vm_start > end))
+		goto out_unlock;
+
+	for (; vma; vma = vma->vm_next) {
+		if (vma->vm_start > end)
+			break;
+
+		if (vma->vm_file ||
+			(vma->vm_flags & (VM_SPECIAL | VM_LOCKED)))
+			continue;
+
+		cond_resched();
+		nr_discarded +=
+			discard_vma_pages(zone, mm, vma,
+				max_t(unsigned long, start, vma->vm_start),
+				min_t(unsigned long, end + 1, vma->vm_end),
+				nr_to_discard);
+	}
+out_unlock:
+	up_read(&mm->mmap_sem);
+out:
+	return nr_discarded;
+}
+
+/*
+ * Get next victim vrange from LRU and hold a vrange refcount
+ * and vrange->mm's refcount.
+ */
+struct vrange *get_victim_vrange(void)
+{
+	struct mm_struct *mm;
+	struct vrange *vrange = NULL;
+	struct list_head *cur, *tmp;
+
+	spin_lock(&lru_lock);
+	list_for_each_prev_safe(cur, tmp, &lru_vrange) {
+		vrange = list_entry(cur, struct vrange, lru);
+		mm = vrange->mm;
+		/* the process is exiting so pass it */
+		if (atomic_read(&mm->mm_users) == 0) {
+			list_del_init(&vrange->lru);
+			vrange = NULL;
+			continue;
+		}
+
+		/* vrange is freeing so continue to loop */
+		if (!atomic_inc_not_zero(&vrange->refcount)) {
+			list_del_init(&vrange->lru);
+			vrange = NULL;
+			continue;
+		}
+
+		/*
+		 * we need to access mmap_sem further routine so
+		 * need to get a refcount of mm.
+		 * NOTE: We guarantee mm_count isn't zero in here because
+		 * if we found vrange from LRU list, it means we are
+		 * before exit_vrange or remove_vrange.
+		 */
+		atomic_inc(&mm->mm_count);
+
+		/* Isolate vrange */
+		list_del_init(&vrange->lru);
+		break;
+	}
+
+	spin_unlock(&lru_lock);
+	return vrange;
+}
+
+void put_victim_range(struct vrange *vrange)
+{
+	put_vrange(vrange);
+	mmdrop(vrange->mm);
+}
+
+unsigned int discard_vrange_pages(struct zone *zone, int nr_to_discard)
+{
+	struct vrange *vrange, *start_vrange;
+	unsigned int nr_discarded = 0;
+
+	start_vrange = vrange = get_victim_vrange();
+	if (start_vrange) {
+		struct mm_struct *mm = start_vrange->mm;
+		atomic_inc(&start_vrange->refcount);
+		atomic_inc(&mm->mm_count);
+	}
+
+	while (vrange) {
+		nr_discarded += discard_vrange(zone, vrange, nr_to_discard);
+		lru_add_vrange(vrange);
+		put_victim_range(vrange);
+
+		if (nr_discarded >= nr_to_discard)
+			break;
+
+		vrange = get_victim_vrange();
+		/* break if we go round the loop */
+		if (vrange == start_vrange) {
+			lru_add_vrange(vrange);
+			put_victim_range(vrange);
+			break;
+		}
+	}
+
+	if (start_vrange)
+		put_victim_range(start_vrange);
+
+	return nr_discarded;
+}
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
