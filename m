Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44A6B6B0558
	for <linux-mm@kvack.org>; Wed,  9 May 2018 13:33:49 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id b202so26932739qkc.6
        for <linux-mm@kvack.org>; Wed, 09 May 2018 10:33:49 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u17-v6si26864868qvk.226.2018.05.09.10.33.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 10:33:44 -0700 (PDT)
Date: Wed, 9 May 2018 10:33:19 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: [PATCH v4] iomap: add a swapfile activation function
Message-ID: <20180509173319.GE9510@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@infradead.org
Cc: xfs <linux-xfs@vger.kernel.org>, Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, cyberax@amazon.com, osandov@osandov.com, Eryu Guan <guaneryu@gmail.com>

From: Darrick J. Wong <darrick.wong@oracle.com>

Add a new iomap_swapfile_activate function so that filesystems can
activate swap files without having to use the obsolete and slow bmap
function.  This enables XFS to support fallocate'd swap files and
swap files on realtime devices.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/iomap.c            |  162 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/xfs/xfs_aops.c     |   12 ++++
 include/linux/iomap.h |   11 +++
 3 files changed, 185 insertions(+)

diff --git a/fs/iomap.c b/fs/iomap.c
index afd163586aa0..99e7f1aa2779 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -27,6 +27,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/dax.h>
 #include <linux/sched/signal.h>
+#include <linux/swap.h>
 
 #include "internal.h"
 
@@ -1089,3 +1090,164 @@ iomap_dio_rw(struct kiocb *iocb, struct iov_iter *iter,
 	return ret;
 }
 EXPORT_SYMBOL_GPL(iomap_dio_rw);
+
+/* Swapfile activation */
+
+#ifdef CONFIG_SWAP
+struct iomap_swapfile_info {
+	struct iomap iomap;		/* accumulated iomap */
+	struct swap_info_struct *sis;
+	uint64_t lowest_ppage;		/* lowest physical addr seen (pages) */
+	uint64_t highest_ppage;		/* highest physical addr seen (pages) */
+	unsigned long nr_pages;		/* number of pages collected */
+	int nr_extents;			/* extent count */
+};
+
+/*
+ * Collect physical extents for this swap file.  Physical extents reported to
+ * the swap code must be trimmed to align to a page boundary.  The logical
+ * offset within the file is irrelevant since the swapfile code maps logical
+ * page numbers of the swap device to the physical page-aligned extents.
+ */
+static int iomap_swapfile_add_extent(struct iomap_swapfile_info *isi)
+{
+	struct iomap *iomap = &isi->iomap;
+	unsigned long nr_pages;
+	uint64_t first_ppage;
+	uint64_t first_ppage_reported;
+	uint64_t next_ppage;
+	int error;
+
+	/*
+	 * Round the start up and the end down so that the physical
+	 * extent aligns to a page boundary.
+	 */
+	first_ppage = ALIGN(iomap->addr, PAGE_SIZE) >> PAGE_SHIFT;
+	next_ppage = ALIGN_DOWN(iomap->addr + iomap->length, PAGE_SIZE) >>
+			PAGE_SHIFT;
+
+	/* Skip too-short physical extents. */
+	if (first_ppage >= next_ppage)
+		return 0;
+	nr_pages = next_ppage - first_ppage;
+
+	/*
+	 * Calculate how much swap space we're adding; the first page contains
+	 * the swap header and doesn't count.  The mm still wants that first
+	 * page fed to add_swap_extent, however.
+	 */
+	first_ppage_reported = first_ppage;
+	if (iomap->offset == 0)
+		first_ppage_reported++;
+	if (isi->lowest_ppage > first_ppage_reported)
+		isi->lowest_ppage = first_ppage_reported;
+	if (isi->highest_ppage < (next_ppage - 1))
+		isi->highest_ppage = next_ppage - 1;
+
+	/* Add extent, set up for the next call. */
+	error = add_swap_extent(isi->sis, isi->nr_pages, nr_pages, first_ppage);
+	if (error < 0)
+		return error;
+	isi->nr_extents += error;
+	isi->nr_pages += nr_pages;
+	return 0;
+}
+
+/*
+ * Accumulate iomaps for this swap file.  We have to accumulate iomaps because
+ * swap only cares about contiguous page-aligned physical extents and makes no
+ * distinction between written and unwritten extents.
+ */
+static loff_t iomap_swapfile_activate_actor(struct inode *inode, loff_t pos,
+		loff_t count, void *data, struct iomap *iomap)
+{
+	struct iomap_swapfile_info *isi = data;
+	int error;
+
+	/* Skip holes. */
+	if (iomap->type == IOMAP_HOLE)
+		goto out;
+
+	/* Only one bdev per swap file. */
+	if (iomap->bdev != isi->sis->bdev)
+		goto err;
+
+	/* Only real or unwritten extents. */
+	if (iomap->type != IOMAP_MAPPED && iomap->type != IOMAP_UNWRITTEN)
+		goto err;
+
+	/* No uncommitted metadata or shared blocks or inline data. */
+	if (iomap->flags & (IOMAP_F_DIRTY | IOMAP_F_SHARED |
+			    IOMAP_F_DATA_INLINE))
+		goto err;
+
+	/* No null physical addresses. */
+	if (iomap->addr == IOMAP_NULL_ADDR)
+		goto err;
+
+	if (isi->iomap.length == 0) {
+		/* No accumulated extent, so just store it. */
+		memcpy(&isi->iomap, iomap, sizeof(isi->iomap));
+	} else if (isi->iomap.addr + isi->iomap.length == iomap->addr) {
+		/* Append this to the accumulated extent. */
+		isi->iomap.length += iomap->length;
+	} else {
+		/* Otherwise, add the retained iomap and store this one. */
+		error = iomap_swapfile_add_extent(isi);
+		if (error)
+			return error;
+		memcpy(&isi->iomap, iomap, sizeof(isi->iomap));
+	}
+out:
+	return count;
+err:
+	pr_err("swapon: file cannot be used for swap\n");
+	return -EINVAL;
+}
+
+/*
+ * Iterate a swap file's iomaps to construct physical extents that can be
+ * passed to the swapfile subsystem.
+ */
+int iomap_swapfile_activate(struct swap_info_struct *sis,
+		struct file *swap_file, sector_t *pagespan,
+		const struct iomap_ops *ops)
+{
+	struct iomap_swapfile_info isi = {
+		.sis = sis,
+		.lowest_ppage = (sector_t)-1ULL,
+	};
+	struct address_space *mapping = swap_file->f_mapping;
+	struct inode *inode = mapping->host;
+	loff_t pos = 0;
+	loff_t len = ALIGN_DOWN(i_size_read(inode), PAGE_SIZE);
+	loff_t ret;
+
+	ret = filemap_write_and_wait(inode->i_mapping);
+	if (ret)
+		return ret;
+
+	while (len > 0) {
+		ret = iomap_apply(inode, pos, len, IOMAP_REPORT,
+				ops, &isi, iomap_swapfile_activate_actor);
+		if (ret <= 0)
+			return ret;
+
+		pos += ret;
+		len -= ret;
+	}
+
+	if (isi.iomap.length) {
+		ret = iomap_swapfile_add_extent(&isi);
+		if (ret)
+			return ret;
+	}
+
+	*pagespan = 1 + isi.highest_ppage - isi.lowest_ppage;
+	sis->max = isi.nr_pages;
+	sis->pages = isi.nr_pages - 1;
+	sis->highest_bit = isi.nr_pages - 1;
+	return isi.nr_extents;
+}
+EXPORT_SYMBOL_GPL(iomap_swapfile_activate);
+#endif /* CONFIG_SWAP */
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 0ab824f574ed..80de476cecf8 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1475,6 +1475,16 @@ xfs_vm_set_page_dirty(
 	return newly_dirty;
 }
 
