Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 872E16B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 05:55:01 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id o80so2496947lfg.6
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 02:55:01 -0700 (PDT)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [2a02:6b8:0:1a72::290])
        by mx.google.com with ESMTPS id z17si3661077lfb.28.2017.10.02.02.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 02:54:59 -0700 (PDT)
Subject: [PATCH RFC] mm: implement write-behind policy for sequential file
 writes
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Mon, 02 Oct 2017 12:54:54 +0300
Message-ID: <150693809463.587641.5712378065494786263.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Jens Axboe <axboe@kernel.dk>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Traditional writeback tries to accumulate as much dirty data as possible.
This is worth strategy for extremely short-living files and for batching
writes for saving battery power. But for workloads where disk latency is
important this policy generates periodic disk load spikes which increases
latency for concurrent operations.

Present writeback engine allows to tune only dirty data size or expiration
time. Such tuning cannot eliminate pikes - this just lowers and multiplies
them. Other option is switching into sync mode which flushes written data
right after each write, obviously this have significant performance impact.
Such tuning is system-wide and affects memory-mapped and randomly written
files, flusher threads handle them much better.

This patch implements write-behind policy which tracks sequential writes
and starts background writeback when have enough dirty pages in a row.

Write-behind tracks current writing position and looks into two windows
behind it: first represents unwitten pages, Second - async writeback.

Next write starts background writeback when first window exceed threshold
and waits for pages falling behind async writeback window. This allows to
combine small writes into bigger requests and maintain optimal io-depth.

This affects only writes via syscalls, memory mapped writes are unchanged.
Also write-behind doesn't affect files with fadvise POSIX_FADV_RANDOM.

If async window set to 0 then write-behind skips dirty pages for congested
disk and never wait for writeback. This is used for files with O_NONBLOCK.

Also for files with fadvise POSIX_FADV_NOREUSE write-behind automatically
evicts completely written pages from cache. This is perfect for writing
verbose logs without pushing more important data out of cache.

As a bonus write-behind makes blkio throttling much more smooth for most
bulk file operations like copying or downloading which writes sequentially.

Size of minimal write-behind request is set in:
/sys/block/$DISK/bdi/min_write_behind_kb
Default is 256Kb, 0 - disable write-behind for this disk.

Size of async window set in:
/sys/block/$DISK/bdi/async_write_behind_kb
Default is 1024Kb, 0 - disables sync write-behind.

Write-behind is controlled by sysctl vm.dirty_write_behind:
=0: disabled, default
=1: enabled

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 Documentation/ABI/testing/sysfs-class-bdi |   11 ++++
 Documentation/sysctl/vm.txt               |   15 +++++
 include/linux/backing-dev-defs.h          |    2 +
 include/linux/fs.h                        |    9 +++
 include/linux/mm.h                        |    3 +
 kernel/sysctl.c                           |    9 +++
 mm/backing-dev.c                          |   46 +++++++++-------
 mm/fadvise.c                              |    4 +
 mm/page-writeback.c                       |   84 +++++++++++++++++++++++++++++
 9 files changed, 162 insertions(+), 21 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-bdi b/Documentation/ABI/testing/sysfs-class-bdi
index d773d5697cf5..50a8b8750c13 100644
--- a/Documentation/ABI/testing/sysfs-class-bdi
+++ b/Documentation/ABI/testing/sysfs-class-bdi
@@ -30,6 +30,17 @@ read_ahead_kb (read-write)
 
 	Size of the read-ahead window in kilobytes
 
+min_write_behind_kb (read-write)
+
+	Size of minimal write-behind request in kilobytes.
+	0 -> disable write-behind for this disk.
+
+async_write_behind_kb (read-write)
+
+	Size of async write-behind window in kilobytes.
+	Next write will wait for writeback falling behind window.
+	0 -> completely async mode, skip if disk is congested.
+
 min_ratio (read-write)
 
 	Under normal circumstances each device is given a part of the
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9baf66a9ef4e..c491fb6d8ba6 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -28,6 +28,7 @@ Currently, these files are in /proc/sys/vm:
 - dirty_expire_centisecs
 - dirty_ratio
 - dirty_writeback_centisecs
+- dirty_write_behind
 - drop_caches
 - extfrag_threshold
 - hugepages_treat_as_movable
@@ -188,6 +189,20 @@ Setting this to zero disables periodic writeback altogether.
 
 ==============================================================
 
