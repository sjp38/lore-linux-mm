Date: Wed, 15 Aug 2001 20:34:22 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 2.4.8-ac5 VM changes
Message-ID: <Pine.LNX.4.33L.0108152033200.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, andi@suse.de
List-ID: <linux-mm.kvack.org>

This time, WITH patch...
------------------------
Hi Alan,

the following patch implements these (trivial) things,
which clean up the code slightly and will give us the
opportunity to experiment with the VM by tuning some
parameters at run-time:

1) merge the page_age*() cleanups from -linus

2) make /proc/sys/vm/freepages writeable again

3) switch the page aging tactic in /proc/sys/vm:
     0)  no page aging
     1)  exponential decline   * current, default
     2)  linear decline        * Linux 2.0, FreeBSD

4) specify a static inactive_target in /proc/sys/vm,
   this can be good for some specific workloads, but
   seems mostly useful for VM experimenting and tuning

Note that this patch does not modify the default behaviour
of the kernel.

Please apply for the next -ac.

thanks,

Rik
--
IA64: a worthy successor to i860.


--- linux-2.4.8-ac5/fs/proc/proc_misc.c.orig	Wed Aug 15 06:20:45 2001
+++ linux-2.4.8-ac5/fs/proc/proc_misc.c	Wed Aug 15 06:36:57 2001
@@ -173,7 +173,7 @@
 		"Active:       %8u kB\n"
 		"Inact_dirty:  %8u kB\n"
 		"Inact_clean:  %8u kB\n"
-		"Inact_target: %8lu kB\n"
+		"Inact_target: %8u kB\n"
 		"HighTotal:    %8lu kB\n"
 		"HighFree:     %8lu kB\n"
 		"LowTotal:     %8lu kB\n"
@@ -189,7 +189,7 @@
 		K(nr_active_pages),
 		K(nr_inactive_dirty_pages),
 		K(nr_inactive_clean_pages()),
-		K(inactive_target),
+		K(inactive_target()),
 		K(i.totalhigh),
 		K(i.freehigh),
 		K(i.totalram-i.totalhigh),
--- linux-2.4.8-ac5/kernel/sysctl.c.orig	Wed Aug 15 01:35:40 2001
+++ linux-2.4.8-ac5/kernel/sysctl.c	Wed Aug 15 06:33:56 2001
@@ -22,6 +22,7 @@
 #include <linux/slab.h>
 #include <linux/sysctl.h>
 #include <linux/swapctl.h>
+#include <linux/swap.h>
 #include <linux/proc_fs.h>
 #include <linux/ctype.h>
 #include <linux/utsname.h>
@@ -259,7 +260,7 @@

 static ctl_table vm_table[] = {
 	{VM_FREEPG, "freepages",
-	 &freepages, sizeof(freepages_t), 0444, NULL, &proc_dointvec},
+	 &freepages, sizeof(freepages_t), 0644, NULL, &proc_dointvec},
 	{VM_BDFLUSH, "bdflush", &bdf_prm, 9*sizeof(int), 0644, NULL,
 	 &proc_dointvec_minmax, &sysctl_intvec, NULL,
 	 &bdflush_min, &bdflush_max},
@@ -281,6 +282,10 @@
 	&vm_min_readahead,sizeof(int), 0644, NULL, &proc_dointvec},
 	{VM_MAX_READAHEAD, "max-readahead",
 	&vm_max_readahead,sizeof(int), 0644, NULL, &proc_dointvec},
+	{VM_AGING_TACTIC, "page_aging_tactic",
+	 &page_aging_tactic, sizeof(int), 0644, NULL, &proc_dointvec},
+	{VM_INACTIVE_TARGET, "static_inactive_target",
+	 &static_inactive_target, sizeof(int), 0644, NULL, &proc_dointvec},
 	{0}
 };

