Date: Fri, 15 Sep 2006 20:28:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Add node to zone for the NUMA case.
In-Reply-To: <20060915183604.11a8d045.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609152024020.10908@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
 <20060915170455.f8b98784.pj@sgi.com> <20060915183604.11a8d045.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Paul Jackson <pj@sgi.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add the node in order to optimize zone_to_nid.


Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.18-rc6-mm2.orig/include/linux/mmzone.h	2006-09-15 12:26:08.000000000 -0500
+++ linux-2.6.18-rc6-mm2/include/linux/mmzone.h	2006-09-15 22:11:53.103125905 -0500
@@ -168,6 +168,7 @@ struct zone {
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
 
 #ifdef CONFIG_NUMA
+	int node;
 	/*
 	 * zone reclaim becomes active if more unmapped pages exist.
 	 */
Index: linux-2.6.18-rc6-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/page_alloc.c	2006-09-15 12:43:12.000000000 -0500
+++ linux-2.6.18-rc6-mm2/mm/page_alloc.c	2006-09-15 22:13:02.412755301 -0500
@@ -2477,6 +2477,7 @@ static void __meminit free_area_init_cor
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
 #ifdef CONFIG_NUMA
+		zone->node = nid;
 		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
 						/ 100;
 		zone->min_slab_pages = (realsize * sysctl_min_slab_ratio) / 100;
Index: linux-2.6.18-rc6-mm2/include/linux/mm.h
===================================================================
--- linux-2.6.18-rc6-mm2.orig/include/linux/mm.h	2006-09-15 12:43:12.000000000 -0500
+++ linux-2.6.18-rc6-mm2/include/linux/mm.h	2006-09-15 22:13:23.418455663 -0500
@@ -449,7 +449,7 @@ static inline int page_zone_id(struct pa
 
 static inline unsigned long zone_to_nid(struct zone *zone)
 {
-	return zone->zone_pgdat->node_id;
+	return zone->node;
 }
 
 #ifdef NODE_NOT_IN_PAGE_FLAGS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
