Date: Fri, 25 Aug 2006 18:24:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Replace min_unmapped_ratio by min_unmapped_pages in struct zone
Message-ID: <Pine.LNX.4.64.0608251823190.11715@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

*_pages is a better description of the role of the variable.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/vmscan.c	2006-08-23 12:37:01.865351033 -0700
+++ linux-2.6.18-rc4-mm2/mm/vmscan.c	2006-08-25 17:32:56.633796461 -0700
@@ -1626,7 +1626,7 @@ int zone_reclaim(struct zone *zone, gfp_
 	 * unmapped file backed pages.
 	 */
 	if (zone_page_state(zone, NR_FILE_PAGES) -
-	    zone_page_state(zone, NR_FILE_MAPPED) <= zone->min_unmapped_ratio)
+	    zone_page_state(zone, NR_FILE_MAPPED) <= zone->min_unmapped_pages)
 		return 0;
 
 	/*
Index: linux-2.6.18-rc4-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.18-rc4-mm2.orig/include/linux/mmzone.h	2006-08-23 12:37:01.103679381 -0700
+++ linux-2.6.18-rc4-mm2/include/linux/mmzone.h	2006-08-25 17:31:34.208237181 -0700
@@ -168,7 +168,7 @@ struct zone {
 	/*
 	 * zone reclaim becomes active if more unmapped pages exist.
 	 */
-	unsigned long		min_unmapped_ratio;
+	unsigned long		min_unmapped_pages;
 	struct per_cpu_pageset	*pageset[NR_CPUS];
 #else
 	struct per_cpu_pageset	pageset[NR_CPUS];
Index: linux-2.6.18-rc4-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/page_alloc.c	2006-08-23 12:37:01.845820991 -0700
+++ linux-2.6.18-rc4-mm2/mm/page_alloc.c	2006-08-25 17:33:44.045899298 -0700
@@ -2101,7 +2101,7 @@ static void __meminit free_area_init_cor
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
 #ifdef CONFIG_NUMA
-		zone->min_unmapped_ratio = (realsize*sysctl_min_unmapped_ratio)
+		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
 						/ 100;
 #endif
 		zone->name = zone_names[j];
@@ -2412,7 +2412,7 @@ int sysctl_min_unmapped_ratio_sysctl_han
 		return rc;
 
 	for_each_zone(zone)
-		zone->min_unmapped_ratio = (zone->present_pages *
+		zone->min_unmapped_pages = (zone->present_pages *
 				sysctl_min_unmapped_ratio) / 100;
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
