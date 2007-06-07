From: clameter@sgi.com
Subject: [patch 08/12] procfs: inode defragmentation support
Date: Thu, 07 Jun 2007 14:55:37 -0700
Message-ID: <20070607215909.907281916@sgi.com>
References: <20070607215529.147027769@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966221AbXFGWDa@vger.kernel.org>
Content-Disposition: inline; filename=slub_defrag_fs_proc
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/proc/inode.c |   22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

Index: slub/fs/proc/inode.c
===================================================================
--- slub.orig/fs/proc/inode.c	2007-06-04 20:12:56.000000000 -0700
+++ slub/fs/proc/inode.c	2007-06-04 21:35:00.000000000 -0700
@@ -112,14 +112,25 @@ static void init_once(void * foo, struct
 
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
