Subject: Re: [PATCH] Cleanup and kernelify shrinker registration (rc5-mm2)
From: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20070402215702.6e3782a9.akpm@linux-foundation.org>
References: <1175571885.12230.473.camel@localhost.localdomain>
	 <20070402205825.12190e52.akpm@linux-foundation.org>
	 <1175575503.12230.484.camel@localhost.localdomain>
	 <20070402215702.6e3782a9.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 03 Apr 2007 15:47:05 +1000
Message-Id: <1175579225.12230.504.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, xfs-masters@oss.sgi.com, reiserfs-dev@namesys.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-02 at 21:57 -0700, Andrew Morton wrote:
> On Tue, 03 Apr 2007 14:45:02 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:
> > Does that mean the to function correctly every user needs some internal
> > cursor so it doesn't end up scanning the first N entries over and over?
> > 
> 
> If it wants to be well-behaved, and to behave as the VM expects, yes. 
> 
> There's an expectation that the callback will be performing some scan-based
> aging operation and of course to do LRU (or whatever) aging, the callback
> will need to remember where it was up to last time it was called.
> 
> But it's just a guideline - callbacks could do something different but
> in-the-spirit, I guess.

Hmm, actually the callers I looked at (nfs, dcache, mbcache) seem to use
an LRU list and just walk the first "nr_to_scan" entries, and nr_to_scan
is always 128.

Someone who keeps a cursor will be disadvantaged: the other shrinkers
could well get less effective on repeated calls, but we won't.  Someone
who picks entries at random might have the same issue.

I think it is clearest to describe how we expect everyone to work, and
let whoever is getting creative worry about it themselves.

How's this:
==
Cleanup and kernelify shrinker registration.

I can never remember what the function to register to receive VM pressure
is called.  I have to trace down from __alloc_pages() to find it.

It's called "set_shrinker()", and it needs Your Help.

New version:
1) Don't hide struct shrinker.  It contains no magic.
2) Don't allocate "struct shrinker".  It's not helpful.
3) Call them "register_shrinker" and "unregister_shrinker".
4) Call the function "shrink" not "shrinker".
5) Reduce the 17 lines of waffly comments to 13, but document it properly.

Comments:
1) The comment in reiserfs4 makes me a little queasy.
2) The wrapper code in xfs might no longer be needed.
3) The placing in the x86-64 "hot function list" for seems a little
   unlikely.  Clearly, Andi was testing if anyone was paying attention.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r 0b43dab739aa arch/x86_64/kernel/functionlist
--- a/arch/x86_64/kernel/functionlist	Tue Apr 03 15:37:49 2007 +1000
+++ b/arch/x86_64/kernel/functionlist	Tue Apr 03 15:37:53 2007 +1000
@@ -1118,7 +1118,6 @@
 *(.text.simple_strtoll)
 *(.text.set_termios)
 *(.text.set_task_comm)
-*(.text.set_shrinker)
 *(.text.set_normalized_timespec)
 *(.text.set_brk)
 *(.text.serial_in)
diff -r 0b43dab739aa fs/dcache.c
--- a/fs/dcache.c	Tue Apr 03 15:37:49 2007 +1000
+++ b/fs/dcache.c	Tue Apr 03 15:37:53 2007 +1000
@@ -884,6 +884,11 @@ static int shrink_dcache_memory(int nr, 
 	}
 	return (dentry_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
 }
