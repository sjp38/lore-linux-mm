Message-Id: <20071114221022.355777425@sgi.com>
References: <20071114220906.206294426@sgi.com>
Date: Wed, 14 Nov 2007 14:09:18 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 12/17] FS: Proc filesystem support for slab defrag
Content-Disposition: inline; filename=0058-FS-Proc-filesystem-support-for-slab-defrag.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Support procfs inode defragmentation

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/proc/inode.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux-2.6.24-rc2-mm1/fs/proc/inode.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/fs/proc/inode.c	2007-11-14 11:08:37.264011681 -0800
+++ linux-2.6.24-rc2-mm1/fs/proc/inode.c	2007-11-14 12:19:50.457593499 -0800
@@ -109,6 +109,12 @@ static void init_once(struct kmem_cache 
 	inode_init_once(&ei->vfs_inode);
 }
 
+static void *proc_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+		offsetof(struct proc_inode, vfs_inode));
+};
+
 int __init proc_init_inodecache(void)
 {
 	proc_inode_cachep = kmem_cache_create("proc_inode_cache",
@@ -116,6 +122,8 @@ int __init proc_init_inodecache(void)
 					     0, (SLAB_RECLAIM_ACCOUNT|
 						SLAB_MEM_SPREAD|SLAB_PANIC),
 					     init_once);
+	kmem_cache_setup_defrag(proc_inode_cachep,
+				proc_get_inodes, kick_inodes);
 	return 0;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
