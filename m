From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070430185624.7142.5198.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
References: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/4] Use SLAB_ACCOUNT_RECLAIM to determine when __GFP_RECLAIMABLE should be used
Date: Mon, 30 Apr 2007 19:56:24 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

A number of slab caches are reclaimable and some of their allocation
callsites were updated to use the __GFP_RECLAIMABLE flag. However, slabs
that are reclaimable specify the SLAB_ACCOUNT_RECLAIM flag at creation time
and this information is available at the time of page allocation.

This patch uses the SLAB_ACCOUNT_RECLAIM flag in the SLAB and SLUB
allocators to determine if __GFP_RECLAIMABLE should be used when allocating
pages. The SLOB allocator is not updated as it is unlikely to be used on
a system where grouping pages by mobility is worthwhile. The callsites
for reclaimable cache allocations  no longer specify __GFP_RECLAIMABLE
as the information is redundant. This can be considered as fix to
group-short-lived-and-reclaimable-kernel-allocations.patch.

Credit goes to Christoph Lameter for identifying this problem during review
and suggesting this fix.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 fs/dcache.c         |    2 +-
 fs/ext2/super.c     |    3 +--
 fs/ext3/super.c     |    2 +-
 fs/ntfs/inode.c     |    4 ++--
 fs/reiserfs/super.c |    3 +--
 mm/slab.c           |    2 ++
 mm/slub.c           |    3 +++
 7 files changed, 11 insertions(+), 8 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-001_deprecate/fs/dcache.c linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/dcache.c
--- linux-2.6.21-rc7-mm2-001_deprecate/fs/dcache.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/dcache.c	2007-04-30 16:08:39.000000000 +0100
@@ -904,7 +904,7 @@ struct dentry *d_alloc(struct dentry * p
 	struct dentry *dentry;
 	char *dname;
 
-	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL|__GFP_RECLAIMABLE);
+	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL);
 	if (!dentry)
 		return NULL;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-001_deprecate/fs/ext2/super.c linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/ext2/super.c
--- linux-2.6.21-rc7-mm2-001_deprecate/fs/ext2/super.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/ext2/super.c	2007-04-30 16:22:29.000000000 +0100
@@ -140,8 +140,7 @@ static struct kmem_cache * ext2_inode_ca
 static struct inode *ext2_alloc_inode(struct super_block *sb)
 {
 	struct ext2_inode_info *ei;
-	ei = (struct ext2_inode_info *)kmem_cache_alloc(ext2_inode_cachep,
-						GFP_KERNEL|__GFP_RECLAIMABLE);
+	ei = (struct ext2_inode_info *)kmem_cache_alloc(ext2_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 #ifdef CONFIG_EXT2_FS_POSIX_ACL
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-001_deprecate/fs/ext3/super.c linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/ext3/super.c
--- linux-2.6.21-rc7-mm2-001_deprecate/fs/ext3/super.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/ext3/super.c	2007-04-30 16:08:39.000000000 +0100
@@ -445,7 +445,7 @@ static struct inode *ext3_alloc_inode(st
 {
 	struct ext3_inode_info *ei;
 
-	ei = kmem_cache_alloc(ext3_inode_cachep, GFP_NOFS|__GFP_RECLAIMABLE);
+	ei = kmem_cache_alloc(ext3_inode_cachep, GFP_NOFS);
 	if (!ei)
 		return NULL;
 #ifdef CONFIG_EXT3_FS_POSIX_ACL
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-001_deprecate/fs/ntfs/inode.c linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/ntfs/inode.c
--- linux-2.6.21-rc7-mm2-001_deprecate/fs/ntfs/inode.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/ntfs/inode.c	2007-04-30 16:08:39.000000000 +0100
@@ -323,7 +323,7 @@ struct inode *ntfs_alloc_big_inode(struc
 	ntfs_inode *ni;
 
 	ntfs_debug("Entering.");
-	ni = kmem_cache_alloc(ntfs_big_inode_cache, GFP_NOFS|__GFP_RECLAIMABLE);
+	ni = kmem_cache_alloc(ntfs_big_inode_cache, GFP_NOFS);
 	if (likely(ni != NULL)) {
 		ni->state = 0;
 		return VFS_I(ni);
@@ -348,7 +348,7 @@ static inline ntfs_inode *ntfs_alloc_ext
 	ntfs_inode *ni;
 
 	ntfs_debug("Entering.");
-	ni = kmem_cache_alloc(ntfs_inode_cache, GFP_NOFS|__GFP_RECLAIMABLE);
+	ni = kmem_cache_alloc(ntfs_inode_cache, GFP_NOFS);
 	if (likely(ni != NULL)) {
 		ni->state = 0;
 		return ni;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-001_deprecate/fs/reiserfs/super.c linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/reiserfs/super.c
--- linux-2.6.21-rc7-mm2-001_deprecate/fs/reiserfs/super.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/reiserfs/super.c	2007-04-30 16:08:39.000000000 +0100
@@ -496,8 +496,7 @@ static struct inode *reiserfs_alloc_inod
 {
 	struct reiserfs_inode_info *ei;
 	ei = (struct reiserfs_inode_info *)
-	    kmem_cache_alloc(reiserfs_inode_cachep,
-						GFP_KERNEL|__GFP_RECLAIMABLE);
+	    kmem_cache_alloc(reiserfs_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-001_deprecate/mm/slab.c linux-2.6.21-rc7-mm2-002_account_reclaimable/mm/slab.c
--- linux-2.6.21-rc7-mm2-001_deprecate/mm/slab.c	2007-04-27 22:04:34.000000000 +0100
+++ linux-2.6.21-rc7-mm2-002_account_reclaimable/mm/slab.c	2007-04-30 16:17:34.000000000 +0100
@@ -1656,6 +1656,8 @@ static void *kmem_getpages(struct kmem_c
 #endif
 
 	flags |= cachep->gfpflags;
+	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
+		flags |= __GFP_RECLAIMABLE;
 
 	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
 	if (!page)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-001_deprecate/mm/slub.c linux-2.6.21-rc7-mm2-002_account_reclaimable/mm/slub.c
--- linux-2.6.21-rc7-mm2-001_deprecate/mm/slub.c	2007-04-27 22:04:34.000000000 +0100
+++ linux-2.6.21-rc7-mm2-002_account_reclaimable/mm/slub.c	2007-04-30 16:17:44.000000000 +0100
@@ -762,6 +762,9 @@ static struct page *allocate_slab(struct
 	if (s->flags & SLAB_CACHE_DMA)
 		flags |= SLUB_DMA;
 
+	if (s->flags & SLAB_ACCOUNT_RECLAIM)
+		gfpflags |= __GFP_RECLAIMABLE;
+
 	if (node == -1)
 		page = alloc_pages(flags, s->order);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