--- linux-2.4.8-ac5/mm/swap.c.orig	Wed Aug 15 01:09:30 2001
+++ linux-2.4.8-ac5/mm/swap.c	Wed Aug 15 01:20:33 2001
@@ -75,82 +75,6 @@
 };

 /**
- * age_page_{up,down} -	page aging helper functions
- * @page - the page we want to age
- * @nolock - are we already holding the pagelist_lru_lock?
- *
- * If the page is on one of the lists (active, inactive_dirty or
- * inactive_clean), we will grab the pagelist_lru_lock as needed.
- * If you're already holding the lock, call this function with the
- * nolock argument non-zero.
- */
-void age_page_up_nolock(struct page * page)
-{
-	/*
-	 * We're dealing with an inactive page, move the page
-	 * to the active list.
-	 */
-	if (!page->age)
-		activate_page_nolock(page);
-
-	/* The actual page aging bit */
-	page->age += PAGE_AGE_ADV;
-	if (page->age > PAGE_AGE_MAX)
-		page->age = PAGE_AGE_MAX;
-}
-
-/*
- * We use this (minimal) function in the case where we
- * know we can't deactivate the page (yet).
- */
-void age_page_down_ageonly(struct page * page)
-{
-	page->age /= 2;
-}
-
-void age_page_down_nolock(struct page * page)
-{
-	/* The actual page aging bit */
-	page->age /= 2;
-
-	/*
-	 * The page is now an old page. Move to the inactive
-	 * list (if possible ... see below).
-	 */
-	if (!page->age)
-	       deactivate_page_nolock(page);
-}
-
-void age_page_up(struct page * page)
-{
-	/*
-	 * We're dealing with an inactive page, move the page
-	 * to the active list.
-	 */
-	if (!page->age)
-		activate_page(page);
-
-	/* The actual page aging bit */
-	page->age += PAGE_AGE_ADV;
-	if (page->age > PAGE_AGE_MAX)
-		page->age = PAGE_AGE_MAX;
-}
-
-void age_page_down(struct page * page)
-{
-	/* The actual page aging bit */
-	page->age /= 2;
-
-	/*
-	 * The page is now an old page. Move to the inactive
-	 * list (if possible ... see below).
-	 */
-	if (!page->age)
-	       deactivate_page(page);
-}
-
-
-/**
  * (de)activate_page - move pages from/to active and inactive lists
  * @page: the page we want to move
  * @nolock - are we already holding the pagemap_lru_lock?
--- linux-2.4.8-ac5/mm/vmscan.c.orig	Wed Aug 15 01:09:30 2001
+++ linux-2.4.8-ac5/mm/vmscan.c	Wed Aug 15 06:56:17 2001
@@ -25,6 +25,41 @@
 #include <asm/pgalloc.h>

 #define MAX(a,b) ((a) > (b) ? (a) : (b))
+int static_inactive_target;
+
+/*
+ * Helper functions for page aging. You can tune the page
+ * aging policy in /proc/sys/vm/page_aging_tactic.
+ */
+#define	PAGE_AGE_NONE		0
+#define	PAGE_AGE_EXPONENTIAL	1
+#define	PAGE_AGE_LINEAR		2
+int page_aging_tactic = PAGE_AGE_EXPONENTIAL;
+
+static inline void age_page_up(struct page *page)
+{
+	unsigned long age = page->age + PAGE_AGE_ADV;
+	if (age > PAGE_AGE_MAX)
+		age = PAGE_AGE_MAX;
+	page->age = age;
+}
+
+static inline void age_page_down(struct page *page)
+{
+	switch (page_aging_tactic) {
+		case PAGE_AGE_LINEAR:
+			if (page->age)
+				page->age -= PAGE_AGE_DECL;
+			break;
+		case PAGE_AGE_EXPONENTIAL:
+		default:
+			page->age /= 2;
+			break;
+		case PAGE_AGE_NONE:
+			page->age = 0;
+			break;
+	}
+}

 /*
  * The swap-out function returns 1 if it successfully
@@ -51,9 +86,7 @@

 	/* Don't look at this pte if it's been accessed recently. */
 	if (ptep_test_and_clear_young(page_table)) {
-		page->age += PAGE_AGE_ADV;
-		if (page->age > PAGE_AGE_MAX)
-			page->age = PAGE_AGE_MAX;
+		age_page_up(page);
 		return;
 	}

