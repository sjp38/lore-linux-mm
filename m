Date: Tue, 14 Dec 2004 11:53:33 -0600
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: [PATCH 2/3] filesystem hashes: NUMA interleaving
Message-ID: <Pine.SGI.4.61.0412141149140.22462@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

The following patch against 2.6.10-rc3 modifies the dentry cache and
inode cache to enable the use of vmalloc to alleviate boottime memory
allocation imbalances on NUMA systems, utilizing flags to the
alloc_large_system_hash routine in order to centralize the enabling of
this behavior.

In general, for each hash, we check at the early allocation point
whether hash distribution is enabled, and if so we defer allocation.
At the late allocation point we perform the allocation if it was
not earlier deferred.  These late allocation points are the same
points utilized prior to the addition of alloc_large_system_hash
to the kernel.

This patch (2/3) depends on patch 1/3 in this patch series.  It
does not depend on, nor is depended upon by, patch 3/3 in the
series.

Signed-off-by: Brent Casavant <bcasavan@sgi.com>

Index: linux/fs/inode.c
===================================================================
--- linux.orig/fs/inode.c	2004-12-10 18:10:39.626044070 -0600
+++ linux/fs/inode.c	2004-12-10 18:10:47.317614515 -0600
@@ -1328,6 +1328,12 @@
 {
 	int loop;
 
+	/* If hashes are distributed across NUMA nodes, defer
+	 * hash allocation until vmalloc space is available.
+	 */
+	if (hashdist)
+		return;
+
 	inode_hashtable =
 		alloc_large_system_hash("Inode-cache",
 					sizeof(struct hlist_head),
@@ -1344,10 +1350,29 @@
 
 void __init inode_init(unsigned long mempages)
 {
+	int loop;
+
 	/* inode slab cache */
 	inode_cachep = kmem_cache_create("inode_cache", sizeof(struct inode),
 				0, SLAB_PANIC, init_once, NULL);
 	set_shrinker(DEFAULT_SEEKS, shrink_icache_memory);
+
+	/* Hash may have been set up in inode_init_early */
+	if (!hashdist)
+		return;
+
+	inode_hashtable =
+		alloc_large_system_hash("Inode-cache",
+					sizeof(struct hlist_head),
+					ihash_entries,
+					14,
+					0,
+					&i_hash_shift,
+					&i_hash_mask,
+					0);
+
+	for (loop = 0; loop < (1 << i_hash_shift); loop++)
+		INIT_HLIST_HEAD(&inode_hashtable[loop]);
 }
 
 void init_special_inode(struct inode *inode, umode_t mode, dev_t rdev)
Index: linux/fs/dcache.c
===================================================================
--- linux.orig/fs/dcache.c	2004-12-10 18:10:39.630926367 -0600
+++ linux/fs/dcache.c	2004-12-10 18:10:47.322496812 -0600
@@ -1574,6 +1574,12 @@
 {
 	int loop;
 
+	/* If hashes are distributed across NUMA nodes, defer
+	 * hash allocation until vmalloc space is available.
+	 */
+	if (hashdist)
+		return;
+
 	dentry_hashtable =
 		alloc_large_system_hash("Dentry cache",
 					sizeof(struct hlist_head),
@@ -1590,6 +1596,8 @@
 
 static void __init dcache_init(unsigned long mempages)
 {
+	int loop;
+
 	/* 
 	 * A constructor could be added for stable state like the lists,
 	 * but it is probably not worth it because of the cache nature
@@ -1602,6 +1610,23 @@
 					 NULL, NULL);
 	
 	set_shrinker(DEFAULT_SEEKS, shrink_dcache_memory);
+
+	/* Hash may have been set up in dcache_init_early */
+	if (!hashdist)
+		return;
+
+	dentry_hashtable =
+		alloc_large_system_hash("Dentry cache",
+					sizeof(struct hlist_head),
+					dhash_entries,
+					13,
+					0,
+					&d_hash_shift,
+					&d_hash_mask,
+					0);
+
+	for (loop = 0; loop < (1 << d_hash_shift); loop++)
+		INIT_HLIST_HEAD(&dentry_hashtable[loop]);
 }
 
 /* SLAB cache for __getname() consumers */


-- 
Brent Casavant                          If you had nothing to fear,
bcasavan@sgi.com                        how then could you be brave?
Silicon Graphics, Inc.                    -- Queen Dama, Source Wars
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
