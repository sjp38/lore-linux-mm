Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 09C086B006C
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 16:28:43 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id bg2so3072736pad.32
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 13:28:43 -0800 (PST)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH v2 2/3] mm: Update file times when inodes are written after mmaped writes
Date: Fri, 21 Dec 2012 13:28:27 -0800
Message-Id: <6b22b806806b21af02b70a2fa860a9d10304fc16.1356124965.git.luto@amacapital.net>
In-Reply-To: <cover.1356124965.git.luto@amacapital.net>
References: <cover.1356124965.git.luto@amacapital.net>
In-Reply-To: <cover.1356124965.git.luto@amacapital.net>
References: <cover.1356124965.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@amacapital.net>

The onus is currently on filesystems to call file_update_time
somewhere in the page_mkwrite path.  This is unfortunate for three
reasons:

1. page_mkwrite on a locked page should be fast.  ext4, for example,
   often sleeps while dirtying inodes.  (This could be considered a
   fixable problem with ext4, but this approach makes it
   irrelevant.)

2. The current behavior is surprising -- the timestamp resulting
   from an mmaped write will be before the write, not after.  This
   contradicts POSIX, which says:

      The st_ctime and st_mtime fields of a file that is mapped with
      MAP_SHARED and PROT_WRITE, will be marked for update at some
      point in the interval between a write reference to the mapped
      region and the next call to msync() with MS_ASYNC or MS_SYNC
      for that portion of the file by any process. If there is no
      such call, these fields may be marked for update at any time
      after a write reference if the underlying file is modified as
      a result.

   We currently get this wrong:

    addr = mmap(..., PROT_WRITE, MAP_SHARED, fd, 0);
    *addr = 0;  <-- mtime is updated here
    sleep(5);
    *addr = 1;  <-- this write will never trigger an mtime update
    msync(fd, MS_SYNC);

   For now, MS_ASYNC still doesn't trigger an mtime update because
   it doesn't do anything at all.  This would be easy enough to fix.

   POSIX (oddly IMO) does not require that munmap(2), fsync(2), or
   _exit(2) cause mtime writes, but this patch is careful to do that
   as well.  According to Jan Kara, people have complained about
   ld(1) writing its output via mmap and the timestamp magically
   changing well after ld is done.

3. (An ulterior motive) I'd like to use hardware dirty tracking for
   shared, locked, writable mappings (instead of page faults).
   Moving important work out of the page_mkwrite path is an
   important first step.

This patch moves the time update into the core pagecache code.  When
a pte dirty bit is transferred to struct page, a new address_space
flag AS_CMTIME is atomically set on the mapping.  (This happens
during writeback and when ptes are unmapped.)  Subsequently (after
an inode is written back or when a vma is removed), the AS_CMTIME
bit is checked, and, if set, the inode's time is updated.

The next patch will remove the now-unnecessary file_update_time
calls in ->page_mkwrite.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 fs/inode.c              | 72 ++++++++++++++++++++++++++++++++++++++-----------
 include/linux/fs.h      |  1 +
 include/linux/pagemap.h |  3 +++
 mm/memory.c             |  2 +-
 mm/mmap.c               |  4 +++
 mm/page-writeback.c     | 30 +++++++++++++++++++--
 6 files changed, 94 insertions(+), 18 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 64999f1..1d2e303 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1640,6 +1640,34 @@ int file_remove_suid(struct file *file)
 }
 EXPORT_SYMBOL(file_remove_suid);
 
+/*
+ * This does the work that's common to file_update_time and
+ * inode_update_time.
+ */
+static int prepare_update_cmtime(struct inode *inode, struct timespec *now)
+{
+	int sync_it;
+
+	/* First try to exhaust all avenues to not sync */
+	if (IS_NOCMTIME(inode))
+		return 0;
+
+	*now = current_fs_time(inode->i_sb);
+	if (!timespec_equal(&inode->i_mtime, now))
+		sync_it = S_MTIME;
+
+	if (!timespec_equal(&inode->i_ctime, now))
+		sync_it |= S_CTIME;
+
+	if (IS_I_VERSION(inode))
+		sync_it |= S_VERSION;
+
+	if (!sync_it)
+		return 0;
+
+	return sync_it;
+}
+
 /**
  *	file_update_time	-	update mtime and ctime time
  *	@file: file accessed
@@ -1657,23 +1685,9 @@ int file_update_time(struct file *file)
 {
 	struct inode *inode = file->f_path.dentry->d_inode;
 	struct timespec now;
-	int sync_it = 0;
+	int sync_it = prepare_update_cmtime(inode, &now);
 	int ret;
 
-	/* First try to exhaust all avenues to not sync */
-	if (IS_NOCMTIME(inode))
-		return 0;
-
-	now = current_fs_time(inode->i_sb);
-	if (!timespec_equal(&inode->i_mtime, &now))
-		sync_it = S_MTIME;
-
-	if (!timespec_equal(&inode->i_ctime, &now))
-		sync_it |= S_CTIME;
-
-	if (IS_I_VERSION(inode))
-		sync_it |= S_VERSION;
-
 	if (!sync_it)
 		return 0;
 
