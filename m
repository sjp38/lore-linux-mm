Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 98C296B0027
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 19:52:43 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w11so1114114pde.9
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 16:52:42 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [RFC PATCH 2/4] vrange: Introduce vrange_root to make vrange structures more flexible
Date: Wed,  3 Apr 2013 16:52:21 -0700
Message-Id: <1365033144-15156-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
References: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

Instead of having the vrange trees hanging directly off of the
mm_struct, use a vrange_root structure, which will allow us
to have vrange_roots that hang off the mm_struct for anonomous
memory, as well as address_space structures for file backed memory.

Cc: linux-mm@kvack.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Arun Sharma <asharma@fb.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Jason Evans <je@fb.com>
Cc: sanjay@google.com
Cc: Paul Turner <pjt@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 fs/proc/task_mmu.c           |   10 +--
 include/linux/mm_types.h     |    4 +-
 include/linux/vrange.h       |   35 +++++-----
 include/linux/vrange_types.h |   21 ++++++
 kernel/fork.c                |    2 +-
 mm/vrange.c                  |  156 ++++++++++++++++++++++--------------------
 6 files changed, 126 insertions(+), 102 deletions(-)
 create mode 100644 include/linux/vrange_types.h

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index df009f0..11f63d4 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -391,13 +391,13 @@ static void *v_start(struct seq_file *m, loff_t *pos)
 	if (!mm || IS_ERR(mm))
 		return mm;
 
-	vrange_lock(mm);
-	root = &mm->v_rb;
+	vrange_lock(&mm->vroot);
+	root = &mm->vroot.v_rb;
 
-	if (RB_EMPTY_ROOT(&mm->v_rb))
+	if (RB_EMPTY_ROOT(&mm->vroot.v_rb))
 		goto out;
 
-	next = rb_first(&mm->v_rb);
+	next = rb_first(&mm->vroot.v_rb);
 	range = vrange_entry(next);
 	while(n > 0 && range) {
 		n--;
@@ -432,7 +432,7 @@ static void v_stop(struct seq_file *m, void *v)
 	struct proc_vrange_private *priv = m->private;
 	if (priv->task) {
 		struct mm_struct *mm = priv->task->mm;
-		vrange_unlock(mm);
+		vrange_unlock(&mm->vroot);
 		mmput(mm);
 		put_task_struct(priv->task);
 	}
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 080bf74..2e02a6d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -14,6 +14,7 @@
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
 #include <linux/mutex.h>
+#include <linux/vrange_types.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -353,8 +354,7 @@ struct mm_struct {
 
 
 #ifdef CONFIG_MMU
-	struct rb_root v_rb;		/* vrange rb tree */
-	struct mutex v_lock;		/* Protect v_rb */
+	struct vrange_root vroot;
 #endif
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 4bcec40..b9b219c 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -1,42 +1,39 @@
 #ifndef _LINUX_VRANGE_H
 #define _LINUX_VRANGE_H
 
-#include <linux/mutex.h>
-#include <linux/interval_tree.h>
+#include <linux/vrange_types.h>
 #include <linux/mm.h>
 
-struct vrange {
-	struct interval_tree_node node;
-	bool purged;
-	struct mm_struct *mm;
-	struct list_head lru; /* protected by lru_lock */
-	atomic_t refcount;
-};
-
 #define vrange_entry(ptr) \
 	container_of(ptr, struct vrange, node.rb)
 
 #ifdef CONFIG_MMU
-struct mm_struct;
 
 static inline void mm_init_vrange(struct mm_struct *mm)
 {
-	mm->v_rb = RB_ROOT;
-	mutex_init(&mm->v_lock);
+	mm->vroot.v_rb = RB_ROOT;
+	mutex_init(&mm->vroot.v_lock);
+}
+
+static inline void vrange_lock(struct vrange_root *vroot)
+{
+	mutex_lock(&vroot->v_lock);
 }
 
-static inline void vrange_lock(struct mm_struct *mm)
+static inline void vrange_unlock(struct vrange_root *vroot)
 {
-	mutex_lock(&mm->v_lock);
+	mutex_unlock(&vroot->v_lock);
 }
 
-static inline void vrange_unlock(struct mm_struct *mm)
+static inline struct mm_struct *vrange_get_owner_mm(struct vrange *vrange)
 {
-	mutex_unlock(&mm->v_lock);
+
+	return container_of(vrange->owner, struct mm_struct, vroot);
 }
 
-extern void exit_vrange(struct mm_struct *mm);
+
 void vrange_init(void);
+extern void mm_exit_vrange(struct mm_struct *mm);
 int discard_vpage(struct page *page);
 bool vrange_address(struct mm_struct *mm, unsigned long start,
 			unsigned long end);
@@ -50,7 +47,7 @@ void lru_move_vrange_to_head(struct mm_struct *mm, unsigned long address);
 
 static inline void vrange_init(void) {};
 static inline void mm_init_vrange(struct mm_struct *mm) {};
-static inline void exit_vrange(struct mm_struct *mm);
+static inline void mm_exit_vrange(struct mm_struct *mm);
 
 static inline bool vrange_address(struct mm_struct *mm, unsigned long start,
 		unsigned long end) { return false; };
diff --git a/include/linux/vrange_types.h b/include/linux/vrange_types.h
new file mode 100644
index 0000000..bede336
--- /dev/null
+++ b/include/linux/vrange_types.h
@@ -0,0 +1,21 @@
+#ifndef _LINUX_VRANGE_TYPES_H
+#define _LINUX_VRANGE_TYPES_H
+
+#include <linux/mutex.h>
+#include <linux/interval_tree.h>
+
+struct vrange_root {
+	struct rb_root v_rb;		/* vrange rb tree */
+	struct mutex v_lock;		/* Protect v_rb */
+};
+
+
+struct vrange {
+	struct interval_tree_node node;
+	struct vrange_root *owner;
+	bool purged;
+	struct list_head lru; /* protected by lru_lock */
+	atomic_t refcount;
+};
+#endif
+
diff --git a/kernel/fork.c b/kernel/fork.c
index e3aa120..f2da4a0 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -614,7 +614,7 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		uprobe_clear_state(mm);
-		exit_vrange(mm);
+		mm_exit_vrange(mm);
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
diff --git a/mm/vrange.c b/mm/vrange.c
index d07884d..9facbbc 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -39,10 +39,12 @@ void __init vrange_init(void)
 }
 
 static inline void __set_vrange(struct vrange *range,
-		unsigned long start_idx, unsigned long end_idx)
+		unsigned long start_idx, unsigned long end_idx,
+		bool purged)
 {
 	range->node.start = start_idx;
 	range->node.last = end_idx;
+	range->purged = purged;
 }
 
 static void lru_add_vrange(struct vrange *vrange)
