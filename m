Message-Id: <20050810200944.197606000@jumble.boston.redhat.com>
References: <20050810200216.644997000@jumble.boston.redhat.com>
Date: Wed, 10 Aug 2005 16:02:21 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH/RFT 5/5] CLOCK-Pro page replacement
Content-Disposition: inline; filename=clockpro-stats
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Export the active limit statistic through /proc.  We may want to
export some more CLOCK-Pro statistics in the future, but I'm not
sure yet which ones.

Signed-off-by: Rik van Riel

Index: linux-2.6.12-vm/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.12-vm.orig/fs/proc/proc_misc.c
+++ linux-2.6.12-vm/fs/proc/proc_misc.c
@@ -125,11 +125,13 @@ static int meminfo_read_proc(char *page,
 	unsigned long free;
 	unsigned long committed;
 	unsigned long allowed;
+	unsigned long active_limit;
 	struct vmalloc_info vmi;
 	long cached;
 
 	get_page_state(&ps);
 	get_zone_counts(&active, &inactive, &free);
+	active_limit = get_active_limit();
 
 /*
  * display in kilobytes.
@@ -158,6 +160,7 @@ static int meminfo_read_proc(char *page,
 		"SwapCached:   %8lu kB\n"
 		"Active:       %8lu kB\n"
 		"Inactive:     %8lu kB\n"
+		"ActiveLimit:  %8lu kB\n"
 		"HighTotal:    %8lu kB\n"
 		"HighFree:     %8lu kB\n"
 		"LowTotal:     %8lu kB\n"
@@ -181,6 +184,7 @@ static int meminfo_read_proc(char *page,
 		K(total_swapcache_pages),
 		K(active),
 		K(inactive),
+		K(active_limit),
 		K(i.totalhigh),
 		K(i.freehigh),
 		K(i.totalram-i.totalhigh),
Index: linux-2.6.12-vm/include/linux/swap.h
===================================================================
--- linux-2.6.12-vm.orig/include/linux/swap.h
+++ linux-2.6.12-vm/include/linux/swap.h
@@ -161,6 +161,7 @@ extern void init_nonresident(void);
 /* linux/mm/clockpro.c */
 extern void remember_page(struct page *, struct address_space *, unsigned long);
 extern int page_is_hot(struct page *, struct address_space *, unsigned long);
+extern unsigned long get_active_limit(void);
 DECLARE_PER_CPU(unsigned long, evicted_pages);
 
 /* linux/mm/page_alloc.c */
Index: linux-2.6.12-vm/mm/clockpro.c
===================================================================
--- linux-2.6.12-vm.orig/mm/clockpro.c
+++ linux-2.6.12-vm/mm/clockpro.c
@@ -100,3 +100,14 @@ void remember_page(struct page * page, s
 			zone->active_limit < zone->present_pages * 7 / 8)
 		zone->active_limit++;
 }
+
+unsigned long get_active_limit(void)
+{
+	unsigned long total = 0;
+	struct zone * zone;
+	
+	for_each_zone(zone)
+		total += zone->active_limit;
+
+	return total;
+}

--
-- 
All Rights Reversed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
