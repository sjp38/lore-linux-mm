Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [RFC][PATCH] cache shrinking via page age
Date: Mon, 13 May 2002 22:38:31 -0400
References: <200205111614.29698.tomlins@cam.org> <200205120949.13081.tomlins@cam.org>
In-Reply-To: <200205120949.13081.tomlins@cam.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200205132238.31589.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@zip.com.au>
List-ID: <linux-mm.kvack.org>

Hi,

Andrew Morton pointed out that the kernel is using 8m pages and is 
setting reference bits for these pages...  He suggested (amoung other
things - thanks) that setting the bits in kmem_cache_alloc would be 
a good start to making aging happen.   This version of the patch 
impliments his suggestion.

Comments?

Ed Tomlinson

On May 11, 2002 04:14 pm, Ed Tomlinson wrote:

> > When running under low vm pressure rmap does not shrink caches.   This
> > happens since we only call do_try_to_free_pages when we have a shortage.
> > On my box the combination of background_aging calling
> > refill_inactive_zone is able to supply the pages needed.  The end result
> > of this the box acts sluggish, with about half my memory used by slab
> > pages (dcache/icache). This does correct itself under pressure but it
> > should never get into this state in the first place.
> >
> > Idealy we want all pages to be about the same age.  Having half the pages
> > in the system 'cold' in the slab cache is not good - it implies the other
> > pages are 'hotter' than they need to be.
> >
> > To fix the situation I move reapable slab pages into the active list. 
> > When aging moves a page into the inactive dirty list I watch for slab
> > pages and record the caches with old pages.  After
> > refill_inactive/background_aging ends I call a new function,
> > kmem_call_shrinkers.  This scans the list of slab caches and, via a
> > callback, shrinks caches with old pages.  Note that we never swap out
> > slab pages they just cycle through active and inactive dirty lists.
> >
> > The end result is that slab caches are shrunk selectivily when they have
> > old 'cold' pages.  I avoid adding any magic numbers to the vm and create
> > a generic interface to allow creators of slab caches to supply the vm
> > with a unique method to shrink their caches.
> >
> > When testing this there is one side effect to remember.  Using cat
> > /proc/slabinfo references pages - this will tend to keep the slab pages
> > warmer than they should be.  Like in quantum theory, watching (to often)
> > can change results.
>
> One additional comment.  I have tried modifing kmem_cache_shrink_nr to
> free only the number of pages seen by refill_inactive_zone.  This scheme
> revives the original problem.  Think the issue is that, in essence, the the
> dentry/inode caches often work in read once mode (thats each object in
> a slab is used once...).   Without the more aggresive shrink in this patch
> the 'read once' slab pages upset the vm balance.
>
> A data point.   Comparing this patch to my previous one the inode/entry
> caches stabilize at about twice the size here.
>
> > I have testing on UP only - think the locking is ok though...

Patch is against 2.4.19-pre7-ac2

--------------
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.422   -> 1.432  
#	         fs/dcache.c	1.18    -> 1.20   
#	         mm/vmscan.c	1.60    -> 1.66   
#	include/linux/slab.h	1.9     -> 1.11   
#	           mm/slab.c	1.16    -> 1.22   
#	          fs/inode.c	1.35    -> 1.38   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/05/10	ed@oscar.et.ca	1.423
# Use the vm's page aging to tell us when we need to shrink the caches.
# The vm uses callbacks to tell the slabs caches its time to shrink.
# --------------------------------------------
# 02/05/10	ed@oscar.et.ca	1.424
# Change the way process_shrinks is called so refill_invalid does not
# need to be changed.
# --------------------------------------------
# 02/05/10	ed@oscar.et.ca	1.425
# Remove debuging stuff
# --------------------------------------------
# 02/05/11	ed@oscar.et.ca	1.426
# Simplify the scheme.  Use per cache callbacks instead of per family.
# This lets us target specific caches instead of being generic.  We
# still include a generic call (kmem_cache_reap) as a failsafe
# before ooming.
# --------------------------------------------
# 02/05/11	ed@oscar.et.ca	1.427
# Remove debugging printk
# --------------------------------------------
# 02/05/11	ed@oscar.et.ca	1.428
# Change factoring, removing changes from background_aging and putting
# the kmem_call_shrinkers call in kswapd.
# --------------------------------------------
# 02/05/12	ed@oscar.et.ca	1.429
# The icache is a slave of the dcache.  We will not reuse the inodes so
# lets clean them all.
# --------------------------------------------
# 02/05/12	ed@oscar.et.ca	1.430
# Only call shrink callback if we have seen a slab's worth of pages
# --------------------------------------------
# 02/05/13	ed@oscar.et.ca	1.431
# Andrew Morton pointed out that kernal pages are big (8M) and the 
# hardware reference bit is working with these big pages.  This makes 
# aging slabs on 4K pages a little more difficult.  Andrew suggested 
# hooking into the kmem_cache_alloc process and set the bit(s) there.  
# This changeset does this.
# --------------------------------------------
# 02/05/13	ed@oscar.et.ca	1.432
# Cleanup debug stuff
# --------------------------------------------
#
diff -Nru a/fs/dcache.c b/fs/dcache.c
--- a/fs/dcache.c	Mon May 13 22:27:31 2002
+++ b/fs/dcache.c	Mon May 13 22:27:31 2002
@@ -1186,6 +1186,8 @@
 	if (!dentry_cache)
 		panic("Cannot create dentry cache");
 
