Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 73CF46B0037
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 19:52:45 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kp14so1174831pab.36
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 16:52:44 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [RFC PATCH 3/4] vrange: Support fvrange() syscall for file based volatile ranges
Date: Wed,  3 Apr 2013 16:52:22 -0700
Message-Id: <1365033144-15156-4-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
References: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

Add vrange support on addres_space structures, and add fvrange()
syscall for creating ranges on address_space structures.

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
 arch/x86/syscalls/syscall_64.tbl |    1 +
 fs/file_table.c                  |    5 +++
 fs/inode.c                       |    2 ++
 include/linux/fs.h               |    2 ++
 include/linux/vrange.h           |   19 +++++++++-
 include/linux/vrange_types.h     |    1 +
 mm/vrange.c                      |   72 +++++++++++++++++++++++++++++++++++++-
 7 files changed, 100 insertions(+), 2 deletions(-)

diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index dc332bd..910d9f3 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -321,6 +321,7 @@
 312	common	kcmp			sys_kcmp
 313	common	finit_module		sys_finit_module
 314	common	vrange			sys_vrange
+315	common	fvrange			sys_fvrange
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/file_table.c b/fs/file_table.c
index cd4d87a..61c8aaa 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -26,6 +26,7 @@
 #include <linux/hardirq.h>
 #include <linux/task_work.h>
 #include <linux/ima.h>
+#include <linux/vrange.h>
 
 #include <linux/atomic.h>
 
@@ -244,6 +245,10 @@ static void __fput(struct file *file)
 			file->f_op->fasync(-1, file, 0);
 	}
 	ima_file_free(file);
+
+	/* drop all vranges on last close */
+	mapping_exit_vrange(inode->i_mapping);
+
 	if (file->f_op && file->f_op->release)
 		file->f_op->release(inode, file);
 	security_file_free(file);
diff --git a/fs/inode.c b/fs/inode.c
index f5f7c06..4707c95 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -17,6 +17,7 @@
 #include <linux/prefetch.h>
 #include <linux/buffer_head.h> /* for inode_has_buffers */
 #include <linux/ratelimit.h>
+#include <linux/vrange.h>
 #include "internal.h"
 
 /*
@@ -350,6 +351,7 @@ void address_space_init_once(struct address_space *mapping)
 	spin_lock_init(&mapping->private_lock);
 	mapping->i_mmap = RB_ROOT;
 	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
+	mapping_init_vrange(mapping);
 }
 EXPORT_SYMBOL(address_space_init_once);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2c28271..6f86c7c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -27,6 +27,7 @@
 #include <linux/lockdep.h>
 #include <linux/percpu-rwsem.h>
 #include <linux/blk_types.h>
+#include <linux/vrange_types.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -411,6 +412,7 @@ struct address_space {
 	struct rb_root		i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
+	struct vrange_root	vroot;
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index b9b219c..91960eb 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -3,6 +3,7 @@
 
 #include <linux/vrange_types.h>
 #include <linux/mm.h>
+#include <linux/fs.h>
 
 #define vrange_entry(ptr) \
 	container_of(ptr, struct vrange, node.rb)
@@ -11,10 +12,19 @@
 
 static inline void mm_init_vrange(struct mm_struct *mm)
 {
+	mm->vroot.type = VRANGE_ANON;
 	mm->vroot.v_rb = RB_ROOT;
 	mutex_init(&mm->vroot.v_lock);
 }
 
+static inline void mapping_init_vrange(struct address_space *mapping)
+{
+	mapping->vroot.type = VRANGE_FILE;
+	mapping->vroot.v_rb = RB_ROOT;
+	mutex_init(&mapping->vroot.v_lock);
+}
+
+
 static inline void vrange_lock(struct vrange_root *vroot)
 {
 	mutex_lock(&vroot->v_lock);
@@ -25,15 +35,22 @@ static inline void vrange_unlock(struct vrange_root *vroot)
 	mutex_unlock(&vroot->v_lock);
 }
 
-static inline struct mm_struct *vrange_get_owner_mm(struct vrange *vrange)
+static inline int vrange_type(struct vrange *vrange)
 {
+	return vrange->owner->type;
+}
 
+static inline struct mm_struct *vrange_get_owner_mm(struct vrange *vrange)
+{
+	if (vrange_type(vrange) != VRANGE_ANON)
+		return NULL;
 	return container_of(vrange->owner, struct mm_struct, vroot);
 }
 
 
 void vrange_init(void);
 extern void mm_exit_vrange(struct mm_struct *mm);
+extern void mapping_exit_vrange(struct address_space *mapping);
 int discard_vpage(struct page *page);
 bool vrange_address(struct mm_struct *mm, unsigned long start,
 			unsigned long end);
diff --git a/include/linux/vrange_types.h b/include/linux/vrange_types.h
index bede336..c7154e4 100644
--- a/include/linux/vrange_types.h
+++ b/include/linux/vrange_types.h
@@ -7,6 +7,7 @@
 struct vrange_root {
 	struct rb_root v_rb;		/* vrange rb tree */
 	struct mutex v_lock;		/* Protect v_rb */
