Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id B4BEF6B0039
	for <linux-mm@kvack.org>; Thu, 16 May 2013 16:34:37 -0400 (EDT)
Subject: [RFCv2][PATCH 4/5] break out mapping "freepage" code
From: Dave Hansen <dave@sr71.net>
Date: Thu, 16 May 2013 13:34:33 -0700
References: <20130516203427.E3386936@viggo.jf.intel.com>
In-Reply-To: <20130516203427.E3386936@viggo.jf.intel.com>
Message-Id: <20130516203433.CC770268@viggo.jf.intel.com>
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
Acked-by: Mel Gorman <mgorman@suse.de>
---

 linux.git-davehans/mm/vmscan.c |   28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff -puN mm/vmscan.c~free_mapping_page mm/vmscan.c
--- linux.git/mm/vmscan.c~free_mapping_page	2013-05-16 13:27:25.520174273 -0700
+++ linux.git-davehans/mm/vmscan.c	2013-05-16 13:27:25.525174493 -0700
@@ -497,6 +497,24 @@ static int __remove_mapping(struct addre
 	return 1;
 }
 
+/*
+ * Release any resources the mapping had tied up in
+ * the page.
+ */
+static void mapping_release_page(struct address_space *mapping,
+				 struct page *page)
+{
+	if (PageSwapCache(page)) {
+		swapcache_free_page_entry(page);
+	} else {
+		void (*freepage)(struct page *);
+		freepage = mapping->a_ops->freepage;
+		mem_cgroup_uncharge_cache_page(page);
+		if (freepage != NULL)
+			freepage(page);
+	}
+}
+
 static int lock_remove_mapping(struct address_space *mapping, struct page *page)
 {
 	int ret;
@@ -510,15 +528,7 @@ static int lock_remove_mapping(struct ad
 	if (!ret)
 		return 0;
 
-	if (PageSwapCache(page)) {
-		swapcache_free_page_entry(page);
-	} else {
-		void (*freepage)(struct page *);
-		freepage = mapping->a_ops->freepage;
-		mem_cgroup_uncharge_cache_page(page);
-		if (freepage != NULL)
-			freepage(page);
-	}
+	mapping_release_page(mapping, page);
 	return ret;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
