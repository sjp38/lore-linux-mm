From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 19/23] FS: Socket inode defragmentation
Date: Tue, 06 Nov 2007 17:11:49 -0800
Message-ID: <20071107011231.189627912@sgi.com>
References: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758150AbXKGBSg@vger.kernel.org>
Content-Disposition: inline; filename=0022-slab_defrag_socket.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Support inode defragmentation for sockets

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 net/socket.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux-2.6/net/socket.c
===================================================================
--- linux-2.6.orig/net/socket.c	2007-10-30 16:34:39.000000000 -0700
+++ linux-2.6/net/socket.c	2007-11-06 12:56:27.000000000 -0800
@@ -265,6 +265,12 @@ static void init_once(struct kmem_cache 
 	inode_init_once(&ei->vfs_inode);
 }
 
+static void *sock_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+		offsetof(struct socket_alloc, vfs_inode));
+}
+
 static int init_inodecache(void)
 {
 	sock_inode_cachep = kmem_cache_create("sock_inode_cache",
@@ -276,6 +282,8 @@ static int init_inodecache(void)
 					      init_once);
 	if (sock_inode_cachep == NULL)
 		return -ENOMEM;
+	kmem_cache_setup_defrag(sock_inode_cachep,
+			sock_get_inodes, kick_inodes);
 	return 0;
 }
 

-- 
