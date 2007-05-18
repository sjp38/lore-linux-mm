From: clameter@sgi.com
Subject: [patch 09/10] sockets: inode defragmentation support
Date: Fri, 18 May 2007 11:10:49 -0700
Message-ID: <20070518181120.708884638@sgi.com>
References: <20070518181040.465335396@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764027AbXERSOo@vger.kernel.org>
Content-Disposition: inline; filename=fs_socket
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 net/socket.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

Index: slub/net/socket.c
===================================================================
--- slub.orig/net/socket.c	2007-05-18 00:54:30.000000000 -0700
+++ slub/net/socket.c	2007-05-18 01:03:31.000000000 -0700
@@ -264,6 +264,17 @@ static void init_once(void *foo, struct 
 	inode_init_once(&ei->vfs_inode);
 }
 
+static void *sock_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+		offsetof(struct socket_alloc, vfs_inode));
+}
+
+static struct kmem_cache_ops sock_kmem_cache_ops = {
+	.get = sock_get_inodes,
+	.kick = kick_inodes
+};
+
 static int init_inodecache(void)
 {
 	sock_inode_cachep = kmem_cache_create("sock_inode_cache",
@@ -273,7 +284,7 @@ static int init_inodecache(void)
 					       SLAB_RECLAIM_ACCOUNT |
 					       SLAB_MEM_SPREAD),
 					      init_once,
-					      NULL);
+					      &sock_kmem_cache_ops);
 	if (sock_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;

-- 
