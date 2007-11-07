From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 18/23] FS: Slab defrag: Reiserfs support
Date: Tue, 06 Nov 2007 17:11:48 -0800
Message-ID: <20071107011230.954605776@sgi.com>
References: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757418AbXKGBST@vger.kernel.org>
Content-Disposition: inline; filename=0021-slab_defrag_reiserfs.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Slab defragmentation: Support reiserfs inode defragmentation

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/reiserfs/super.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux-2.6.23-mm1/fs/reiserfs/super.c
===================================================================
--- linux-2.6.23-mm1.orig/fs/reiserfs/super.c	2007-10-12 16:26:09.000000000 -0700
+++ linux-2.6.23-mm1/fs/reiserfs/super.c	2007-10-12 18:48:36.000000000 -0700
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