+
+static struct shrinker dcache_shrinker = {
+	.shrink = shrink_dcache_memory,
+	.seeks = DEFAULT_SEEKS,
+};
 
 /**
  * d_alloc	-	allocate a dcache entry
@@ -2144,8 +2149,8 @@ static void __init dcache_init(unsigned 
 					 (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
 					 SLAB_MEM_SPREAD),
 					 NULL, NULL);
-	
-	set_shrinker(DEFAULT_SEEKS, shrink_dcache_memory);
+
+	register_shrinker(&dcache_shrinker);
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
diff -r 0b43dab739aa fs/dquot.c
--- a/fs/dquot.c	Tue Apr 03 15:37:49 2007 +1000
+++ b/fs/dquot.c	Tue Apr 03 15:37:53 2007 +1000
@@ -538,6 +538,11 @@ static int shrink_dqcache_memory(int nr,
 	}
 	return (dqstats.free_dquots / 100) * sysctl_vfs_cache_pressure;
 }
+
+static struct shrinker dqcache_shrinker = {
+	.shrink = shrink_dqcache_memory,
+	.seeks = DEFAULT_SEEKS,
+};
 
 /*
  * Put reference to dquot
@@ -1871,7 +1876,7 @@ static int __init dquot_init(void)
 	printk("Dquot-cache hash table entries: %ld (order %ld, %ld bytes)\n",
 			nr_hash, order, (PAGE_SIZE << order));
 
-	set_shrinker(DEFAULT_SEEKS, shrink_dqcache_memory);
+	register_shrinker(&dqcache_shrinker);
 
 	return 0;
 }
diff -r 0b43dab739aa fs/inode.c
--- a/fs/inode.c	Tue Apr 03 15:37:49 2007 +1000
+++ b/fs/inode.c	Tue Apr 03 15:37:53 2007 +1000
@@ -474,6 +474,11 @@ static int shrink_icache_memory(int nr, 
 	return (inodes_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
 }
 
+static struct shrinker icache_shrinker = {
+	.shrink = shrink_icache_memory,
+	.seeks = DEFAULT_SEEKS,
+};
+
 static void __wait_on_freeing_inode(struct inode *inode);
 /*
  * Called with the inode lock held.
@@ -1393,7 +1398,7 @@ void __init inode_init(unsigned long mem
 					 SLAB_MEM_SPREAD),
 					 init_once,
 					 NULL);
-	set_shrinker(DEFAULT_SEEKS, shrink_icache_memory);
+	register_shrinker(&icache_shrinker);
 
 	/* Hash may have been set up in inode_init_early */
 	if (!hashdist)
diff -r 0b43dab739aa fs/mbcache.c
--- a/fs/mbcache.c	Tue Apr 03 15:37:49 2007 +1000
+++ b/fs/mbcache.c	Tue Apr 03 15:37:53 2007 +1000
@@ -100,7 +100,6 @@ static LIST_HEAD(mb_cache_list);
 static LIST_HEAD(mb_cache_list);
 static LIST_HEAD(mb_cache_lru_list);
 static DEFINE_SPINLOCK(mb_cache_spinlock);
-static struct shrinker *mb_shrinker;
 
 static inline int
 mb_cache_indexes(struct mb_cache *cache)
@@ -118,6 +117,10 @@ mb_cache_indexes(struct mb_cache *cache)
 
 static int mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask);
 
+static struct shrinker mb_cache_shrinker = {
+	.shrink = mb_cache_shrink_fn,
+	.seeks = DEFAULT_SEEKS,
+};
 
 static inline int
 __mb_cache_entry_is_hashed(struct mb_cache_entry *ce)
@@ -662,13 +665,13 @@ mb_cache_entry_find_next(struct mb_cache
 
 static int __init init_mbcache(void)
 {
-	mb_shrinker = set_shrinker(DEFAULT_SEEKS, mb_cache_shrink_fn);
+	register_shrinker(&mb_cache_shrinker);
 	return 0;
 }
 
 static void __exit exit_mbcache(void)
 {
-	remove_shrinker(mb_shrinker);
+	unregister_shrinker(&mb_cache_shrinker);
 }
 
 module_init(init_mbcache)
diff -r 0b43dab739aa fs/nfs/super.c
--- a/fs/nfs/super.c	Tue Apr 03 15:37:49 2007 +1000
+++ b/fs/nfs/super.c	Tue Apr 03 15:37:53 2007 +1000
@@ -138,7 +138,10 @@ static const struct super_operations nfs
 };
 #endif
 