+	enum {VRANGE_ANON, VRANGE_FILE} type; /* range root type */
 };
 
 
diff --git a/mm/vrange.c b/mm/vrange.c
index 9facbbc..671909c 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -14,6 +14,7 @@
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
 #include <linux/migrate.h>
+#include <linux/file.h>
 
 struct vrange_walker_private {
 	struct zone *zone;
@@ -234,6 +235,20 @@ void mm_exit_vrange(struct mm_struct *mm)
 	}
 }
 
+void mapping_exit_vrange(struct address_space *mapping)
+{
+	struct vrange *range;
+	struct rb_node *next;
+
+	next = rb_first(&mapping->vroot.v_rb);
+	while (next) {
+		range = vrange_entry(next);
+		next = rb_next(next);
+		__remove_range(range);
+		put_vrange(range);
+	}
+}
+
 /*
  * The vrange(2) system call.
  *
@@ -291,6 +306,51 @@ out:
 }
 
 
+SYSCALL_DEFINE5(fvrange, int, fd, size_t, offset,
+		size_t, len, int, mode, int, behavior)
+{
+	struct fd f = fdget(fd);
+	struct address_space *mapping;
+	u64 start = offset;
+	u64 end;
+	int ret = -EINVAL;
+
+	if (!f.file)
+		return -EBADF;
+
+	if (S_ISFIFO(file_inode(f.file)->i_mode)) {
+		ret = -ESPIPE;
+		goto out;
+	}
+
+	mapping = f.file->f_mapping;
+	if (!mapping || len < 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (start & ~PAGE_MASK)
+		goto out;
+
+
+	len &= PAGE_MASK;
+	if (!len)
+		goto out;
+
+	end = start + len;
+	if (end < start)
+		goto out;
+
+	if (mode == VRANGE_VOLATILE)
+		ret = add_vrange(&mapping->vroot, start, end - 1);
+	else if (mode == VRANGE_NOVOLATILE)
+		ret = remove_vrange(&mapping->vroot, start, end - 1);
+out:
+	fdput(f);
+	return ret;
+}
+
+
 static bool __vrange_address(struct mm_struct *mm,
 			unsigned long start, unsigned long end)
 {
@@ -641,6 +701,9 @@ unsigned int discard_vrange(struct zone *zone, struct vrange *vrange,
 
 	mm = vrange_get_owner_mm(vrange);
 
+	if (!mm)
+		goto out;
+
 	if (!down_read_trylock(&mm->mmap_sem))
 		goto out;
 
@@ -683,6 +746,12 @@ static struct vrange *get_victim_vrange(void)
 	list_for_each_prev_safe(cur, tmp, &lru_vrange) {
 		vrange = list_entry(cur, struct vrange, lru);
 		mm = vrange_get_owner_mm(vrange);
+
+		if (!mm) {
+			vrange = NULL;
+			continue;
+		}
+
 		/* the process is exiting so pass it */
 		if (atomic_read(&mm->mm_users) == 0) {
 			list_del_init(&vrange->lru);
@@ -720,7 +789,8 @@ static void put_victim_range(struct vrange *vrange)
 	struct mm_struct *mm = vrange_get_owner_mm(vrange);
 
 	put_vrange(vrange);
-	mmdrop(mm);
+	if (mm)
+		mmdrop(mm);
 }
 
 unsigned int discard_vrange_pages(struct zone *zone, int nr_to_discard)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
