Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id E2A1E6B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 17:35:20 -0500 (EST)
Received: by mail-la0-f50.google.com with SMTP id pn19so26966268lab.9
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 14:35:20 -0800 (PST)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com. [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id d5si1235302lab.63.2015.01.12.14.35.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 14:35:19 -0800 (PST)
Received: by mail-la0-f46.google.com with SMTP id q1so26750552lam.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 14:35:19 -0800 (PST)
From: Dmitry Voytik <voytikd@gmail.com>
Subject: [PATCH] mm: wrap BUG() branches with unlikely()
Date: Tue, 13 Jan 2015 01:35:26 +0300
Message-Id: <1421102126-3637-1-git-send-email-voytikd@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Voytik <voytikd@gmail.com>

Wrap BUG() branches with unlikely() where it is possible. Use BUG_ON()
instead of "if () BUG();" where it is feasible.

Signed-off-by: Dmitry Voytik <voytikd@gmail.com>
---
 mm/bootmem.c        |  6 +++---
 mm/filemap.c        |  2 +-
 mm/huge_memory.c    |  4 ++--
 mm/memory.c         |  3 ++-
 mm/memory_hotplug.c |  3 +--
 mm/mempolicy.c      |  5 ++---
 mm/migrate.c        |  2 +-
 mm/mmap.c           | 19 ++++++++++---------
 mm/readahead.c      |  2 +-
 mm/slab.c           |  6 +++---
 mm/vmstat.c         |  2 +-
 mm/workingset.c     |  2 +-
 12 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 477be69..b8ccc25 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -297,7 +297,7 @@ static void __init __free(bootmem_data_t *bdata,
 		bdata->hint_idx = sidx;
 
 	for (idx = sidx; idx < eidx; idx++)
-		if (!test_and_clear_bit(idx, bdata->node_bootmem_map))
+		if (unlikely(!test_and_clear_bit(idx, bdata->node_bootmem_map)))
 			BUG();
 }
 
@@ -572,8 +572,8 @@ find_block:
 		/*
 		 * Reserve the area now:
 		 */
-		if (__reserve(bdata, PFN_DOWN(start_off) + merge,
-				PFN_UP(end_off), BOOTMEM_EXCLUSIVE))
+		if (unlikely(__reserve(bdata, PFN_DOWN(start_off) + merge,
+				PFN_UP(end_off), BOOTMEM_EXCLUSIVE)))
 			BUG();
 
 		region = phys_to_virt(PFN_PHYS(bdata->node_min_pfn) +
diff --git a/mm/filemap.c b/mm/filemap.c
index bf7a271..8d6244c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -769,7 +769,7 @@ void end_page_writeback(struct page *page)
 		rotate_reclaimable_page(page);
 	}
 
-	if (!test_clear_page_writeback(page))
+	if (unlikely(!test_clear_page_writeback(page)))
 		BUG();
 
 	smp_mb__after_atomic();
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b29c487..56ffca2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1908,7 +1908,7 @@ static void __split_huge_page(struct page *page,
 	 * the newly established pmd of the child later during the
 	 * walk, to be able to set it as pmd_trans_splitting too.
 	 */
-	if (mapcount != page_mapcount(page)) {
+	if (unlikely(mapcount != page_mapcount(page))) {
 		pr_err("mapcount %d page_mapcount %d\n",
 			mapcount, page_mapcount(page));
 		BUG();
@@ -1923,7 +1923,7 @@ static void __split_huge_page(struct page *page,
 		BUG_ON(is_vma_temporary_stack(vma));
 		mapcount2 += __split_huge_page_map(page, vma, addr);
 	}
-	if (mapcount != mapcount2) {
+	if (unlikely(mapcount != mapcount2)) {
 		pr_err("mapcount %d mapcount2 %d page_mapcount %d\n",
 			mapcount, mapcount2, page_mapcount(page));
 		BUG();
diff --git a/mm/memory.c b/mm/memory.c
index 5afb6d8..930c7d1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1193,7 +1193,8 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
 #ifdef CONFIG_DEBUG_VM
-				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
+				if (unlikely(!rwsem_is_locked(
+							&tlb->mm->mmap_sem))) {
 					pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
 						__func__, addr, end,
 						vma->vm_start,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b82b61e..c2c8723 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -2012,8 +2012,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 	 */
 	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
 				check_memblock_offlined_cb);
-	if (ret)
-		BUG();
+	BUG_ON(ret);
 
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0e0961b..2b0e34a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -408,14 +408,13 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask,
 	if (step == MPOL_REBIND_STEP1 && (pol->flags & MPOL_F_REBINDING))
 		return;
 
-	if (step == MPOL_REBIND_STEP2 && !(pol->flags & MPOL_F_REBINDING))
-		BUG();
+	BUG_ON(step == MPOL_REBIND_STEP2 && !(pol->flags & MPOL_F_REBINDING));
 
 	if (step == MPOL_REBIND_STEP1)
 		pol->flags |= MPOL_F_REBINDING;
 	else if (step == MPOL_REBIND_STEP2)
 		pol->flags &= ~MPOL_F_REBINDING;
-	else if (step >= MPOL_REBIND_NSTEP)
+	else if (unlikely(step >= MPOL_REBIND_NSTEP))
 		BUG();
 
 	mpol_ops[pol->mode].rebind(pol, newmask, step);
diff --git a/mm/migrate.c b/mm/migrate.c
index 6e284bc..def8cae 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -724,7 +724,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 	 * establishing additional references. We are the only one
 	 * holding a reference to the new page at this point.
 	 */
-	if (!trylock_page(newpage))
+	if (unlikely(!trylock_page(newpage)))
 		BUG();
 
 	/* Prepare mapping for the new page.*/
diff --git a/mm/mmap.c b/mm/mmap.c
index 14d8466..3ec0c40 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -690,8 +690,8 @@ static void __insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 	struct vm_area_struct *prev;
 	struct rb_node **rb_link, *rb_parent;
 
-	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
-			   &prev, &rb_link, &rb_parent))
+	if (unlikely(find_vma_links(mm, vma->vm_start, vma->vm_end, &prev,
+				    &rb_link, &rb_parent)))
 		BUG();
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	mm->map_count++;
@@ -3133,8 +3133,8 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 		 * can't change from under us thanks to the
 		 * anon_vma->root->rwsem.
 		 */
-		if (__test_and_set_bit(0, (unsigned long *)
-				       &anon_vma->root->rb_root.rb_node))
+		if (unlikely(__test_and_set_bit(0, (unsigned long *)
+				       &anon_vma->root->rb_root.rb_node)))
 			BUG();
 	}
 }
@@ -3151,7 +3151,8 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
 		 * mm_all_locks_mutex, there may be other cpus
 		 * changing other bitflags in parallel to us.
 		 */
-		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
+		if (unlikely(test_and_set_bit(AS_MM_ALL_LOCKS,
+					      &mapping->flags)))
 			BUG();
 		down_write_nest_lock(&mapping->i_mmap_rwsem, &mm->mmap_sem);
 	}
@@ -3234,8 +3235,8 @@ static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 		 * can't change from under us until we release the
 		 * anon_vma->root->rwsem.
 		 */
-		if (!__test_and_clear_bit(0, (unsigned long *)
-					  &anon_vma->root->rb_root.rb_node))
+		if (unlikely(!__test_and_clear_bit(0, (unsigned long *)
+					  &anon_vma->root->rb_root.rb_node)))
 			BUG();
 		anon_vma_unlock_write(anon_vma);
 	}
