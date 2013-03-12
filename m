Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 6F35C6B0038
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:38:54 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v7 02/11] add vrange basic data structure and functions
Date: Tue, 12 Mar 2013 16:38:26 +0900
Message-Id: <1363073915-25000-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1363073915-25000-1-git-send-email-minchan@kernel.org>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

This patch adds vrange data structure(interval tree) and
related functions.

The vrange uses generic interval tree as main data structure
because it handles address range so generic interval tree
fits well for the purpose.

The add_vrange/remove_vrange are core functions for system call
will be introdcued next patch.

1. add_vrange inserts new address range into interval tree.
   If new address range crosses over existing volatile range,
   existing volatile range will be expanded to cover new range.
   Then, if existing volatile range has purged state, new range
   will have a purged state.
   It's not good and we need more fine-grained purged state handling
   in a vrange(TODO)

   If new address range is inside existing range, we ignore it

2. remove_vrange removes address range
   Then, return a purged state of the address ranges.

This patch copied some part from John Stultz's work but different semantic.

Signed-off-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mm_types.h |   5 ++
 include/linux/vrange.h   |  45 ++++++++++++++
 init/main.c              |   2 +
 kernel/fork.c            |   3 +
 mm/Makefile              |   2 +-
 mm/vrange.c              | 157 +++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 213 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/vrange.h
 create mode 100644 mm/vrange.c

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ace9a5f..080bf74 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
+#include <linux/mutex.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -351,6 +352,10 @@ struct mm_struct {
 						 */
 
 
+#ifdef CONFIG_MMU
+	struct rb_root v_rb;		/* vrange rb tree */
+	struct mutex v_lock;		/* Protect v_rb */
+#endif
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
 
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
new file mode 100644
index 0000000..74b5e37
--- /dev/null
+++ b/include/linux/vrange.h
@@ -0,0 +1,45 @@
+#ifndef _LINUX_VRANGE_H
+#define _LINUX_VRANGE_H
+
+#include <linux/mutex.h>
+#include <linux/interval_tree.h>
+#include <linux/mm.h>
+
+struct vrange {
+	struct interval_tree_node node;
+	bool purged;
+};
+
+#define vrange_entry(ptr) \
+	container_of(ptr, struct vrange, node.rb)
+
+#ifdef CONFIG_MMU
+struct mm_struct;
+
+static inline void mm_init_vrange(struct mm_struct *mm)
+{
+	mm->v_rb = RB_ROOT;
+	mutex_init(&mm->v_lock);
+}
+
+static inline void vrange_lock(struct mm_struct *mm)
+{
+	mutex_lock(&mm->v_lock);
+}
+
+static inline void vrange_unlock(struct mm_struct *mm)
+{
+	mutex_unlock(&mm->v_lock);
+}
+
+extern void exit_vrange(struct mm_struct *mm);
+void vrange_init(void);
+
+#else
+
+static inline void vrange_init(void) {};
+static inline void mm_init_vrange(struct mm_struct *mm) {};
+static inline void exit_vrange(struct mm_struct *mm);
+
+#endif
+#endif /* _LINIUX_VRANGE_H */
diff --git a/init/main.c b/init/main.c
index 63534a1..0b9e0b5 100644
--- a/init/main.c
+++ b/init/main.c
@@ -72,6 +72,7 @@
 #include <linux/ptrace.h>
 #include <linux/blkdev.h>
 #include <linux/elevator.h>
+#include <linux/vrange.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -605,6 +606,7 @@ asmlinkage void __init start_kernel(void)
 	calibrate_delay();
 	pidmap_init();
 	anon_vma_init();
+	vrange_init();
 #ifdef CONFIG_X86
 	if (efi_enabled(EFI_RUNTIME_SERVICES))
 		efi_enter_virtual_mode();
diff --git a/kernel/fork.c b/kernel/fork.c
index 8d932b1..e3aa120 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -70,6 +70,7 @@
 #include <linux/khugepaged.h>
 #include <linux/signalfd.h>
 #include <linux/uprobes.h>
