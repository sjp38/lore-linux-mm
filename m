Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E12166B0055
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:21 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so13834409pdj.30
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:21 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id yl2si2381029pab.240.2014.01.01.23.13.18
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:20 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 13/16] vrange: Allocate vroot dynamically
Date: Thu,  2 Jan 2014 16:12:21 +0900
Message-Id: <1388646744-15608-14-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

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

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
[jstultz: Commit rewording, renamed functions, added helper functions]
Signed-off-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/inode.c                   |    4 +-
 include/linux/fs.h           |    2 +-
 include/linux/mm_types.h     |    2 +-
 include/linux/vrange.h       |    2 -
 include/linux/vrange_types.h |    1 +
 kernel/fork.c                |    5 +-
 mm/mmap.c                    |    2 +-
 mm/vrange.c                  |  267 ++++++++++++++++++++++++++++++++++++++++--
 8 files changed, 266 insertions(+), 19 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index b029472134ea..2f0f878be213 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -354,7 +354,6 @@ void address_space_init_once(struct address_space *mapping)
 	spin_lock_init(&mapping->private_lock);
 	mapping->i_mmap = RB_ROOT;
 	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
-	vrange_root_init(&mapping->vroot, VRANGE_FILE, mapping);
 }
 EXPORT_SYMBOL(address_space_init_once);
 
@@ -1390,7 +1389,8 @@ static void iput_final(struct inode *inode)
 		inode_lru_list_del(inode);
 	spin_unlock(&inode->i_lock);
 