-static struct shrinker *acl_shrinker;
+static struct shrinker acl_shrinker = {
+	.shrink		= nfs_access_cache_shrinker,
+	.seeks		= DEFAULT_SEEKS,
+};
 
 /*
  * Register the NFS filesystems
@@ -159,7 +162,7 @@ int __init register_nfs_fs(void)
 	if (ret < 0)
 		goto error_2;
 #endif
-	acl_shrinker = set_shrinker(DEFAULT_SEEKS, nfs_access_cache_shrinker);
+	register_shrinker(&acl_shrinker);
 	return 0;
 
 #ifdef CONFIG_NFS_V4
@@ -177,8 +180,7 @@ error_0:
  */
 void __exit unregister_nfs_fs(void)
 {
-	if (acl_shrinker != NULL)
-		remove_shrinker(acl_shrinker);
+	unregister_shrinker(&acl_shrinker);
 #ifdef CONFIG_NFS_V4
 	unregister_filesystem(&nfs4_fs_type);
 	nfs_unregister_sysctl();
diff -r 0b43dab739aa fs/reiser4/fsdata.c
--- a/fs/reiser4/fsdata.c	Tue Apr 03 15:37:49 2007 +1000
+++ b/fs/reiser4/fsdata.c	Tue Apr 03 15:37:53 2007 +1000
@@ -7,7 +7,6 @@
 
 /* cache or dir_cursors */
 static struct kmem_cache *d_cursor_cache;
-static struct shrinker *d_cursor_shrinker;
 
 /* list of unused cursors */
 static LIST_HEAD(cursor_cache);
@@ -53,6 +52,18 @@ static int d_cursor_shrink(int nr, gfp_t
 	return d_cursor_unused;
 }
 
+/*
+ * actually, d_cursors are "priceless", because there is no way to
+ * recover information stored in them. On the other hand, we don't
+ * want to consume all kernel memory by them. As a compromise, just
+ * assign higher "seeks" value to d_cursor cache, so that it will be
+ * shrunk only if system is really tight on memory.
+ */
+static struct shrinker d_cursor_shrinker = {
+	.shrink = d_cursor_shrink,
+	.seeks = DEFAULT_SEEKS << 3,
+};
+
 /**
  * reiser4_init_d_cursor - create d_cursor cache
  *
@@ -66,20 +77,7 @@ int reiser4_init_d_cursor(void)
 	if (d_cursor_cache == NULL)
 		return RETERR(-ENOMEM);
 
-	/*
-	 * actually, d_cursors are "priceless", because there is no way to
-	 * recover information stored in them. On the other hand, we don't
-	 * want to consume all kernel memory by them. As a compromise, just
-	 * assign higher "seeks" value to d_cursor cache, so that it will be
-	 * shrunk only if system is really tight on memory.
-	 */
-	d_cursor_shrinker = set_shrinker(DEFAULT_SEEKS << 3,
-					 d_cursor_shrink);
-	if (d_cursor_shrinker == NULL) {
-		destroy_reiser4_cache(&d_cursor_cache);
-		d_cursor_cache = NULL;
-		return RETERR(-ENOMEM);
-	}
+	register_shrinker(&d_cursor_shrinker);
 	return 0;
 }
 
@@ -90,9 +88,7 @@ int reiser4_init_d_cursor(void)
  */
 void reiser4_done_d_cursor(void)
 {
-	BUG_ON(d_cursor_shrinker == NULL);
-	remove_shrinker(d_cursor_shrinker);
-	d_cursor_shrinker = NULL;
+	unregister_shrinker(&d_cursor_shrinker);
 
 	destroy_reiser4_cache(&d_cursor_cache);
 }
diff -r 0b43dab739aa fs/xfs/linux-2.6/kmem.h
--- a/fs/xfs/linux-2.6/kmem.h	Tue Apr 03 15:37:49 2007 +1000
+++ b/fs/xfs/linux-2.6/kmem.h	Tue Apr 03 15:37:53 2007 +1000
@@ -110,13 +110,23 @@ static inline kmem_shaker_t
 static inline kmem_shaker_t
 kmem_shake_register(kmem_shake_func_t sfunc)
 {
-	return set_shrinker(DEFAULT_SEEKS, sfunc);
+	/* FIXME: Perhaps caller should setup & hand in the shrinker? */
+	struct shrinker *shrinker = kmalloc(sizeof *shrinker, GFP_ATOMIC);
+	if (shrinker) {
+		shrinker->shrink = sfunc;
+		shrinker->seeks = DEFAULT_SEEKS;
+		register_shrinker(shrinker);
+	}
+	return shrinker;
 }
 
 static inline void
 kmem_shake_deregister(kmem_shaker_t shrinker)
 {
-	remove_shrinker(shrinker);
+	if (shrinker) {
+		unregister_shrinker(shrinker);
+		kfree(shrinker);
+	}
 }
 
 static inline int