+dirty_write_behind
+
+This controls write-behind writeback policy - automatic background writeback
+for sequentially written data behind current writing position.
+
+=0: disabled, default
+=1: enabled
+
+Minimum requeqst size and async window size configured in for each bdi:
+/sys/block/$DEV/bdi/min_write_behind_kb
+/sys/block/$DEV/bdi/async_write_behind_kb
+
+==============================================================
+
 drop_caches
 
 Writing to this will cause the kernel to drop clean caches, as well as
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 866c433e7d32..ba5322ea970a 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -143,6 +143,8 @@ struct backing_dev_info {
 	struct list_head bdi_list;
 	unsigned long ra_pages;	/* max readahead in PAGE_SIZE units */
 	unsigned long io_pages;	/* max allowed IO size */
+	unsigned long min_write_behind; /* Minimum write-behind in pages */
+	unsigned long async_write_behind; /* Async write-behind in pages */
 	congested_fn *congested_fn; /* Function pointer if device is md/dm */
 	void *congested_data;	/* Pointer to aux data for congested func */
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 339e73742e73..828494ce556e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -144,6 +144,8 @@ typedef int (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define FMODE_CAN_READ          ((__force fmode_t)0x20000)
 /* Has write method(s) */
 #define FMODE_CAN_WRITE         ((__force fmode_t)0x40000)
+/* "Use once" access pattern is expected */
+#define FMODE_NOREUSE		((__force fmode_t)0x80000)
 
 /* File was opened by fanotify and shouldn't generate fanotify events */
 #define FMODE_NONOTIFY		((__force fmode_t)0x4000000)
@@ -871,6 +873,7 @@ struct file {
 	struct fown_struct	f_owner;
 	const struct cred	*f_cred;
 	struct file_ra_state	f_ra;
+	pgoff_t			f_write_behind;
 
 	u64			f_version;
 #ifdef CONFIG_SECURITY
@@ -2655,6 +2658,9 @@ extern int vfs_fsync_range(struct file *file, loff_t start, loff_t end,
 			   int datasync);
 extern int vfs_fsync(struct file *file, int datasync);
 
+extern int vm_dirty_write_behind;
+extern ssize_t generic_write_behind(struct kiocb *iocb, ssize_t count);
+
 /*
  * Sync the bytes written if this was a synchronous write.  Expect ki_pos
  * to already be updated for the write, and will return either the amount
@@ -2668,7 +2674,8 @@ static inline ssize_t generic_write_sync(struct kiocb *iocb, ssize_t count)
 				(iocb->ki_flags & IOCB_SYNC) ? 0 : 1);
 		if (ret)
 			return ret;
-	}
+	} else if (vm_dirty_write_behind)
+		return generic_write_behind(iocb, count);
 
 	return count;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f8c10d336e42..592efaeca2d4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2217,6 +2217,9 @@ extern int filemap_page_mkwrite(struct vm_fault *vmf);
 int __must_check write_one_page(struct page *page);
 void task_dirty_inc(struct task_struct *tsk);
 
+#define VM_MIN_WRITE_BEHIND_KB		256
+#define VM_ASYNC_WRITE_BEHIND_KB	1024
+
 /* readahead.c */
 #define VM_MAX_READAHEAD	128	/* kbytes */
 #define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 423554ad3610..a40e4839a390 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1346,6 +1346,15 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 	},
 	{
+		.procname	= "dirty_write_behind",
+		.data		= &vm_dirty_write_behind,
+		.maxlen		= sizeof(vm_dirty_write_behind),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+	{
 		.procname       = "nr_pdflush_threads",
 		.mode           = 0444 /* read-only */,
 		.proc_handler   = pdflush_proc_obsolete,
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e19606bb41a0..c0f8aba4133d 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -138,25 +138,6 @@ static inline void bdi_debug_unregister(struct backing_dev_info *bdi)
 }
 #endif
 
-static ssize_t read_ahead_kb_store(struct device *dev,
-				  struct device_attribute *attr,
-				  const char *buf, size_t count)
-{
-	struct backing_dev_info *bdi = dev_get_drvdata(dev);
-	unsigned long read_ahead_kb;
-	ssize_t ret;
-
-	ret = kstrtoul(buf, 10, &read_ahead_kb);
-	if (ret < 0)
-		return ret;
-
-	bdi->ra_pages = read_ahead_kb >> (PAGE_SHIFT - 10);
-
-	return count;
-}
-
-#define K(pages) ((pages) << (PAGE_SHIFT - 10))
-
 #define BDI_SHOW(name, expr)						\
 static ssize_t name##_show(struct device *dev,				\
 			   struct device_attribute *attr, char *page)	\
@@ -167,7 +148,27 @@ static ssize_t name##_show(struct device *dev,				\
 }									\
 static DEVICE_ATTR_RW(name);
 
-BDI_SHOW(read_ahead_kb, K(bdi->ra_pages))
+#define BDI_ATTR_KB(name, field)					\
+static ssize_t name##_store(struct device *dev,				\
+			    struct device_attribute *attr,		\
+			    const char *buf, size_t count)		\
+{									\
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);		\
+	unsigned long kb;						\
+	ssize_t ret;							\
+									\
+	ret = kstrtoul(buf, 10, &kb);					\
+	if (ret < 0)							\
+		return ret;						\
+									\
+	bdi->field = kb >> (PAGE_SHIFT - 10);				\
+	return count;							\
+}									\
+BDI_SHOW(name, ((bdi->field) << (PAGE_SHIFT - 10)))
+
+BDI_ATTR_KB(read_ahead_kb, ra_pages)
+BDI_ATTR_KB(min_write_behind_kb, min_write_behind)
+BDI_ATTR_KB(async_write_behind_kb, async_write_behind)
 
 static ssize_t min_ratio_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
