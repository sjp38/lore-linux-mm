Message-Id: <20070618095917.943779191@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:58:57 -0700
From: clameter@sgi.com
Subject: [patch 19/26] Slab defragmentation: Support reiserfs inode defragmentation
Content-Disposition: inline; filename=slub_defrag_fs_reiser
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

Add inode defrag support

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/reiserfs/super.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

Index: slub/fs/reiserfs/super.c
===================================================================
--- slub.orig/fs/reiserfs/super.c	2007-06-07 14:09:36.000000000 -0700
+++ slub/fs/reiserfs/super.c	2007-06-07 14:30:49.000000000 -0700
@@ -520,6 +520,17 @@ static void init_once(void *foo, struct 
 #endif
 }
 
+static void *reiserfs_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+			offsetof(struct reiserfs_inode_info, vfs_inode));
+}
+
+struct kmem_cache_ops reiserfs_kmem_cache_ops = {
+	.get = reiserfs_get_inodes,
+	.kick = kick_inodes
+};
+
 static int init_inodecache(void)
 {
 	reiserfs_inode_cachep = kmem_cache_create("reiser_inode_cache",
@@ -527,7 +538,8 @@ static int init_inodecache(void)
 							 reiserfs_inode_info),
 						  0, (SLAB_RECLAIM_ACCOUNT|
 							SLAB_MEM_SPREAD),
-						  init_once, NULL);
+						  init_once,
+						  &reiserfs_kmem_cache_ops);
 	if (reiserfs_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
