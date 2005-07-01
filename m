Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j620WAFo017041
	for <linux-mm@kvack.org>; Fri, 1 Jul 2005 17:32:10 -0700
Date: Fri, 1 Jul 2005 15:40:58 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050701224058.542.34586.15636@jackhammer.engr.sgi.com>
In-Reply-To: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
References: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.13-rc1 3/11] mm: manual page migration-rc4 -- add-node_map-arg-to-try_to_migrate_pages-rc4.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch changes the interface to try_to_migrate_pages() so that one
can specify the nodes where the pages are to be migrated to.  This is
done by adding a "node_map" argument to try_to_migrate_pages(), node_map
is of type "int *".

If this argument is NULL, then try_to_migrate_pages() behaves exactly
as before and this is the interface the rest of the memory hotplug
patch should use.  (Note:  This patchset does not include the changes
for the rest of the memory hotplug patch that will be necessary to use
this new interface [if it is accepted].  Those chagnes will be provided
as a distinct patch.)

If the argument is non-NULL, the node_map points at an array of shorts
of size MAX_NUMNODES.   node_map[N] is either the id of an online node
or -1.  If node_map[N] >=0 then pages found in the page list passed
to try_to_migrate_pages() that are found on node N are migrated to node
node_map[N].  if node_map[N] == -1, then pages found on node N are left
where they are.

This change depends on previous changes to migrate_onepage()
that support migrating a page to a specified node.  These changes
are already part of the memory migration sub-patch of the memory
hotplug patch.

Signed-off-by:  Ray Bryant <raybry@sgi.com>

 include/linux/mmigrate.h |   11 ++++++++++-
 mm/mmigrate.c            |   10 ++++++----
 2 files changed, 16 insertions(+), 5 deletions(-)

Index: linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/mmigrate.h
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/include/linux/mmigrate.h	2005-06-10 14:47:25.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/mmigrate.h	2005-06-13 10:22:22.000000000 -0700
@@ -16,7 +16,16 @@ extern int migrate_page_buffer(struct pa
 extern int page_migratable(struct page *, struct page *, int,
 					struct list_head *);
 extern struct page * migrate_onepage(struct page *, int nodeid);
-extern int try_to_migrate_pages(struct list_head *);
+extern int try_to_migrate_pages(struct list_head *, int *);
+
+static inline struct page *node_migrate_onepage(struct page *page, int *node_map)
+{
+	if (node_map)
+		return migrate_onepage(page, node_map[page_to_nid(page)]);
+	else
+		return migrate_onepage(page, MIGRATE_NODE_ANY);
+
+}
 
 #else
 static inline int generic_migrate_page(struct page *page, struct page *newpage,
Index: linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-06-10 14:47:25.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c	2005-06-13 10:22:02.000000000 -0700
@@ -501,9 +501,11 @@ out_unlock:
 /*
  * This is the main entry point to migrate pages in a specific region.
  * If a page is inactive, the page may be just released instead of
- * migration.
+ * migration.  node_map is supplied in those cases (on NUMA systems)
+ * where the caller wishes to specify to which nodes the pages are
+ * migrated.  If node_map is null, the target node is MIGRATE_NODE_ANY.
  */
-int try_to_migrate_pages(struct list_head *page_list)
+int try_to_migrate_pages(struct list_head *page_list, int *node_map)
 {
 	struct page *page, *page2, *newpage;
 	LIST_HEAD(pass1_list);
@@ -541,7 +543,7 @@ int try_to_migrate_pages(struct list_hea
 	list_for_each_entry_safe(page, page2, &pass1_list, lru) {
 		list_del(&page->lru);
 		if (PageLocked(page) || PageWriteback(page) ||
-		    IS_ERR(newpage = migrate_onepage(page, MIGRATE_NODE_ANY))) {
+		    IS_ERR(newpage = node_migrate_onepage(page, node_map))) {
 			if (page_count(page) == 1) {
 				/* the page is already unused */
 				putback_page_to_lru(page_zone(page), page);
@@ -559,7 +561,7 @@ int try_to_migrate_pages(struct list_hea
 	 */
 	list_for_each_entry_safe(page, page2, &pass2_list, lru) {
 		list_del(&page->lru);
-		if (IS_ERR(newpage = migrate_onepage(page, MIGRATE_NODE_ANY))) {
+		if (IS_ERR(newpage = node_migrate_onepage(page, node_map))) {
 			if (page_count(page) == 1) {
 				/* the page is already unused */
 				putback_page_to_lru(page_zone(page), page);

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