+static int
+xfs_iomap_swapfile_activate(
+	struct swap_info_struct		*sis,
+	struct file			*swap_file,
+	sector_t			*span)
+{
+	sis->bdev = xfs_find_bdev_for_inode(file_inode(swap_file));
+	return iomap_swapfile_activate(sis, swap_file, span, &xfs_iomap_ops);
+}
+
 const struct address_space_operations xfs_address_space_operations = {
 	.readpage		= xfs_vm_readpage,
 	.readpages		= xfs_vm_readpages,
@@ -1488,6 +1498,7 @@ const struct address_space_operations xfs_address_space_operations = {
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
 	.error_remove_page	= generic_error_remove_page,
+	.swap_activate		= xfs_iomap_swapfile_activate,
 };
 
 const struct address_space_operations xfs_dax_aops = {
@@ -1495,4 +1506,5 @@ const struct address_space_operations xfs_dax_aops = {
 	.direct_IO		= noop_direct_IO,
 	.set_page_dirty		= noop_set_page_dirty,
 	.invalidatepage		= noop_invalidatepage,
+	.swap_activate		= xfs_iomap_swapfile_activate,
 };
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index 19a07de28212..4bd87294219a 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -106,4 +106,15 @@ typedef int (iomap_dio_end_io_t)(struct kiocb *iocb, ssize_t ret,
 ssize_t iomap_dio_rw(struct kiocb *iocb, struct iov_iter *iter,
 		const struct iomap_ops *ops, iomap_dio_end_io_t end_io);
 
+#ifdef CONFIG_SWAP
+struct file;
+struct swap_info_struct;
+
+int iomap_swapfile_activate(struct swap_info_struct *sis,
+		struct file *swap_file, sector_t *pagespan,
+		const struct iomap_ops *ops);
+#else
+# define iomap_swapfile_activate(sis, swapfile, pagespan, ops)	(-EIO)
+#endif /* CONFIG_SWAP */
+
 #endif /* LINUX_IOMAP_H */
