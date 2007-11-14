Message-Id: <20071114221022.827871900@sgi.com>
References: <20071114220906.206294426@sgi.com>
Date: Wed, 14 Nov 2007 14:09:20 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 14/17] FS: Socket inode defragmentation
Content-Disposition: inline; filename=0060-FS-Socket-inode-defragmentation.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Support inode defragmentation for sockets

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 net/socket.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 5d879fd..78a193f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -265,6 +265,12 @@ static void init_once(struct kmem_cache *cachep, void *foo)
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
1.5.3.4

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