@@ -220,6 +221,8 @@ static DEVICE_ATTR_RO(stable_pages_required);
 
 static struct attribute *bdi_dev_attrs[] = {
 	&dev_attr_read_ahead_kb.attr,
+	&dev_attr_min_write_behind_kb.attr,
+	&dev_attr_async_write_behind_kb.attr,
 	&dev_attr_min_ratio.attr,
 	&dev_attr_max_ratio.attr,
 	&dev_attr_stable_pages_required.attr,
@@ -836,6 +839,9 @@ static int bdi_init(struct backing_dev_info *bdi)
 	INIT_LIST_HEAD(&bdi->wb_list);
 	init_waitqueue_head(&bdi->wb_waitq);
 
+	bdi->min_write_behind = VM_MIN_WRITE_BEHIND_KB >> (PAGE_SHIFT - 10);
+	bdi->async_write_behind = VM_ASYNC_WRITE_BEHIND_KB >> (PAGE_SHIFT - 10);
+
 	ret = cgwb_bdi_init(bdi);
 
 	return ret;
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 702f239cd6db..8817343955e7 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -82,6 +82,7 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		f.file->f_ra.ra_pages = bdi->ra_pages;
 		spin_lock(&f.file->f_lock);
 		f.file->f_mode &= ~FMODE_RANDOM;
+		f.file->f_mode &= ~FMODE_NOREUSE;
 		spin_unlock(&f.file->f_lock);
 		break;
 	case POSIX_FADV_RANDOM:
@@ -113,6 +114,9 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 					   nrpages);
 		break;
 	case POSIX_FADV_NOREUSE:
+		spin_lock(&f.file->f_lock);
+		f.file->f_mode |= FMODE_NOREUSE;
+		spin_unlock(&f.file->f_lock);
 		break;
 	case POSIX_FADV_DONTNEED:
 		if (!inode_write_congested(mapping->host))
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cbe8eba..95151f3ebd4f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2851,3 +2851,87 @@ void wait_for_stable_page(struct page *page)
 		wait_on_page_writeback(page);
 }
 EXPORT_SYMBOL_GPL(wait_for_stable_page);
+
+int vm_dirty_write_behind __read_mostly;
+EXPORT_SYMBOL(vm_dirty_write_behind);
+
+/**
+ * generic_write_behind() - writeback dirty pages behind current position.
+ *
+ * This function tracks writing position and starts background writeback if
+ * file has enough sequentially written data.
+ *
+ * Returns @count or a negative error code if I/O failed.
+ */
+extern ssize_t generic_write_behind(struct kiocb *iocb, ssize_t count)
+{
+	struct file *file = iocb->ki_filp;
+	struct address_space *mapping = file->f_mapping;
+	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
+	unsigned long min_size = READ_ONCE(bdi->min_write_behind);
+	unsigned long async_size = READ_ONCE(bdi->async_write_behind);
+	pgoff_t head = file->f_write_behind;
+	pgoff_t begin = (iocb->ki_pos - count) >> PAGE_SHIFT;
+	pgoff_t end = iocb->ki_pos >> PAGE_SHIFT;
+	int ret;
+
+	/* Disabled, contiguous and not big enough yet or marked as random. */
+	if (!min_size || end - head < min_size || (file->f_mode & FMODE_RANDOM))
+		goto out;
+
+	spin_lock(&file->f_lock);
+
+	/* Re-read under lock. */
+	head = file->f_write_behind;
+
+	/* Non-contiguous, move head position. */
+	if (head > end || begin - head > async_size)
+		file->f_write_behind = head = begin;
+
+	/* Still not big enough. */
+	if (end - head < min_size) {
+		spin_unlock(&file->f_lock);
+		goto out;
+	}
+
+	/* Set head for next iteration, everything behind will be written. */
+	file->f_write_behind = end;
+
+	spin_unlock(&file->f_lock);
+
+	/* Non-blocking files always works in async mode. */
+	if (file->f_flags & O_NONBLOCK)
+		async_size = 0;
+
+	/* Skip pages in async mode if disk is congested. */
+	if (!async_size && inode_write_congested(mapping->host))
+		goto out;
+
+	/* Start background writeback. */
+	ret = __filemap_fdatawrite_range(mapping,
+					 (loff_t)head << PAGE_SHIFT,
+					 ((loff_t)end << PAGE_SHIFT) - 1,
+					 WB_SYNC_NONE);
+	if (ret < 0)
+		return ret;
+
+	if (!async_size || head < async_size)
+		goto out;
+
+	/* Wait for pages falling behind async window. */
+	head -= async_size;
+	end -= async_size;
+	ret = filemap_fdatawait_range(mapping,
+				      (loff_t)head << PAGE_SHIFT,
+				      ((loff_t)end << PAGE_SHIFT) - 1);
+	if (ret < 0)
+		return ret;
+
+	/* Evict completely written pages if no more access expected. */
+	if (file->f_mode & FMODE_NOREUSE)
+		invalidate_mapping_pages(mapping, head, end - 1);
+
+out:
+	return count;
+}
+EXPORT_SYMBOL(generic_write_behind);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
