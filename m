Date: Tue, 30 May 2000 19:49:01 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] VM bugfix + rebalanced + code beauty
Message-ID: <Pine.LNX.4.21.0005301941030.16985-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: evil7@bellsouth.net
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi evil7, Alan,

here is a patch (versus 2.4.0-test1-ac5 and 6) that fixes a number
of things in the VM subsystem.

- since the pagecache can now contain dirty pages, we no
  longer take them out of the pagecache when they get dirtied
- the aging code is beautified and better readable
- don't start IO on a page from the wrong zone (in shrink_mmap),
  this should make the stalls less
- in __alloc_pages(), wake up kswapd when zone->zone_wake_kswapd
  is set for *all* zones, and keep waking it up until it is reset
  for at least one zone   (the rinse, leather, repeat algorithm
  should give us proper balancing between zones here)
- keep a smaller percentage of highmem pages free
- don't give up so early in __alloc_pages ... as long as there is
  still hope, we keep trying; this should make VM more stable too

The biggest impact is the change where we wake up kswapd when
we should ... this makes kswapd do all the hard work in the
background so foreground applications can just continue with
the allocation without stalls. This will make kswapd use a
little bit more CPU, but since this reduces latency for your
applications a lot this is nothing to worry about.

I'm interested in situations where the code still does the
"wrong thing", but of course I'd also like to hear of any
success stories ;)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/


--- linux-2.4.0-t1-ac5/mm/filemap.c.orig	Tue May 30 12:54:44 2000
+++ linux-2.4.0-t1-ac5/mm/filemap.c	Tue May 30 19:00:43 2000
@@ -56,6 +56,8 @@
 #define CLUSTER_PAGES		(1 << page_cluster)
 #define CLUSTER_OFFSET(x)	(((x) >> page_cluster) << page_cluster)
 
+#define min(a,b)		((a < b) ? a : b)
+
 void __add_page_to_hash_queue(struct page * page, struct page **p)
 {
 	atomic_inc(&page_cache_size);
@@ -265,19 +267,25 @@
 		list_del(page_lru);
 
 		if (PageTestandClearReferenced(page)) {
-			page->age += 3;
-			if (page->age > 10)
-				page->age = 10;
+			page->age += PG_AGE_ADV;
+			if (page->age > PG_AGE_MAX)
+				page->age = PG_AGE_MAX;
 			goto dispose_continue;
 		}
-		if (page->age)
-			page->age--;
+		page->age -= min(PG_AGE_DECL, page->age);
 
 		if (page->age)
 			goto dispose_continue;
 
 		count--;
 		/*
+		 * Page is from a zone we don't care about.
+		 * Don't drop page cache entries in vain.
+		 */
+		if (page->zone->free_pages > page->zone->pages_high)
+			goto dispose_continue;
+
+		/*
 		 * Avoid unscalable SMP locking for pages we can
 		 * immediate tell are untouchable..
 		 */
@@ -326,13 +334,6 @@
 			goto cache_unlock_continue;
 
 		/*
-		 * Page is from a zone we don't care about.
-		 * Don't drop page cache entries in vain.
-		 */
-		if (page->zone->free_pages > page->zone->pages_high)
-			goto cache_unlock_continue;
-
-		/*
 		 * Is it a page swap page? If so, we want to
 		 * drop it if it is no longer used, even if it
 		 * were to be marked referenced..
@@ -345,7 +346,7 @@
 			}
 			/* PageDeferswap -> we swap out the page now. */
 			if (gfp_mask & __GFP_IO)
-				goto async_swap;
+				goto async_swap_continue;
 			goto cache_unlock_continue;
 		}
 
@@ -368,7 +369,7 @@
 		UnlockPage(page);
 		page_cache_release(page);
 		goto dispose_continue;
-async_swap:
+async_swap_continue:
 		spin_unlock(&pagecache_lock);
 		/* Do NOT unlock the page ... that is done after IO. */
 		ClearPageDirty(page);
--- linux-2.4.0-t1-ac5/mm/memory.c.orig	Tue May 30 12:54:44 2000
+++ linux-2.4.0-t1-ac5/mm/memory.c	Tue May 30 18:59:36 2000
@@ -847,7 +847,7 @@
 			UnlockPage(old_page);
 			break;
 		}
-		delete_from_swap_cache_nolock(old_page);
+		SetPageDirty(old_page);
 		UnlockPage(old_page);
 		/* FallThrough */
 	case 1:
@@ -1058,7 +1058,7 @@
 	 */
 	lock_page(page);
 	swap_free(entry);
-	if (write_access && !is_page_shared(page)) {
+	if (write_access && !is_page_shared(page) && nr_free_highpages()) {
 		delete_from_swap_cache_nolock(page);
 		UnlockPage(page);
 		page = replace_with_highmem(page);
--- linux-2.4.0-t1-ac5/mm/page_alloc.c.orig	Tue May 30 12:54:44 2000
+++ linux-2.4.0-t1-ac5/mm/page_alloc.c	Tue May 30 19:26:06 2000
@@ -29,7 +29,7 @@
 pg_data_t *pgdat_list;
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
-static int zone_balance_ratio[MAX_NR_ZONES] = { 128, 128, 128, };
+static int zone_balance_ratio[MAX_NR_ZONES] = { 128, 128, 512, };
 static int zone_balance_min[MAX_NR_ZONES] = { 10 , 10, 10, };
 static int zone_balance_max[MAX_NR_ZONES] = { 255 , 255, 255, };
 
@@ -141,10 +141,13 @@
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 
-	if (zone->free_pages > zone->pages_high) {
-		zone->zone_wake_kswapd = 0;
+	if (zone->free_pages >= zone->pages_low) {
 		zone->low_on_memory = 0;
 	}
+
+	if (zone->free_pages >= zone->pages_high) {
+		zone->zone_wake_kswapd = 0;
+	}
 }
 
 #define MARK_USED(index, order, area) \
@@ -239,14 +242,16 @@
 			struct page *page = rmqueue(z, order);
 			if (z->free_pages < z->pages_low) {
 				z->zone_wake_kswapd = 1;
-				if (waitqueue_active(&kswapd_wait))
-					wake_up_interruptible(&kswapd_wait);
 			}
 			if (page)
 				return page;
 		}
 	}
 
+	/* All zones are in need of kswapd. */
+	if (waitqueue_active(&kswapd_wait))
+		wake_up_interruptible(&kswapd_wait);
+
 	/*
 	 * Ok, we don't have any zones that don't need some
 	 * balancing.. See if we have any that aren't critical..
@@ -258,7 +263,7 @@
 			break;
 		if (!z->low_on_memory) {
 			struct page *page = rmqueue(z, order);
-			if (z->free_pages < z->pages_min)
+			if (z->free_pages < (z->pages_min + z->pages_low) / 2)
 				z->low_on_memory = 1;
 			if (page)
 				return page;
@@ -279,7 +284,7 @@
 	}
 
 	/*
-	 * Final phase: allocate anything we can!
+	 * We freed something, so we're allowed to allocate anything we can!
 	 */
 	zone = zonelist->zones;
 	for (;;) {
@@ -294,6 +299,19 @@
 	}
 
 fail:
+	/* Last try, zone->low_on_memory isn't reset until we hit pages_low */
+	zone = zonelist->zones;
+	for (;;) {
+		zone_t *z = *(zone++);
+		int gfp_mask = zonelist->gfp_mask;
+		if (!z)
+			break;
+		if (z->free_pages > z->pages_min) {
+			struct page *page = rmqueue(z, order);
+			if (page)
+				return page;
+		}
+	}
 	/* No luck.. */
 	return NULL;
 }
--- linux-2.4.0-t1-ac5/include/linux/swap.h.orig	Tue May 30 14:29:42 2000
+++ linux-2.4.0-t1-ac5/include/linux/swap.h	Tue May 30 14:36:53 2000
@@ -161,6 +161,16 @@
 extern spinlock_t pagemap_lru_lock;
 
 /*
+ * Magic constants for page aging. If the system is programmed
+ * right, tweaking these should have almost no effect...
+ * The 2.4 code, however, is mostly simple and stable ;)
+ */
+#define PG_AGE_MAX	64
+#define PG_AGE_START	5
+#define PG_AGE_ADV	3
+#define PG_AGE_DECL	1
+
+/*
  * Helper macros for lru_pages handling.
  */
 #define	lru_cache_add(page)			\
@@ -168,7 +178,7 @@
 	spin_lock(&pagemap_lru_lock);		\
 	list_add(&(page)->lru, &lru_cache);	\
 	nr_lru_pages++;				\
-	page->age = 2;				\
+	page->age = PG_AGE_START;		\
 	SetPageActive(page);			\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
