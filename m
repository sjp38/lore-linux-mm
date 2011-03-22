Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 999D08D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 15:15:15 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2MJ8SQQ008585
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 13:08:28 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p2MJF42Y088696
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 13:15:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2MJF2Zh004861
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 13:15:03 -0600
Subject: [RFC][PATCH 1/2] rename alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Tue, 22 Mar 2011 12:15:02 -0700
Message-Id: <20110322191501.7EEC645D@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>


alloc_pages_exact() returns a virtual address.  But, alloc_pages() returns
a 'struct page *'.  That makes for very confused kernel hackers.

__get_free_pages(), on the other hand, returns virtual addresses.  That
makes alloc_pages_exact() a much closer match to __get_free_pages(), so
rename it to get_free_pages_exact().

Note that alloc_pages_exact()'s partner, free_pages_exact() already
matches free_pages(), so we do not have to touch the free side of things.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/drivers/video/fsl-diu-fb.c  |    2 +-
 linux-2.6.git-dave/drivers/video/pxafb.c       |    4 ++--
 linux-2.6.git-dave/drivers/virtio/virtio_pci.c |    2 +-
 linux-2.6.git-dave/include/linux/gfp.h         |    2 +-
 linux-2.6.git-dave/kernel/profile.c            |    2 +-
 linux-2.6.git-dave/mm/page_alloc.c             |   22 +++++++++++-----------
 6 files changed, 17 insertions(+), 17 deletions(-)

