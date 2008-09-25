Date: Thu, 25 Sep 2008 02:06:48 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: tiny-shmem nommu fix
Message-ID: <20080925000648.GA23494@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, David Howells <dhowells@redhat.com>, Matt Mackall <mpm@selenic.com>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The previous patch db203d53d474aa068984e409d807628f5841da1b to fix the LOR in
tiny-shmem breaks shared anonymous and IPC memory on NOMMU architectures
because it was using the expanding truncate to signal ramfs to allocate a
physically contiguous RAM backing the inode (otherwise it is unusable for
"memory mapping" it to userspace).

However do_truncate is what caused the LOR, due to it taking i_mutex. In
this case, we can actually just call ramfs directly to allocate memory for
the mapping, rather than go via truncate.

Acked-by: David Howells <dhowells@redhat.com>
Acked-by: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---

Index: linux-2.6/include/linux/ramfs.h
===================================================================
--- linux-2.6.orig/include/linux/ramfs.h
+++ linux-2.6/include/linux/ramfs.h
@@ -6,6 +6,7 @@ extern int ramfs_get_sb(struct file_syst
 	 int flags, const char *dev_name, void *data, struct vfsmount *mnt);
 
 #ifndef CONFIG_MMU
+extern int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize);
 extern unsigned long ramfs_nommu_get_unmapped_area(struct file *file,
 						   unsigned long addr,
 						   unsigned long len,
Index: linux-2.6/mm/tiny-shmem.c
===================================================================
--- linux-2.6.orig/mm/tiny-shmem.c
+++ linux-2.6/mm/tiny-shmem.c
@@ -80,6 +80,12 @@ struct file *shmem_file_setup(char *name
         inode->i_nlink = 0;     /* It is unlinked */
         init_file(file, shm_mnt, dentry, FMODE_WRITE | FMODE_READ,
                         &ramfs_file_operations);
+
+#ifndef CONFIG_MMU
+	error = ramfs_nommu_expand_for_mapping(inode, size);
+	if (error)
+		goto close_file;
+#endif
 	return file;
 
 close_file:
Index: linux-2.6/fs/ramfs/file-nommu.c
===================================================================
--- linux-2.6.orig/fs/ramfs/file-nommu.c
+++ linux-2.6/fs/ramfs/file-nommu.c
@@ -58,7 +58,7 @@ const struct inode_operations ramfs_file
  * size 0 on the assumption that it's going to be used for an mmap of shared
  * memory
  */
-static int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
+int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
 {
 	struct pagevec lru_pvec;
 	unsigned long npages, xpages, loop, limit;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