@@ -63,12 +65,13 @@ static void lru_remove_vrange(struct vrange *vrange)
 
 void lru_move_vrange_to_head(struct mm_struct *mm, unsigned long address)
 {
-	struct rb_root *root = &mm->v_rb;
+	struct vrange_root *vroot = &mm->vroot;
 	struct interval_tree_node *node;
 	struct vrange *vrange;
 
-	vrange_lock(mm);
-	node = interval_tree_iter_first(root, address, address + PAGE_SIZE - 1);
+	vrange_lock(vroot);
+	node = interval_tree_iter_first(&vroot->v_rb, address,
+						address + PAGE_SIZE - 1);
 	if (node) {
 		vrange = container_of(node, struct vrange, node);
 		spin_lock(&lru_lock);
@@ -81,22 +84,21 @@ void lru_move_vrange_to_head(struct mm_struct *mm, unsigned long address)
 			list_move(&vrange->lru, &lru_vrange);
 		spin_unlock(&lru_lock);
 	}
-	vrange_unlock(mm);
+	vrange_unlock(vroot);
 }
 
-static void __add_range(struct vrange *range,
-			struct rb_root *root, struct mm_struct *mm)
+static void __add_range(struct vrange *range, struct vrange_root *vroot)
 {
-	range->mm = mm;
+	range->owner = vroot;
 	lru_add_vrange(range);
-	interval_tree_insert(&range->node, root);
+	interval_tree_insert(&range->node, &vroot->v_rb);
 }
 
 /* remove range from interval tree */
-static void __remove_range(struct vrange *range,
-				struct rb_root *root)
+static void __remove_range(struct vrange *range)
 {
-	interval_tree_remove(&range->node, root);
+	interval_tree_remove(&range->node, &range->owner->v_rb);
+	range->owner = NULL;
 }
 
 static struct vrange *alloc_vrange(void)
