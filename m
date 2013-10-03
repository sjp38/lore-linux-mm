Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2486B006C
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:32 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so1666857pbc.32
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:32 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1814602pad.28
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:29 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 13/14] vrange: Allocate vroot dynamically
Date: Wed,  2 Oct 2013 17:51:42 -0700
Message-Id: <1380761503-14509-14-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

This patch allocates vroot dynamically when vrange syscall is called
so if anybody doesn't call vrange syscall, we don't waste memory space
occupied by vroot.

The vroot is allocated by SLAB_DESTROY_BY_RCU, thus because we can't
guarantee vroot's validity when we are about to access vroot of
a different process, the rules are as follows:

1. rcu_read_lock
2. checkt vroot == NULL
3. increment vroot's refcount
4. rcu_read_unlock
5. vrange_lock(vroot)
6. get vrange from tree
7. vrange->owenr == vroot check again because vroot can be allocated
   for another one in same RCU period.

If we're accessing the vroot from our own context, we can skip
the rcu & extra checking, since we know the vroot won't disappear
from under us while we're running.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dhaval.giani@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rob Clark <robdclark@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
[jstultz: Commit rewording, renamed functions, added helper functions]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 fs/inode.c                   |   4 +-
 include/linux/fs.h           |   2 +-
 include/linux/mm_types.h     |   2 +-
 include/linux/vrange_types.h |   1 +
 kernel/fork.c                |   5 +-
 mm/mmap.c                    |   2 +-
 mm/vrange.c                  | 257 +++++++++++++++++++++++++++++++++++++++++--
 7 files changed, 255 insertions(+), 18 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 5364f91..f5b8990 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -353,7 +353,6 @@ void address_space_init_once(struct address_space *mapping)
 	spin_lock_init(&mapping->private_lock);
 	mapping->i_mmap = RB_ROOT;
 	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
-	vrange_root_init(&mapping->vroot, VRANGE_FILE, mapping);
 }
 EXPORT_SYMBOL(address_space_init_once);
 
@@ -1421,7 +1420,8 @@ static void iput_final(struct inode *inode)
 		inode_lru_list_del(inode);
 	spin_unlock(&inode->i_lock);
 