-	vrange_root_cleanup(&inode->i_mapping->vroot);
+	vrange_root_cleanup(inode->i_mapping->vroot);
+	inode->i_mapping->vroot = NULL;
 
 	evict(inode);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 19b70288e219..a01fb319499b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -416,7 +416,7 @@ struct address_space {
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
 #ifdef CONFIG_MMU
-	struct vrange_root	vroot;
+	struct vrange_root	*vroot;
 #endif
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index a4de9cfa8ff1..a46f565341a1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -352,7 +352,7 @@ struct mm_struct {
 
 
 #ifdef CONFIG_MMU
-	struct vrange_root vroot;
+	struct vrange_root *vroot;
 #endif
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index eba155a0263c..d69262edf986 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -30,8 +30,6 @@ static inline void vrange_root_init(struct vrange_root *vroot, int type,
 								void *object)
 {
 	vroot->type = type;
-	vroot->v_rb = RB_ROOT;
-	mutex_init(&vroot->v_lock);
 	vroot->object = object;
 }
 
diff --git a/include/linux/vrange_types.h b/include/linux/vrange_types.h
index d7d451cd50b6..c4ef8b69a0a1 100644
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
index 36d3c4bb4c4d..81960d6b01b3 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -542,9 +542,9 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
 	mm->core_state = NULL;
 	mm->nr_ptes = 0;
+	mm->vroot = NULL;
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
-	vrange_root_init(&mm->vroot, VRANGE_MM, mm);
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 
@@ -616,7 +616,8 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		uprobe_clear_state(mm);
-		vrange_root_cleanup(&mm->vroot);
+		vrange_root_cleanup(mm->vroot);
+		mm->vroot = NULL;
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
diff --git a/mm/mmap.c b/mm/mmap.c
index b8e2c1e57336..115698d53f7a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1506,7 +1506,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 munmap_back:
 
 	/* zap any volatile ranges */
-	vrange_clear(&mm->vroot, addr, addr + len);
+	vrange_clear(mm->vroot, addr, addr + len);
 
 	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
 		if (do_munmap(mm, addr, len))
diff --git a/mm/vrange.c b/mm/vrange.c
index 51875f256592..4e0775b722af 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -17,6 +17,7 @@
 #include <linux/shmem_fs.h>
 
 static struct kmem_cache *vrange_cachep;
+static struct kmem_cache *vroot_cachep;
 
 static struct vrange_list {
 	struct list_head list;
@@ -33,16 +34,182 @@ static inline unsigned long vrange_size(struct vrange *range)
 	return range->node.last + 1 - range->node.start;
 }
 
+static void vroot_ctor(void *data)
+{
+	struct vrange_root *vroot = data;
+
+	atomic_set(&vroot->refcount, 0);
+	mutex_init(&vroot->v_lock);
+	vroot->v_rb = RB_ROOT;
+}
+
 static int __init vrange_init(void)
 {
 	INIT_LIST_HEAD(&vrange_list.list);
 	spin_lock_init(&vrange_list.lock);
 
+	vroot_cachep = kmem_cache_create("vrange_root",
+				sizeof(struct vrange_root), 0,
+				SLAB_DESTROY_BY_RCU|SLAB_PANIC, vroot_ctor);
 	vrange_cachep = KMEM_CACHE(vrange, SLAB_PANIC);
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
+	allocated = __vroot_alloc(GFP_KERNEL);
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
+		kmem_cache_free(vroot_cachep, allocated);
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
@@ -197,6 +364,9 @@ static int vrange_remove(struct vrange_root *vroot,
 	struct interval_tree_node *node, *next;
 	bool used_new = false;
 
+	if (!vroot)
+		return 0;
+
 	if (!purged)
 		return -EINVAL;
 
@@ -267,6 +437,9 @@ void vrange_root_cleanup(struct vrange_root *vroot)
 	struct vrange *range;
 	struct rb_node *node;
 
+	if (vroot == NULL)
+		return;
+
 	vrange_lock(vroot);
 	/* We should remove node by post-order traversal */
 	while ((node = rb_first(&vroot->v_rb))) {
@@ -275,6 +448,12 @@ void vrange_root_cleanup(struct vrange_root *vroot)
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
@@ -282,6 +461,7 @@ void vrange_root_cleanup(struct vrange_root *vroot)
  * can't have copied own vrange data structure so that pages in the
  * vrange couldn't be purged. It would be better rather than failing
  * fork.
+ * The down_write of both mm->mmap_sem protects mm->vroot race.
  */
 int vrange_fork(struct mm_struct *new_mm, struct mm_struct *old_mm)
 {
@@ -289,8 +469,14 @@ int vrange_fork(struct mm_struct *new_mm, struct mm_struct *old_mm)
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
@@ -311,6 +497,7 @@ int vrange_fork(struct mm_struct *new_mm, struct mm_struct *old_mm)
 
 	}
 	vrange_unlock(old);
+
 	return 0;
 fail:
 	vrange_unlock(old);
@@ -323,9 +510,27 @@ static inline struct vrange_root *__vma_to_vroot(struct vm_area_struct *vma)
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
 
@@ -371,6 +576,11 @@ static ssize_t do_vrange(struct mm_struct *mm, unsigned long start_idx,
 			tmp = end_idx;
 
 		vroot = __vma_to_vroot(vma);
+		if (!vroot)
+			vroot = vroot_alloc_vma(vma);
+		if (!vroot)
+			goto out;
+
 		vstart_idx = __vma_addr_to_index(vma, start_idx);
 		vend_idx = __vma_addr_to_index(vma, tmp);
 
@@ -483,17 +693,31 @@ out:
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
 
@@ -505,12 +729,16 @@ bool vrange_addr_purged(struct vm_area_struct *vma, unsigned long addr)
 	bool ret = false;
 
 	vroot = __vma_to_vroot(vma);
+	if (!vroot)
+		return false;
+
 	vstart_idx = __vma_addr_to_index(vma, addr);
 
 	vrange_lock(vroot);
 	range = __vrange_find(vroot, vstart_idx, vstart_idx);
 	if (range && range->purged)
 		ret = true;
+
 	vrange_unlock(vroot);
 	return ret;
 }
@@ -538,6 +766,7 @@ static void try_to_discard_one(struct vrange_root *vroot, struct page *page,
 	pte_t pteval;
 	spinlock_t *ptl;
 
+	VM_BUG_ON(!vroot);
 	VM_BUG_ON(!PageLocked(page));
 
 	pte = page_check_address(page, mm, addr, &ptl, 0);
@@ -596,9 +825,11 @@ static int try_to_discard_anon_vpage(struct page *page)
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
@@ -625,7 +856,10 @@ static int try_to_discard_file_vpage(struct page *page)
 	if (!page->mapping)
 		return ret;
 
-	vroot = &mapping->vroot;
+	vroot = mapping->vroot;
+	if (!vroot)
+		return ret;
+
 	vstart_idx = page->index << PAGE_SHIFT;
 
 	mutex_lock(&mapping->i_mmap_mutex);
@@ -901,6 +1135,17 @@ static int discard_vrange(struct vrange *vrange, unsigned long *nr_discard)
 	struct vrange_root *vroot;
 	vroot = vrange->owner;
 
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
+
 	if (vroot->type == VRANGE_MM) {
 		struct mm_struct *mm = vroot->object;
 		ret = __discard_vrange_anon(mm, vrange, nr_discard);
@@ -909,6 +1154,8 @@ static int discard_vrange(struct vrange *vrange, unsigned long *nr_discard)
 		ret = __discard_vrange_file(mapping, vrange, nr_discard);
 	}
 
+out:
+	__vroot_put(vroot);
 	return ret;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