+	kmem_set_shrinker(dentry_cache, (shrinker_t)kmem_shrink_dcache);
+
 #if PAGE_SHIFT < 13
 	mempages >>= (13 - PAGE_SHIFT);
 #endif
@@ -1278,6 +1280,9 @@
 			SLAB_HWCACHE_ALIGN, NULL, NULL);
 	if (!dquot_cachep)
 		panic("Cannot create dquot SLAB cache");
+	
+	kmem_set_shrinker(dquot_cachep, (shrinker_t)kmem_shrink_dquota);
+	
 #endif
 
 	dcache_init(mempages);
diff -Nru a/fs/inode.c b/fs/inode.c
--- a/fs/inode.c	Mon May 13 22:27:31 2002
+++ b/fs/inode.c	Mon May 13 22:27:31 2002
@@ -722,7 +722,7 @@
 	if (!(gfp_mask & __GFP_FS))
 		return 0;
 
-	count = inodes_stat.nr_unused / priority;
+	count = inodes_stat.nr_unused;
 
 	prune_icache(count);
 	return kmem_cache_shrink_nr(inode_cachep);
@@ -1172,6 +1172,8 @@
 					 NULL);
 	if (!inode_cachep)
 		panic("cannot create inode slab cache");
+
+	kmem_set_shrinker(inode_cachep, (shrinker_t)kmem_shrink_icache);
 
 	unused_inodes_flush_task.routine = try_to_sync_unused_inodes;
 }
diff -Nru a/include/linux/slab.h b/include/linux/slab.h
--- a/include/linux/slab.h	Mon May 13 22:27:31 2002
+++ b/include/linux/slab.h	Mon May 13 22:27:31 2002
@@ -55,6 +55,19 @@
 				       void (*)(void *, kmem_cache_t *, unsigned long));
 extern int kmem_cache_destroy(kmem_cache_t *);
 extern int kmem_cache_shrink(kmem_cache_t *);
+
+typedef int (*shrinker_t)(kmem_cache_t *, int, int);
+
+extern void kmem_set_shrinker(kmem_cache_t *, shrinker_t);
+extern int kmem_call_shrinkers(int, int);
+extern void kmem_count_page(struct page *);
+
+/* shrink drivers */
+extern int kmem_shrink_default(kmem_cache_t *, int, int);
+extern int kmem_shrink_dcache(kmem_cache_t *, int, int);
+extern int kmem_shrink_icache(kmem_cache_t *, int, int);
+extern int kmem_shrink_dquota(kmem_cache_t *, int, int);
+
 extern int kmem_cache_shrink_nr(kmem_cache_t *);
 extern void *kmem_cache_alloc(kmem_cache_t *, int);
 extern void kmem_cache_free(kmem_cache_t *, void *);
diff -Nru a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c	Mon May 13 22:27:31 2002
+++ b/mm/slab.c	Mon May 13 22:27:31 2002
@@ -213,6 +213,8 @@
 	kmem_cache_t		*slabp_cache;
 	unsigned int		growing;
 	unsigned int		dflags;		/* dynamic flags */
+	shrinker_t		shrinker;	/* shrink callback */
+	int 			count;		/* count used to trigger shrink */
 
 	/* constructor func */
 	void (*ctor)(void *, kmem_cache_t *, unsigned long);
@@ -382,6 +384,69 @@
 static void enable_cpucache (kmem_cache_t *cachep);
 static void enable_all_cpucaches (void);
 #endif
