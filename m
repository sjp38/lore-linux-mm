Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 8AD446B006E
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 23:16:54 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Fri, 28 Sep 2012 21:16:53 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 1E60DC40006
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 21:16:47 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8T3GppW230034
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 21:16:51 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8T3Gn9f021048
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 21:16:51 -0600
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 2/3] [RFC] tmpfs: Add FALLOC_FL_MARK_VOLATILE/UNMARK_VOLATILE handlers
Date: Fri, 28 Sep 2012 23:16:32 -0400
Message-Id: <1348888593-23047-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
References: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This patch enables FALLOC_FL_MARK_VOLATILE/UNMARK_VOLATILE
functionality for tmpfs making use of the volatile range
management code.

Conceptually, FALLOC_FL_MARK_VOLATILE is like a delayed
FALLOC_FL_PUNCH_HOLE.  This allows applications that have
data caches that can be re-created to tell the kernel that
some memory contains data that is useful in the future, but
can be recreated if needed, so if the kernel needs, it can
zap the memory without having to swap it out.

In use, applications use FALLOC_FL_MARK_VOLATILE to mark
page ranges as volatile when they are not in use. Then later
if they wants to reuse the data, they use
FALLOC_FL_UNMARK_VOLATILE, which will return an error if the
data has been purged.

This is very much influenced by the Android Ashmem interface by
Robert Love so credits to him and the Android developers.
In many cases the code & logic come directly from the ashmem patch.
The intent of this patch is to allow for ashmem-like behavior, but
embeds the idea a little deeper into the VM code.

This is a reworked version of the fadvise volatile idea submitted
earlier to the list. Thanks to Dave Chinner for suggesting to
rework the idea in this fashion. Also thanks to Dmitry Adamushko
for continued review and bug reporting, and Dave Hansen for
help with the original design and mentoring me in the VM code.

v3:
* Fix off by one issue when truncating page ranges
* Use Dave Hansesn's suggestion to use shmem_writepage to trigger
  range purging instead of using a shrinker.

v4:
* Revert the shrinker removal, since writepage won't get called
  if we don't have swap.

v5:
* Cleanups

v7:
* Convert to byte ranges rather then page ranges to make userland's
  life easier.
* Add volatile_range_address_is_purged checking in shmem_fault to
  proivde SIGBUS on purged page access.

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
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 fs/open.c              |    3 +-
 include/linux/falloc.h |    7 +--
 mm/shmem.c             |  120 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 126 insertions(+), 4 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index e1f2cdb..6b8b983 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -225,7 +225,8 @@ int do_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
 		return -EINVAL;
 
 	/* Return error if mode is not supported */
-	if (mode & ~(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE))
+	if (mode & ~(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE |
+			FALLOC_FL_MARK_VOLATILE | FALLOC_FL_UNMARK_VOLATILE))
 		return -EOPNOTSUPP;
 
 	/* Punch hole must have keep size set */
diff --git a/include/linux/falloc.h b/include/linux/falloc.h
index 73e0b62..3e47ad5 100644
--- a/include/linux/falloc.h
+++ b/include/linux/falloc.h
@@ -1,9 +1,10 @@
 #ifndef _FALLOC_H_
 #define _FALLOC_H_
 