diff -r 0b43dab739aa include/linux/mm.h
--- a/include/linux/mm.h	Tue Apr 03 15:37:49 2007 +1000
+++ b/include/linux/mm.h	Tue Apr 03 15:42:36 2007 +1000
@@ -813,27 +813,31 @@ extern unsigned long do_mremap(unsigned 
 			       unsigned long flags, unsigned long new_addr);
 
 /*
- * Prototype to add a shrinker callback for ageable caches.
- * 
- * These functions are passed a count `nr_to_scan' and a gfpmask.  They should
- * scan `nr_to_scan' objects, attempting to free them.
- *
- * The callback must return the number of objects which remain in the cache.
- *
- * The callback will be passed nr_to_scan == 0 when the VM is querying the
- * cache size, so a fastpath for that case is appropriate.
- */
-typedef int (*shrinker_t)(int nr_to_scan, gfp_t gfp_mask);
-
-/*
- * Add an aging callback.  The int is the number of 'seeks' it takes
- * to recreate one of the objects that these functions age.
- */
-
-#define DEFAULT_SEEKS 2
-struct shrinker;
-extern struct shrinker *set_shrinker(int, shrinker_t);
-extern void remove_shrinker(struct shrinker *shrinker);
+ * A callback you can register to apply pressure to ageable caches.
+ *
+ * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
+ * look through the least-recently-used 'nr_to_scan' entries and
+ * attempt to free them up.  It should return the number of objects
+ * which remain in the cache.  If it returns -1, it means it cannot do
+ * any scanning at this time (eg. there is a risk of deadlock).
+ *
+ * The 'gfpmask' refers to the allocation we are currently trying to
+ * fulfil.
+ *
+ * Note that 'shrink' will be passed nr_to_scan == 0 when the VM is
+ * querying the cache size, so a fastpath for that case is appropriate.
+ */
+struct shrinker {
+	int (*shrink)(int nr_to_scan, gfp_t gfp_mask);
+	int seeks;	/* seeks to recreate an obj */
+
+	/* These are for internal use */
+	struct list_head list;
+	long nr;	/* objs pending delete */
+};
+#define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
+extern void register_shrinker(struct shrinker *);
+extern void unregister_shrinker(struct shrinker *);
 
 /*
  * Some shared mappigns will want the pages marked read-only
diff -r 0b43dab739aa mm/vmscan.c
--- a/mm/vmscan.c	Tue Apr 03 15:37:49 2007 +1000
+++ b/mm/vmscan.c	Tue Apr 03 15:37:53 2007 +1000
@@ -72,17 +72,6 @@ struct scan_control {
 	int order;
 };
 
-/*
- * The list of shrinker callbacks used by to apply pressure to
- * ageable caches.
- */
-struct shrinker {
-	shrinker_t		shrinker;
-	struct list_head	list;
-	int			seeks;	/* seeks to recreate an obj */
-	long			nr;	/* objs pending delete */
-};
-
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 #ifdef ARCH_HAS_PREFETCH
@@ -125,34 +114,25 @@ static DECLARE_RWSEM(shrinker_rwsem);
 /*
  * Add a shrinker callback to be called from the vm
  */
-struct shrinker *set_shrinker(int seeks, shrinker_t theshrinker)
-{
-        struct shrinker *shrinker;
-
-        shrinker = kmalloc(sizeof(*shrinker), GFP_KERNEL);
-        if (shrinker) {
-	        shrinker->shrinker = theshrinker;
-	        shrinker->seeks = seeks;
-	        shrinker->nr = 0;
-	        down_write(&shrinker_rwsem);
-	        list_add_tail(&shrinker->list, &shrinker_list);
-	        up_write(&shrinker_rwsem);
-	}
-	return shrinker;
-}
-EXPORT_SYMBOL(set_shrinker);
+void register_shrinker(struct shrinker *shrinker)
+{
+	shrinker->nr = 0;
+	down_write(&shrinker_rwsem);
+	list_add_tail(&shrinker->list, &shrinker_list);
+	up_write(&shrinker_rwsem);
+}
+EXPORT_SYMBOL(register_shrinker);
 
 /*
  * Remove one
  */
-void remove_shrinker(struct shrinker *shrinker)
+void unregister_shrinker(struct shrinker *shrinker)
 {
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
-	kfree(shrinker);
-}
-EXPORT_SYMBOL(remove_shrinker);
+}
+EXPORT_SYMBOL(unregister_shrinker);
 
 #define SHRINK_BATCH 128
 /*
@@ -189,11 +169,11 @@ unsigned long shrink_slab(unsigned long 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		unsigned long long delta;
 		unsigned long total_scan;
-		unsigned long max_pass = (*shrinker->shrinker)(0, gfp_mask);
+		unsigned long max_pass = (*shrinker->shrink)(0, gfp_mask);
 
 		if (!shrinker->seeks) {
 			print_symbol("shrinker %s has zero seeks\n",
-				(unsigned long)shrinker->shrinker);
+				(unsigned long)shrinker->shrink);
 			delta = (4 * scanned) / DEFAULT_SEEKS;
 		} else {
 			delta = (4 * scanned) / shrinker->seeks;
@@ -223,8 +203,8 @@ unsigned long shrink_slab(unsigned long 
 			int shrink_ret;
 			int nr_before;
 
-			nr_before = (*shrinker->shrinker)(0, gfp_mask);
-			shrink_ret = (*shrinker->shrinker)(this_scan, gfp_mask);
+			nr_before = (*shrinker->shrink)(0, gfp_mask);
+			shrink_ret = (*shrinker->shrink)(this_scan, gfp_mask);
 			if (shrink_ret == -1)
 				break;
 			if (shrink_ret < nr_before)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
