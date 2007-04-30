From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070430185644.7142.89206.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
References: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/4] Add __GFP_TEMPORARY to identify allocations that are short-lived
Date: Mon, 30 Apr 2007 19:56:44 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently allocations that are short-lived or reclaimable by the kernel are
grouped together by specifying __GFP_RECLAIMABLE in the GFP flags. However,
it is confusing when reading code to see a temporary allocation using
__GFP_RECLAIMABLE when it is clearly not reclaimable.

This patch adds __GFP_TEMPORARY, GFP_TEMPORARY and SLAB_TEMPORARY for
temporary allocations. In reality, reclaimable and temporary allocations
are grouped into the same blocks but this might change in the future. This
change makes call sites for temporary allocations clearer. Not all temporary
allocations were previously flagged. This patch flags a few additional
allocations appropriately.

Note that some GFP_USER and GFP_KERNEL allocations are both changed to
GFP_TEMPORARY. The difference between GFP_USER and GFP_KERNEL is only in how
cpuset boundaries are handled which is unimportant to temporary allocations.

This patch can be considered as fix to
group-short-lived-and-reclaimable-kernel-allocations.patch.

Credit goes to Christoph Lameter for identifying the problems in relation to
temporary allocations during review and providing an illustration-of-concept
patch to act as a starting point.

