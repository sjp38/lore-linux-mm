Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 206F86B01F1
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 00:17:24 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: [RFC][PATCH] Per file dirty limit throttling
Date: Mon, 16 Aug 2010 09:49:50 +0530
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201008160949.51512.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

When the total dirty pages exceed vm_dirty_ratio, the dirtier is made to do
the writeback. But this dirtier may not be the one who took the system to this
state. Instead, if we can track the dirty count per-file, we could throttle
the dirtier of a file, when the file's dirty pages exceed a certain limit.
Even though this dirtier may not be the one who dirtied the other pages of
this file, it is fair to throttle this process, as it uses that file.

This patch
1. Adds dirty page accounting per-file.
2. Exports the number of pages of this file in cache and no of pages dirty via
proc-fdinfo.
3. Adds a new tunable, /proc/sys/vm/file_dirty_bytes. When a files dirty data
exceeds this limit, the writeback of that inode is done by the current
dirtier.

This certainly will affect the throughput of certain heavy-dirtying workloads,
but should help for interactive systems.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

---

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index b606c2c..4f8bc06 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -133,6 +133,15 @@ Setting this to zero disables periodic writeback altogether.
 
 ==============================================================
 
+file_dirty_bytes
+
+When a files total dirty data exceeds file_dirty_bytes, the current generator
+of dirty data would be made to do the writeback of dirty pages of that file.
+
+0 disables this behaviour.
+
+==============================================================
+
 drop_caches
 
 Writing to this will cause the kernel to drop clean caches, dentries and
diff --git a/fs/proc/base.c b/fs/proc/base.c
index a1c43e7..23becb2 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -83,6 +83,8 @@
 #include <linux/pid_namespace.h>
 #include <linux/fs_struct.h>
 #include <linux/slab.h>
