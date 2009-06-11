From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/5] HWPOISON: use the safer invalidate page for possible metadata pages
Date: Thu, 11 Jun 2009 22:22:44 +0800
Message-ID: <20090611144430.947740750@intel.com>
References: <20090611142239.192891591@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EB6006B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 10:52:08 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-skip-metadata.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

As recommended by Nick Piggin.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/mm.h  |    1 +
 mm/memory-failure.c |   23 +++++++++++++----------
 mm/truncate.c       |    3 +--
 3 files changed, 15 insertions(+), 12 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -113,6 +113,10 @@ static int me_pagecache_clean(struct pag
 	if (!isolate_lru_page(p))
 		page_cache_release(p);
 
+	mapping = page_mapping(p);
+	if (mapping == NULL)
+		return RECOVERED;
+
 	/*
 	 * Now truncate the page in the page cache. This is really
 	 * more like a "temporary hole punch"
@@ -120,20 +124,19 @@ static int me_pagecache_clean(struct pag
 	 * has a reference, because it could be file system metadata
 	 * and that's not safe to truncate.
 	 */
-	mapping = page_mapping(p);
-	if (mapping && S_ISBLK(mapping->host->i_mode) && page_count(p) > 1) {
+	if (!S_ISREG(mapping->host->i_mode) &&
+	    !invalidate_complete_page(mapping, p)) {
 		printk(KERN_ERR
-		       "MCE %#lx: page looks like a unsupported file system metadata page\n",
+		       "MCE %#lx: failed to invalidate metadata page\n",
 		       pfn);
 		return FAILED;
 	}
-	if (mapping) {
-		truncate_inode_page(mapping, p);
-		if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO)) {
-			pr_debug(KERN_ERR "MCE %#lx: failed to release buffers\n",
-				 pfn);
-			return FAILED;
-		}
+
+	truncate_inode_page(mapping, p);
+	if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO)) {
+		pr_debug(KERN_ERR "MCE %#lx: failed to release buffers\n",
+			 pfn);
+		return FAILED;
 	}
 	return RECOVERED;
 }
--- sound-2.6.orig/include/linux/mm.h
+++ sound-2.6/include/linux/mm.h
@@ -817,6 +817,7 @@ extern int vmtruncate(struct inode * ino
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
 void truncate_inode_page(struct address_space *mapping, struct page *page);
+int invalidate_complete_page(struct address_space *mapping, struct page *page);
 
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
--- sound-2.6.orig/mm/truncate.c
+++ sound-2.6/mm/truncate.c
@@ -118,8 +118,7 @@ truncate_complete_page(struct address_sp
  *
  * Returns non-zero if the page was successfully invalidated.
  */
-static int
-invalidate_complete_page(struct address_space *mapping, struct page *page)
+int invalidate_complete_page(struct address_space *mapping, struct page *page)
 {
 	int ret;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
