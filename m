From: clameter@sgi.com
Subject: [patch 08/10] shmem: inode defragmentation support
Date: Fri, 18 May 2007 11:10:48 -0700
Message-ID: <20070518181120.477184338@sgi.com>
References: <20070518181040.465335396@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762926AbXERSNk@vger.kernel.org>
Content-Disposition: inline; filename=fs_shmem
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/shmem.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

Index: slub/mm/shmem.c
===================================================================
--- slub.orig/mm/shmem.c	2007-05-18 00:54:30.000000000 -0700
+++ slub/mm/shmem.c	2007-05-18 01:02:26.000000000 -0700
@@ -2337,11 +2337,22 @@ static void init_once(void *foo, struct 
 #endif
 }
 
+static void *shmem_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+			offsetof(struct shmem_inode_info, vfs_inode));
+}
+
+static struct kmem_cache_ops shmem_kmem_cache_ops = {
+	.get = shmem_get_inodes,
+	.kick = kick_inodes
+};
+
 static int init_inodecache(void)
 {
 	shmem_inode_cachep = kmem_cache_create("shmem_inode_cache",
 				sizeof(struct shmem_inode_info),
-				0, 0, init_once, NULL);
+				0, 0, init_once, &shmem_kmem_cache_ops);
 	if (shmem_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;

-- 
