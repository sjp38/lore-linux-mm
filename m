From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070515150512.16348.58421.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 6/8] Add __GFP_TEMPORARY to identify allocations that are short-lived
Date: Tue, 15 May 2007 16:05:12 +0100 (IST)
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
temporary allocations. The journal_handle, journal_head, revoke_table,
revoke_record, skbuff_head_cache and skbuff_fclone_cache slabs are converted
to use SLAB_TEMPORARY instead of flagging the allocation call-sites. In the
implementation, reclaimable and temporary allocations are grouped into the
same blocks but this might change in the future. This change makes call
sites for temporary allocations clearer. Not all temporary allocations
were previously flagged. This patch flags a few additional allocations
appropriately.

Note that some GFP_USER and GFP_KERNEL allocations are both changed to
GFP_TEMPORARY. The difference between GFP_USER and GFP_KERNEL is only in how
cpuset boundaries are handled which is unimportant to temporary allocations.

This patch can be considered as fix to
group-short-lived-and-reclaimable-kernel-allocations.patch.

Credit goes to Christoph Lameter for identifying the problems in relation to
temporary allocations during review and providing an illustration-of-concept
patch to act as a starting point.

[clameter@sgi.com: patch framework]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 drivers/block/acsi_slm.c |    2 +-
 fs/jbd/journal.c         |   10 ++++------
 fs/jbd/revoke.c          |   14 ++++++++------
 fs/proc/base.c           |   12 ++++++------
 fs/proc/generic.c        |    2 +-
 include/linux/gfp.h      |    2 ++
 include/linux/slab.h     |    5 ++++-
 kernel/cpuset.c          |    2 +-
 mm/slub.c                |    2 +-
 net/core/skbuff.c        |   19 +++++++++----------
 10 files changed, 37 insertions(+), 33 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-012_shmem/drivers/block/acsi_slm.c linux-2.6.21-mm2-020_temporary/drivers/block/acsi_slm.c