@@ -750,10 +783,10 @@

 		/* Do aging on the pages. */
 		if (PageTestandClearReferenced(page)) {
-			age_page_up_nolock(page);
+			age_page_up(page);
 			page_active = 1;
 		} else {
-			age_page_down_ageonly(page);
+			age_page_down(page);
 			/*
 			 * Since we don't hold a reference on the page
 			 * ourselves, we have to do our test a bit more
@@ -861,7 +894,7 @@
 	/* Is the inactive dirty list too small? */

 	shortage += freepages.high;
-	shortage += inactive_target;
+	shortage += inactive_target();
 	shortage -= nr_free_pages();
 	shortage -= nr_inactive_clean_pages();
 	shortage -= nr_inactive_dirty_pages;
--- linux-2.4.8-ac5/include/linux/mm.h.orig	Wed Aug 15 06:29:44 2001
+++ linux-2.4.8-ac5/include/linux/mm.h	Wed Aug 15 06:37:07 2001
@@ -13,7 +13,6 @@
 #include <linux/swap.h>

 extern unsigned long max_mapnr;
-extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
 /* The inactive_clean lists are per zone. */
--- linux-2.4.8-ac5/include/linux/swap.h.orig	Wed Aug 15 01:32:19 2001
+++ linux-2.4.8-ac5/include/linux/swap.h	Wed Aug 15 06:35:23 2001
@@ -79,6 +79,7 @@
 };

 extern int nr_swap_pages;
+extern unsigned long num_physpages;
 extern unsigned int nr_free_pages(void);
 extern unsigned int nr_free_pages_zone(int);
 extern unsigned int nr_inactive_clean_pages(void);
@@ -93,6 +94,10 @@
 extern spinlock_t pagecache_lock;
 extern void __remove_inode_page(struct page *);

+/* Sysctl tunables. */
+extern int page_aging_tactic;
+extern int static_inactive_target;
+
 /* Incomplete types for prototype declarations: */
 struct task_struct;
 struct vm_area_struct;
@@ -102,11 +107,6 @@

 /* linux/mm/swap.c */
 extern int memory_pressure;
-extern void age_page_up(struct page *);
-extern void age_page_up_nolock(struct page *);
-extern void age_page_down(struct page *);
-extern void age_page_down_nolock(struct page *);
-extern void age_page_down_ageonly(struct page *);
 extern void deactivate_page(struct page *);
 extern void deactivate_page_nolock(struct page *);
 extern void activate_page(struct page *);
@@ -198,6 +198,7 @@
  */
 #define PAGE_AGE_START 2
 #define PAGE_AGE_ADV 3
+#define PAGE_AGE_DECL 1
 #define PAGE_AGE_MAX 64

 /*
@@ -268,9 +269,27 @@
  * 64 (1 << INACTIVE_SHIFT) seconds.
  */
 #define INACTIVE_SHIFT 6
-#define inactive_min(a,b) ((a) < (b) ? (a) : (b))
-#define inactive_target inactive_min((memory_pressure >> INACTIVE_SHIFT), \
-		(num_physpages / 4))
+
+/*
+ * The target size for the inactive list, in pages.
+ *
+ * If the user specified a target in /proc/sys/vm/static_inactive_target
+ * we use that, otherwise we calculate one second of page replacement
+ * activity (memory pressure) capped to 1/4th of physical memory.
+ */
+static inline int inactive_target(void)
+{
+	int target;
+
+	if (static_inactive_target)
+		return static_inactive_target;
+
+	target = memory_pressure >> INACTIVE_SHIFT;
+	if (target > num_physpages / 4)
+		target = num_physpages / 4;
+
+	return target;
+}

 /*
  * Ugly ugly ugly HACK to make sure the inactive lists
--- linux-2.4.8-ac5/include/linux/sysctl.h.orig	Wed Aug 15 01:32:30 2001
+++ linux-2.4.8-ac5/include/linux/sysctl.h	Wed Aug 15 05:47:29 2001
@@ -138,7 +138,9 @@
 	VM_PAGE_CLUSTER=10,	/* int: set number of pages to swap together */
 	VM_MAX_MAP_COUNT=11,	/* int: Maximum number of active map areas */
         VM_MIN_READAHEAD=12,    /* Min file readahead */
-        VM_MAX_READAHEAD=13     /* Max file readahead */
+        VM_MAX_READAHEAD=13,    /* Max file readahead */
+	VM_AGING_TACTIC=14,	/* Page aging strategy */
+	VM_INACTIVE_TARGET=15,	/* Static inactive target, zero for dynamic */
 };



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