-	vrange_root_cleanup(&inode->i_mapping->vroot);
+	vrange_root_cleanup(inode->i_mapping->vroot);
+	inode->i_mapping->vroot = NULL;
 
 	evict(inode);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6ec2953..32ef488 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -415,7 +415,7 @@ struct address_space {
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
 #ifdef CONFIG_MMU
-	struct vrange_root	vroot;
+	struct vrange_root	*vroot;
 #endif
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5d8cdc3..ad7e2fc 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -351,7 +351,7 @@ struct mm_struct {
 
 
 #ifdef CONFIG_MMU
-	struct vrange_root vroot;
+	struct vrange_root *vroot;
 #endif
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
diff --git a/include/linux/vrange_types.h b/include/linux/vrange_types.h
index d7d451c..c4ef8b6 100644
--- a/include/linux/vrange_types.h
+++ b/include/linux/vrange_types.h
@@ -14,6 +14,7 @@ struct vrange_root {
 	struct mutex v_lock;		/* Protect v_rb */
 	enum vrange_type type;		/* range root type */
 	void *object;			/* pointer to mm_struct or mapping */
+	atomic_t refcount;
 };
 
 struct vrange {
diff --git a/kernel/fork.c b/kernel/fork.c
index ceb38bf..16d58ca 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -545,9 +545,9 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
 	mm->core_state = NULL;
 	mm->nr_ptes = 0;
+	mm->vroot = NULL;
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
-	vrange_root_init(&mm->vroot, VRANGE_MM, mm);
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 
@@ -619,7 +619,8 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		uprobe_clear_state(mm);
-		vrange_root_cleanup(&mm->vroot);
+		vrange_root_cleanup(mm->vroot);
+		mm->vroot = NULL;
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
diff --git a/mm/mmap.c b/mm/mmap.c
index ed7056f..cb2f9e0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1505,7 +1505,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 munmap_back:
 
 	/* zap any volatile ranges */
-	vrange_clear(&mm->vroot, addr, addr + len);
+	vrange_clear(mm->vroot, addr, addr + len);
 
 	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
 		if (do_munmap(mm, addr, len))
diff --git a/mm/vrange.c b/mm/vrange.c
index 3f21dc9..c30e3dd 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -16,6 +16,7 @@
 #include <linux/pagevec.h>
 
 static struct kmem_cache *vrange_cachep;
+static struct kmem_cache *vroot_cachep;
 
 static struct vrange_list {
 	struct list_head list;
@@ -44,12 +45,169 @@ static int __init vrange_init(void)
 {
 	INIT_LIST_HEAD(&vrange_list.list);
 	mutex_init(&vrange_list.lock);
+	vroot_cachep = kmem_cache_create("vrange_root",
+				sizeof(struct vrange_root), 0,
+				SLAB_DESTROY_BY_RCU|SLAB_PANIC, NULL);
 	vrange_cachep = KMEM_CACHE(vrange, SLAB_PANIC);
 	register_shrinker(&vrange_shrinker);
 	return 0;
 }
 module_init(vrange_init);
 
+static struct vrange_root *__vroot_alloc(gfp_t flags)
+{
+	struct vrange_root *vroot = kmem_cache_alloc(vroot_cachep, flags);
+	if (!vroot)
+		return vroot;
+
+	atomic_set(&vroot->refcount, 1);
+	return vroot;
+}
+
+static inline int __vroot_get(struct vrange_root *vroot)
+{
+	if (!atomic_inc_not_zero(&vroot->refcount))
+		return 0;
+
+	return 1;
+}
+
+static inline void __vroot_put(struct vrange_root *vroot)
+{
+	if (atomic_dec_and_test(&vroot->refcount)) {
+		enum {VRANGE_MM, VRANGE_FILE} type = vroot->type;
+		if (type == VRANGE_MM) {
+			struct mm_struct *mm = vroot->object;
+			mmdrop(mm);
+		} else if (type == VRANGE_FILE) {
+			/* TODO : */
+		} else
+			BUG();
+
+		WARN_ON(!RB_EMPTY_ROOT(&vroot->v_rb));
+		kmem_cache_free(vroot_cachep, vroot);
+	}
+}
+
+static bool __vroot_init_mm(struct vrange_root *vroot, struct mm_struct *mm)
+{
+	bool ret = false;
+
+	spin_lock(&mm->page_table_lock);
+	if (!mm->vroot) {
+		mm->vroot = vroot;
+		vrange_root_init(mm->vroot, VRANGE_MM, mm);
+		atomic_inc(&mm->mm_count);
+		ret = true;
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	return ret;
+}
+
+static bool __vroot_init_mapping(struct vrange_root *vroot,
+						struct address_space *mapping)
+{
+	bool ret = false;
+
+	mutex_lock(&mapping->i_mmap_mutex);
+	if (!mapping->vroot) {
+		mapping->vroot = vroot;
+		vrange_root_init(mapping->vroot, VRANGE_FILE, mapping);
+		/* XXX - inc ref count on mapping? */
+		ret = true;
+	}
+	mutex_unlock(&mapping->i_mmap_mutex);
+
+	return ret;
+}
+
+static struct vrange_root *vroot_alloc_mm(struct mm_struct *mm)
+{
+	struct vrange_root *ret, *allocated;
+
+	ret = NULL;
+	allocated = __vroot_alloc(GFP_NOFS);
+	if (!allocated)
+		return NULL;
+
+	if (__vroot_init_mm(allocated, mm)) {
+		ret = allocated;
+		allocated = NULL;
+	}
+
+	if (allocated)
+		__vroot_put(allocated);
+
+	return ret;
+}
+
+static struct vrange_root *vroot_alloc_vma(struct vm_area_struct *vma)
+{
+	struct vrange_root *ret, *allocated;
+	bool val;
+
+	ret = NULL;
+	allocated = __vroot_alloc(GFP_NOFS);
+	if (!allocated)
+		return NULL;
+
+	if (vma->vm_file && (vma->vm_flags & VM_SHARED))
+		val = __vroot_init_mapping(allocated, vma->vm_file->f_mapping);
+	else
+		val = __vroot_init_mm(allocated, vma->vm_mm);
+
+	if (val) {
+		ret = allocated;
+		allocated = NULL;
+	}
+
+	if (allocated)
+		__vroot_put(allocated);
+
+	return ret;
+}
+
+static struct vrange_root *vrange_get_vroot(struct vrange *vrange)
+{
+	struct vrange_root *vroot;
+	struct vrange_root *ret = NULL;
+
+	rcu_read_lock();
+	/*
+	 * Prevent compiler from re-fetching vrange->owner while others
+	 * clears vrange->owner.
+	 */
+	vroot = ACCESS_ONCE(vrange->owner);
+	if (!vroot)
+		goto out;
+
+	/*
+	 * vroot couldn't be destroyed while we're holding rcu_read_lock
+	 * so it's okay to access vroot
+	 */
+	if (!__vroot_get(vroot))
+		goto out;
+
+
+	/* If we reach here, vroot is either ours or others because
+	 * vroot could be allocated for othres in same RCU period
+	 * so we should check it carefully. For free/reallocating
+	 * for others, all vranges from vroot->tree should be detached
+	 * firstly right before vroot freeing so if we check vrange->owner
+	 * isn't NULL, it means vroot is ours.
+	 */
+	smp_rmb();
+	if (!vrange->owner) {
+		__vroot_put(vroot);
+		goto out;
+	}
+	ret = vroot;
+out:
+	rcu_read_unlock();
+	return ret;
+}
+
 static struct vrange *__vrange_alloc(gfp_t flags)
 {
 	struct vrange *vrange = kmem_cache_alloc(vrange_cachep, flags);
@@ -209,6 +367,9 @@ static int vrange_remove(struct vrange_root *vroot,
 	struct interval_tree_node *node, *next;
 	bool used_new = false;
 
+	if (!vroot)
+		return 0;
+
 	if (!purged)
 		return -EINVAL;
 
@@ -279,6 +440,9 @@ void vrange_root_cleanup(struct vrange_root *vroot)
 	struct vrange *range;
 	struct rb_node *node;
 
+	if (vroot == NULL)
+		return;
+
 	vrange_lock(vroot);
 	/* We should remove node by post-order traversal */
 	while ((node = rb_first(&vroot->v_rb))) {
@@ -287,6 +451,12 @@ void vrange_root_cleanup(struct vrange_root *vroot)
 		__vrange_put(range);
 	}
 	vrange_unlock(vroot);
+	/*
+	 * Before removing vroot, we should make sure range-owner
+	 * should be NULL. See the smp_rmb of vrange_get_vroot.
+	 */
+	smp_wmb();
+	__vroot_put(vroot);
 }
 
 /*
@@ -294,6 +464,7 @@ void vrange_root_cleanup(struct vrange_root *vroot)
  * can't have copied own vrange data structure so that pages in the
  * vrange couldn't be purged. It would be better rather than failing
  * fork.
+ * The down_write of both mm->mmap_sem protects mm->vroot race.
  */
 int vrange_fork(struct mm_struct *new_mm, struct mm_struct *old_mm)
 {
@@ -301,8 +472,14 @@ int vrange_fork(struct mm_struct *new_mm, struct mm_struct *old_mm)
 	struct vrange *range, *new_range;
 	struct rb_node *next;
 
-	new = &new_mm->vroot;
-	old = &old_mm->vroot;
+	if (!old_mm->vroot)
+		return 0;
+
+	new = vroot_alloc_mm(new_mm);
+	if (!new)
+		return -ENOMEM;
+
+	old = old_mm->vroot;
 
 	vrange_lock(old);
 	next = rb_first(&old->v_rb);
@@ -323,6 +500,7 @@ int vrange_fork(struct mm_struct *new_mm, struct mm_struct *old_mm)
 
 	}
 	vrange_unlock(old);
+
 	return 0;
 fail:
 	vrange_unlock(old);
@@ -335,9 +513,27 @@ static inline struct vrange_root *__vma_to_vroot(struct vm_area_struct *vma)
 	struct vrange_root *vroot = NULL;
 
 	if (vma->vm_file && (vma->vm_flags & VM_SHARED))
-		vroot = &vma->vm_file->f_mapping->vroot;
+		vroot = vma->vm_file->f_mapping->vroot;
 	else
-		vroot = &vma->vm_mm->vroot;
+		vroot = vma->vm_mm->vroot;
+
+	return vroot;
+}
+
+static inline struct vrange_root *__vma_to_vroot_get(struct vm_area_struct *vma)
+{
+	struct vrange_root *vroot = NULL;
+
+	rcu_read_lock();
+	vroot = __vma_to_vroot(vma);
+
+	if (!vroot)
+		goto out;
+
+	if (!__vroot_get(vroot))
+		vroot = NULL;
+out:
+	rcu_read_unlock();
 	return vroot;
 }
 
@@ -383,6 +579,11 @@ static ssize_t do_vrange(struct mm_struct *mm, unsigned long start_idx,
 			tmp = end_idx;
 
 		vroot = __vma_to_vroot(vma);
+		if (!vroot)
+			vroot = vroot_alloc_vma(vma);
+		if (!vroot)
+			goto out;
+
 		vstart_idx = __vma_addr_to_index(vma, start_idx);
 		vend_idx = __vma_addr_to_index(vma, tmp);
 
@@ -495,17 +696,31 @@ out:
 bool vrange_addr_volatile(struct vm_area_struct *vma, unsigned long addr)
 {
 	struct vrange_root *vroot;
+	struct vrange *vrange;
 	unsigned long vstart_idx, vend_idx;
 	bool ret = false;
 
-	vroot = __vma_to_vroot(vma);
+	vroot = __vma_to_vroot_get(vma);
+
+	if (!vroot)
+		return ret;
+
 	vstart_idx = __vma_addr_to_index(vma, addr);
 	vend_idx = vstart_idx + PAGE_SIZE - 1;
 
 	vrange_lock(vroot);
-	if (__vrange_find(vroot, vstart_idx, vend_idx))
-		ret = true;
+	vrange = __vrange_find(vroot, vstart_idx, vend_idx);
+	if (vrange) {
+		/*
+		 * vroot can be allocated for another process in
+		 * same period so let's check vroot's stability
+		 */
+		if (likely(vroot == vrange->owner))
+			ret = true;
+	}
 	vrange_unlock(vroot);
+	__vroot_put(vroot);
+
 	return ret;
 }
 
@@ -517,6 +732,8 @@ bool vrange_addr_purged(struct vm_area_struct *vma, unsigned long addr)
 	bool ret = false;
 
 	vroot = __vma_to_vroot(vma);
+	if (!vroot)
+		return false;
 	vstart_idx = __vma_addr_to_index(vma, addr);
 
 	vrange_lock(vroot);
@@ -550,6 +767,7 @@ static void try_to_discard_one(struct vrange_root *vroot, struct page *page,
 	pte_t pteval;
 	spinlock_t *ptl;
 
+	VM_BUG_ON(!vroot);
 	VM_BUG_ON(!PageLocked(page));
 
 	pte = page_check_address(page, mm, addr, &ptl, 0);
@@ -608,9 +826,11 @@ static int try_to_discard_anon_vpage(struct page *page)
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		vma = avc->vma;
 		mm = vma->vm_mm;
-		vroot = &mm->vroot;
-		address = vma_address(page, vma);
+		vroot = __vma_to_vroot(vma);
+		if (!vroot)
+			continue;
 
+		address = vma_address(page, vma);
 		vrange_lock(vroot);
 		if (!__vrange_find(vroot, address, address + PAGE_SIZE - 1)) {
 			vrange_unlock(vroot);
@@ -634,10 +854,14 @@ static int try_to_discard_file_vpage(struct page *page)
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
-		struct vrange_root *vroot = &mapping->vroot;
+		struct vrange_root *vroot;
 		long vstart_idx;
 
+		vroot = __vma_to_vroot(vma);
+		if (!vroot)
+			continue;
 		vstart_idx = __vma_addr_to_index(vma, address);
+
 		vrange_lock(vroot);
 		if (!__vrange_find(vroot, vstart_idx,
 					vstart_idx + PAGE_SIZE - 1)) {
@@ -901,7 +1125,16 @@ static int discard_vrange(struct vrange *vrange)
 	int ret = 0;
 	struct vrange_root *vroot;
 	unsigned int nr_discard = 0;
-	vroot = vrange->owner;
+	vroot = vrange_get_vroot(vrange);
+	if (!vroot)
+		return 0;
+
+	/*
+	 * Race of vrange->owner could happens with __vrange_remove
+	 * but it's okay because subfunctions will check it again
+	 */
+	if (vrange->owner == NULL)
+		goto out;
 
 	if (vroot->type == VRANGE_MM) {
 		struct mm_struct *mm = vroot->object;
@@ -911,6 +1144,8 @@ static int discard_vrange(struct vrange *vrange)
 		ret = __discard_vrange_file(mapping, vrange, &nr_discard);
 	}
 
+out:
+	__vroot_put(vroot);
 	return nr_discard;
 }
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