-#define FALLOC_FL_KEEP_SIZE	0x01 /* default is extend size */
-#define FALLOC_FL_PUNCH_HOLE	0x02 /* de-allocates range */
-
+#define FALLOC_FL_KEEP_SIZE		0x01 /* default is extend size */
+#define FALLOC_FL_PUNCH_HOLE		0x02 /* de-allocates range */
+#define FALLOC_FL_MARK_VOLATILE		0x04 /* mark range volatile */
+#define FALLOC_FL_UNMARK_VOLATILE	0x08 /* mark range non-volatile */
 #ifdef __KERNEL__
 
 /*
diff --git a/mm/shmem.c b/mm/shmem.c
index d4e184e..9403ffb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -64,6 +64,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/highmem.h>
 #include <linux/seq_file.h>
 #include <linux/magic.h>
+#include <linux/volatile.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -633,6 +634,100 @@ static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
 	return error;
 }
 
+static DEFINE_VOLATILE_FS_HEAD(shmem_volatile_head);
+
+static int shmem_mark_volatile(struct inode *inode, loff_t offset, loff_t len)
+{
+	u64 start, end;
+	int ret;
+
+	start = offset;
+	end = offset + len;
+
+	volatile_range_lock(&shmem_volatile_head);
+	ret = volatile_range_add(&shmem_volatile_head, &inode->i_data,
+								&start, &end);
+	if (ret > 0) { /* immdiately purge */
+		shmem_truncate_range(inode, (loff_t)start, (loff_t)end-1);
+		ret = 0;
+	}
+	volatile_range_unlock(&shmem_volatile_head);
+
+	return ret;
+}
+
+static int shmem_unmark_volatile(struct inode *inode, loff_t offset, loff_t len)
+{
+	u64 start, end;
+	int ret;
+
+	start = offset;
+	end = offset + len;
+
+	volatile_range_lock(&shmem_volatile_head);
+	ret = volatile_range_remove(&shmem_volatile_head, &inode->i_data,
+								start, end);
+	volatile_range_unlock(&shmem_volatile_head);
+
+	return ret;
+}
+
+static void shmem_clear_volatile(struct inode *inode)
+{
+	volatile_range_lock(&shmem_volatile_head);
+	volatile_range_clear(&shmem_volatile_head, &inode->i_data);
+	volatile_range_unlock(&shmem_volatile_head);
+}
+
+static
+int shmem_volatile_shrink(struct shrinker *ignored, struct shrink_control *sc)
+{
+	s64 nr_to_scan = sc->nr_to_scan;
+	const gfp_t gfp_mask = sc->gfp_mask;
+	struct address_space *mapping;
+	u64 start, end;
+	int ret;
+	s64 page_count;
+
+	if (nr_to_scan && !(gfp_mask & __GFP_FS))
+		return -1;
+
+	volatile_range_lock(&shmem_volatile_head);
+	page_count = volatile_range_lru_size(&shmem_volatile_head);
+	if (!nr_to_scan)
+		goto out;
+
+	do {
+		ret = volatile_ranges_pluck_lru(&shmem_volatile_head,
+							&mapping, &start, &end);
+		if (ret) {
+			shmem_truncate_range(mapping->host, (loff_t) start,
+								(loff_t) end-1);
+
+			nr_to_scan -= (end-start) >> PAGE_CACHE_SHIFT;
+			page_count -= (end-start) >> PAGE_CACHE_SHIFT;
+		};
+	} while (ret && (nr_to_scan > 0));
+
+out:
+	volatile_range_unlock(&shmem_volatile_head);
+
+	return page_count;
+}
+
+static struct shrinker shmem_volatile_shrinker = {
+	.shrink = shmem_volatile_shrink,
+	.seeks = DEFAULT_SEEKS,
+};
+
+static int __init shmem_shrinker_init(void)
+{
+	register_shrinker(&shmem_volatile_shrinker);
+	return 0;
+}
+arch_initcall(shmem_shrinker_init);
+
+
 static void shmem_evict_inode(struct inode *inode)
 {
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -1292,6 +1387,16 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	int error;
 	int ret = VM_FAULT_LOCKED;
 
+
+	volatile_range_lock(&shmem_volatile_head);
+	if (volatile_range_is_purged(inode->i_mapping,
+					(u64)vmf->pgoff << PAGE_CACHE_SHIFT)) {
+		volatile_range_unlock(&shmem_volatile_head);
+		return VM_FAULT_SIGBUS;
+	}
+	volatile_range_unlock(&shmem_volatile_head);
+
+
 	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
@@ -1732,6 +1837,14 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		/* No need to unmap again: hole-punching leaves COWed pages */
 		error = 0;
 		goto out;
+	} else if (mode & FALLOC_FL_MARK_VOLATILE) {
+		/* Mark pages volatile, sort of delayed hole punching */
+		error = shmem_mark_volatile(inode, offset, len);
+		goto out;
+	} else if (mode & FALLOC_FL_UNMARK_VOLATILE) {
+		/* Mark pages non-volatile, return error if pages were purged */
+		error = shmem_unmark_volatile(inode, offset, len);
+		goto out;
 	}
 
 	/* We need to check rlimit even when FALLOC_FL_KEEP_SIZE */
@@ -1810,6 +1923,12 @@ out:
 	return error;
 }
 
+static int shmem_release(struct inode *inode, struct file *file)
+{
+	shmem_clear_volatile(inode);
+	return 0;
+}
+
 static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	struct shmem_sb_info *sbinfo = SHMEM_SB(dentry->d_sb);
@@ -2721,6 +2840,7 @@ static const struct file_operations shmem_file_operations = {
 	.splice_read	= shmem_file_splice_read,
 	.splice_write	= generic_file_splice_write,
 	.fallocate	= shmem_fallocate,
+	.release	= shmem_release,
 #endif
 };
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
