Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 389118D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 14:21:53 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p37H1DLD020376
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 13:01:13 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id AFF106E8036
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 13:21:07 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p37HL7fJ382956
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 13:21:07 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p37HL5A5006192
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 14:21:07 -0300
Subject: [PATCH 1/2] rename alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Thu, 07 Apr 2011 10:21:04 -0700
Message-Id: <20110407172104.1F8B7329@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>


alloc_pages_exact() returns a virtual address.  But, alloc_pages() returns
a 'struct page *'.  That makes for very confused kernel hackers.

__get_free_pages(), on the other hand, returns virtual addresses.  That
makes alloc_pages_exact() a much closer match to __get_free_pages(), so
rename it to get_free_pages_exact().

Note that alloc_pages_exact()'s partner, free_pages_exact() already
matches free_pages(), so we do not have to touch the free side of things.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
---

 linux-2.6.git-dave/drivers/video/fsl-diu-fb.c  |    2 +-
 linux-2.6.git-dave/drivers/video/mxsfb.c       |    2 +-
 linux-2.6.git-dave/drivers/video/pxafb.c       |    4 ++--
 linux-2.6.git-dave/drivers/virtio/virtio_pci.c |    2 +-
 linux-2.6.git-dave/include/linux/gfp.h         |    2 +-
 linux-2.6.git-dave/kernel/profile.c            |    2 +-
 linux-2.6.git-dave/mm/page_alloc.c             |   24 ++++++++++++------------
 linux-2.6.git-dave/mm/page_cgroup.c            |    2 +-
 8 files changed, 20 insertions(+), 20 deletions(-)