From: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 drivers/block/acsi_slm.c |    2 +-
 fs/jbd/journal.c         |    8 +++-----
 fs/jbd/revoke.c          |   10 +++++-----
 fs/proc/base.c           |   12 ++++++------
 fs/proc/generic.c        |    2 +-
 fs/proc/proc_misc.c      |    2 +-
 include/linux/gfp.h      |    2 ++
 include/linux/slab.h     |    5 ++++-
 kernel/cpuset.c          |    2 +-
 mm/slub.c                |    2 +-
 net/core/skbuff.c        |    2 +-
 11 files changed, 26 insertions(+), 23 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/drivers/block/acsi_slm.c linux-2.6.21-rc7-mm2-003_temporary/drivers/block/acsi_slm.c
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/drivers/block/acsi_slm.c	2007-04-27 22:04:30.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/drivers/block/acsi_slm.c	2007-04-30 16:10:55.000000000 +0100
@@ -367,7 +367,7 @@ static ssize_t slm_read( struct file *fi
 	int length;
 	int end;
 
-	if (!(page = __get_free_page( GFP_KERNEL )))
+	if (!(page = __get_free_page( GFP_TEMPORARY)))
 		return( -ENOMEM );
 	
 	length = slm_getstats( (char *)page, iminor(node) );
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/jbd/journal.c linux-2.6.21-rc7-mm2-003_temporary/fs/jbd/journal.c
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/jbd/journal.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/fs/jbd/journal.c	2007-04-30 16:38:41.000000000 +0100
@@ -1739,8 +1739,7 @@ static struct journal_head *journal_allo
 #ifdef CONFIG_JBD_DEBUG
 	atomic_inc(&nr_journal_heads);
 #endif
-	ret = kmem_cache_alloc(journal_head_cache,
-			set_migrateflags(GFP_NOFS, __GFP_RECLAIMABLE));
+	ret = kmem_cache_alloc(journal_head_cache, GFP_NOFS);
 	if (ret == 0) {
 		jbd_debug(1, "out of memory for journal_head\n");
 		if (time_after(jiffies, last_warning + 5*HZ)) {
@@ -1750,8 +1749,7 @@ static struct journal_head *journal_allo
 		}
 		while (ret == 0) {
 			yield();
-			ret = kmem_cache_alloc(journal_head_cache,
-					GFP_NOFS|__GFP_RECLAIMABLE);
+			ret = kmem_cache_alloc(journal_head_cache, GFP_NOFS);
 		}
 	}
 	return ret;
@@ -2017,7 +2015,7 @@ static int __init journal_init_handle_ca
 	jbd_handle_cache = kmem_cache_create("journal_handle",
 				sizeof(handle_t),
 				0,		/* offset */
-				0,		/* flags */
+				SLAB_TEMPORARY,	/* flags */
 				NULL,		/* ctor */
 				NULL);		/* dtor */
 	if (jbd_handle_cache == NULL) {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/jbd/revoke.c linux-2.6.21-rc7-mm2-003_temporary/fs/jbd/revoke.c
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/jbd/revoke.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/fs/jbd/revoke.c	2007-04-30 16:39:43.000000000 +0100
@@ -169,7 +169,9 @@ int __init journal_init_revoke_caches(vo
 {
 	revoke_record_cache = kmem_cache_create("revoke_record",
 					   sizeof(struct jbd_revoke_record_s),
-					   0, SLAB_HWCACHE_ALIGN, NULL, NULL);
+					   0,
+					   SLAB_HWCACHE_ALIGN|SLAB_TEMPORARY,
+					   NULL, NULL);
 	if (revoke_record_cache == 0)
 		return -ENOMEM;
 
@@ -205,8 +207,7 @@ int journal_init_revoke(journal_t *journ
 	while((tmp >>= 1UL) != 0UL)
 		shift++;
 
-	journal->j_revoke_table[0] = kmem_cache_alloc(revoke_table_cache,
-					GFP_KERNEL|__GFP_RECLAIMABLE);
+	journal->j_revoke_table[0] = kmem_cache_alloc(revoke_table_cache, GFP_KERNEL);
 	if (!journal->j_revoke_table[0])
 		return -ENOMEM;
 	journal->j_revoke = journal->j_revoke_table[0];
@@ -229,8 +230,7 @@ int journal_init_revoke(journal_t *journ
 	for (tmp = 0; tmp < hash_size; tmp++)
 		INIT_LIST_HEAD(&journal->j_revoke->hash_table[tmp]);
 
-	journal->j_revoke_table[1] = kmem_cache_alloc(revoke_table_cache,
-					GFP_KERNEL|__GFP_RECLAIMABLE);
+	journal->j_revoke_table[1] = kmem_cache_alloc(revoke_table_cache, GFP_KERNEL);
 	if (!journal->j_revoke_table[1]) {
 		kfree(journal->j_revoke_table[0]->hash_table);
 		kmem_cache_free(revoke_table_cache, journal->j_revoke_table[0]);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/proc/base.c linux-2.6.21-rc7-mm2-003_temporary/fs/proc/base.c
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/proc/base.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/fs/proc/base.c	2007-04-30 16:10:55.000000000 +0100
@@ -388,7 +388,7 @@ static int __mounts_open(struct inode *i
 		p = kmalloc(sizeof(struct proc_mounts), GFP_KERNEL);
 		if (p) {
 			file->private_data = &p->m;
-			p->page = (void *)__get_free_page(GFP_KERNEL);
+			p->page = (void *)__get_free_page(GFP_TEMPORARY);
 			if (p->page)
 				ret = seq_open(file, seq_ops);
 			if (!ret) {
@@ -479,7 +479,7 @@ static ssize_t proc_info_read(struct fil
 		count = PROC_BLOCK_SIZE;
 
 	length = -ENOMEM;
-	if (!(page = __get_free_page(GFP_KERNEL|__GFP_RECLAIMABLE)))
+	if (!(page = __get_free_page(GFP_TEMPORARY)))
 		goto out;
 
 	length = PROC_I(inode)->op.proc_read(task, (char*)page);
@@ -589,7 +589,7 @@ static ssize_t mem_write(struct file * f
 		goto out;
 
 	copied = -ENOMEM;
-	page = (char *)__get_free_page(GFP_USER|__GFP_RECLAIMABLE);
+	page = (char *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		goto out;
 
@@ -746,7 +746,7 @@ static ssize_t proc_loginuid_write(struc
 		/* No partial writes. */
 		return -EINVAL;
 	}
-	page = (char*)__get_free_page(GFP_USER|__GFP_RECLAIMABLE);
+	page = (char*)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		return -ENOMEM;
 	length = -EFAULT;
@@ -928,7 +928,7 @@ static int do_proc_readlink(struct dentr
 			    char __user *buffer, int buflen)
 {
 	struct inode * inode;
-	char *tmp = (char*)__get_free_page(GFP_KERNEL|__GFP_RECLAIMABLE);
+	char *tmp = (char*)__get_free_page(GFP_TEMPORARY);
 	char *path;
 	int len;
 
@@ -1701,7 +1701,7 @@ static ssize_t proc_pid_attr_write(struc
 		goto out;
 
 	length = -ENOMEM;
-	page = (char*)__get_free_page(GFP_USER|__GFP_RECLAIMABLE);
+	page = (char*)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		goto out;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/proc/generic.c linux-2.6.21-rc7-mm2-003_temporary/fs/proc/generic.c
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/proc/generic.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/fs/proc/generic.c	2007-04-30 16:10:55.000000000 +0100
@@ -74,7 +74,7 @@ proc_file_read(struct file *file, char _
 		nbytes = MAX_NON_LFS - pos;
 
 	dp = PDE(inode);
-	if (!(page = (char*) __get_free_page(GFP_KERNEL|__GFP_RECLAIMABLE)))
+	if (!(page = (char*) __get_free_page(GFP_TEMPORARY)))
 		return -ENOMEM;
 
 	while ((nbytes > 0) && !eof) {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/proc/proc_misc.c linux-2.6.21-rc7-mm2-003_temporary/fs/proc/proc_misc.c
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/proc/proc_misc.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/fs/proc/proc_misc.c	2007-04-30 16:10:55.000000000 +0100
@@ -678,7 +678,7 @@ static ssize_t kpagemap_read(struct file
 	if (src & KPMMASK || count & KPMMASK)
 		return -EIO;
 
-	page = (unsigned long *)__get_free_page(GFP_USER);
+	page = (unsigned long *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		return -ENOMEM;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/include/linux/gfp.h linux-2.6.21-rc7-mm2-003_temporary/include/linux/gfp.h
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/include/linux/gfp.h	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/include/linux/gfp.h	2007-04-30 16:10:55.000000000 +0100
@@ -50,6 +50,7 @@ struct vm_area_struct;
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
+#define __GFP_TEMPORARY   ((__force gfp_t)0x80000u) /* Page is short-lived */
 #define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */
 
 #define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
@@ -72,6 +73,7 @@ struct vm_area_struct;
 #define GFP_NOIO	(__GFP_WAIT)
 #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
+#define GFP_TEMPORARY	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_TEMPORARY)
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
 			 __GFP_HIGHMEM)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/include/linux/slab.h linux-2.6.21-rc7-mm2-003_temporary/include/linux/slab.h
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/include/linux/slab.h	2007-04-27 22:04:34.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/include/linux/slab.h	2007-04-30 16:10:55.000000000 +0100
@@ -26,12 +26,15 @@ typedef struct kmem_cache kmem_cache_t _
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
-#define SLAB_RECLAIM_ACCOUNT	0x00020000UL	/* Objects are reclaimable */
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
 #define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
 #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
 #define SLAB_TRACE		0x00200000UL	/* Trace allocations and frees */
 
+/* The following flags affect grouping pages by mobility */
+#define SLAB_RECLAIM_ACCOUNT	0x00020000UL	/* Objects are reclaimable */
+#define SLAB_TEMPORARY	SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
+
 /* Flags passed to a constructor functions */
 #define SLAB_CTOR_CONSTRUCTOR	0x001UL		/* If not set, then deconstructor */
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/kernel/cpuset.c linux-2.6.21-rc7-mm2-003_temporary/kernel/cpuset.c
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/kernel/cpuset.c	2007-04-27 22:04:34.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/kernel/cpuset.c	2007-04-30 16:10:55.000000000 +0100
@@ -1361,7 +1361,7 @@ static ssize_t cpuset_common_file_read(s
 	ssize_t retval = 0;
 	char *s;
 
-	if (!(page = (char *)__get_free_page(GFP_KERNEL)))
+	if (!(page = (char *)__get_free_page(GFP_TEMPORARY)))
 		return -ENOMEM;
 
 	s = page;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/mm/slub.c linux-2.6.21-rc7-mm2-003_temporary/mm/slub.c
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/mm/slub.c	2007-04-30 16:17:44.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/mm/slub.c	2007-04-30 16:32:45.000000000 +0100
@@ -2691,7 +2691,7 @@ static int alloc_loc_track(struct loc_tr
 
 	order = get_order(sizeof(struct location) * max);
 
-	l = (void *)__get_free_pages(GFP_KERNEL, order);
+	l = (void *)__get_free_pages(GFP_TEMPORARY, order);
 
 	if (!l)
 		return 0;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/net/core/skbuff.c linux-2.6.21-rc7-mm2-003_temporary/net/core/skbuff.c
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/net/core/skbuff.c	2007-04-27 22:04:34.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/net/core/skbuff.c	2007-04-30 16:10:55.000000000 +0100
@@ -152,7 +152,7 @@ struct sk_buff *__alloc_skb(unsigned int
 	u8 *data;
 
 	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
-	gfp_mask = set_migrateflags(gfp_mask, __GFP_RECLAIMABLE);
+	gfp_mask = set_migrateflags(gfp_mask, __GFP_TEMPORARY);
 
 	/* Get the HEAD */
 	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