@@ -1688,6 +1702,34 @@ int file_update_time(struct file *file)
 }
 EXPORT_SYMBOL(file_update_time);
 
+/**
+ *	inode_update_time_writable	-	update mtime and ctime time
+ *	@inode: inode accessed
+ *
+ *	This is like file_update_time, but it assumes the mnt is writable
+ *	and takes an inode parameter instead.  (We need to assume the mnt
+ *	was writable because inodes aren't associated with any particular
+ *	mnt.
+ */
+
+int inode_update_time_writable(struct inode *inode)
+{
+	struct timespec now;
+	int sync_it = prepare_update_cmtime(inode, &now);
+	int ret;
+
+	if (!sync_it)
+		return 0;
+
+	/* sb_start_pagefault and update_time can both sleep. */
+	sb_start_pagefault(inode->i_sb);
+	ret = update_time(inode, &now, sync_it);
+	sb_end_pagefault(inode->i_sb);
+
+	return ret;
+}
+EXPORT_SYMBOL(inode_update_time_writable);
+
 int inode_needs_sync(struct inode *inode)
 {
 	if (IS_SYNC(inode))
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 75fe9a1..c95f9fa 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2554,6 +2554,7 @@ extern int inode_newsize_ok(const struct inode *, loff_t offset);
 extern void setattr_copy(struct inode *inode, const struct iattr *attr);
 
 extern int file_update_time(struct file *file);
+extern int inode_update_time_writable(struct inode *inode);
 
 extern int generic_show_options(struct seq_file *m, struct dentry *root);
 extern void save_mount_options(struct super_block *sb, char *options);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e42c762..a038ed9 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -24,6 +24,7 @@ enum mapping_flags {
 	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
+	AS_CMTIME	= __GFP_BITS_SHIFT + 4, /* written via pte */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -68,6 +69,8 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
 				(__force unsigned long)mask;
 }
 
+extern void mapping_flush_cmtime(struct address_space *mapping);
+
 /*
  * The page cache can done in larger chunks than
  * one page, because it allows for more efficient
diff --git a/mm/memory.c b/mm/memory.c
index 221fc9f..086b901 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1160,7 +1160,7 @@ again:
 				rss[MM_ANONPAGES]--;
 			else {
 				if (pte_dirty(ptent))
-					set_page_dirty(page);
+					set_page_dirty_from_pte(page);
 				if (pte_young(ptent) &&
 				    likely(!VM_SequentialReadHint(vma)))
 					mark_page_accessed(page);
diff --git a/mm/mmap.c b/mm/mmap.c
index 3913262..60301dc 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -223,6 +223,10 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	struct vm_area_struct *next = vma->vm_next;
 
 	might_sleep();
+
+	if (vma->vm_file)
+		mapping_flush_cmtime(vma->vm_file->f_mapping);
+
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index cdea11a..9f5d50f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1910,6 +1910,13 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
 		ret = mapping->a_ops->writepages(mapping, wbc);
 	else
 		ret = generic_writepages(mapping, wbc);
+
+	/*
+	 * This is after writepages because the AS_CMTIME bit won't
+	 * bet set until writepages is called.
+	 */
+	mapping_flush_cmtime(mapping);
+
 	return ret;
 }
 
@@ -2117,8 +2124,17 @@ EXPORT_SYMBOL(set_page_dirty);
  */
 int set_page_dirty_from_pte(struct page *page)
 {
-	/* Doesn't do anything interesting yet. */
-	return set_page_dirty(page);
+	int ret = set_page_dirty(page);
+	struct address_space *mapping = page_mapping(page);
+
+	/*
+	 * We may be out of memory and/or have various locks held, so
+	 * there isn't much we can do in here.
+	 */
+	if (mapping)
+		set_bit(AS_CMTIME, &mapping->flags);
+
+	return ret;
 }
 
 /*
@@ -2287,3 +2303,13 @@ int mapping_tagged(struct address_space *mapping, int tag)
 	return radix_tree_tagged(&mapping->page_tree, tag);
 }
 EXPORT_SYMBOL(mapping_tagged);
+
+/*
+ * Call from any context from which inode_update_time_writable would be okay
+ * to flush deferred cmtime changes.
+ */
+void mapping_flush_cmtime(struct address_space *mapping)
+{
+	if (test_and_clear_bit(AS_CMTIME, &mapping->flags))
+		inode_update_time_writable(mapping->host);
+}
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
