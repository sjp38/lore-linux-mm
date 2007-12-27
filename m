Message-Id: <20071227203404.128867608@sgi.com>
References: <20071227203253.297427289@sgi.com>
Date: Thu, 27 Dec 2007 12:33:06 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [13/17] FS: Slab defrag: Reiserfs support
Content-Disposition: inline; filename=0059-FS-Slab-defrag-Reiserfs-support.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

Slab defragmentation: Support reiserfs inode defragmentation

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/reiserfs/super.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux-2.6.24-rc6-mm1/fs/reiserfs/super.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/reiserfs/super.c	2007-12-26 17:47:05.407423958 -0800
+++ linux-2.6.24-rc6-mm1/fs/reiserfs/super.c	2007-12-27 12:04:46.718354502 -0800
@@ -532,6 +532,12 @@ static void init_once(struct kmem_cache 
 #endif
 }
 
+static void *reiserfs_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+		offsetof(struct reiserfs_inode_info, vfs_inode));
+}
+
 static int init_inodecache(void)
 {
 	reiserfs_inode_cachep = kmem_cache_create("reiser_inode_cache",
@@ -542,6 +548,8 @@ static int init_inodecache(void)
 						  init_once);
 	if (reiserfs_inode_cachep == NULL)
 		return -ENOMEM;
+	kmem_cache_setup_defrag(reiserfs_inode_cachep,
+			reiserfs_get_inodes, kick_inodes);
 	return 0;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
