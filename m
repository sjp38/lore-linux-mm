Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 739536B0037
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:12 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id lf10so14311598pab.28
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:12 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ll1si23308157pab.57.2014.01.01.23.13.09
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:11 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 01/16] vrange: Add vrange support to mm_structs
Date: Thu,  2 Jan 2014 16:12:09 +0900
Message-Id: <1388646744-15608-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

This patch adds vroot on mm_struct so process can set volatile
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

NOTE: Additionally, as a optimization point, we could remove pages
like MADV_DONTNEED instantly when we see the allocation fail.
There would be no point to make new volatile ranges when memory
pressure was already tight.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
[jstultz: Bit of refactoring. Comment cleanups]
Signed-off-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mm_types.h |    4 ++++
 include/linux/vrange.h   |    7 ++++++-
 kernel/fork.c            |   11 +++++++++++
 mm/vrange.c              |   40 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 61 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d9851eeb6e1d..a4de9cfa8ff1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
+#include <linux/vrange_types.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -350,6 +351,9 @@ struct mm_struct {
 						 */
 
 
+#ifdef CONFIG_MMU
+	struct vrange_root vroot;
+#endif
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
 
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 0d378a5dc8d7..2b96ee1ee75b 100644
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
index 086fe73ad6bd..36d3c4bb4c4d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -71,6 +71,7 @@
 #include <linux/signalfd.h>
 #include <linux/uprobes.h>
 #include <linux/aio.h>
+#include <linux/vrange.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -376,6 +377,14 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
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
@@ -535,6 +544,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm->nr_ptes = 0;
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
+	vrange_root_init(&mm->vroot, VRANGE_MM, mm);
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 
@@ -606,6 +616,7 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		uprobe_clear_state(mm);
+		vrange_root_cleanup(&mm->vroot);
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
diff --git a/mm/vrange.c b/mm/vrange.c
index a5daea44e031..57dad4d72b04 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -182,3 +182,43 @@ void vrange_root_cleanup(struct vrange_root *vroot)
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
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
