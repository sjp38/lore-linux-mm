From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 22/26] FS: Socket inode defragmentation
Date: Fri, 31 Aug 2007 18:41:29 -0700
Message-ID: <20070901014224.368426395@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0022-slab_defrag_socket.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Support inode defragmentation for sockets

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 net/socket.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index ec07703..89fc7a5 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -264,6 +264,12 @@ static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
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
@@ -275,6 +281,8 @@ static int init_inodecache(void)
 					      init_once);
 	if (sock_inode_cachep == NULL)
 		return -ENOMEM;
+	kmem_cache_setup_defrag(sock_inode_cachep,
+			sock_get_inodes, kick_inodes);
 	return 0;
 }
 
-- 
1.5.2.4

-- 
