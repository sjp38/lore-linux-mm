Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 666CE6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 09:47:45 -0400 (EDT)
Received: by wgra20 with SMTP id a20so28058610wgr.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:47:44 -0700 (PDT)
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id e5si4472339wjw.70.2015.03.25.06.47.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 06:47:43 -0700 (PDT)
Received: by wgbcc7 with SMTP id cc7so28093609wgb.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:47:43 -0700 (PDT)
Message-ID: <5512BC7C.7060709@plexistor.com>
Date: Wed, 25 Mar 2015 15:47:40 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [FIXME] NOT-GOOD: dax: dax_prepare_freeze
References: <5512B961.8070409@plexistor.com>
In-Reply-To: <5512B961.8070409@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>


This is just for reference!

When freezing an FS, we must write protect all IS_DAX()
inodes that have an mmap mapping on an inode. Otherwise
application will be able to modify previously faulted-in
file pages.

I'm actually doing a full unmap_mapping_range because
there is no readily available "mapping_write_protect" like
functionality. I do not think it is worth it to define one
just for here and just for some extra read-faults after an
fs_freeze.

How hot-path is fs_freeze at all?

FIXME: As pointed out by Dave this is completely the wrong
       fix because we need to first fsync all cache dirty
       inodes, and only for those write protect. So maybe
       plug this in the regular sb_sync path, checking the
       FREEZE flag.

CC: Dave Chinner <dchinner@redhat.com>
CC: Jan Kara <jack@suse.cz>
CC: Matthew Wilcox <matthew.r.wilcox@intel.com>
NOT-Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 fs/dax.c           | 29 +++++++++++++++++++++++++++++
 fs/super.c         |  3 +++
 include/linux/fs.h |  5 +++++
 3 files changed, 37 insertions(+)

diff --git a/fs/dax.c b/fs/dax.c
index d0bd1f4..ec99d1c 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -26,6 +26,7 @@
 #include <linux/sched.h>
 #include <linux/uio.h>
 #include <linux/vmstat.h>
+#include "internal.h"
 
 int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 {
@@ -549,3 +550,31 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 	return dax_zero_page_range(inode, from, length, get_block);
 }
 EXPORT_SYMBOL_GPL(dax_truncate_page);
+
+/* This is meant to be called as part of freeze_super. otherwise we might
+ * Need some extra locking before calling here.
+ */
+void dax_prepare_freeze(struct super_block *sb)
+{
+	struct inode *inode;
+
+	if (!(sb->s_bdev && sb->s_bdev->bd_disk->fops->direct_access))
+		return;
+
+	spin_lock(&inode_sb_list_lock);
+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
+		/* TODO: For freezing we can actually do with write-protecting
+		 * the page. But I cannot find a ready made function that does
+		 * that for a giving mapping (with all the proper locking).
+		 * How performance sensitive is the all sb_freeze API?
+		 * For now we can just unmap the all mapping, and pay extra
+		 * on read faults.
+		 */
+		/* NOTE: Do not unmap private COW mapped pages it will not
+		 * modify the FS.
+		 */
+		if (IS_DAX(inode))
+			unmap_mapping_range(inode->i_mapping, 0, 0, 0);
+	}
+	spin_unlock(&inode_sb_list_lock);
+}
diff --git a/fs/super.c b/fs/super.c
index 2b7dc90..9ef490c 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -1329,6 +1329,9 @@ int freeze_super(struct super_block *sb)
 	/* All writers are done so after syncing there won't be dirty data */
 	sync_filesystem(sb);
 
+	/* Need to take care of DAX mmaped inodes */
+	dax_prepare_freeze(sb);
+
 	/* Now wait for internal filesystem counter */
 	sb->s_writers.frozen = SB_FREEZE_FS;
 	smp_wmb();
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 24af817..ac48ba6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2599,6 +2599,11 @@ int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
 int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
 #define dax_mkwrite(vma, vmf, gb)	dax_fault(vma, vmf, gb)
+#ifdef CONFIG_FS_DAX
+void dax_prepare_freeze(struct super_block *sb);
+#else /* !CONFIG_FS_DAX */
+static inline void dax_prepare_freeze(struct super_block *sb){}
+#endif /* !CONFIG_FS_DAX */
 
 #ifdef CONFIG_BLOCK
 typedef void (dio_submit_t)(int rw, struct bio *bio, struct inode *inode,
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
