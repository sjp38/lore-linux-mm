Date: Wed, 1 Jun 2005 10:22:41 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH 1/4] VM: add may_swap flag to scan_control
Message-ID: <20050601142241.GT14894@localhost>
References: <20050601141154.GN14894@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050601141154.GN14894@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Ray Bryant <raybry@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

This adds an extra switch to the scan_control struct.  It simply
lets the reclaim code know if its allowed to swap pages out.

This was required for a simple per-zone reclaimer.  Without this
addition pages would be swapped out as soon as a zone ran out of
memory and the early reclaim kicked in.

Signed-off-by: Martin Hicks <mort@sgi.com>

 mm/vmscan.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

Index: linux-2.6.12-rc5-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.12-rc5-mm1.orig/mm/vmscan.c	2005-05-26 12:27:01.000000000 -0700
+++ linux-2.6.12-rc5-mm1/mm/vmscan.c	2005-05-26 12:27:05.000000000 -0700
@@ -74,6 +74,9 @@ struct scan_control {
 
 	int may_writepage;
 
+	/* Can pages be swapped as part of reclaim? */
+	int may_swap;
+
 	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
 	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
 	 * In this context, it doesn't matter that we scan the
@@ -414,7 +417,7 @@ static int shrink_list(struct list_head 
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
+		if (PageAnon(page) && !PageSwapCache(page) && sc->may_swap) {
 			void *cookie = page->mapping;
 			pgoff_t index = page->index;
 
@@ -930,6 +933,7 @@ int try_to_free_pages(struct zone **zone
 
 	sc.gfp_mask = gfp_mask;
 	sc.may_writepage = 0;
+	sc.may_swap = 1;
 
 	inc_page_state(allocstall);
 
@@ -1030,6 +1034,7 @@ loop_again:
 	total_reclaimed = 0;
 	sc.gfp_mask = GFP_KERNEL;
 	sc.may_writepage = 0;
+	sc.may_swap = 1;
 	sc.nr_mapped = read_page_state(nr_mapped);
 
 	inc_page_state(pageoutrun);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
