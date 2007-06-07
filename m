From: clameter@sgi.com
Subject: [patch 10/12] sockets: inode defragmentation support
Date: Thu, 07 Jun 2007 14:55:39 -0700
Message-ID: <20070607215910.379088320@sgi.com>
References: <20070607215529.147027769@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966380AbXFGWCP@vger.kernel.org>
Content-Disposition: inline; filename=slub_defrag_fs_socket
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 net/socket.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

Index: slub/net/socket.c
===================================================================
--- slub.orig/net/socket.c	2007-06-06 15:19:29.000000000 -0700
+++ slub/net/socket.c	2007-06-06 15:20:54.000000000 -0700
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
