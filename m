Message-Id: <20071227203402.850753712@sgi.com>
References: <20071227203253.297427289@sgi.com>
Date: Thu, 27 Dec 2007 12:33:03 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [10/17] FS: ExtX filesystem defrag
Content-Disposition: inline; filename=0056-FS-ExtX-filesystem-defrag.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

Support defragmentation for extX filesystem inodes

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/ext2/super.c |    9 +++++++++
 fs/ext3/super.c |    8 ++++++++
 fs/ext4/super.c |    8 ++++++++
 3 files changed, 25 insertions(+)

Index: linux-2.6.24-rc6-mm1/fs/ext2/super.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/ext2/super.c	2007-12-26 17:47:01.987405542 -0800
+++ linux-2.6.24-rc6-mm1/fs/ext2/super.c	2007-12-27 12:04:37.798315149 -0800
@@ -171,6 +171,12 @@ static void init_once(struct kmem_cache 
 	inode_init_once(&ei->vfs_inode);
 }
 
+static void *ext2_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+		offsetof(struct ext2_inode_info, vfs_inode));
+}
+
 static int init_inodecache(void)
 {
 	ext2_inode_cachep = kmem_cache_create("ext2_inode_cache",
@@ -180,6 +186,9 @@ static int init_inodecache(void)
 					     init_once);
 	if (ext2_inode_cachep == NULL)
 		return -ENOMEM;
+
+	kmem_cache_setup_defrag(ext2_inode_cachep,
+			ext2_get_inodes, kick_inodes);
 	return 0;
 }
 
Index: linux-2.6.24-rc6-mm1/fs/ext3/super.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/ext3/super.c	2007-12-26 17:47:01.995405564 -0800
+++ linux-2.6.24-rc6-mm1/fs/ext3/super.c	2007-12-27 12:04:37.802315408 -0800
@@ -484,6 +484,12 @@ static void init_once(struct kmem_cache 
 	inode_init_once(&ei->vfs_inode);
 }
 
+static void *ext3_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+		offsetof(struct ext3_inode_info, vfs_inode));
+}
+
 static int init_inodecache(void)
 {
 	ext3_inode_cachep = kmem_cache_create("ext3_inode_cache",
@@ -493,6 +499,8 @@ static int init_inodecache(void)
 					     init_once);
 	if (ext3_inode_cachep == NULL)
 		return -ENOMEM;
+	kmem_cache_setup_defrag(ext3_inode_cachep,
+			ext3_get_inodes, kick_inodes);
 	return 0;
 }
 
Index: linux-2.6.24-rc6-mm1/fs/ext4/super.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/ext4/super.c	2007-12-26 17:47:02.011405842 -0800
+++ linux-2.6.24-rc6-mm1/fs/ext4/super.c	2007-12-27 12:04:37.814315317 -0800
@@ -600,6 +600,12 @@ static void init_once(struct kmem_cache 
 	inode_init_once(&ei->vfs_inode);
 }
 
+static void *ext4_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+		offsetof(struct ext4_inode_info, vfs_inode));
+}
+
 static int init_inodecache(void)
 {
 	ext4_inode_cachep = kmem_cache_create("ext4_inode_cache",
@@ -609,6 +615,8 @@ static int init_inodecache(void)
 					     init_once);
 	if (ext4_inode_cachep == NULL)
 		return -ENOMEM;
+	kmem_cache_setup_defrag(ext4_inode_cachep,
+			ext4_get_inodes, kick_inodes);
 	return 0;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
