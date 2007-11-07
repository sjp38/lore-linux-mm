From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 15/23] FS: ExtX filesystem defrag
Date: Tue, 06 Nov 2007 17:11:45 -0800
Message-ID: <20071107011230.155752215@sgi.com>
References: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758038AbXKGBRx@vger.kernel.org>
Content-Disposition: inline; filename=0018-slab_defrag_ext234.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Support defragmentation for extX filesystem inodes

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/ext2/super.c |    9 +++++++++
 fs/ext3/super.c |    8 ++++++++
 fs/ext4/super.c |    8 ++++++++
 3 files changed, 25 insertions(+)

Index: linux-2.6/fs/ext2/super.c
===================================================================
--- linux-2.6.orig/fs/ext2/super.c	2007-10-25 18:28:40.000000000 -0700
+++ linux-2.6/fs/ext2/super.c	2007-11-06 12:56:18.000000000 -0800
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
 
Index: linux-2.6/fs/ext3/super.c
===================================================================
--- linux-2.6.orig/fs/ext3/super.c	2007-10-25 18:28:40.000000000 -0700
+++ linux-2.6/fs/ext3/super.c	2007-11-06 12:56:18.000000000 -0800
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
 
Index: linux-2.6/fs/ext4/super.c
===================================================================
--- linux-2.6.orig/fs/ext4/super.c	2007-10-25 18:28:40.000000000 -0700
+++ linux-2.6/fs/ext4/super.c	2007-11-06 12:56:18.000000000 -0800
@@ -537,6 +537,12 @@ static void init_once(struct kmem_cache 
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
@@ -546,6 +552,8 @@ static int init_inodecache(void)
 					     init_once);
 	if (ext4_inode_cachep == NULL)
 		return -ENOMEM;
+	kmem_cache_setup_defrag(ext4_inode_cachep,
+			ext4_get_inodes, kick_inodes);
 	return 0;
 }
 

-- 