diff -puN drivers/video/fsl-diu-fb.c~change-alloc_pages_exact-name drivers/video/fsl-diu-fb.c
--- linux-2.6.git/drivers/video/fsl-diu-fb.c~change-alloc_pages_exact-name	2011-04-07 08:37:58.074400957 -0700
+++ linux-2.6.git-dave/drivers/video/fsl-diu-fb.c	2011-04-07 08:37:58.186400949 -0700
@@ -294,7 +294,7 @@ static void *fsl_diu_alloc(size_t size, 
 
 	pr_debug("size=%zu\n", size);
 
-	virt = alloc_pages_exact(size, GFP_DMA | __GFP_ZERO);
+	virt = get_free_pages_exact(GFP_DMA | __GFP_ZERO, size);
 	if (virt) {
 		*phys = virt_to_phys(virt);
 		pr_debug("virt=%p phys=%llx\n", virt,
diff -puN drivers/video/pxafb.c~change-alloc_pages_exact-name drivers/video/pxafb.c
--- linux-2.6.git/drivers/video/pxafb.c~change-alloc_pages_exact-name	2011-04-07 08:37:58.078400957 -0700
+++ linux-2.6.git-dave/drivers/video/pxafb.c	2011-04-07 08:39:16.198395385 -0700
@@ -905,7 +905,7 @@ static int __devinit pxafb_overlay_map_v
 	/* We assume that user will use at most video_mem_size for overlay fb,
 	 * anyway, it's useless to use 16bpp main plane and 24bpp overlay
 	 */
-	ofb->video_mem = alloc_pages_exact(PAGE_ALIGN(pxafb->video_mem_size),
+	ofb->video_mem = get_free_pages_exact(PAGE_ALIGN(pxafb->video_mem_size),
 		GFP_KERNEL | __GFP_ZERO);
 	if (ofb->video_mem == NULL)
 		return -ENOMEM;
@@ -1714,7 +1714,7 @@ static int __devinit pxafb_init_video_me
 {
 	int size = PAGE_ALIGN(fbi->video_mem_size);
 
-	fbi->video_mem = alloc_pages_exact(size, GFP_KERNEL | __GFP_ZERO);
+	fbi->video_mem = get_free_pages_exact(GFP_KERNEL | __GFP_ZERO, size);
 	if (fbi->video_mem == NULL)
 		return -ENOMEM;
 
diff -puN drivers/virtio/virtio_pci.c~change-alloc_pages_exact-name drivers/virtio/virtio_pci.c
--- linux-2.6.git/drivers/virtio/virtio_pci.c~change-alloc_pages_exact-name	2011-04-07 08:37:58.082400957 -0700
+++ linux-2.6.git-dave/drivers/virtio/virtio_pci.c	2011-04-07 08:37:58.190400949 -0700
@@ -385,7 +385,7 @@ static struct virtqueue *setup_vq(struct
 	info->msix_vector = msix_vec;
 
 	size = PAGE_ALIGN(vring_size(num, VIRTIO_PCI_VRING_ALIGN));
-	info->queue = alloc_pages_exact(size, GFP_KERNEL|__GFP_ZERO);
+	info->queue = get_free_pages_exact(GFP_KERNEL|__GFP_ZERO, size);
 	if (info->queue == NULL) {
 		err = -ENOMEM;
 		goto out_info;
diff -puN include/linux/gfp.h~change-alloc_pages_exact-name include/linux/gfp.h
--- linux-2.6.git/include/linux/gfp.h~change-alloc_pages_exact-name	2011-04-07 08:37:58.086400956 -0700
+++ linux-2.6.git-dave/include/linux/gfp.h	2011-04-07 08:37:58.190400949 -0700
@@ -351,7 +351,7 @@ extern struct page *alloc_pages_vma(gfp_
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
-void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
+void *get_free_pages_exact(gfp_t gfp_mask, size_t size);
 void free_pages_exact(void *virt, size_t size);
 
 #define __get_free_page(gfp_mask) \
diff -puN kernel/profile.c~change-alloc_pages_exact-name kernel/profile.c
--- linux-2.6.git/kernel/profile.c~change-alloc_pages_exact-name	2011-04-07 08:37:58.090400955 -0700
+++ linux-2.6.git-dave/kernel/profile.c	2011-04-07 08:37:58.190400949 -0700
@@ -121,7 +121,7 @@ int __ref profile_init(void)
 	if (prof_buffer)
 		return 0;
 
-	prof_buffer = alloc_pages_exact(buffer_bytes,
+	prof_buffer = get_free_pages_exact(buffer_bytes,
 					GFP_KERNEL|__GFP_ZERO|__GFP_NOWARN);
 	if (prof_buffer)
 		return 0;
diff -puN mm/page_alloc.c~change-alloc_pages_exact-name mm/page_alloc.c
--- linux-2.6.git/mm/page_alloc.c~change-alloc_pages_exact-name	2011-04-07 08:37:58.094400955 -0700
+++ linux-2.6.git-dave/mm/page_alloc.c	2011-04-07 08:37:58.194400949 -0700
@@ -2318,19 +2318,19 @@ void free_pages(unsigned long addr, unsi
 EXPORT_SYMBOL(free_pages);
 
 /**
- * alloc_pages_exact - allocate an exact number physically-contiguous pages.
- * @size: the number of bytes to allocate
+ * get_free_pages_exact - allocate an exact number physically-contiguous pages.
  * @gfp_mask: GFP flags for the allocation
+ * @size: the number of bytes to allocate
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
+void *get_free_pages_exact(gfp_t gfp_mask, size_t size)
 {
 	unsigned int order = get_order(size);
 	unsigned long addr;
@@ -2349,14 +2349,14 @@ void *alloc_pages_exact(size_t size, gfp
 
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
@@ -5308,10 +5308,10 @@ void *__init alloc_large_system_hash(con
 			/*
 			 * If bucketsize is not a power-of-two, we may free
 			 * some pages at the end of hash table which
-			 * alloc_pages_exact() automatically does
+			 * get_free_pages_exact() automatically does
 			 */
 			if (get_order(size) < MAX_ORDER) {
-				table = alloc_pages_exact(size, GFP_ATOMIC);
+				table = get_free_pages_exact(GFP_ATOMIC, size);
 				kmemleak_alloc(table, size, 1, GFP_ATOMIC);
 			}
 		}
diff -puN mm/page_cgroup.c~change-alloc_pages_exact-name mm/page_cgroup.c
--- linux-2.6.git/mm/page_cgroup.c~change-alloc_pages_exact-name	2011-04-07 08:37:58.098400955 -0700
+++ linux-2.6.git-dave/mm/page_cgroup.c	2011-04-07 08:37:58.198400948 -0700
@@ -134,7 +134,7 @@ static void *__init_refok alloc_page_cgr
 {
 	void *addr = NULL;
 
-	addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN);
+	addr = get_free_pages_exact(GFP_KERNEL | __GFP_NOWARN, size);
 	if (addr)
 		return addr;
 
diff -puN drivers/video/mxsfb.c~change-alloc_pages_exact-name drivers/video/mxsfb.c
--- linux-2.6.git/drivers/video/mxsfb.c~change-alloc_pages_exact-name	2011-04-07 08:37:58.102400955 -0700
+++ linux-2.6.git-dave/drivers/video/mxsfb.c	2011-04-07 08:37:58.198400948 -0700
@@ -718,7 +718,7 @@ static int __devinit mxsfb_init_fbinfo(s
 	} else {
 		if (!fb_size)
 			fb_size = SZ_2M; /* default */
-		fb_virt = alloc_pages_exact(fb_size, GFP_DMA);
+		fb_virt = get_free_pages_exact(GFP_DMA, fb_size);
 		if (!fb_virt)
 			return -ENOMEM;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
