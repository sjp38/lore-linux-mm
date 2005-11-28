Date: Mon, 28 Nov 2005 20:36:51 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 2[5/5]
Message-Id: <20051128200550.5D82.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Joel Schopp <jschopp@austin.ibm.com>, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is to disable __GFP_EASY_RECLAIM flag at add_to_page_cache().
If this patch is not applied, cache_grow() checks and call BUG(),
at here. 

	if (flags & ~(SLAB_DMA|SLAB_LEVEL_MASK|SLAB_NO_GROW))
		BUG();

This patch is to solve it.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: new_zone_mm/mm/filemap.c
===================================================================
--- new_zone_mm.orig/mm/filemap.c	2005-11-22 15:21:23.000000000 +0900
+++ new_zone_mm/mm/filemap.c	2005-11-22 15:21:27.000000000 +0900
@@ -381,7 +381,7 @@ int filemap_write_and_wait_range(struct 
 int add_to_page_cache(struct page *page, struct address_space *mapping,
 		pgoff_t offset, gfp_t gfp_mask)
 {
-	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	int error = radix_tree_preload(gfp_mask & ~(__GFP_HIGHMEM | __GFP_EASY_RECLAIM));
 
 	if (error == 0) {
 		write_lock_irq(&mapping->tree_lock);

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