diff -puN drivers/video/fsl-diu-fb.c~change-alloc_pages_exact-name drivers/video/fsl-diu-fb.c
--- linux-2.6.git/drivers/video/fsl-diu-fb.c~change-alloc_pages_exact-name	2011-03-22 12:11:56.905452820 -0700
+++ linux-2.6.git-dave/drivers/video/fsl-diu-fb.c	2011-03-22 12:11:56.937452815 -0700
@@ -294,7 +294,7 @@ static void *fsl_diu_alloc(size_t size, 
 
 	pr_debug("size=%zu\n", size);
 
-	virt = alloc_pages_exact(size, GFP_DMA | __GFP_ZERO);
+	virt = get_free_pages_exact(size, GFP_DMA | __GFP_ZERO);
 	if (virt) {
 		*phys = virt_to_phys(virt);
 		pr_debug("virt=%p phys=%llx\n", virt,
diff -puN drivers/video/pxafb.c~change-alloc_pages_exact-name drivers/video/pxafb.c
--- linux-2.6.git/drivers/video/pxafb.c~change-alloc_pages_exact-name	2011-03-22 12:11:56.909452819 -0700
+++ linux-2.6.git-dave/drivers/video/pxafb.c	2011-03-22 12:11:56.941452815 -0700
@@ -820,7 +820,7 @@ static int overlayfb_map_video_memory(st
 		free_pages_exact(ofb->video_mem, ofb->video_mem_size);
 	}
 
-	ofb->video_mem = alloc_pages_exact(size, GFP_KERNEL | __GFP_ZERO);
+	ofb->video_mem = get_free_pages_exact(size, GFP_KERNEL | __GFP_ZERO);
 	if (ofb->video_mem == NULL)
 		return -ENOMEM;
 
@@ -1678,7 +1678,7 @@ static int __devinit pxafb_init_video_me
 {
 	int size = PAGE_ALIGN(fbi->video_mem_size);
 
-	fbi->video_mem = alloc_pages_exact(size, GFP_KERNEL | __GFP_ZERO);
+	fbi->video_mem = get_free_pages_exact(size, GFP_KERNEL | __GFP_ZERO);
 	if (fbi->video_mem == NULL)
 		return -ENOMEM;
 
diff -puN drivers/virtio/virtio_pci.c~change-alloc_pages_exact-name drivers/virtio/virtio_pci.c
--- linux-2.6.git/drivers/virtio/virtio_pci.c~change-alloc_pages_exact-name	2011-03-22 12:11:56.913452818 -0700
+++ linux-2.6.git-dave/drivers/virtio/virtio_pci.c	2011-03-22 12:11:56.941452815 -0700
@@ -385,7 +385,7 @@ static struct virtqueue *setup_vq(struct
 	info->msix_vector = msix_vec;
 
 	size = PAGE_ALIGN(vring_size(num, VIRTIO_PCI_VRING_ALIGN));
-	info->queue = alloc_pages_exact(size, GFP_KERNEL|__GFP_ZERO);
+	info->queue = get_free_pages_exact(size, GFP_KERNEL|__GFP_ZERO);
 	if (info->queue == NULL) {
 		err = -ENOMEM;
 		goto out_info;
diff -puN include/linux/gfp.h~change-alloc_pages_exact-name include/linux/gfp.h
--- linux-2.6.git/include/linux/gfp.h~change-alloc_pages_exact-name	2011-03-22 12:11:56.917452818 -0700
+++ linux-2.6.git-dave/include/linux/gfp.h	2011-03-22 12:11:56.945452815 -0700
@@ -346,7 +346,7 @@ extern struct page *alloc_pages_vma(gfp_
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
-void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
+void *get_free_pages_exact(size_t size, gfp_t gfp_mask);
 void free_pages_exact(void *virt, size_t size);
 
 #define __get_free_page(gfp_mask) \
diff -puN kernel/profile.c~change-alloc_pages_exact-name kernel/profile.c
--- linux-2.6.git/kernel/profile.c~change-alloc_pages_exact-name	2011-03-22 12:11:56.921452818 -0700
+++ linux-2.6.git-dave/kernel/profile.c	2011-03-22 12:11:56.941452815 -0700
@@ -121,7 +121,7 @@ int __ref profile_init(void)
 	if (prof_buffer)
 		return 0;
 
-	prof_buffer = alloc_pages_exact(buffer_bytes,
+	prof_buffer = get_free_pages_exact(buffer_bytes,
 					GFP_KERNEL|__GFP_ZERO|__GFP_NOWARN);
 	if (prof_buffer)
 		return 0;
diff -puN mm/page_alloc.c~change-alloc_pages_exact-name mm/page_alloc.c
--- linux-2.6.git/mm/page_alloc.c~change-alloc_pages_exact-name	2011-03-22 12:11:56.925452818 -0700
+++ linux-2.6.git-dave/mm/page_alloc.c	2011-03-22 12:11:56.937452815 -0700
@@ -2284,19 +2284,19 @@ void free_pages(unsigned long addr, unsi
 EXPORT_SYMBOL(free_pages);
 
 /**
- * alloc_pages_exact - allocate an exact number physically-contiguous pages.
+ * get_free_pages_exact - allocate an exact number physically-contiguous pages.
  * @size: the number of bytes to allocate
  * @gfp_mask: GFP flags for the allocation
  *
- * This function is similar to alloc_pages(), except that it allocates the
- * minimum number of pages to satisfy the request.  alloc_pages() can only
+ * This function is similar to __get_free_pages(), except that it allocates the
+ * minimum number of pages to satisfy the request.  get_free_pages() can only
  * allocate memory in power-of-two pages.
  *
  * This function is also limited by MAX_ORDER.
  *
  * Memory allocated by this function must be released by free_pages_exact().
  */
-void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
+void *get_free_pages_exact(size_t size, gfp_t gfp_mask)
 {
 	unsigned int order = get_order(size);
 	unsigned long addr;
@@ -2315,14 +2315,14 @@ void *alloc_pages_exact(size_t size, gfp
 
 	return (void *)addr;
 }
-EXPORT_SYMBOL(alloc_pages_exact);
+EXPORT_SYMBOL(get_free_pages_exact);
 
 /**
- * free_pages_exact - release memory allocated via alloc_pages_exact()
- * @virt: the value returned by alloc_pages_exact.
- * @size: size of allocation, same value as passed to alloc_pages_exact().
+ * free_pages_exact - release memory allocated via get_free_pages_exact()
+ * @virt: the value returned by get_free_pages_exact().
+ * @size: size of allocation, same value as passed to get_free_pages_exact().
  *
- * Release the memory allocated by a previous call to alloc_pages_exact.
+ * Release the memory allocated by a previous call to get_free_pages_exact().
  */
 void free_pages_exact(void *virt, size_t size)
 {
@@ -5247,10 +5247,10 @@ void *__init alloc_large_system_hash(con
 			/*
 			 * If bucketsize is not a power-of-two, we may free
 			 * some pages at the end of hash table which
-			 * alloc_pages_exact() automatically does
+			 * get_free_pages_exact() automatically does
 			 */
 			if (get_order(size) < MAX_ORDER) {
-				table = alloc_pages_exact(size, GFP_ATOMIC);
+				table = get_free_pages_exact(size, GFP_ATOMIC);
 				kmemleak_alloc(table, size, 1, GFP_ATOMIC);
 			}
 		}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