@@ -104,11 +106,13 @@ static struct vrange *alloc_vrange(void)
 	struct vrange *vrange = kmem_cache_alloc(vrange_cachep, GFP_KERNEL);
 	if (vrange)
 		atomic_set(&vrange->refcount, 1);
+	vrange->owner = NULL;
 	return vrange;
 }
 
 static void free_vrange(struct vrange *range)
 {
+	WARN_ON(range->owner);
 	lru_remove_vrange(range);
 	kmem_cache_free(vrange_cachep, range);
 }
@@ -120,20 +124,20 @@ static void put_vrange(struct vrange *range)
 		free_vrange(range);
 }
 
-static inline void range_resize(struct rb_root *root,
-		struct vrange *range,
-		unsigned long start, unsigned long end,
-		struct mm_struct *mm)
+static inline void range_resize(struct vrange *range,
+		unsigned long start, unsigned long end)
 {
-	__remove_range(range, root);
-	__set_vrange(range, start, end);
-	__add_range(range, root, mm);
+	struct vrange_root *vroot = range->owner;
+	bool purged = range->purged;
+
+	__remove_range(range);
+	__set_vrange(range, start, end, purged);
+	__add_range(range, vroot);
 }
 
-static int add_vrange(struct mm_struct *mm,
+static int add_vrange(struct vrange_root *vroot,
 			unsigned long start, unsigned long end)
 {
-	struct rb_root *root;
 	struct vrange *new_range, *range;
 	struct interval_tree_node *node, *next;
 	int purged = 0;
@@ -142,9 +146,8 @@ static int add_vrange(struct mm_struct *mm,
 	if (!new_range)
 		return -ENOMEM;
 
-	root = &mm->v_rb;
-	vrange_lock(mm);
-	node = interval_tree_iter_first(root, start, end);
+	vrange_lock(vroot);
+	node = interval_tree_iter_first(&vroot->v_rb, start, end);
 	while (node) {
 		next = interval_tree_iter_next(node, start, end);
 
@@ -158,24 +161,22 @@ static int add_vrange(struct mm_struct *mm,
 		end = max_t(unsigned long, end, node->last);
 
 		purged |= range->purged;
-		__remove_range(range, root);
+		__remove_range(range);
 		put_vrange(range);
 
 		node = next;
 	}
 
-	__set_vrange(new_range, start, end);
-	new_range->purged = purged;
-	__add_range(new_range, root, mm);
+	__set_vrange(new_range, start, end, purged);
+	__add_range(new_range, vroot);
 out:
-	vrange_unlock(mm);
+	vrange_unlock(vroot);
 	return 0;
 }
 
-static int remove_vrange(struct mm_struct *mm,
+static int remove_vrange(struct vrange_root *vroot,
 		unsigned long start, unsigned long end)
 {
-	struct rb_root *root;
 	struct vrange *new_range, *range;
 	struct interval_tree_node *node, *next;
 	int ret	= 0;
@@ -185,10 +186,9 @@ static int remove_vrange(struct mm_struct *mm,
 	if (!new_range)
 		return -ENOMEM;
 
-	root = &mm->v_rb;
-	vrange_lock(mm);
+	vrange_lock(vroot);
 
-	node = interval_tree_iter_first(root, start, end);
+	node = interval_tree_iter_first(&vroot->v_rb, start, end);
 	while (node) {
 		next = interval_tree_iter_next(node, start, end);
 
@@ -196,42 +196,40 @@ static int remove_vrange(struct mm_struct *mm,
 		ret |= range->purged;
 
 		if (start <= node->start && end >= node->last) {
-			__remove_range(range, root);
+			__remove_range(range);
 			put_vrange(range);
 		} else if (node->start >= start) {
-			range_resize(root, range, end, node->last, mm);
+			range_resize(range, end, node->last);
 		} else if (node->last <= end) {
-			range_resize(root, range, node->start, start, mm);
+			range_resize(range, node->start, start);
 		} else {
 			used_new = true;
-			__set_vrange(new_range, end, node->last);
-			new_range->purged = range->purged;
-			new_range->mm = mm;
-			range_resize(root, range, node->start, start, mm);
-			__add_range(new_range, root, mm);
+			__set_vrange(new_range, end, node->last, range->purged);
+			range_resize(range, node->start, start);
+			__add_range(new_range, vroot);
 			break;
 		}
 
 		node = next;
 	}
 
-	vrange_unlock(mm);
+	vrange_unlock(vroot);
 	if (!used_new)
 		put_vrange(new_range);
 
 	return ret;
 }
 
-void exit_vrange(struct mm_struct *mm)
+void mm_exit_vrange(struct mm_struct *mm)
 {
 	struct vrange *range;
 	struct rb_node *next;
 
-	next = rb_first(&mm->v_rb);
+	next = rb_first(&mm->vroot.v_rb);
 	while (next) {
 		range = vrange_entry(next);
 		next = rb_next(next);
-		__remove_range(range, &mm->v_rb);
+		__remove_range(range);
 		put_vrange(range);
 	}
 }
@@ -285,17 +283,18 @@ SYSCALL_DEFINE4(vrange, unsigned long, start,
 		goto out;
 
 	if (mode == VRANGE_VOLATILE)
-		ret = add_vrange(mm, start, end - 1);
+		ret = add_vrange(&mm->vroot, start, end - 1);
 	else if (mode == VRANGE_NOVOLATILE)
-		ret = remove_vrange(mm, start, end - 1);
+		ret = remove_vrange(&mm->vroot, start, end - 1);
 out:
 	return ret;
 }
 
+
 static bool __vrange_address(struct mm_struct *mm,
 			unsigned long start, unsigned long end)
 {
-	struct rb_root *root = &mm->v_rb;
+	struct rb_root *root = &mm->vroot.v_rb;
 	struct interval_tree_node *node;
 
 	node = interval_tree_iter_first(root, start, end);
@@ -306,10 +305,11 @@ bool vrange_address(struct mm_struct *mm,
 			unsigned long start, unsigned long end)
 {
 	bool ret;
+	struct vrange_root *vroot = &mm->vroot;
 
-	vrange_lock(mm);
+	vrange_lock(vroot);
 	ret = __vrange_address(mm, start, end);
-	vrange_unlock(mm);
+	vrange_unlock(vroot);
 	return ret;
 }
 
@@ -372,14 +372,13 @@ static inline pte_t *vpage_check_address(struct page *page,
 	return ptep;
 }
 
-static void __vrange_purge(struct mm_struct *mm,
+static void __vrange_purge(struct vrange_root *vroot,
 		unsigned long start, unsigned long end)
 {
-	struct rb_root *root = &mm->v_rb;
-	struct vrange *range;
 	struct interval_tree_node *node;
+	struct vrange *range;
 
-	node = interval_tree_iter_first(root, start, end);
+	node = interval_tree_iter_first(&vroot->v_rb, start, end);
 	while (node) {
 		range = container_of(node, struct vrange, node);
 		range->purged = true;
@@ -396,20 +395,19 @@ static int try_to_discard_one(struct page *page, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int ret = 0;
 	bool present;
+	struct vrange_root *vroot = &mm->vroot;
 
 	VM_BUG_ON(!PageLocked(page));
 
-	vrange_lock(mm);
+	vrange_lock(vroot);
 	pte = vpage_check_address(page, mm, address, &ptl);
 	if (!pte) {
-		vrange_unlock(mm);
 		goto out;
 	}
 
 	if (vma->vm_flags & VM_LOCKED) {
 		pte_unmap_unlock(pte, ptl);
-		vrange_unlock(mm);
-		return 0;
+		goto out;
 	}
 
 	present = pte_present(*pte);
@@ -431,12 +429,13 @@ static int try_to_discard_one(struct page *page, struct vm_area_struct *vma,
 	}
 
 	set_pte_at(mm, address, pte, pteval);
-	__vrange_purge(mm, address, address + PAGE_SIZE -1);
+	__vrange_purge(&mm->vroot, address, address + PAGE_SIZE - 1);
 	pte_unmap_unlock(pte, ptl);
 	mmu_notifier_invalidate_page(mm, address);
-	vrange_unlock(mm);
 	ret = 1;
+
 out:
+	vrange_unlock(vroot);
 	return ret;
 }
 
@@ -458,12 +457,14 @@ static int try_to_discard_vpage(struct page *page)
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		pte_t *pte;
 		spinlock_t *ptl;
+		struct vrange_root *vroot;
 
 		vma = avc->vma;
 		mm = vma->vm_mm;
+		vroot = &mm->vroot;
 		address = vma_address(page, vma);
 
-		vrange_lock(mm);
+		vrange_lock(vroot);
 		/*
 		 * We can't use page_check_address because it doesn't check
 		 * swap entry of the page table. We need the check because
@@ -473,24 +474,24 @@ static int try_to_discard_vpage(struct page *page)
 		 */
 		pte = vpage_check_address(page, mm, address, &ptl);
 		if (!pte) {
-			vrange_unlock(mm);
+			vrange_unlock(vroot);
 			continue;
 		}
 
 		if (vma->vm_flags & VM_LOCKED) {
 			pte_unmap_unlock(pte, ptl);
-			vrange_unlock(mm);
+			vrange_unlock(vroot);
 			goto out;
 		}
 
 		pte_unmap_unlock(pte, ptl);
 		if (!__vrange_address(mm, address,
 					address + PAGE_SIZE - 1)) {
-			vrange_unlock(mm);
+			vrange_unlock(vroot);
 			goto out;
 		}
 
-		vrange_unlock(mm);
+		vrange_unlock(vroot);
 	}
 
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
@@ -531,19 +532,20 @@ int discard_vpage(struct page *page)
 
 bool is_purged_vrange(struct mm_struct *mm, unsigned long address)
 {
-	struct rb_root *root = &mm->v_rb;
+	struct vrange_root *vroot = &mm->vroot;
 	struct interval_tree_node *node;
 	struct vrange *range;
 	bool ret = false;
 
-	vrange_lock(mm);
-	node = interval_tree_iter_first(root, address, address + PAGE_SIZE - 1);
+	vrange_lock(vroot);
+	node = interval_tree_iter_first(&vroot->v_rb, address,
+						address + PAGE_SIZE - 1);
 	if (node) {
 		range = container_of(node, struct vrange, node);
 		if (range->purged)
 			ret = true;
 	}
-	vrange_unlock(mm);
+	vrange_unlock(vroot);
 	return ret;
 }
 
@@ -631,12 +633,14 @@ static unsigned int discard_vma_pages(struct zone *zone, struct mm_struct *mm,
 unsigned int discard_vrange(struct zone *zone, struct vrange *vrange,
 				int nr_to_discard)
 {
-	struct mm_struct *mm = vrange->mm;
+	struct mm_struct *mm;
 	unsigned long start = vrange->node.start;
 	unsigned long end = vrange->node.last;
 	struct vm_area_struct *vma;
 	unsigned int nr_discarded = 0;
 
+	mm = vrange_get_owner_mm(vrange);
+
 	if (!down_read_trylock(&mm->mmap_sem))
 		goto out;
 
@@ -678,7 +682,7 @@ static struct vrange *get_victim_vrange(void)
 	spin_lock(&lru_lock);
 	list_for_each_prev_safe(cur, tmp, &lru_vrange) {
 		vrange = list_entry(cur, struct vrange, lru);
-		mm = vrange->mm;
+		mm = vrange_get_owner_mm(vrange);
 		/* the process is exiting so pass it */
 		if (atomic_read(&mm->mm_users) == 0) {
 			list_del_init(&vrange->lru);
@@ -698,7 +702,7 @@ static struct vrange *get_victim_vrange(void)
 		 * need to get a refcount of mm.
 		 * NOTE: We guarantee mm_count isn't zero in here because
 		 * if we found vrange from LRU list, it means we are
-		 * before exit_vrange or remove_vrange.
+		 * before mm_exit_vrange or remove_vrange.
 		 */
 		atomic_inc(&mm->mm_count);
 
@@ -713,8 +717,10 @@ static struct vrange *get_victim_vrange(void)
 
 static void put_victim_range(struct vrange *vrange)
 {
+	struct mm_struct *mm = vrange_get_owner_mm(vrange);
+
 	put_vrange(vrange);
-	mmdrop(vrange->mm);
+	mmdrop(mm);
 }
 
 unsigned int discard_vrange_pages(struct zone *zone, int nr_to_discard)
@@ -724,7 +730,7 @@ unsigned int discard_vrange_pages(struct zone *zone, int nr_to_discard)
 
 	start_vrange = vrange = get_victim_vrange();
 	if (start_vrange) {
-		struct mm_struct *mm = start_vrange->mm;
+		struct mm_struct *mm = vrange_get_owner_mm(vrange);
 		atomic_inc(&start_vrange->refcount);
 		atomic_inc(&mm->mm_count);
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
