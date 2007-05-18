From: clameter@sgi.com
Subject: [patch 07/10] procfs: inode defragmentation support
Date: Fri, 18 May 2007 11:10:47 -0700
Message-ID: <20070518181120.266687200@sgi.com>
References: <20070518181040.465335396@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763741AbXERSNR@vger.kernel.org>
Content-Disposition: inline; filename=fs_proc
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

Hmmm... Do we really need this?

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/proc/inode.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

Index: slub/fs/proc/inode.c
===================================================================
--- slub.orig/fs/proc/inode.c	2007-05-18 00:54:30.000000000 -0700
+++ slub/fs/proc/inode.c	2007-05-18 01:00:36.000000000 -0700
@@ -111,14 +111,25 @@ static void init_once(void * foo, struct
 
 	inode_init_once(&ei->vfs_inode);
 }
- 
+
+static void *proc_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+			offsetof(struct proc_inode, vfs_inode));
+};
+
+static struct kmem_cache_ops proc_kmem_cache_ops = {
+	.get = proc_get_inodes,
+	.kick = kick_inodes
+};
+
 int __init proc_init_inodecache(void)
 {
 	proc_inode_cachep = kmem_cache_create("proc_inode_cache",
 					     sizeof(struct proc_inode),
 					     0, (SLAB_RECLAIM_ACCOUNT|
 						SLAB_MEM_SPREAD),
-					     init_once, NULL);
+					     init_once, &proc_kmem_cache_ops);
 	if (proc_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;

-- 
