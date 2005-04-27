Date: Wed, 27 Apr 2005 16:32:31 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH/RFC 2/4] VM: page cache reclaim core
Message-Id: <20050427163231.6d7e792e.akpm@osdl.org>
In-Reply-To: <20050427150932.GT8018@localhost>
References: <20050427145734.GL8018@localhost>
	<20050427150932.GT8018@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Hicks <mort@sgi.com>
Cc: linux-mm@kvack.org, raybry@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Martin Hicks <mort@sgi.com> wrote:
>
> The core of the local reclaim code.  It contains a few modifications
> to the current reclaim code to support scanning for easily freed
> Active pages. The core routine for reclaiming easily freed pages
> is reclaim_clean_pages().
> 
> The motivation for this patch is for NUMA systems that would much
> prefer to get local memory allocations if possible.  Large performance
> regressions have been seen in situations as simple as compiling
> kernels on a busy build server with a lot of memory trapped in page
> cache.
> 
> The feature adds the core mechanism to free up caches, although page cache
> freeing is the only one implemented currently.  Cleaning the slab
> cache is a future goal.
> 
> The follow-on patches provide a manual reclaim and automatic reclaim method.

Boy, it's a bit complex.

The timeout stuff looks a bit hairy and I'd like to hear more details about
why it is needed.   And why it wasn't implemented in the caller?

reclaim_clean_pages() needs an introductory comment.  Please include a
description of the handling of the `manual' thing, and a description of why
we have that stuf in there to prevent concurrent automatic reclaim.


I dinked with your patch:



- Don't need to show zone->unreclaimable in sysrq-M output: -mm has
  /proc/zoneinfo.

- `foo = ATOMIC_INIT()' doesn't compile.  Use atomic_set().

- Use jiffies, not get_jiffies_64().  The latter returns u64.

- Add comments (dammit)

- s/ALL_UNRECL/ALL_UNRECLAIMABLE/

- Don't assume that HZ = ~1000.


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/linux/mmzone.h |   13 ++++++-------
 mm/page_alloc.c        |   12 +++++-------
 mm/vmscan.c            |   45 +++++++++++++++++++++++++++------------------
 3 files changed, 38 insertions(+), 32 deletions(-)