--- linux-2.6.21-mm2-012_shmem/drivers/block/acsi_slm.c	2007-05-11 21:16:08.000000000 +0100
+++ linux-2.6.21-mm2-020_temporary/drivers/block/acsi_slm.c	2007-05-15 12:31:22.000000000 +0100
@@ -367,7 +367,7 @@ static ssize_t slm_read( struct file *fi
 	int length;
 	int end;
 
-	if (!(page = __get_free_page( GFP_KERNEL )))
+	if (!(page = __get_free_page(GFP_TEMPORARY)))
 		return( -ENOMEM );
 	
 	length = slm_getstats( (char *)page, iminor(node) );
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-012_shmem/fs/jbd/journal.c linux-2.6.21-mm2-020_temporary/fs/jbd/journal.c
--- linux-2.6.21-mm2-012_shmem/fs/jbd/journal.c	2007-05-11 21:16:10.000000000 +0100
+++ linux-2.6.21-mm2-020_temporary/fs/jbd/journal.c	2007-05-15 12:31:22.000000000 +0100
@@ -1710,7 +1710,7 @@ static int journal_init_journal_head_cac
 	journal_head_cache = kmem_cache_create("journal_head",
 				sizeof(struct journal_head),
 				0,		/* offset */
-				0,		/* flags */
+				SLAB_TEMPORARY,	/* flags */
 				NULL,		/* ctor */
 				NULL);		/* dtor */
 	retval = 0;
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-012_shmem/fs/jbd/revoke.c linux-2.6.21-mm2-020_temporary/fs/jbd/revoke.c
--- linux-2.6.21-mm2-012_shmem/fs/jbd/revoke.c	2007-05-11 21:16:10.000000000 +0100
+++ linux-2.6.21-mm2-020_temporary/fs/jbd/revoke.c	2007-05-15 12:31:22.000000000 +0100
@@ -169,13 +169,17 @@ int __init journal_init_revoke_caches(vo
 {
 	revoke_record_cache = kmem_cache_create("revoke_record",
 					   sizeof(struct jbd_revoke_record_s),
-					   0, SLAB_HWCACHE_ALIGN, NULL, NULL);
+					   0,
+					   SLAB_HWCACHE_ALIGN|SLAB_TEMPORARY,
+					   NULL, NULL);
 	if (revoke_record_cache == 0)
 		return -ENOMEM;
 
 	revoke_table_cache = kmem_cache_create("revoke_table",
 					   sizeof(struct jbd_revoke_table_s),
-					   0, 0, NULL, NULL);
+					   0,
+					   SLAB_TEMPORARY,
+					   NULL, NULL);
 	if (revoke_table_cache == 0) {
 		kmem_cache_destroy(revoke_record_cache);
 		revoke_record_cache = NULL;
@@ -205,8 +209,7 @@ int journal_init_revoke(journal_t *journ
 	while((tmp >>= 1UL) != 0UL)
 		shift++;
 
-	journal->j_revoke_table[0] = kmem_cache_alloc(revoke_table_cache,
-					GFP_KERNEL|__GFP_RECLAIMABLE);
+	journal->j_revoke_table[0] = kmem_cache_alloc(revoke_table_cache, GFP_KERNEL);
 	if (!journal->j_revoke_table[0])
 		return -ENOMEM;
 	journal->j_revoke = journal->j_revoke_table[0];
@@ -229,8 +232,7 @@ int journal_init_revoke(journal_t *journ
 	for (tmp = 0; tmp < hash_size; tmp++)
 		INIT_LIST_HEAD(&journal->j_revoke->hash_table[tmp]);
 
-	journal->j_revoke_table[1] = kmem_cache_alloc(revoke_table_cache,
-					GFP_KERNEL|__GFP_RECLAIMABLE);
+	journal->j_revoke_table[1] = kmem_cache_alloc(revoke_table_cache, GFP_KERNEL);
 	if (!journal->j_revoke_table[1]) {
 		kfree(journal->j_revoke_table[0]->hash_table);
 		kmem_cache_free(revoke_table_cache, journal->j_revoke_table[0]);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-012_shmem/fs/proc/base.c linux-2.6.21-mm2-020_temporary/fs/proc/base.c
--- linux-2.6.21-mm2-012_shmem/fs/proc/base.c	2007-05-11 21:16:10.000000000 +0100
+++ linux-2.6.21-mm2-020_temporary/fs/proc/base.c	2007-05-15 12:31:22.000000000 +0100
@@ -487,7 +487,7 @@ static ssize_t proc_info_read(struct fil
 		count = PROC_BLOCK_SIZE;
 
 	length = -ENOMEM;
-	if (!(page = __get_free_page(GFP_KERNEL|__GFP_RECLAIMABLE)))
+	if (!(page = __get_free_page(GFP_TEMPORARY)))
 		goto out;
 
 	length = PROC_I(inode)->op.proc_read(task, (char*)page);
@@ -527,7 +527,7 @@ static ssize_t mem_read(struct file * fi
 		goto out;
 
 	ret = -ENOMEM;
-	page = (char *)__get_free_page(GFP_USER);
+	page = (char *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		goto out;
 
@@ -597,7 +597,7 @@ static ssize_t mem_write(struct file * f
 		goto out;
 
 	copied = -ENOMEM;
-	page = (char *)__get_free_page(GFP_USER|__GFP_RECLAIMABLE);
+	page = (char *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		goto out;
 
@@ -747,7 +747,7 @@ static ssize_t proc_loginuid_write(struc
 		/* No partial writes. */
 		return -EINVAL;
 	}
-	page = (char*)__get_free_page(GFP_USER|__GFP_RECLAIMABLE);
+	page = (char*)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		return -ENOMEM;
 	length = -EFAULT;
@@ -915,7 +915,7 @@ static int do_proc_readlink(struct dentr
 			    char __user *buffer, int buflen)
 {
 	struct inode * inode;
-	char *tmp = (char*)__get_free_page(GFP_KERNEL|__GFP_RECLAIMABLE);
+	char *tmp = (char*)__get_free_page(GFP_TEMPORARY);
 	char *path;
 	int len;
 
@@ -1688,7 +1688,7 @@ static ssize_t proc_pid_attr_write(struc
 		goto out;
 
 	length = -ENOMEM;
-	page = (char*)__get_free_page(GFP_USER|__GFP_RECLAIMABLE);
+	page = (char*)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		goto out;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-012_shmem/fs/proc/generic.c linux-2.6.21-mm2-020_temporary/fs/proc/generic.c
--- linux-2.6.21-mm2-012_shmem/fs/proc/generic.c	2007-05-11 21:16:10.000000000 +0100
+++ linux-2.6.21-mm2-020_temporary/fs/proc/generic.c	2007-05-15 12:31:22.000000000 +0100
@@ -74,7 +74,7 @@ proc_file_read(struct file *file, char _
 		nbytes = MAX_NON_LFS - pos;
 
 	dp = PDE(inode);
-	if (!(page = (char*) __get_free_page(GFP_KERNEL|__GFP_RECLAIMABLE)))
+	if (!(page = (char*) __get_free_page(GFP_TEMPORARY)))
 		return -ENOMEM;
 
 	while ((nbytes > 0) && !eof) {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-012_shmem/include/linux/gfp.h linux-2.6.21-mm2-020_temporary/include/linux/gfp.h
--- linux-2.6.21-mm2-012_shmem/include/linux/gfp.h	2007-05-15 12:24:58.000000000 +0100
+++ linux-2.6.21-mm2-020_temporary/include/linux/gfp.h	2007-05-15 12:31:22.000000000 +0100
@@ -71,6 +71,8 @@ struct vm_area_struct;
 #define GFP_NOIO	(__GFP_WAIT)
 #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
+#define GFP_TEMPORARY	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
+			 __GFP_RECLAIMABLE)
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
 			 __GFP_HIGHMEM)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-012_shmem/include/linux/slab.h linux-2.6.21-mm2-020_temporary/include/linux/slab.h
--- linux-2.6.21-mm2-012_shmem/include/linux/slab.h	2007-05-11 21:16:11.000000000 +0100
+++ linux-2.6.21-mm2-020_temporary/include/linux/slab.h	2007-05-15 12:31:22.000000000 +0100
@@ -26,12 +26,15 @@ typedef struct kmem_cache kmem_cache_t _
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
-#define SLAB_RECLAIM_ACCOUNT	0x00020000UL	/* Objects are reclaimable */
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
 #define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
 #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
 #define SLAB_TRACE		0x00200000UL	/* Trace allocations and frees */
 
+/* The following flags affect the page allocator grouping pages by mobility */
+#define SLAB_RECLAIM_ACCOUNT	0x00020000UL	/* Objects are reclaimable */
+#define SLAB_TEMPORARY	SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
+
 /* Flags passed to a constructor functions */
 #define SLAB_CTOR_CONSTRUCTOR	0x001UL		/* If not set, then deconstructor */
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-012_shmem/kernel/cpuset.c linux-2.6.21-mm2-020_temporary/kernel/cpuset.c
--- linux-2.6.21-mm2-012_shmem/kernel/cpuset.c	2007-05-11 21:16:11.000000000 +0100
+++ linux-2.6.21-mm2-020_temporary/kernel/cpuset.c	2007-05-15 12:31:22.000000000 +0100
@@ -1383,7 +1383,7 @@ static ssize_t cpuset_common_file_read(s
 	ssize_t retval = 0;
 	char *s;
 
-	if (!(page = (char *)__get_free_page(GFP_KERNEL)))
+	if (!(page = (char *)__get_free_page(GFP_TEMPORARY)))
 		return -ENOMEM;
 
 	s = page;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-012_shmem/mm/slub.c linux-2.6.21-mm2-020_temporary/mm/slub.c
--- linux-2.6.21-mm2-012_shmem/mm/slub.c	2007-05-15 12:21:44.000000000 +0100
+++ linux-2.6.21-mm2-020_temporary/mm/slub.c	2007-05-15 12:31:22.000000000 +0100
@@ -2846,7 +2846,7 @@ static int alloc_loc_track(struct loc_tr
 
 	order = get_order(sizeof(struct location) * max);
 
-	l = (void *)__get_free_pages(GFP_KERNEL, order);
+	l = (void *)__get_free_pages(GFP_TEMPORARY, order);
 
 	if (!l)
 		return 0;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-012_shmem/net/core/skbuff.c linux-2.6.21-mm2-020_temporary/net/core/skbuff.c
--- linux-2.6.21-mm2-012_shmem/net/core/skbuff.c	2007-05-11 21:16:12.000000000 +0100
+++ linux-2.6.21-mm2-020_temporary/net/core/skbuff.c	2007-05-15 12:31:22.000000000 +0100
@@ -152,7 +152,6 @@ struct sk_buff *__alloc_skb(unsigned int
 	u8 *data;
 
 	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
-	gfp_mask = set_migrateflags(gfp_mask, __GFP_RECLAIMABLE);
 
 	/* Get the HEAD */
 	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
@@ -2002,16 +2001,16 @@ EXPORT_SYMBOL_GPL(skb_segment);
 void __init skb_init(void)
 {
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
-					      sizeof(struct sk_buff),
-					      0,
-					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-					      NULL, NULL);
+				sizeof(struct sk_buff),
+				0,
+				SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_TEMPORARY,
+				NULL, NULL);
 	skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
-						(2*sizeof(struct sk_buff)) +
-						sizeof(atomic_t),
-						0,
-						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-						NULL, NULL);
+				(2*sizeof(struct sk_buff)) +
+				sizeof(atomic_t),
+				0,
+				SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_TEMPORARY,
+				NULL, NULL);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
