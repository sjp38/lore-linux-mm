Date: Mon, 18 Jun 2007 13:52:29 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] mm: More __meminit annotations.
Message-ID: <20070618045229.GA31635@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sam Ravnborg <sam@ravnborg.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Currently zone_spanned_pages_in_node() and zone_absent_pages_in_node()
are non-static for ARCH_POPULATES_NODE_MAP and static otherwise. However,
only the non-static versions are __meminit annotated, despite only being
called from __meminit functions in either case.

zone_init_free_lists() is currently non-static and not __meminit
annotated either, despite only being called once in the entire tree by
init_currently_empty_zone(), which too is __meminit. So make it static
and properly annotated.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 mm/page_alloc.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bd8e335..12dc471 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1953,8 +1953,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	}
 }
 
-void zone_init_free_lists(struct pglist_data *pgdat, struct zone *zone,
-				unsigned long size)
+static void __meminit zone_init_free_lists(struct pglist_data *pgdat,
+				struct zone *zone, unsigned long size)
 {
 	int order;
 	for (order = 0; order < MAX_ORDER ; order++) {
@@ -2431,7 +2431,7 @@ void __meminit get_pfn_range_for_nid(unsigned int nid,
  * Return the number of pages a zone spans in a node, including holes
  * present_pages = zone_spanned_pages_in_node() - zone_absent_pages_in_node()
  */
-unsigned long __meminit zone_spanned_pages_in_node(int nid,
+static unsigned long __meminit zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
 					unsigned long *ignored)
 {
@@ -2519,7 +2519,7 @@ unsigned long __init absent_pages_in_range(unsigned long start_pfn,
 }
 
 /* Return the number of page frames in holes in a zone on a node */
-unsigned long __meminit zone_absent_pages_in_node(int nid,
+static unsigned long __meminit zone_absent_pages_in_node(int nid,
 					unsigned long zone_type,
 					unsigned long *ignored)
 {
@@ -2536,14 +2536,14 @@ unsigned long __meminit zone_absent_pages_in_node(int nid,
 }
 
 #else
-static inline unsigned long zone_spanned_pages_in_node(int nid,
+static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
 					unsigned long *zones_size)
 {
 	return zones_size[zone_type];
 }
 
-static inline unsigned long zone_absent_pages_in_node(int nid,
+static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
 						unsigned long zone_type,
 						unsigned long *zholes_size)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
