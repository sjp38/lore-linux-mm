Message-Id: <20071114221021.887190135@sgi.com>
References: <20071114220906.206294426@sgi.com>
Date: Wed, 14 Nov 2007 14:09:16 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 10/17] FS: ExtX filesystem defrag
Content-Disposition: inline; filename=0056-FS-ExtX-filesystem-defrag.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Support defragmentation for extX filesystem inodes

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/ext2/super.c |    9 +++++++++
 fs/ext3/super.c |    8 ++++++++
 fs/ext4/super.c |    8 ++++++++
 3 files changed, 25 insertions(+)

Index: linux-2.6.24-rc2-mm1/fs/ext2/super.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/fs/ext2/super.c	2007-11-14 11:08:36.224011551 -0800
+++ linux-2.6.24-rc2-mm1/fs/ext2/super.c	2007-11-14 12:19:30.425593698 -0800
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
 
Index: linux-2.6.24-rc2-mm1/fs/ext3/super.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/fs/ext3/super.c	2007-11-14 11:08:36.228011618 -0800
+++ linux-2.6.24-rc2-mm1/fs/ext3/super.c	2007-11-14 12:19:30.458593321 -0800
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
 
Index: linux-2.6.24-rc2-mm1/fs/ext4/super.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/fs/ext4/super.c	2007-11-14 11:08:36.252011333 -0800
+++ linux-2.6.24-rc2-mm1/fs/ext4/super.c	2007-11-14 12:19:30.485842935 -0800
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
