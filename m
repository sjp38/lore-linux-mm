Message-ID: <4030BB86.8060206@cyberone.com.au>
Date: Mon, 16 Feb 2004 23:45:58 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: [PATCH] 2.6.3-rc3-mm1: align scan_page per node
Content-Type: multipart/mixed;
 boundary="------------020501030808040203050408"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <Nikita@Namesys.COM>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020501030808040203050408
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Ok ok, I'll do it... is this the right way to go about it?
I'm assuming it is worth doing?


--------------020501030808040203050408
Content-Type: text/plain;
 name="vm-align-scan_page.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-align-scan_page.patch"

 linux-2.6-npiggin/mm/page_alloc.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff -puN mm/page_alloc.c~vm-align-scan_page mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c~vm-align-scan_page	2004-02-16 22:52:26.000000000 +1100
+++ linux-2.6-npiggin/mm/page_alloc.c	2004-02-16 23:41:06.000000000 +1100
@@ -1217,8 +1217,14 @@ void __init memmap_init_zone(struct page
 	memmap_init_zone((start), (size), (nid), (zone), (start_pfn))
 #endif
 
-/* dummy pages used to scan active lists */
-static struct page scan_pages[MAX_NUMNODES][MAX_NR_ZONES];
+/*
+ * Dummy pages used to scan active lists. It would be cleaner if these
+ * could be part of struct zone directly, but include dependencies currently
+ * prevent that.
+ */
+static struct {
+	struct page zone[MAX_NR_ZONES];
+} ____cacheline_aligned scan_pages[MAX_NUMNODES];
 
 /*
  * Set up the zone data structures:
@@ -1299,7 +1305,7 @@ static void __init free_area_init_core(s
 		zone->nr_inactive = 0;
 
 		/* initialize dummy page used for scanning */
-		scan_page = &scan_pages[nid][j];
+		scan_page = &(scan_pages[nid].zone[j]);
 		zone->scan_page = scan_page;
 		memset(scan_page, 0, sizeof *scan_page);
 		scan_page->flags =

_

--------------020501030808040203050408--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