diff -puN include/linux/mmzone.h~vm-page-cache-reclaim-core-tidy include/linux/mmzone.h
--- 25/include/linux/mmzone.h~vm-page-cache-reclaim-core-tidy	Wed Apr 27 16:22:35 2005
+++ 25-akpm/include/linux/mmzone.h	Wed Apr 27 16:22:35 2005
@@ -29,13 +29,12 @@ struct free_area {
 struct pglist_data;
 
 /*
- * Information about reclaimability of a zone's pages.
- * After we have scanned a zone and determined that there
- * are no other pages to free of a certain type we can
- * stop scanning it
+ * Information about reclaimability of a zone's pages, in zone->unreclaimable.
+ * After we have scanned a zone and determined that there are no other pages to
+ * free of a certain type we can stop scanning it.
  */
-#define CLEAN_UNRECL		0x1
-#define ALL_UNRECL		0x3
+#define CLEAN_UNRECLAIMABLE	0x1	/* No reclaimable clean pages */
+#define ALL_UNRECLAIMABLE	0x3	/* No reclaimable pages at all */
 
 /*
  * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
@@ -152,7 +151,7 @@ struct zone {
 	unsigned long		nr_inactive;
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			unreclaimable;     /* pinned pages marker */
-	atomic_t		reclaim_count;
+	atomic_t		reclaim_count;	   /* concurrency counter */
 	unsigned long		reclaim_timeout;
 
 	/*
diff -puN mm/vmscan.c~vm-page-cache-reclaim-core-tidy mm/vmscan.c
--- 25/mm/vmscan.c~vm-page-cache-reclaim-core-tidy	Wed Apr 27 16:22:35 2005
+++ 25-akpm/mm/vmscan.c	Wed Apr 27 16:22:35 2005
@@ -717,6 +717,9 @@ static void shrink_cache(struct zone *zo
  *
  * The downside is that we have to touch page->_count against each page.
  * But we had to alter page->flags anyway.
+ *
+ * Returns the number of pages which were moved from the active list to the
+ * inactive list.
  */
 static int
 refill_inactive_zone(struct zone *zone, struct scan_control *sc)
@@ -933,7 +936,7 @@ shrink_caches(struct zone **zones, struc
 		if (zone->prev_priority > sc->priority)
 			zone->prev_priority = sc->priority;
 
-		if (zone->unreclaimable == ALL_UNRECL &&
+		if (zone->unreclaimable == ALL_UNRECLAIMABLE &&
 		    		sc->priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
 
@@ -1098,7 +1101,7 @@ loop_again:
 				if (zone->present_pages == 0)
 					continue;
 
-				if (zone->unreclaimable == ALL_UNRECL &&
+				if (zone->unreclaimable == ALL_UNRECLAIMABLE &&
 				    		priority != DEF_PRIORITY)
 					continue;
 
@@ -1135,7 +1138,7 @@ scan:
 			if (zone->present_pages == 0)
 				continue;
 
-			if (zone->unreclaimable == ALL_UNRECL &&
+			if (zone->unreclaimable == ALL_UNRECLAIMABLE &&
 			    		priority != DEF_PRIORITY)
 				continue;
 
@@ -1158,11 +1161,11 @@ scan:
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_reclaimed += sc.nr_reclaimed;
 			total_scanned += sc.nr_scanned;
-			if (zone->unreclaimable == ALL_UNRECL)
+			if (zone->unreclaimable == ALL_UNRECLAIMABLE)
 				continue;
 			if (nr_slab == 0 && zone->pages_scanned >=
 				    (zone->nr_active + zone->nr_inactive) * 4)
-				zone->unreclaimable = ALL_UNRECL;
+				zone->unreclaimable = ALL_UNRECLAIMABLE;
 			/*
 			 * If we've done a decent amount of scanning and
 			 * the reclaim ratio is low, start doing writepage
@@ -1367,7 +1370,15 @@ module_init(kswapd_init)
 /* How many pages are processed at a time. */
 #define MIN_RECLAIM 32
 #define MAX_BATCH_SIZE 128
-#define UNRECLAIMABLE_TIMEOUT 5
+
+/*
+ * Rate-limit the period between automatic clean page reclaim attempts to this
+ * many jiffies.
+ */
+#define UNRECLAIMABLE_TIMEOUT_MSECS	5
+#define UNRECLAIMABLE_TIMEOUT_JIFS ((UNRECLAIMABLE_TIMEOUT_MSECS * HZ) / 1000)
+#define UNRECLAIMABLE_TIMEOUT \
+	(UNRECLAIMABLE_TIMEOUT_JIFS ? UNRECLAIMABLE_TIMEOUT_JIFS : 1)
 
 unsigned int reclaim_clean_pages(struct zone *zone, long pages, int flags)
 {
@@ -1379,15 +1390,14 @@ unsigned int reclaim_clean_pages(struct 
 	int manual = flags & RECLAIM_MANUAL;
 
 	/* Zone is marked dead */
-	if (zone->unreclaimable & CLEAN_UNRECL && !manual)
+	if ((zone->unreclaimable & CLEAN_UNRECLAIMABLE) && !manual)
 		return 0;
 
 	/* We don't really want to call this too often */
-	if (get_jiffies_64() < zone->reclaim_timeout) {
+	if (time_before(jiffies, zone->reclaim_timeout)) {
 		/* check for jiffies overflow -- needed? */
-		if (zone->reclaim_timeout - get_jiffies_64() >
-		    UNRECLAIMABLE_TIMEOUT)
-			zone->reclaim_timeout = get_jiffies_64();
+		if (zone->reclaim_timeout - jiffies > UNRECLAIMABLE_TIMEOUT)
+			zone->reclaim_timeout = jiffies;
 		else if (!manual)
 			return 0;
 	}
@@ -1411,9 +1421,8 @@ unsigned int reclaim_clean_pages(struct 
 		pages = MIN_RECLAIM;
 
 	/*
-	 * Also don't take too many pages at a time,
-	 * which can lead to a big overshoot in the
-	 * number of pages that are freed.
+	 * Also don't take too many pages at a time, which can lead to a big
+	 * overshoot in the number of pages that are freed.
 	 */
 	if (pages > MAX_BATCH_SIZE)
 		batch_size = MAX_BATCH_SIZE;
@@ -1454,7 +1463,8 @@ unsigned int reclaim_clean_pages(struct 
 	}
 
 	if (flags & (RECLAIM_ACTIVE_UNMAPPED | RECLAIM_ACTIVE_MAPPED)) {
-		/* Get flags for scan_control again, in case they were
+		/*
+		 * Get flags for scan_control again, in case they were
 		 * cleared while doing inactive reclaim
 		 */
 		sc.reclaim_flags = flags;
@@ -1487,9 +1497,8 @@ unsigned int reclaim_clean_pages(struct 
 
 	/* The goal wasn't met */
 	if (pages > 0) {
-		zone->reclaim_timeout = get_jiffies_64() +
-					UNRECLAIMABLE_TIMEOUT;
-		zone->unreclaimable |= CLEAN_UNRECL;
+		zone->reclaim_timeout = jiffies + UNRECLAIMABLE_TIMEOUT;
+		zone->unreclaimable |= CLEAN_UNRECLAIMABLE;
 	}
 
 	atomic_set(&zone->reclaim_count, -1);
diff -puN mm/page_alloc.c~vm-page-cache-reclaim-core-tidy mm/page_alloc.c
--- 25/mm/page_alloc.c~vm-page-cache-reclaim-core-tidy	Wed Apr 27 16:22:35 2005
+++ 25-akpm/mm/page_alloc.c	Wed Apr 27 16:24:03 2005
@@ -1279,7 +1279,6 @@ void show_free_areas(void)
 			" inactive:%lukB"
 			" present:%lukB"
 			" pages_scanned:%lu"
-			" unreclaimable: %d"
 			"\n",
 			zone->name,
 			K(zone->free_pages),
@@ -1289,8 +1288,7 @@ void show_free_areas(void)
 			K(zone->nr_active),
 			K(zone->nr_inactive),
 			K(zone->present_pages),
-			zone->pages_scanned,
-		        zone->unreclaimable
+			zone->pages_scanned
 			);
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
@@ -1712,8 +1710,8 @@ static void __init free_area_init_core(s
 		zone->nr_scan_inactive = 0;
 		zone->nr_active = 0;
 		zone->nr_inactive = 0;
-		zone->reclaim_count = ATOMIC_INIT(-1);
-		zone->reclaim_timeout = get_jiffies_64();
+		atomic_set(&zone->reclaim_count, -1);
+		zone->reclaim_timeout = jiffies;
 		if (!size)
 			continue;
 
@@ -1945,11 +1943,11 @@ static int zoneinfo_show(struct seq_file
 #endif
 		}
 		seq_printf(m,
-			   "\n  all_unreclaimable: %u"
+			   "\n  unreclaimable: %u"
 			   "\n  prev_priority:     %i"
 			   "\n  temp_priority:     %i"
 			   "\n  start_pfn:         %lu",
-			   zone->all_unreclaimable,
+			   zone->unreclaimable,
 			   zone->prev_priority,
 			   zone->temp_priority,
 			   zone->zone_start_pfn);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
