Received: from oscar.casa.dyndns.org ([65.92.168.147])
          by tomts21-srv.bellnexxia.net
          (InterMail vM.5.01.04.05 201-253-122-122-105-20011231) with ESMTP
          id <20020511201453.FNTY11344.tomts21-srv.bellnexxia.net@oscar.casa.dyndns.org>
          for <linux-mm@kvack.org>; Sat, 11 May 2002 16:14:53 -0400
Received: from oscar (localhost [127.0.0.1])
	by oscar.casa.dyndns.org (Postfix) with ESMTP id AD4EC16425
	for <linux-mm@kvack.org>; Sat, 11 May 2002 16:14:30 -0400 (EDT)
Content-Type: text/plain;
  charset="us-ascii"
From: Ed Tomlinson <tomlins@cam.org>
Subject: [RFC][PATCH] cache shrinking via page age 
Date: Sat, 11 May 2002 16:14:29 -0400
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200205111614.29698.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

When running under low vm pressure rmap does not shrink caches.   This 
happens since we only call do_try_to_free_pages when we have a shortage.  On
my box the combination of background_aging calling refill_inactive_zone is able
to supply the pages needed.  The end result of this the box acts sluggish, with
about half my memory used by slab pages (dcache/icache).   This does correct
itself under pressure but it should never get into this state in the first place.

Idealy we want all pages to be about the same age.  Having half the pages in the
system 'cold' in the slab cache is not good - it implies the other pages are 'hotter'
than they need to be.  

To fix the situation I move reapable slab pages into the active list.  When
aging moves a page into the inactive dirty list I watch for slab pages and record
the caches with old pages.  After refill_inactive/background_aging ends I call
a new function, kmem_call_shrinkers.  This scans the list of slab caches and, via
a callback, shrinks caches with old pages.  Note that we never swap out slab pages
they just cycle through active and inactive dirty lists.

The end result is that slab caches are shrunk selectivily when they have old 
'cold' pages.  I avoids adding any magic numbers to the vm and create 
a generic interface to allow creators of slab caches to supply the vm with a
unique method to shrink their caches.

When testing this there is one side effect to remember.  Using cat /proc/slabinfo
references pages - this will tend to keep the slab pages warmer than they should
be.  Like in quantum theory, watching (to often) can change results.

I have testing on UP only - think the locking is ok though...  

Patch is against 2.4.19-pre7-ac2

Comments?
Ed Tomlinson

------------
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.422   -> 1.428  
#	         fs/dcache.c	1.18    -> 1.20   
#	         mm/vmscan.c	1.60    -> 1.65   
#	include/linux/slab.h	1.9     -> 1.11   
#	           mm/slab.c	1.16    -> 1.19   
#	          fs/inode.c	1.35    -> 1.37   
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
#
diff -Nru a/fs/dcache.c b/fs/dcache.c
--- a/fs/dcache.c	Sat May 11 15:31:40 2002
+++ b/fs/dcache.c	Sat May 11 15:31:40 2002
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
--- a/fs/inode.c	Sat May 11 15:31:40 2002
+++ b/fs/inode.c	Sat May 11 15:31:40 2002
@@ -1173,6 +1173,8 @@
 	if (!inode_cachep)
 		panic("cannot create inode slab cache");
 
+	kmem_set_shrinker(inode_cachep, (shrinker_t)kmem_shrink_icache);
+
 	unused_inodes_flush_task.routine = try_to_sync_unused_inodes;
 }
 
diff -Nru a/include/linux/slab.h b/include/linux/slab.h
--- a/include/linux/slab.h	Sat May 11 15:31:40 2002
+++ b/include/linux/slab.h	Sat May 11 15:31:40 2002
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
--- a/mm/slab.c	Sat May 11 15:31:40 2002
+++ b/mm/slab.c	Sat May 11 15:31:40 2002
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
+		if (cachep->count > 0) {
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
@@ -514,6 +579,8 @@
 	 * vm_scan(). Shouldn't be a worry.
 	 */
 	while (i--) {
+		if (!(cachep->flags & SLAB_NO_REAP))
+			lru_cache_del(page);
 		PageClearSlab(page);
 		page++;
 	}
@@ -781,6 +848,8 @@
 		flags |= CFLGS_OPTIMIZE;
 
 	cachep->flags = flags;
+	cachep->shrinker = ( shrinker_t)(kmem_shrink_default);
+	cachep->count = 0;
 	cachep->gfpflags = 0;
 	if (flags & SLAB_CACHE_DMA)
 		cachep->gfpflags |= GFP_DMA;
@@ -1184,6 +1253,8 @@
 		SET_PAGE_CACHE(page, cachep);
 		SET_PAGE_SLAB(page, slabp);
 		PageSetSlab(page);
+		if (!(cachep->flags & SLAB_NO_REAP))
+			lru_cache_add(page);
 		page++;
 	} while (--i);
 
@@ -1903,6 +1974,7 @@
 		unsigned long	num_objs;
 		unsigned long	active_slabs = 0;
 		unsigned long	num_slabs;
+		int		ref;
 		cachep = list_entry(p, kmem_cache_t, next);
 
 		spin_lock_irq(&cachep->spinlock);
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Sat May 11 15:31:40 2002
+++ b/mm/vmscan.c	Sat May 11 15:31:40 2002
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
@@ -253,6 +257,12 @@
 		}
 
 		/*
+		 * SlabPages get shrunk in refill_inactive_zone
+		 */
+		if (PageSlab(page))
+			continue;
+
+		/*
 		 * Page is being freed, don't worry about it.
 		 */
 		if (unlikely(page_count(page)) == 0)
@@ -446,6 +456,7 @@
  * This function will scan a portion of the active list of a zone to find
  * unused pages, those pages will then be moved to the inactive list.
  */
+
 int refill_inactive_zone(struct zone_struct * zone, int priority)
 {
 	int maxscan = zone->active_pages >> priority;
@@ -473,7 +484,7 @@
 		 * bother with page aging.  If the page is touched again
 		 * while on the inactive_clean list it'll be reactivated.
 		 */
-		if (!page_mapping_inuse(page)) {
+		if (!page_mapping_inuse(page) && !PageSlab(page)) {
 			drop_page(page);
 			continue;
 		}
@@ -497,8 +508,12 @@
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
@@ -513,6 +528,7 @@
 	return nr_deactivated;
 }
 
+
 /**
  * refill_inactive - checks all zones and refills the inactive list as needed
  *
@@ -577,24 +593,15 @@
 
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
 
@@ -603,11 +610,14 @@
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
@@ -700,6 +710,7 @@
 
 			/* Do background page aging. */
 			background_aging(DEF_PRIORITY);
+			kmem_call_shrinkers(DEF_PRIORITY, GFP_KSWAPD);
 		}
 
 		wakeup_memwaiters();
------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
