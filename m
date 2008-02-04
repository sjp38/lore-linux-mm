Message-Id: <20080204144204.739740888@szeredi.hu>
References: <20080204144142.002127391@szeredi.hu>
Date: Mon, 04 Feb 2008 15:41:43 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 1/3] mm: bdi: export bdi_writeout_inc()
Content-Disposition: inline; filename=export_bdi_writeout_inc.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fuse needs this for writable mmap support.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/include/linux/backing-dev.h
===================================================================
--- linux.orig/include/linux/backing-dev.h	2008-02-04 12:29:01.000000000 +0100
+++ linux/include/linux/backing-dev.h	2008-02-04 13:01:23.000000000 +0100
@@ -149,6 +149,8 @@ static inline unsigned long bdi_stat_err
 int bdi_set_min_ratio(struct backing_dev_info *bdi, unsigned int min_ratio);
 int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 
+extern void bdi_writeout_inc(struct backing_dev_info *bdi);
+
 /*
  * Flags in backing_dev_info::capability
  * - The first two flags control whether dirty pages will contribute to the
Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2008-02-04 12:29:01.000000000 +0100
+++ linux/mm/page-writeback.c	2008-02-04 13:01:23.000000000 +0100
@@ -168,6 +168,16 @@ static inline void __bdi_writeout_inc(st
 			      bdi->max_prop_frac);
 }
 
+void bdi_writeout_inc(struct backing_dev_info *bdi)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__bdi_writeout_inc(bdi);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(bdi_writeout_inc);
+
 static inline void task_dirty_inc(struct task_struct *tsk)
 {
 	prop_inc_single(&vm_dirties, &tsk->dirties);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
