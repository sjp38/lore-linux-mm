Message-Id: <20080216004635.167873441@sgi.com>
References: <20080216004526.763643520@sgi.com>
Date: Fri, 15 Feb 2008 16:45:41 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 15/17] FS: Socket inode defragmentation
Content-Disposition: inline; filename=0060-FS-Socket-inode-defragmentation.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

Support inode defragmentation for sockets

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 net/socket.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: mm/net/socket.c
===================================================================
--- mm.orig/net/socket.c	2007-11-28 12:28:01.311962427 -0800
+++ mm/net/socket.c	2007-11-28 12:31:46.383962876 -0800
@@ -269,6 +269,12 @@ static void init_once(struct kmem_cache 
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
@@ -280,6 +286,8 @@ static int init_inodecache(void)
 					      init_once);
 	if (sock_inode_cachep == NULL)
 		return -ENOMEM;
+	kmem_cache_setup_defrag(sock_inode_cachep,
+			sock_get_inodes, kick_inodes);
 	return 0;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