+#include <linux/vrange.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -541,6 +542,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	spin_lock_init(&mm->page_table_lock);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
+	mm_init_vrange(mm);
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 
@@ -612,6 +614,7 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		uprobe_clear_state(mm);
+		exit_vrange(mm);
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
diff --git a/mm/Makefile b/mm/Makefile
index 3a46287..a31235e 100644
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
index 0000000..e265c82
--- /dev/null
+++ b/mm/vrange.c
@@ -0,0 +1,157 @@
+/*
+ * mm/vrange.c
+ */
+
+#include <linux/vrange.h>
+#include <linux/slab.h>
+
+static struct kmem_cache *vrange_cachep;
+
+void __init vrange_init(void)
+{
+	vrange_cachep = KMEM_CACHE(vrange, SLAB_PANIC);
+}
+
+static inline void __set_vrange(struct vrange *range,
+		unsigned long start_idx, unsigned long end_idx)
+{
+	range->node.start = start_idx;
+	range->node.last = end_idx;
+}
+
+static void __add_range(struct vrange *range,
+				struct rb_root *root)
+{
+	interval_tree_insert(&range->node, root);
+}
+
+static void __remove_range(struct vrange *range,
+				struct rb_root *root)
+{
+	interval_tree_remove(&range->node, root);
+}
+
+static struct vrange *alloc_vrange(void)
+{
+	return kmem_cache_alloc(vrange_cachep, GFP_KERNEL);
+}
+
+static void free_vrange(struct vrange *range)
+{
+	kmem_cache_free(vrange_cachep, range);
+}
+
+static inline void range_resize(struct rb_root *root,
+		struct vrange *range,
+		unsigned long start, unsigned long end)
+{
+	__remove_range(range, root);
+	__set_vrange(range, start, end);
+	__add_range(range, root);
+}
+
+int add_vrange(struct mm_struct *mm,
+			unsigned long start, unsigned long end)
+{
+	struct rb_root *root;
+	struct vrange *new_range, *range;
+	struct interval_tree_node *node, *next;
+	int purged = 0;
+
+	new_range = alloc_vrange();
+	if (!new_range)
+		return -ENOMEM;
+
+	root = &mm->v_rb;
+	vrange_lock(mm);
+	node = interval_tree_iter_first(root, start, end);
+	while (node) {
+		next = interval_tree_iter_next(node, start, end);
+
+		range = container_of(node, struct vrange, node);
+		if (node->start < start && node->last > end) {
+			free_vrange(new_range);
+			goto out;
+		}
+
+		start = min_t(unsigned long, start, node->start);
+		end = max_t(unsigned long, end, node->last);
+
+		purged |= range->purged;
+		__remove_range(range, root);
+		free_vrange(range);
+
+		node = next;
+	}
+
+	__set_vrange(new_range, start, end);
+	new_range->purged = purged;
+
+	__add_range(new_range, root);
+out:
+	vrange_unlock(mm);
+	return 0;
+}
+
+int remove_vrange(struct mm_struct *mm,
+		unsigned long start, unsigned long end)
+{
+	struct rb_root *root;
+	struct vrange *new_range, *range;
+	struct interval_tree_node *node, *next;
+	int ret	= 0;
+	bool used_new = false;
+
+	new_range = alloc_vrange();
+	if (!new_range)
+		return -ENOMEM;
+
+	root = &mm->v_rb;
+	vrange_lock(mm);
+
+	node = interval_tree_iter_first(root, start, end);
+	while (node) {
+		next = interval_tree_iter_next(node, start, end);
+
+		range = container_of(node, struct vrange, node);
+		ret |= range->purged;
+
+		if (start <= node->start && end >= node->last) {
+			__remove_range(range, root);
+			free_vrange(range);
+		} else if (node->start >= start) {
+			range_resize(root, range, end, node->last);
+		} else if (node->last <= end) {
+			range_resize(root, range, node->start, start);
+		} else {
+			used_new = true;
+			__set_vrange(new_range, end, node->last);
+			new_range->purged = range->purged;
+			range_resize(root, range, node->start, start);
+			__add_range(new_range, root);
+			break;
+		}
+
+		node = next;
+	}
+
+	vrange_unlock(mm);
+	if (!used_new)
+		free_vrange(new_range);
+
+	return ret;
+}
+
+void exit_vrange(struct mm_struct *mm)
+{
+	struct vrange *range;
+	struct rb_node *next;
+
+	next = rb_first(&mm->v_rb);
+	while (next) {
+		range = vrange_entry(next);
+		next = rb_next(next);
+		__remove_range(range, &mm->v_rb);
+		free_vrange(range);
+	}
+}
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
