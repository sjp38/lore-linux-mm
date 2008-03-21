Message-Id: <20080321061727.269764652@sgi.com>
References: <20080321061703.921169367@sgi.com>
Date: Thu, 20 Mar 2008 23:17:16 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [13/14] vcompound: Use vcompound for swap_map
Content-Disposition: inline; filename=fixswapon
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Use virtual compound pages for the large swap maps. This only works for
swap maps that are smaller than a MAX_ORDER block though. If the swap map
is larger then there is no way around the use of vmalloc.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/swapfile.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6.25-rc5-mm1/mm/swapfile.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/mm/swapfile.c	2008-03-20 20:32:12.793950570 -0700
+++ linux-2.6.25-rc5-mm1/mm/swapfile.c	2008-03-20 20:37:43.367821147 -0700
@@ -1312,7 +1312,7 @@ asmlinkage long sys_swapoff(const char _
 	p->flags = 0;
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
-	vfree(swap_map);
+	__free_vcompound(swap_map);
 	inode = mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
 		struct block_device *bdev = I_BDEV(inode);
@@ -1636,13 +1636,13 @@ asmlinkage long sys_swapon(const char __
 			goto bad_swap;
 
 		/* OK, set up the swap map and apply the bad block list */
-		if (!(p->swap_map = vmalloc(maxpages * sizeof(short)))) {
+		if (!(p->swap_map = __alloc_vcompound(GFP_KERNEL | __GFP_ZERO,
+					get_order(maxpages * sizeof(short))))) {
 			error = -ENOMEM;
 			goto bad_swap;
 		}
 
 		error = 0;
-		memset(p->swap_map, 0, maxpages * sizeof(short));
 		for (i = 0; i < swap_header->info.nr_badpages; i++) {
 			int page_nr = swap_header->info.badpages[i];
 			if (page_nr <= 0 || page_nr >= swap_header->info.last_page)
@@ -1718,7 +1718,7 @@ bad_swap_2:
 	if (!(swap_flags & SWAP_FLAG_PREFER))
 		++least_priority;
 	spin_unlock(&swap_lock);
-	vfree(swap_map);
+	__free_vcompound(swap_map);
 	if (swap_file)
 		filp_close(swap_file, NULL);
 out:

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