+#include <linux/pagemap.h>
+#include <linux/writeback.h>
 #include "internal.h"
 
 /* NOTE:
@@ -1791,7 +1793,7 @@ out:
 	return ~0U;
 }
 
-#define PROC_FDINFO_MAX 64
+#define PROC_FDINFO_MAX 128
 
 static int proc_fd_info(struct inode *inode, struct path *path, char *info)
 {
@@ -1805,6 +1807,7 @@ static int proc_fd_info(struct inode *inode, struct path *path, char *info)
 		put_task_struct(task);
 	}
 	if (files) {
+		int infolen = 0;
 		/*
 		 * We are not taking a ref to the file structure, so we must
 		 * hold ->file_lock.
@@ -1816,12 +1819,24 @@ static int proc_fd_info(struct inode *inode, struct path *path, char *info)
 				*path = file->f_path;
 				path_get(&file->f_path);
 			}
-			if (info)
-				snprintf(info, PROC_FDINFO_MAX,
+			if (info) {
+				struct address_space *as = file->f_mapping;
+
+				infolen = snprintf(info, PROC_FDINFO_MAX,
 					 "pos:\t%lli\n"
 					 "flags:\t0%o\n",
 					 (long long) file->f_pos,
 					 file->f_flags);
+				if (as) {
+					snprintf(info + infolen, PROC_FDINFO_MAX - infolen,
+					"cache_kb:\t%lu\n"
+					"dirty_kb:\t%lu\n",
+					(as->nrpages * PAGE_SIZE) / 1024,
+					(as->nrdirty * PAGE_SIZE) / 1024);
+				}
+
+			}
+	
 			spin_unlock(&files->file_lock);
 			put_files_struct(files);
 			return 0;
diff --git a/fs/read_write.c b/fs/read_write.c
index 74e3658..8881b7d 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -16,6 +16,8 @@
 #include <linux/syscalls.h>
 #include <linux/pagemap.h>
 #include <linux/splice.h>
+#include <linux/buffer_head.h>
+#include <linux/writeback.h>
 #include "read_write.h"
 
 #include <asm/uaccess.h>
@@ -414,9 +416,19 @@ SYSCALL_DEFINE3(write, unsigned int, fd, const char __user *, buf,
 
 	file = fget_light(fd, &fput_needed);
 	if (file) {
+		struct address_space *as = file->f_mapping;
+		unsigned long file_dirty_pages;
 		loff_t pos = file_pos_read(file);
+
 		ret = vfs_write(file, buf, count, &pos);
 		file_pos_write(file, pos);
+		/* Start write-out ? */
+		if (file_dirty_bytes) {
+			file_dirty_pages = file_dirty_bytes / PAGE_SIZE;
+			if (as->nrdirty > file_dirty_pages)
+				write_inode_now(as->host, 0);
+		}
+
 		fput_light(file, fput_needed);
 	}
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7a0625e..5de7f32 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -638,6 +638,7 @@ struct address_space {
 	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
 	unsigned int		truncate_count;	/* Cover race condition with truncate */
 	unsigned long		nrpages;	/* number of total pages */
+	unsigned long		nrdirty;
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 72a5d64..c31bf16 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -99,6 +99,7 @@ extern int dirty_background_ratio;
 extern unsigned long dirty_background_bytes;
 extern int vm_dirty_ratio;
 extern unsigned long vm_dirty_bytes;
+extern unsigned long file_dirty_bytes;
 extern unsigned int dirty_writeback_interval;
 extern unsigned int dirty_expire_interval;
 extern int vm_highmem_is_dirtyable;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ca38e8e..8b76b9f 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1041,6 +1041,13 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &dirty_bytes_min,
 	},
 	{
+		.procname	= "file_dirty_bytes",
+		.data		= &file_dirty_bytes,
+		.maxlen		= sizeof(file_dirty_bytes),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+	},
+	{
 		.procname	= "dirty_writeback_centisecs",
 		.data		= &dirty_writeback_interval,
 		.maxlen		= sizeof(dirty_writeback_interval),
diff --git a/mm/memory.c b/mm/memory.c
index 9606ceb..0961f70 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2873,6 +2873,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct vm_fault vmf;
 	int ret;
 	int page_mkwrite = 0;
+	unsigned long file_dirty_pages;
 
 	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
 	vmf.pgoff = pgoff;
@@ -3024,6 +3025,13 @@ out:
 		/* file_update_time outside page_lock */
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);
+
+		/* Start write-back ? */
+		if (mapping && file_dirty_bytes) {
+			file_dirty_pages = file_dirty_bytes / PAGE_SIZE;
+			if (mapping->nrdirty > file_dirty_pages)
+				write_inode_now(mapping->host, 0);
+		}
 	} else {
 		unlock_page(vmf.page);
 		if (anon)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 20890d8..1cabd7f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -87,6 +87,13 @@ int vm_dirty_ratio = 20;
 unsigned long vm_dirty_bytes;
 
 /*
+ * When a files total dirty data exceeds file_dirty_bytes, the current generator
+ * of dirty data would be made to do the writeback of dirty pages of that file.
+ * 0 disables this behaviour.
+ */
+unsigned long file_dirty_bytes = 0;
+
+/*
  * The interval between `kupdate'-style writebacks
  */
 unsigned int dirty_writeback_interval = 5 * 100; /* centiseconds */
@@ -796,6 +803,8 @@ static struct notifier_block __cpuinitdata ratelimit_nb = {
 void __init page_writeback_init(void)
 {
 	int shift;
+	unsigned long background;
+	unsigned long dirty;
 
 	writeback_set_ratelimit();
 	register_cpu_notifier(&ratelimit_nb);
@@ -803,6 +812,8 @@ void __init page_writeback_init(void)
 	shift = calc_period_shift();
 	prop_descriptor_init(&vm_completions, shift);
 	prop_descriptor_init(&vm_dirties, shift);
+	global_dirty_limits(&background, &dirty);
+	file_dirty_bytes = dirty;
 }
 
 /**
@@ -1126,6 +1137,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
+		mapping->nrdirty++;
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
@@ -1301,6 +1313,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 */
 		if (TestClearPageDirty(page)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
+			mapping->nrdirty--;
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
 			return 1;
diff --git a/mm/truncate.c b/mm/truncate.c
index ba887bf..5846d6a 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -75,6 +75,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
+			mapping->nrdirty--;
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
 			if (account_size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
