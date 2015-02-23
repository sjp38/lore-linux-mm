Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 909E76B0073
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 07:59:37 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id h11so16464251wiw.1
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 04:59:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dd2si17440050wib.96.2015.02.23.04.59.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 04:59:21 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 6/6] mm, thp: remove no longer needed khugepaged code
Date: Mon, 23 Feb 2015 13:58:42 +0100
Message-Id: <1424696322-21952-7-git-send-email-vbabka@suse.cz>
In-Reply-To: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

With collapse scanning moved to processes, we can remove lot of code from
khugepaged, mostly related to maintenance of mm_slots, where khugepaged used
to track which mm's to scan.

We keep the hooks for vma operations such as khugepaged_enter() only to set
the MMF_VM_HUGEPAGE bit, which enables the scanning for given mm.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/khugepaged.h |  14 +---
 kernel/fork.c              |   1 -
 mm/huge_memory.c           | 193 +--------------------------------------------
 3 files changed, 3 insertions(+), 205 deletions(-)

diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
index 51b2cc5..5af0f35 100644
--- a/include/linux/khugepaged.h
+++ b/include/linux/khugepaged.h
@@ -31,16 +31,10 @@ extern bool khugepaged_scan_mm(struct mm_struct *mm,
 static inline int khugepaged_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 {
 	if (test_bit(MMF_VM_HUGEPAGE, &oldmm->flags))
-		return __khugepaged_enter(mm);
+		set_bit(MMF_VM_HUGEPAGE, &mm->flags);
 	return 0;
 }
 
-static inline void khugepaged_exit(struct mm_struct *mm)
-{
-	if (test_bit(MMF_VM_HUGEPAGE, &mm->flags))
-		__khugepaged_exit(mm);
-}
-
 static inline int khugepaged_enter(struct vm_area_struct *vma,
 				   unsigned long vm_flags)
 {
@@ -48,8 +42,7 @@ static inline int khugepaged_enter(struct vm_area_struct *vma,
 		if ((khugepaged_always() ||
 		     (khugepaged_req_madv() && (vm_flags & VM_HUGEPAGE))) &&
 		    !(vm_flags & VM_NOHUGEPAGE))
-			if (__khugepaged_enter(vma->vm_mm))
-				return -ENOMEM;
+			set_bit(MMF_VM_HUGEPAGE, &vma->vm_mm->flags);
 	return 0;
 }
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
@@ -57,9 +50,6 @@ static inline int khugepaged_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 {
 	return 0;
 }
-static inline void khugepaged_exit(struct mm_struct *mm)
-{
-}
 static inline int khugepaged_enter(struct vm_area_struct *vma,
 				   unsigned long vm_flags)
 {
diff --git a/kernel/fork.c b/kernel/fork.c
index cf65139..5541a9f 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -659,7 +659,6 @@ void mmput(struct mm_struct *mm)
 		uprobe_clear_state(mm);
 		exit_aio(mm);
 		ksm_exit(mm);
-		khugepaged_exit(mm); /* must run before exit_mmap */
 		exit_mmap(mm);
 		set_mm_exe_file(mm, NULL);
 		if (!list_empty(&mm->mmlist)) {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9172c7f..f497e6b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -56,7 +56,6 @@ unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
 static unsigned int khugepaged_alloc_sleep_millisecs __read_mostly = 60000;
 static struct task_struct *khugepaged_thread __read_mostly;
 static DEFINE_MUTEX(khugepaged_mutex);
-static DEFINE_SPINLOCK(khugepaged_mm_lock);
 static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
 /*
  * default collapse hugepages if there is at least one pte mapped like
@@ -66,41 +65,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
 static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
 
 static int khugepaged(void *none);
-static int khugepaged_slab_init(void);
 
-#define MM_SLOTS_HASH_BITS 10
-static __read_mostly DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
-
-static struct kmem_cache *mm_slot_cache __read_mostly;
-
-/**
- * struct mm_slot - hash lookup from mm to mm_slot
- * @hash: hash collision list
- * @mm_node: khugepaged scan list headed in khugepaged_scan.mm_head
- * @mm: the mm that this information is valid for
- */
-struct mm_slot {
-	struct hlist_node hash;
-	struct list_head mm_node;
-	struct mm_struct *mm;
-};
-
-/**
- * struct khugepaged_scan - cursor for scanning
- * @mm_head: the head of the mm list to scan
- * @mm_slot: the current mm_slot we are scanning
- * @address: the next address inside that to be scanned
- *
- * There is only the one khugepaged_scan instance of this cursor structure.
- */
-struct khugepaged_scan {
-	struct list_head mm_head;
-	struct mm_slot *mm_slot;
-	unsigned long address;
-};
-static struct khugepaged_scan khugepaged_scan = {
-	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
-};
 static nodemask_t thp_avail_nodes = NODE_MASK_ALL;
 
 static int set_recommended_min_free_kbytes(void)
@@ -601,21 +566,12 @@ delete_obj:
 	return err;
 }
 
-static void __init hugepage_exit_sysfs(struct kobject *hugepage_kobj)
-{
-	sysfs_remove_group(hugepage_kobj, &khugepaged_attr_group);
-	sysfs_remove_group(hugepage_kobj, &hugepage_attr_group);
-	kobject_put(hugepage_kobj);
-}
 #else
 static inline int hugepage_init_sysfs(struct kobject **hugepage_kobj)
 {
 	return 0;
 }
 
-static inline void hugepage_exit_sysfs(struct kobject *hugepage_kobj)
-{
-}
 #endif /* CONFIG_SYSFS */
 
 static int __init hugepage_init(void)
@@ -632,10 +588,6 @@ static int __init hugepage_init(void)
 	if (err)
 		return err;
 
-	err = khugepaged_slab_init();
-	if (err)
-		goto out;
-
 	register_shrinker(&huge_zero_page_shrinker);
 
 	/*
@@ -649,9 +601,6 @@ static int __init hugepage_init(void)
 	start_khugepaged();
 
 	return 0;
-out:
-	hugepage_exit_sysfs(hugepage_kobj);
-	return err;
 }
 subsys_initcall(hugepage_init);
 
@@ -1979,83 +1928,6 @@ int hugepage_madvise(struct vm_area_struct *vma,
 	return 0;
 }
 
-static int __init khugepaged_slab_init(void)
-{
-	mm_slot_cache = kmem_cache_create("khugepaged_mm_slot",
-					  sizeof(struct mm_slot),
-					  __alignof__(struct mm_slot), 0, NULL);
-	if (!mm_slot_cache)
-		return -ENOMEM;
-
-	return 0;
-}
-
-static inline struct mm_slot *alloc_mm_slot(void)
-{
-	if (!mm_slot_cache)	/* initialization failed */
-		return NULL;
-	return kmem_cache_zalloc(mm_slot_cache, GFP_KERNEL);
-}
-
-static inline void free_mm_slot(struct mm_slot *mm_slot)
-{
-	kmem_cache_free(mm_slot_cache, mm_slot);
-}
-
-static struct mm_slot *get_mm_slot(struct mm_struct *mm)
-{
-	struct mm_slot *mm_slot;
-
-	hash_for_each_possible(mm_slots_hash, mm_slot, hash, (unsigned long)mm)
-		if (mm == mm_slot->mm)
-			return mm_slot;
-
-	return NULL;
-}
-
-static void insert_to_mm_slots_hash(struct mm_struct *mm,
-				    struct mm_slot *mm_slot)
-{
-	mm_slot->mm = mm;
-	hash_add(mm_slots_hash, &mm_slot->hash, (long)mm);
-}
-
-static inline int khugepaged_test_exit(struct mm_struct *mm)
-{
-	return atomic_read(&mm->mm_users) == 0;
-}
-
-int __khugepaged_enter(struct mm_struct *mm)
-{
-	struct mm_slot *mm_slot;
-	int wakeup;
-
-	mm_slot = alloc_mm_slot();
-	if (!mm_slot)
-		return -ENOMEM;
-
-	/* __khugepaged_exit() must not run from under us */
-	VM_BUG_ON_MM(khugepaged_test_exit(mm), mm);
-	if (unlikely(test_and_set_bit(MMF_VM_HUGEPAGE, &mm->flags))) {
-		free_mm_slot(mm_slot);
-		return 0;
-	}
-
-	spin_lock(&khugepaged_mm_lock);
-	insert_to_mm_slots_hash(mm, mm_slot);
-	/*
-	 * Insert just behind the scanning cursor, to let the area settle
-	 * down a little.
-	 */
-	wakeup = list_empty(&khugepaged_scan.mm_head);
-	list_add_tail(&mm_slot->mm_node, &khugepaged_scan.mm_head);
-	spin_unlock(&khugepaged_mm_lock);
-
-	atomic_inc(&mm->mm_count);
-
-	return 0;
-}
-
 int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 			       unsigned long vm_flags)
 {
@@ -2077,38 +1949,6 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 	return 0;
 }
 
-void __khugepaged_exit(struct mm_struct *mm)
-{
-	struct mm_slot *mm_slot;
-	int free = 0;
-
-	spin_lock(&khugepaged_mm_lock);
-	mm_slot = get_mm_slot(mm);
-	if (mm_slot && khugepaged_scan.mm_slot != mm_slot) {
-		hash_del(&mm_slot->hash);
-		list_del(&mm_slot->mm_node);
-		free = 1;
-	}
-	spin_unlock(&khugepaged_mm_lock);
-
-	if (free) {
-		clear_bit(MMF_VM_HUGEPAGE, &mm->flags);
-		free_mm_slot(mm_slot);
-		mmdrop(mm);
-	} else if (mm_slot) {
-		/*
-		 * This is required to serialize against
-		 * khugepaged_test_exit() (which is guaranteed to run
-		 * under mmap sem read mode). Stop here (after we
-		 * return all pagetables will be destroyed) until
-		 * khugepaged has finished working on the pagetables
-		 * under the mmap_sem.
-		 */
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
-	}
-}
-
 static void release_pte_page(struct page *page)
 {
 	/* 0 stands for page_is_file_cache(page) == false */
@@ -2450,8 +2290,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * handled by the anon_vma lock + PG_lock.
 	 */
 	down_write(&mm->mmap_sem);
-	if (unlikely(khugepaged_test_exit(mm)))
-		goto out;
+	VM_BUG_ON(atomic_read(&mm->mm_users) == 0);
 
 	vma = find_vma(mm, address);
 	if (!vma)
@@ -2629,29 +2468,6 @@ out:
 	return ret;
 }
 
-static void collect_mm_slot(struct mm_slot *mm_slot)
-{
-	struct mm_struct *mm = mm_slot->mm;
-
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
-
-	if (khugepaged_test_exit(mm)) {
-		/* free mm_slot */
-		hash_del(&mm_slot->hash);
-		list_del(&mm_slot->mm_node);
-
-		/*
-		 * Not strictly needed because the mm exited already.
-		 *
-		 * clear_bit(MMF_VM_HUGEPAGE, &mm->flags);
-		 */
-
-		/* khugepaged_mm_lock actually not necessary for the below */
-		free_mm_slot(mm_slot);
-		mmdrop(mm);
-	}
-}
-
 bool khugepaged_scan_mm(struct mm_struct *mm, unsigned long *start, long pages)
 {
 	struct vm_area_struct *vma;
@@ -2750,7 +2566,6 @@ static void khugepaged_wait_work(bool did_alloc)
 
 static int khugepaged(void *none)
 {
-	struct mm_slot *mm_slot;
 	bool did_alloc;
 
 	set_freezable();
@@ -2761,12 +2576,6 @@ static int khugepaged(void *none)
 		khugepaged_wait_work(did_alloc);
 	}
 
-	spin_lock(&khugepaged_mm_lock);
-	mm_slot = khugepaged_scan.mm_slot;
-	khugepaged_scan.mm_slot = NULL;
-	if (mm_slot)
-		collect_mm_slot(mm_slot);
-	spin_unlock(&khugepaged_mm_lock);
 	return 0;
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
