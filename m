From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 10/12] Slab defragmentation: Support inode defragmentation for xfs
Date: Sat, 07 Jul 2007 20:05:48 -0700
Message-ID: <20070708030845.739539507@sgi.com>
References: <20070708030538.729027694@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756872AbXGHDMn@vger.kernel.org>
Content-Disposition: inline; filename=slub_defrag_fs_xfs
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com
List-Id: linux-mm.kvack.org

Add slab defrag support.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/xfs/linux-2.6/kmem.h      |    5 +++--
 fs/xfs/linux-2.6/xfs_buf.c   |    2 +-
 fs/xfs/linux-2.6/xfs_super.c |   13 ++++++++++++-
 fs/xfs/xfs_vfsops.c          |    6 +++---
 4 files changed, 19 insertions(+), 7 deletions(-)

Index: slub/fs/xfs/linux-2.6/kmem.h
===================================================================
--- slub.orig/fs/xfs/linux-2.6/kmem.h	2007-06-06 13:08:09.000000000 -0700
+++ slub/fs/xfs/linux-2.6/kmem.h	2007-06-06 13:32:58.000000000 -0700
@@ -79,9 +79,10 @@ kmem_zone_init(int size, char *zone_name
 
 static inline kmem_zone_t *
 kmem_zone_init_flags(int size, char *zone_name, unsigned long flags,
-		     void (*construct)(void *, kmem_zone_t *, unsigned long))
+		     void (*construct)(void *, kmem_zone_t *, unsigned long),
+		     const struct kmem_cache_ops *ops)
 {
-	return kmem_cache_create(zone_name, size, 0, flags, construct, NULL);
+	return kmem_cache_create(zone_name, size, 0, flags, construct, ops);
 }
 
 static inline void
Index: slub/fs/xfs/linux-2.6/xfs_buf.c
===================================================================
--- slub.orig/fs/xfs/linux-2.6/xfs_buf.c	2007-06-06 13:08:09.000000000 -0700
+++ slub/fs/xfs/linux-2.6/xfs_buf.c	2007-06-06 13:32:58.000000000 -0700
@@ -1834,7 +1834,7 @@ xfs_buf_init(void)
 #endif
 
 	xfs_buf_zone = kmem_zone_init_flags(sizeof(xfs_buf_t), "xfs_buf",
-						KM_ZONE_HWALIGN, NULL);
+						KM_ZONE_HWALIGN, NULL, NULL);
 	if (!xfs_buf_zone)
 		goto out_free_trace_buf;
 
Index: slub/fs/xfs/linux-2.6/xfs_super.c
===================================================================
--- slub.orig/fs/xfs/linux-2.6/xfs_super.c	2007-06-06 13:08:09.000000000 -0700
+++ slub/fs/xfs/linux-2.6/xfs_super.c	2007-06-06 13:32:58.000000000 -0700
@@ -355,13 +355,24 @@ xfs_fs_inode_init_once(
 	inode_init_once(vn_to_inode((bhv_vnode_t *)vnode));
 }
 
+static void *xfs_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v, offsetof(bhv_vnode_t, v_inode));
+};
+
+static struct kmem_cache_ops xfs_kmem_cache_ops = {
+	.get = xfs_get_inodes,
+	.kick = kick_inodes
+};
+
 STATIC int
 xfs_init_zones(void)
 {
 	xfs_vnode_zone = kmem_zone_init_flags(sizeof(bhv_vnode_t), "xfs_vnode",
 					KM_ZONE_HWALIGN | KM_ZONE_RECLAIM |
 					KM_ZONE_SPREAD,
-					xfs_fs_inode_init_once);
+					xfs_fs_inode_init_once,
+					&xfs_kmem_cache_ops);
 	if (!xfs_vnode_zone)
 		goto out;
 
Index: slub/fs/xfs/xfs_vfsops.c
===================================================================
--- slub.orig/fs/xfs/xfs_vfsops.c	2007-06-06 15:19:52.000000000 -0700
+++ slub/fs/xfs/xfs_vfsops.c	2007-06-06 15:20:36.000000000 -0700
@@ -109,13 +109,13 @@ xfs_init(void)
 	xfs_inode_zone =
 		kmem_zone_init_flags(sizeof(xfs_inode_t), "xfs_inode",
 					KM_ZONE_HWALIGN | KM_ZONE_RECLAIM |
-					KM_ZONE_SPREAD, NULL);
+					KM_ZONE_SPREAD, NULL, NULL);
 	xfs_ili_zone =
 		kmem_zone_init_flags(sizeof(xfs_inode_log_item_t), "xfs_ili",
-					KM_ZONE_SPREAD, NULL);
+					KM_ZONE_SPREAD, NULL, NULL);
 	xfs_chashlist_zone =
 		kmem_zone_init_flags(sizeof(xfs_chashlist_t), "xfs_chashlist",
-					KM_ZONE_SPREAD, NULL);
+					KM_ZONE_SPREAD, NULL, NULL);
 
 	/*
 	 * Allocate global trace buffers.

-- 