+ 
+/* set the shrink family and function */
+void kmem_set_shrinker(kmem_cache_t * cachep, shrinker_t theshrinker) 
+{
+	cachep->shrinker = theshrinker;
+}
+
+/* used by refill_inactive_zone to determine caches that need shrinking */
+void kmem_count_page(struct page *page)
+{
+	kmem_cache_t *cachep = GET_PAGE_CACHE(page);
+	cachep->count++;
+}
+
+/* call the shrink family function */
+int kmem_call_shrinkers(int priority, int gfp_mask) 
+{
+	int ret = 0;
+	struct list_head *p;
+
+        if (gfp_mask & __GFP_WAIT)
+                down(&cache_chain_sem);
+        else
+                if (down_trylock(&cache_chain_sem))
+                        return 0;
+
+        list_for_each(p,&cache_chain) {
+                kmem_cache_t *cachep = list_entry(p, kmem_cache_t, next);
+		if (cachep->count >= (1<<cachep->gfporder)) {
+			if (cachep->shrinker == NULL)
+				BUG();
+			ret += (*cachep->shrinker)(cachep, priority, gfp_mask);
+			cachep->count = 0;
+		}		
+        }
+        up(&cache_chain_sem);
+	return ret;
+}
+
+/* shink methods */
+int kmem_shrink_default(kmem_cache_t * cachep, int priority, int gfp_mask) 
+{
+	return kmem_cache_shrink_nr(cachep);
+}
+
+int kmem_shrink_dcache(kmem_cache_t * cachep, int priority, int gfp_mask) 
+{
+	return shrink_dcache_memory(priority, gfp_mask);
+}
+
+int kmem_shrink_icache(kmem_cache_t * cachep, int priority, int gfp_mask) 
+{
+	return shrink_icache_memory(priority, gfp_mask);
+}
+
+#if defined (CONFIG_QUOTA)
+
+int kmem_shrink_dquota(kmem_cache_t * cachep, int priority, int gfp_mask) 
+{
+	return shrink_dqcache_memory(priority, gfp_mask);
+}
+
+#endif
 
 /* Cal the num objs, wastage, and bytes left over for a given slab size. */
 static void kmem_cache_estimate (unsigned long gfporder, size_t size,
@@ -514,12 +579,31 @@
 	 * vm_scan(). Shouldn't be a worry.
 	 */
 	while (i--) {
+		if (!(cachep->flags & SLAB_NO_REAP))
+			lru_cache_del(page);
 		PageClearSlab(page);
 		page++;
 	}
 	free_pages((unsigned long)addr, cachep->gfporder);
 }
 
+/*
+ * kernel pages are 8M so 4k page ref bit is not set - we need to
+ * do it manually...
+ */
+void kmem_set_referenced(kmem_cache_t *cachep, slab_t *slabp)
+{
+        if (!(cachep->flags & SLAB_NO_REAP)) {
+        	unsigned long i = (1<<cachep->gfporder);
+        	struct page *page = virt_to_page(slabp->s_mem-slabp->colouroff);
+        	while (i--) {
+			SetPageReferenced(page);
+                	page++;
+		}
+        }
+}
+
+
 #if DEBUG
 static inline void kmem_poison_obj (kmem_cache_t *cachep, void *addr)
 {
@@ -781,6 +865,8 @@
 		flags |= CFLGS_OPTIMIZE;
 
 	cachep->flags = flags;
+	cachep->shrinker = ( shrinker_t)(kmem_shrink_default);
+	cachep->count = 0;
 	cachep->gfpflags = 0;
 	if (flags & SLAB_CACHE_DMA)
 		cachep->gfpflags |= GFP_DMA;
@@ -1184,6 +1270,8 @@
 		SET_PAGE_CACHE(page, cachep);
 		SET_PAGE_SLAB(page, slabp);
 		PageSetSlab(page);
+		if (!(cachep->flags & SLAB_NO_REAP))
+			lru_cache_add(page);
 		page++;
 	} while (--i);
 
@@ -1265,6 +1353,7 @@
 		list_del(&slabp->list);
 		list_add(&slabp->list, &cachep->slabs_full);
 	}
+	kmem_set_referenced(cachep, slabp);
 #if DEBUG
 	if (cachep->flags & SLAB_POISON)
 		if (kmem_check_poison_obj(cachep, objp))
@@ -1903,6 +1992,7 @@
 		unsigned long	num_objs;
 		unsigned long	active_slabs = 0;
 		unsigned long	num_slabs;
