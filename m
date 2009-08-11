Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2B0AC6B0055
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 17:29:32 -0400 (EDT)
Date: Wed, 12 Aug 2009 00:27:52 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2 1/2] mm: export use_mm/unuse_mm to modules
Message-ID: <20090811212752.GB26309@redhat.com>
References: <cover.1249992497.git.mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1249992497.git.mst@redhat.com>
Sender: owner-linux-mm@kvack.org
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com
List-ID: <linux-mm.kvack.org>

vhost net module wants to do copy to/from user from a kernel thread,
which needs use_mm (like what fs/aio has).  Move that into mm/ and
export to modules.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 fs/aio.c                    |   47 +----------------------------------
 include/linux/mmu_context.h |    9 ++++++
 mm/Makefile                 |    2 +-
 mm/mmu_context.c            |   58 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 69 insertions(+), 47 deletions(-)
 create mode 100644 include/linux/mmu_context.h
 create mode 100644 mm/mmu_context.c

diff --git a/fs/aio.c b/fs/aio.c
index d065b2c..fc21c23 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -24,6 +24,7 @@
 #include <linux/file.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
+#include <linux/mmu_context.h>
 #include <linux/slab.h>
 #include <linux/timer.h>
 #include <linux/aio.h>
@@ -34,7 +35,6 @@
 
 #include <asm/kmap_types.h>
 #include <asm/uaccess.h>
-#include <asm/mmu_context.h>
 
 #if DEBUG > 1
 #define dprintk		printk
@@ -595,51 +595,6 @@ static struct kioctx *lookup_ioctx(unsigned long ctx_id)
 }
 
 /*
- * use_mm
- *	Makes the calling kernel thread take on the specified
- *	mm context.
- *	Called by the retry thread execute retries within the
- *	iocb issuer's mm context, so that copy_from/to_user
- *	operations work seamlessly for aio.
- *	(Note: this routine is intended to be called only
- *	from a kernel thread context)
- */
-static void use_mm(struct mm_struct *mm)
-{
-	struct mm_struct *active_mm;
-	struct task_struct *tsk = current;
-
-	task_lock(tsk);
-	active_mm = tsk->active_mm;
-	atomic_inc(&mm->mm_count);
-	tsk->mm = mm;
-	tsk->active_mm = mm;
-	switch_mm(active_mm, mm, tsk);
-	task_unlock(tsk);
-
-	mmdrop(active_mm);
-}
-
-/*
- * unuse_mm
- *	Reverses the effect of use_mm, i.e. releases the
- *	specified mm context which was earlier taken on
- *	by the calling kernel thread
- *	(Note: this routine is intended to be called only
- *	from a kernel thread context)
- */
-static void unuse_mm(struct mm_struct *mm)
-{
-	struct task_struct *tsk = current;
-
-	task_lock(tsk);
-	tsk->mm = NULL;
-	/* active_mm is still 'mm' */
-	enter_lazy_tlb(mm, tsk);
-	task_unlock(tsk);
-}
-
-/*
  * Queue up a kiocb to be retried. Assumes that the kiocb
  * has already been marked as kicked, and places it on
  * the retry run list for the corresponding ioctx, if it
diff --git a/include/linux/mmu_context.h b/include/linux/mmu_context.h
new file mode 100644
index 0000000..70fffeb
--- /dev/null
+++ b/include/linux/mmu_context.h
@@ -0,0 +1,9 @@
+#ifndef _LINUX_MMU_CONTEXT_H
+#define _LINUX_MMU_CONTEXT_H
+
+struct mm_struct;
+
+void use_mm(struct mm_struct *mm);
+void unuse_mm(struct mm_struct *mm);
+
+#endif
diff --git a/mm/Makefile b/mm/Makefile
index 5e0bd64..46c3892 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   maccess.o page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   page_isolation.o mm_init.o $(mmu-y)
+			   page_isolation.o mm_init.o mmu_context.o $(mmu-y)
 obj-y += init-mm.o
 
 obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
diff --git a/mm/mmu_context.c b/mm/mmu_context.c
new file mode 100644
index 0000000..9989c2f
--- /dev/null
+++ b/mm/mmu_context.c
@@ -0,0 +1,58 @@
+/* Copyright (C) 2009 Red Hat, Inc.
+ *
+ * See ../COPYING for licensing terms.
+ */
+
+#include <linux/mm.h>
+#include <linux/mmu_context.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+
+#include <asm/mmu_context.h>
+
+/*
+ * use_mm
+ *	Makes the calling kernel thread take on the specified
+ *	mm context.
+ *	Called by the retry thread execute retries within the
+ *	iocb issuer's mm context, so that copy_from/to_user
+ *	operations work seamlessly for aio.
+ *	(Note: this routine is intended to be called only
+ *	from a kernel thread context)
+ */
+void use_mm(struct mm_struct *mm)
+{
+	struct mm_struct *active_mm;
+	struct task_struct *tsk = current;
+
+	task_lock(tsk);
+	active_mm = tsk->active_mm;
+	atomic_inc(&mm->mm_count);
+	tsk->mm = mm;
+	tsk->active_mm = mm;
+	switch_mm(active_mm, mm, tsk);
+	task_unlock(tsk);
+
+	mmdrop(active_mm);
+}
+EXPORT_SYMBOL_GPL(use_mm);
+
+/*
+ * unuse_mm
+ *	Reverses the effect of use_mm, i.e. releases the
+ *	specified mm context which was earlier taken on
+ *	by the calling kernel thread
+ *	(Note: this routine is intended to be called only
+ *	from a kernel thread context)
+ */
+void unuse_mm(struct mm_struct *mm)
+{
+	struct task_struct *tsk = current;
+
+	task_lock(tsk);
+	tsk->mm = NULL;
+	/* active_mm is still 'mm' */
+	enter_lazy_tlb(mm, tsk);
+	task_unlock(tsk);
+}
+EXPORT_SYMBOL_GPL(unuse_mm);
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
