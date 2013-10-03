Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 031E06B003A
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:05 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so1668317pbc.31
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:05 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so1803880pab.11
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:03 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 02/14] vrange: Add vrange support to mm_structs
Date: Wed,  2 Oct 2013 17:51:31 -0700
Message-Id: <1380761503-14509-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

This patch addes vroot on mm_struct so process can set volatile
ranges on anonymous memory.

This is somewhat wasteful, as it increases the mm struct even
if the process doesn't use vrange syscall. So a later patch
will provide dynamically allocated vroots.

One of note on this patch is vrange_fork. Since we do allocations
while holding a lock on the vrange, its possible it could deadlock
with direct reclaim's purging logic. For this reason, vrange_fork
uses GFP_NOIO for its allocations.

If vrange_fork fails, it isn't a critical problem. Since the result
is the child process's pages won't be volatile/purgable, which
could cause additional memory pressure, but won't cause problematic
application behavior (since volatile pages are only purged at the
kernels' discretion). This is thought to be more desirable then
having fork fail.

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
[jstultz: Bit of refactoring. Comment cleanups]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/mm_types.h |  4 ++++
 include/linux/vrange.h   |  7 ++++++-
 kernel/fork.c            | 11 +++++++++++
 mm/vrange.c              | 40 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 61 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index faf4b7c..5d8cdc3 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
+#include <linux/vrange_types.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -349,6 +350,9 @@ struct mm_struct {
 						 */
 
 
+#ifdef CONFIG_MMU
+	struct vrange_root vroot;
+#endif
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
 
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 0d378a5..2b96ee1 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -37,12 +37,17 @@ static inline int vrange_type(struct vrange *vrange)
 }
 
 extern void vrange_root_cleanup(struct vrange_root *vroot);
-
+extern int vrange_fork(struct mm_struct *new,
+					struct mm_struct *old);
 #else
 
 static inline void vrange_root_init(struct vrange_root *vroot,
 					int type, void *object) {};
 static inline void vrange_root_cleanup(struct vrange_root *vroot) {};
+static inline int vrange_fork(struct mm_struct *new, struct mm_struct *old)
+{
+	return 0;
+}
 
 #endif
 #endif /* _LINIUX_VRANGE_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index bf46287..ceb38bf 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -71,6 +71,7 @@
 #include <linux/signalfd.h>
 #include <linux/uprobes.h>
 #include <linux/aio.h>
+#include <linux/vrange.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -377,6 +378,14 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	retval = khugepaged_fork(mm, oldmm);
 	if (retval)
 		goto out;
+	/*
+	 * Note: vrange_fork can fail in the case of ENOMEM, but
+	 * this only results in the child not having any active
+	 * volatile ranges. This is not harmful. Thus in this case
+	 * the child will not see any pages purged unless it remarks
+	 * them as volatile.
+	 */
+	vrange_fork(mm, oldmm);
 
 	prev = NULL;
 	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
@@ -538,6 +547,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm->nr_ptes = 0;
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
+	vrange_root_init(&mm->vroot, VRANGE_MM, mm);
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 
@@ -609,6 +619,7 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		uprobe_clear_state(mm);
+		vrange_root_cleanup(&mm->vroot);
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
diff --git a/mm/vrange.c b/mm/vrange.c
index 866566c..4ddcc3e9 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -181,3 +181,43 @@ void vrange_root_cleanup(struct vrange_root *vroot)
 	vrange_unlock(vroot);
 }
 
+/*
+ * It's okay to fail vrange_fork because worst case is child process
+ * can't have copied own vrange data structure so that pages in the
+ * vrange couldn't be purged. It would be better rather than failing
+ * fork.
+ */
+int vrange_fork(struct mm_struct *new_mm, struct mm_struct *old_mm)
+{
+	struct vrange_root *new, *old;
+	struct vrange *range, *new_range;
+	struct rb_node *next;
+
+	new = &new_mm->vroot;
+	old = &old_mm->vroot;
+
+	vrange_lock(old);
+	next = rb_first(&old->v_rb);
+	while (next) {
+		range = vrange_entry(next);
+		next = rb_next(next);
+		/*
+		 * We can't use GFP_KERNEL because direct reclaim's
+		 * purging logic on vrange could be deadlock by
+		 * vrange_lock.
+		 */
+		new_range = __vrange_alloc(GFP_NOIO);
+		if (!new_range)
+			goto fail;
+		__vrange_set(new_range, range->node.start,
+					range->node.last, range->purged);
+		__vrange_add(new_range, new);
+
+	}
+	vrange_unlock(old);
+	return 0;
+fail:
+	vrange_unlock(old);
+	vrange_root_cleanup(new);
+	return -ENOMEM;
+}
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