+		int		ref;
 		cachep = list_entry(p, kmem_cache_t, next);
 
 		spin_lock_irq(&cachep->spinlock);
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Mon May 13 22:27:31 2002
+++ b/mm/vmscan.c	Mon May 13 22:27:31 2002
@@ -102,6 +102,9 @@
 			continue;
 		}
 
+		if (PageSlab(page))
+			BUG();
+
 		/* Page is being freed */
 		if (unlikely(page_count(page)) == 0) {
 			list_del(page_lru);
@@ -244,7 +247,8 @@
 		 * The page is in active use or really unfreeable. Move to
 		 * the active list and adjust the page age if needed.
 		 */
-		if (page_referenced(page) && page_mapping_inuse(page) &&
+		if (page_referenced(page) &&
+				(page_mapping_inuse(page) || PageSlab(page)) &&
 				!page_over_rsslimit(page)) {
 			del_page_from_inactive_dirty_list(page);
 			add_page_to_active_list(page);
@@ -253,6 +257,13 @@
 		}
 
 		/*
+		 * SlabPages get shrunk in refill_inactive_zone.  These pages
+		 * are 'naked' - we do not want any other tests done on them...
+		 */
+		if (PageSlab(page))
+			continue;
+
+		/*
 		 * Page is being freed, don't worry about it.
 		 */
 		if (unlikely(page_count(page)) == 0)
@@ -446,6 +457,7 @@
  * This function will scan a portion of the active list of a zone to find
  * unused pages, those pages will then be moved to the inactive list.
  */
+
 int refill_inactive_zone(struct zone_struct * zone, int priority)
 {
 	int maxscan = zone->active_pages >> priority;
@@ -473,7 +485,7 @@
 		 * bother with page aging.  If the page is touched again
 		 * while on the inactive_clean list it'll be reactivated.
 		 */
-		if (!page_mapping_inuse(page)) {
+		if (!page_mapping_inuse(page) && !PageSlab(page)) {
 			drop_page(page);
 			continue;
 		}
@@ -497,8 +509,12 @@
 			list_add(page_lru, &zone->active_list);
 		} else {
 			deactivate_page_nolock(page);
-			if (++nr_deactivated > target)
+			if (PageSlab(page))
+				kmem_count_page(page);
+			else {
+				if (++nr_deactivated > target)
 				break;
+			}
 		}
 
 		/* Low latency reschedule point */
@@ -513,6 +529,7 @@
 	return nr_deactivated;
 }
 
+
 /**
  * refill_inactive - checks all zones and refills the inactive list as needed
  *
@@ -577,24 +594,15 @@
 
 	/*
 	 * Eat memory from filesystem page cache, buffer cache,
-	 * dentry, inode and filesystem quota caches.
 	 */
 	ret += page_launder(gfp_mask);
-	ret += shrink_dcache_memory(DEF_PRIORITY, gfp_mask);
-	ret += shrink_icache_memory(1, gfp_mask);
-#ifdef CONFIG_QUOTA
-	ret += shrink_dqcache_memory(DEF_PRIORITY, gfp_mask);
-#endif
 
 	/*
-	 * Move pages from the active list to the inactive list.
+	 * Move pages from the active list to the inactive list and
+	 * shrink caches return pages gained by shrink
 	 */
 	refill_inactive();
-
-	/* 	
-	 * Reclaim unused slab cache memory.
-	 */
-	ret += kmem_cache_reap(gfp_mask);
+	ret += kmem_call_shrinkers(DEF_PRIORITY, gfp_mask);
 
 	refill_freelist();
 
@@ -603,11 +611,14 @@
 		run_task_queue(&tq_disk);
 
 	/*
-	 * Hmm.. Cache shrink failed - time to kill something?
+	 * Hmm.. - time to kill something?
 	 * Mhwahahhaha! This is the part I really like. Giggle.
 	 */
-	if (!ret && free_min(ANY_ZONE) > 0)
-		out_of_memory();
+	if (!ret && free_min(ANY_ZONE) > 0) {
+		ret += kmem_cache_reap(gfp_mask);
+		if (!ret)
+			out_of_memory();
+	}
 
 	return ret;
 }
@@ -700,6 +711,7 @@
 
 			/* Do background page aging. */
 			background_aging(DEF_PRIORITY);
+			kmem_call_shrinkers(DEF_PRIORITY, GFP_KSWAPD);
 		}
 
 		wakeup_memwaiters();

--------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