@@ -3249,8 +3250,8 @@ static void vm_unlock_mapping(struct address_space *mapping)
 		 * because we hold the mm_all_locks_mutex.
 		 */
 		i_mmap_unlock_write(mapping);
-		if (!test_and_clear_bit(AS_MM_ALL_LOCKS,
-					&mapping->flags))
+		if (unlikely(!test_and_clear_bit(AS_MM_ALL_LOCKS,
+					&mapping->flags)))
 			BUG();
 	}
 }
diff --git a/mm/readahead.c b/mm/readahead.c
index 17b9172..fca7df9 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -45,7 +45,7 @@ static void read_cache_pages_invalidate_page(struct address_space *mapping,
 					     struct page *page)
 {
 	if (page_has_private(page)) {
-		if (!trylock_page(page))
+		if (unlikely(!trylock_page(page)))
 			BUG();
 		page->mapping = mapping;
 		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
diff --git a/mm/slab.c b/mm/slab.c
index 65b5dcb..c6090a4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1467,7 +1467,7 @@ void __init kmem_cache_init_late(void)
 	/* 6) resize the head arrays to their final sizes */
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(cachep, &slab_caches, list)
-		if (enable_cpucache(cachep, GFP_NOWAIT))
+		if (unlikely(enable_cpucache(cachep, GFP_NOWAIT)))
 			BUG();
 	mutex_unlock(&slab_mutex);
 
@@ -2551,7 +2551,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
 
 	/* Verify double free bug */
 	for (i = page->active; i < cachep->num; i++) {
-		if (get_free_obj(page, i) == objnr) {
+		if (unlikely(get_free_obj(page, i) == objnr)) {
 			printk(KERN_ERR "slab: double free detected in cache "
 					"'%s', objp %p\n", cachep->name, objp);
 			BUG();
@@ -2668,7 +2668,7 @@ failed:
  */
 static void kfree_debugcheck(const void *objp)
 {
-	if (!virt_addr_valid(objp)) {
+	if (unlikely(!virt_addr_valid(objp))) {
 		printk(KERN_ERR "kfree_debugcheck: out of range ptr %lxh.\n",
 		       (unsigned long)objp);
 		BUG();
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 5fba97d..28c1a68 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1454,7 +1454,7 @@ static void __init start_shepherd_timer(void)
 		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
 			vmstat_update);
 
-	if (!alloc_cpumask_var(&cpu_stat_off, GFP_KERNEL))
+	if (unlikely(!alloc_cpumask_var(&cpu_stat_off, GFP_KERNEL)))
 		BUG();
 	cpumask_copy(cpu_stat_off, cpu_online_mask);
 
diff --git a/mm/workingset.c b/mm/workingset.c
index f7216fa..0c4de09 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -356,7 +356,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	}
 	BUG_ON(node->count);
 	inc_zone_state(page_zone(virt_to_page(node)), WORKINGSET_NODERECLAIM);
-	if (!__radix_tree_delete_node(&mapping->page_tree, node))
+	if (unlikely(!__radix_tree_delete_node(&mapping->page_tree, node)))
 		BUG();
 
 	spin_unlock(&mapping->tree_lock);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
