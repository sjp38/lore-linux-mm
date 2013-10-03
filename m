Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADD76B0038
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:03 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so1672198pde.37
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:03 -0700 (PDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so1657355pbb.38
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:00 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 01/14] vrange: Add basic data structure and functions
Date: Wed,  2 Oct 2013 17:51:30 -0700
Message-Id: <1380761503-14509-2-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

This patch adds vrange data structure and core management
functions.

The vrange uses the generic interval tree as main data
structure because it handles address range, which fits well
for this purpose.

The vrange_add/vrange_remove are core functions for the vrange()
system call that will be introduced in a following patch.

The vrange_add inserts new address range into interval tree.
If new address range crosses over existing volatile range,
existing volatile range will be expanded to cover new range.

Thus, if existing volatile range has purged state, new extended
range will inherit that purged state. If new address range is
inside existing range, we ignore it.

vrange_remove removes the address range, returning the purged
state of the address ranges.

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
[jstultz: Heavy rework and cleanups to make this infrastructure more
easily reused for both file and anonymous pages]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/vrange.h       |  48 ++++++++++++
 include/linux/vrange_types.h |  25 ++++++
 lib/Makefile                 |   2 +-
 mm/Makefile                  |   2 +-
 mm/vrange.c                  | 183 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 258 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/vrange.h
 create mode 100644 include/linux/vrange_types.h
 create mode 100644 mm/vrange.c

diff --git a/include/linux/vrange.h b/include/linux/vrange.h
new file mode 100644
index 0000000..0d378a5
--- /dev/null
+++ b/include/linux/vrange.h
@@ -0,0 +1,48 @@
+#ifndef _LINUX_VRANGE_H
+#define _LINUX_VRANGE_H
+
+#include <linux/vrange_types.h>
+#include <linux/mm.h>
+
+#define vrange_from_node(node_ptr) \
+	container_of(node_ptr, struct vrange, node)
+
+#define vrange_entry(ptr) \
+	container_of(ptr, struct vrange, node.rb)
+
+#ifdef CONFIG_MMU
+
+static inline void vrange_root_init(struct vrange_root *vroot, int type,
+								void *object)
+{
+	vroot->type = type;
+	vroot->v_rb = RB_ROOT;
+	mutex_init(&vroot->v_lock);
+	vroot->object = object;
+}
+
+static inline void vrange_lock(struct vrange_root *vroot)
+{
+	mutex_lock(&vroot->v_lock);
+}
+
+static inline void vrange_unlock(struct vrange_root *vroot)
+{
+	mutex_unlock(&vroot->v_lock);
+}
+
+static inline int vrange_type(struct vrange *vrange)
+{
+	return vrange->owner->type;
+}
+
+extern void vrange_root_cleanup(struct vrange_root *vroot);
+
+#else
+
+static inline void vrange_root_init(struct vrange_root *vroot,
+					int type, void *object) {};
+static inline void vrange_root_cleanup(struct vrange_root *vroot) {};
+
+#endif
+#endif /* _LINIUX_VRANGE_H */
diff --git a/include/linux/vrange_types.h b/include/linux/vrange_types.h
new file mode 100644
index 0000000..0d48b42
--- /dev/null
+++ b/include/linux/vrange_types.h
@@ -0,0 +1,25 @@
+#ifndef _LINUX_VRANGE_TYPES_H
+#define _LINUX_VRANGE_TYPES_H
+
+#include <linux/mutex.h>
+#include <linux/interval_tree.h>
+
+enum vrange_type {
+	VRANGE_MM,
+	VRANGE_FILE,
+};
+
+struct vrange_root {
+	struct rb_root v_rb;		/* vrange rb tree */
+	struct mutex v_lock;		/* Protect v_rb */
+	enum vrange_type type;		/* range root type */
+	void *object;			/* pointer to mm_struct or mapping */
+};
+
+struct vrange {
+	struct interval_tree_node node;
+	struct vrange_root *owner;
+	int purged;
+};
+#endif
+
diff --git a/lib/Makefile b/lib/Makefile
index 7baccfd..c8739ee 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -13,7 +13,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
 	 proportions.o flex_proportions.o prio_heap.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
-	 earlycpio.o percpu-refcount.o
+	 earlycpio.o percpu-refcount.o interval_tree.o
 
 obj-$(CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS) += usercopy.o
 lib-$(CONFIG_MMU) += ioremap.o
diff --git a/mm/Makefile b/mm/Makefile
index f008033..54928af 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -5,7 +5,7 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o pagewalk.o pgtable-generic.o
+			   vmalloc.o pagewalk.o pgtable-generic.o vrange.o
 
 ifdef CONFIG_CROSS_MEMORY_ATTACH
 mmu-$(CONFIG_MMU)	+= process_vm_access.o
