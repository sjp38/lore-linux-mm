From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 17/23] FS: Proc filesystem support for slab defrag
Date: Tue, 06 Nov 2007 17:11:47 -0800
Message-ID: <20071107011230.691184860@sgi.com>
References: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758003AbXKGBSw@vger.kernel.org>
Content-Disposition: inline; filename=0020-slab_defrag_proc.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Support procfs inode defragmentation

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/proc/inode.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux-2.6.23-mm1/fs/proc/inode.c
===================================================================
--- linux-2.6.23-mm1.orig/fs/proc/inode.c	2007-10-12 16:26:08.000000000 -0700
+++ linux-2.6.23-mm1/fs/proc/inode.c	2007-10-12 18:48:32.000000000 -0700
@@ -114,6 +114,12 @@ static void init_once(struct kmem_cache 
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
@@ -121,6 +127,8 @@ int __init proc_init_inodecache(void)
 					     0, (SLAB_RECLAIM_ACCOUNT|
 						SLAB_MEM_SPREAD|SLAB_PANIC),
 					     init_once);
+	kmem_cache_setup_defrag(proc_inode_cachep,
+				proc_get_inodes, kick_inodes);
 	return 0;
 }
 

-- 
