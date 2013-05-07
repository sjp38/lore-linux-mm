Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 5EC766B00D6
	for <linux-mm@kvack.org>; Tue,  7 May 2013 17:20:01 -0400 (EDT)
Subject: [RFC][PATCH 4/7] break out mapping "freepage" code
From: Dave Hansen <dave@sr71.net>
Date: Tue, 07 May 2013 14:20:00 -0700
References: <20130507211954.9815F9D1@viggo.jf.intel.com>
In-Reply-To: <20130507211954.9815F9D1@viggo.jf.intel.com>
Message-Id: <20130507212000.59652B69@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

__remove_mapping() only deals with pages with mappings, meaning
page cache and swap cache.

At this point, the page has been removed from the mapping's radix
tree, and we need to ensure that any fs-specific (or swap-
specific) resources are freed up.

We will be using this function from a second location in a
following patch.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/mm/vmscan.c |   33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff -puN mm/vmscan.c~free_mapping_page mm/vmscan.c
--- linux.git/mm/vmscan.c~free_mapping_page	2013-05-07 13:48:14.520080867 -0700
+++ linux.git-davehans/mm/vmscan.c	2013-05-07 13:48:14.524081045 -0700
@@ -497,6 +497,27 @@ static int __remove_mapping_nolock(struc
 	return 1;
 }
 
+/*
+ * maybe this isnt named the best... it just releases
+ * the mapping's reference to the page.  It frees the
+ * page from *the* *mapping* but not necessarily back
+ * in to the allocator
+ */
+static void free_mapping_page(struct address_space *mapping, struct page *page)
+{
+	if (PageSwapCache(page)) {
+		swapcache_free_page_entry(page);
+		set_page_private(page, 0);
+		ClearPageSwapCache(page);
+	} else {
+		void (*freepage)(struct page *);
+		freepage = mapping->a_ops->freepage;
+		mem_cgroup_uncharge_cache_page(page);
+		if (freepage != NULL)
+			freepage(page);
+	}
+}
+
 static int __remove_mapping(struct address_space *mapping, struct page *page)
 {
 	int ret;
@@ -510,17 +531,7 @@ static int __remove_mapping(struct addre
 	if (!ret)
 		return 0;
 
-	if (PageSwapCache(page)) {
-		swapcache_free_page_entry(page);
-		set_page_private(page, 0);
-		ClearPageSwapCache(page);
-	} else {
-		void (*freepage)(struct page *);
-		freepage = mapping->a_ops->freepage;
-		mem_cgroup_uncharge_cache_page(page);
-		if (freepage != NULL)
-			freepage(page);
-	}
+	free_mapping_page(mapping, page);
 	return ret;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