diff --git a/mm/vrange.c b/mm/vrange.c
new file mode 100644
index 0000000..866566c
--- /dev/null
+++ b/mm/vrange.c
@@ -0,0 +1,183 @@
+/*
+ * mm/vrange.c
+ */
+
+#include <linux/vrange.h>
+#include <linux/slab.h>
+
+static struct kmem_cache *vrange_cachep;
+
+static int __init vrange_init(void)
+{
+	vrange_cachep = KMEM_CACHE(vrange, SLAB_PANIC);
+	return 0;
+}
+module_init(vrange_init);
+
+static struct vrange *__vrange_alloc(gfp_t flags)
+{
+	struct vrange *vrange = kmem_cache_alloc(vrange_cachep, flags);
+	if (!vrange)
+		return vrange;
+	vrange->owner = NULL;
+	return vrange;
+}
+
+static void __vrange_free(struct vrange *range)
+{
+	WARN_ON(range->owner);
+	kmem_cache_free(vrange_cachep, range);
+}
+
+static void __vrange_add(struct vrange *range, struct vrange_root *vroot)
+{
+	range->owner = vroot;
+	interval_tree_insert(&range->node, &vroot->v_rb);
+}
+
+static void __vrange_remove(struct vrange *range)
+{
+	interval_tree_remove(&range->node, &range->owner->v_rb);
+	range->owner = NULL;
+}
+
+static inline void __vrange_set(struct vrange *range,
+		unsigned long start_idx, unsigned long end_idx,
+		bool purged)
+{
+	range->node.start = start_idx;
+	range->node.last = end_idx;
+	range->purged = purged;
+}
+
+static inline void __vrange_resize(struct vrange *range,
+		unsigned long start_idx, unsigned long end_idx)
+{
+	struct vrange_root *vroot = range->owner;
+	bool purged = range->purged;
+
+	__vrange_remove(range);
+	__vrange_set(range, start_idx, end_idx, purged);
+	__vrange_add(range, vroot);
+}
+
+static int vrange_add(struct vrange_root *vroot,
+			unsigned long start_idx, unsigned long end_idx)
+{
+	struct vrange *new_range, *range;
+	struct interval_tree_node *node, *next;
+	int purged = 0;
+
+	new_range = __vrange_alloc(GFP_KERNEL);
+	if (!new_range)
+		return -ENOMEM;
+
+	vrange_lock(vroot);
+
+	node = interval_tree_iter_first(&vroot->v_rb, start_idx, end_idx);
+	while (node) {
+		next = interval_tree_iter_next(node, start_idx, end_idx);
+		range = vrange_from_node(node);
+		/* old range covers new range fully */
+		if (node->start <= start_idx && node->last >= end_idx) {
+			__vrange_free(new_range);
+			goto out;
+		}
+
+		start_idx = min_t(unsigned long, start_idx, node->start);
+		end_idx = max_t(unsigned long, end_idx, node->last);
+		purged |= range->purged;
+
+		__vrange_remove(range);
+		__vrange_free(range);
+
+		node = next;
+	}
+
+	__vrange_set(new_range, start_idx, end_idx, purged);
+	__vrange_add(new_range, vroot);
+out:
+	vrange_unlock(vroot);
+	return 0;
+}
+
+static int vrange_remove(struct vrange_root *vroot,
+				unsigned long start_idx, unsigned long end_idx,
+				int *purged)
+{
+	struct vrange *new_range, *range;
+	struct interval_tree_node *node, *next;
+	bool used_new = false;
+
+	if (!purged)
+		return -EINVAL;
+
+	*purged = 0;
+
+	new_range = __vrange_alloc(GFP_KERNEL);
+	if (!new_range)
+		return -ENOMEM;
+
+	vrange_lock(vroot);
+
+	node = interval_tree_iter_first(&vroot->v_rb, start_idx, end_idx);
+	while (node) {
+		next = interval_tree_iter_next(node, start_idx, end_idx);
+		range = vrange_from_node(node);
+
+		*purged |= range->purged;
+
+		if (start_idx <= node->start && end_idx >= node->last) {
+			/* argumented range covers the range fully */
+			__vrange_remove(range);
+			__vrange_free(range);
+		} else if (node->start >= start_idx) {
+			/*
+			 * Argumented range covers over the left of the
+			 * range
+			 */
+			__vrange_resize(range, end_idx + 1, node->last);
+		} else if (node->last <= end_idx) {
+			/*
+			 * Argumented range covers over the right of the
+			 * range
+			 */
+			__vrange_resize(range, node->start, start_idx - 1);
+		} else {
+			/*
+			 * Argumented range is middle of the range
+			 */
+			unsigned long last = node->last;
+			used_new = true;
+			__vrange_resize(range, node->start, start_idx - 1);
+			__vrange_set(new_range, end_idx + 1, last,
+					range->purged);
+			__vrange_add(new_range, vroot);
+			break;
+		}
+
+		node = next;
+	}
+	vrange_unlock(vroot);
+
+	if (!used_new)
+		__vrange_free(new_range);
+
+	return 0;
+}
+
+void vrange_root_cleanup(struct vrange_root *vroot)
+{
+	struct vrange *range;
+	struct rb_node *node;
+
+	vrange_lock(vroot);
+	/* We should remove node by post-order traversal */
+	while ((node = rb_first(&vroot->v_rb))) {
+		range = vrange_entry(node);
+		__vrange_remove(range);
+		__vrange_free(range);
+	}
+	vrange_unlock(vroot);
+}
+
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
