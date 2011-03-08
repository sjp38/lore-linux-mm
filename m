Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1984D8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 04:07:13 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [BUG?] shmem: memory leak on NO-MMU arch
Date: Tue, 8 Mar 2011 17:17:43 +0800
Message-ID: <1299575863-7069-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, hch@lst.de, hughd@google.com, npiggin@kernel.dk, tj@kernel.org, Bob Liu <lliubbo@gmail.com>

Hi, folks

I got a problem about shmem on NO-MMU arch, it seems memory leak
happened.

A simple test file is like this:
=========
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <errno.h>
#include <string.h>

int main(void)
{
	int i;
	key_t k = ftok("/etc", 42);

	for ( i=0; i<2; ++i) {
		int id = shmget(k, 10000, 0644|IPC_CREAT);
		if (id == -1) {
			printf("shmget error\n");
		}
		if(shmctl(id, IPC_RMID, NULL ) == -1) {
			printf("shm  rm error\n");
			return -1;
		}
	}
	printf("run ok...\n");
	return 0;
}

The test results:
root:/> free 
              total         used         free       shared      buffers
  Mem:        60528        13876        46652            0            0
root:/> ./shmem 
run ok...
root:/> free 
              total         used         free       shared      buffers
  Mem:        60528        15104        45424            0            0
root:/> ./shmem 
run ok...
root:/> free 
              total         used         free       shared      buffers
  Mem:        60528        16292        44236            0            0
root:/> ./shmem 
run ok...
root:/> free 
              total         used         free       shared      buffers
  Mem:        60528        17496        43032            0            0
root:/> ./shmem 
run ok...
root:/> free 
              total         used         free       shared      buffers
  Mem:        60528        18700        41828            0            0
root:/> ./shmem 
run ok...
root:/> free 
              total         used         free       shared      buffers
  Mem:        60528        19904        40624            0            0
root:/> ./shmem 
run ok...
root:/> free 
              total         used         free       shared      buffers
  Mem:        60528        21104        39424            0            0
root:/>

It seems the shmem didn't free it's memory after using shmctl(IPC_RMID) to rm
it.
=========

Patch below can work, but I know it's too simple and may cause other problems.
Any ideas is welcome.

Thanks!

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index 9eead2c..831e6d5 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -59,6 +59,8 @@ const struct inode_operations ramfs_file_inode_operations = {
  * size 0 on the assumption that it's going to be used for an mmap of shared
  * memory
  */
+struct page *ramfs_pages;
+unsigned long ramfs_nr_pages;
 int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
 {
 	unsigned long npages, xpages, loop;
@@ -114,6 +116,8 @@ int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
 		unlock_page(page);
 	}
 
+	ramfs_pages = pages;
+	ramfs_nr_pages = loop;
 	return 0;
 
 add_error:
diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
index eacb166..2eb33e5 100644
--- a/fs/ramfs/inode.c
+++ b/fs/ramfs/inode.c
@@ -139,6 +139,23 @@ static int ramfs_symlink(struct inode * dir, struct dentry *dentry, const char *
 	return error;
 }
 
+static void ramfs_delete_inode(struct inode *inode)
+{
+	int loop;
+	struct page *page;
+
+	truncate_inode_pages(&inode->i_data, 0);
+	clear_inode(inode);
+
+	for (loop = 0; loop < ramfs_nr_pages; loop++ ){
+		page = ramfs_pages[loop];
+		page->flags &= ~PAGE_FLAGS_CHECK_AT_FREE;
+		if(page)
+			__free_pages(page, 0);
+	}
+	kfree(ramfs_pages);
+}
+
 static const struct inode_operations ramfs_dir_inode_operations = {
 	.create		= ramfs_create,
 	.lookup		= simple_lookup,
@@ -153,6 +170,7 @@ static const struct inode_operations ramfs_dir_inode_operations = {
 
 static const struct super_operations ramfs_ops = {
 	.statfs		= simple_statfs,
+	.delete_inode   = ramfs_delete_inode,
 	.drop_inode	= generic_delete_inode,
 	.show_options	= generic_show_options,
 };
diff --git a/fs/ramfs/internal.h b/fs/ramfs/internal.h
index 6b33063..0b7b222 100644
--- a/fs/ramfs/internal.h
+++ b/fs/ramfs/internal.h
@@ -12,3 +12,5 @@
 
 extern const struct address_space_operations ramfs_aops;
 extern const struct inode_operations ramfs_file_inode_operations;
+extern struct page *ramfs_pages;
+extern unsigned long ramfs_nr_pages;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
