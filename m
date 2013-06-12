Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C54EF6B0038
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 00:23:19 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un1so5106594pbc.15
        for <linux-mm@kvack.org>; Tue, 11 Jun 2013 21:23:19 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 3/8] vrange: Add vrange support to mm_structs
Date: Tue, 11 Jun 2013 21:22:46 -0700
Message-Id: <1371010971-15647-4-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

Allows for vranges to be managed against mm_structs.

Includes support for copying vrange trees on fork,
as well as clearing them on exec.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dgiani@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
[jstultz: Heavy refactoring.]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/mm_types.h |  5 +++++
 include/linux/vrange.h   |  7 ++++++-
 kernel/fork.c            |  6 ++++++
 mm/vrange.c              | 30 ++++++++++++++++++++++++++++++
 4 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ace9a5f..2e02a6d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,8 @@
 #include <linux/page-debug-flags.h>
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
+#include <linux/mutex.h>
+#include <linux/vrange_types.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -351,6 +353,9 @@ struct mm_struct {
 						 */
 
 
+#ifdef CONFIG_MMU
+	struct vrange_root vroot;
+#endif
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
 
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 2064cb0..13f4887 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -33,12 +33,17 @@ static inline int vrange_type(struct vrange *vrange)
 
 void vrange_init(void);
 extern void vrange_root_cleanup(struct vrange_root *vroot);
-
+extern int vrange_fork(struct mm_struct *new,
+					struct mm_struct *old);
 #else
 
 static inline void vrange_init(void) {};
 static inline void vrange_root_init(struct vrange_root *vroot, int type) {};
 static inline void vrange_root_cleanup(struct vrange_root *vroot) {};
+static inline int vrange_fork(struct mm_struct *new, struct mm_struct *old)
+{
+	return 0;
+}
 
 #endif
 #endif /* _LINIUX_VRANGE_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 987b28a..6d22625 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -71,6 +71,7 @@
 #include <linux/signalfd.h>
 #include <linux/uprobes.h>
 #include <linux/aio.h>
+#include <linux/vrange.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -379,6 +380,9 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	retval = khugepaged_fork(mm, oldmm);
 	if (retval)
 		goto out;
+	retval = vrange_fork(mm, oldmm);
+	if (retval)
+		goto out;
 
 	prev = NULL;
 	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
@@ -542,6 +546,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	spin_lock_init(&mm->page_table_lock);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
+	vrange_root_init(&mm->vroot, VRANGE_MM);
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 
@@ -613,6 +618,7 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		uprobe_clear_state(mm);
+		vrange_root_cleanup(&mm->vroot);
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
diff --git a/mm/vrange.c b/mm/vrange.c
index e3042e0..bbaa184 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -4,6 +4,7 @@
 
 #include <linux/vrange.h>
 #include <linux/slab.h>
+#include <linux/mman.h>
 
 static struct kmem_cache *vrange_cachep;
 
@@ -179,3 +180,32 @@ void vrange_root_cleanup(struct vrange_root *vroot)
 	vrange_unlock(vroot);
 }
 
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
+
+		new_range = __vrange_alloc(GFP_KERNEL);
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
