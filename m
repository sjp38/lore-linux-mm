From: clameter@sgi.com
Subject: [patch 05/10] reiserfs: inode defragmentation support
Date: Fri, 18 May 2007 11:10:45 -0700
Message-ID: <20070518181119.764521535@sgi.com>
References: <20070518181040.465335396@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763434AbXERSMh@vger.kernel.org>
Content-Disposition: inline; filename=fs_reiser
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

Add inode defrag support

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/reiserfs/super.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

Index: slub/fs/reiserfs/super.c
===================================================================
--- slub.orig/fs/reiserfs/super.c	2007-05-18 00:54:30.000000000 -0700
+++ slub/fs/reiserfs/super.c	2007-05-18 00:57:12.000000000 -0700
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
