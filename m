Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 53F3D6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 05:04:12 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so152123wah.22
        for <linux-mm@kvack.org>; Tue, 28 Apr 2009 02:04:14 -0700 (PDT)
From: Magnus Damm <magnus.damm@gmail.com>
Date: Tue, 28 Apr 2009 18:01:29 +0900
Message-Id: <20090428090129.17081.782.sendpatchset@rx1.opensource.se>
Subject: [PATCH] videobuf-dma-contig: zero copy USERPTR support V2
Sender: owner-linux-mm@kvack.org
To: linux-media@vger.kernel.org
Cc: hverkuil@xs4all.nl, linux-mm@kvack.org, Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

From: Magnus Damm <damm@igel.co.jp>

This is V2 of the V4L2 videobuf-dma-contig USERPTR zero copy patch.

Since videobuf-dma-contig is designed to handle physically contiguous
memory, this patch modifies the videobuf-dma-contig code to only accept
a pointer to physically contiguous memory. For now only VM_PFNMAP vmas
are supported, so forget hotplug.

On SuperH Mobile we use this approach for our sh_mobile_ceu_camera driver
together with various multimedia accelerator blocks that are exported to
user space using UIO. The UIO kernel code exports physically contiugous
memory to user space and lets the user space application mmap() this memory
and pass a pointer using the USERPTR interface for V4L2 zero copy operation.

With this approach we support zero copy capture, hardware scaling and
various forms of hardware encoding and decoding.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 Many thanks to Hannes for the feedback!
 Tested on SH7722 Migo-R with a hacked up capture.c

 Changes since V1:
 - minor cleanups and formatting changes
 - use follow_phys() in videobuf-dma-contig instead of duplicating code
 - since videobuf-dma-contig can be a module: EXPORT_SYMBOL(follow_phys)
 - move CONFIG_HAVE_IOREMAP_PROT to always build follow_phys()

 drivers/media/video/videobuf-dma-contig.c |   82 +++++++++++++++++++++++++++--
 mm/memory.c                               |    3 -
 2 files changed, 79 insertions(+), 6 deletions(-)

--- 0005/drivers/media/video/videobuf-dma-contig.c
+++ work/drivers/media/video/videobuf-dma-contig.c	2009-04-28 14:59:23.000000000 +0900
@@ -17,6 +17,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/mm.h>
+#include <linux/pagemap.h>
 #include <linux/dma-mapping.h>
 #include <media/videobuf-dma-contig.h>
 
@@ -25,6 +26,7 @@ struct videobuf_dma_contig_memory {
 	void *vaddr;
 	dma_addr_t dma_handle;
 	unsigned long size;
+	int is_userptr;
 };
 
 #define MAGIC_DC_MEM 0x0733ac61
@@ -108,6 +110,70 @@ static struct vm_operations_struct video
 	.close    = videobuf_vm_close,
 };
 
+static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
+{
+	mem->is_userptr = 0;
+	mem->dma_handle = 0;
+	mem->size = 0;
+}
+
+static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
+					struct videobuf_buffer *vb)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	unsigned long prev_pfn, this_pfn;
+	unsigned long pages_done, user_address;
+	unsigned long prot;
+	resource_size_t phys;
+	int ret;
+
+	mem->size = PAGE_ALIGN(vb->size);
+	mem->is_userptr = 0;
+	ret = -EINVAL;
+
+	down_read(&mm->mmap_sem);
+
+	vma = find_vma(mm, vb->baddr);
+	if (!vma)
+		goto out_up;
+
+	if ((vb->baddr + mem->size) > vma->vm_end)
+		goto out_up;
+
+	pages_done = 0;
+	prev_pfn = 0; /* kill warning */
+	user_address = vb->baddr;
+
+	while (pages_done < (mem->size >> PAGE_SHIFT)) {
+		ret = follow_phys(vma, user_address, 0, &prot, &phys);
+		if (ret)
+			break;
+
+		this_pfn = phys >> PAGE_SHIFT;
+
+		if (pages_done == 0)
+			mem->dma_handle = phys;
+		else if (this_pfn != (prev_pfn + 1))
+			ret = -EFAULT;
+
+		if (ret)
+			break;
+
+		prev_pfn = this_pfn;
+		user_address += PAGE_SIZE;
+		pages_done++;
+	}
+
+	if (!ret)
+		mem->is_userptr = 1;
+
+ out_up:
+	up_read(&current->mm->mmap_sem);
+
+	return ret;
+}
+
 static void *__videobuf_alloc(size_t size)
 {
 	struct videobuf_dma_contig_memory *mem;
@@ -154,12 +220,11 @@ static int __videobuf_iolock(struct vide
 	case V4L2_MEMORY_USERPTR:
 		dev_dbg(q->dev, "%s memory method USERPTR\n", __func__);
 
-		/* The only USERPTR currently supported is the one needed for
-		   read() method.
-		 */
+		/* handle pointer from user space */
 		if (vb->baddr)
-			return -EINVAL;
+			return videobuf_dma_contig_user_get(mem, vb);
 
+		/* allocate memory for the read() method */
 		mem->size = PAGE_ALIGN(vb->size);
 		mem->vaddr = dma_alloc_coherent(q->dev, mem->size,
 						&mem->dma_handle, GFP_KERNEL);
@@ -386,7 +451,7 @@ void videobuf_dma_contig_free(struct vid
 	   So, it should free memory only if the memory were allocated for
 	   read() operation.
 	 */
-	if ((buf->memory != V4L2_MEMORY_USERPTR) || buf->baddr)
+	if (buf->memory != V4L2_MEMORY_USERPTR)
 		return;
 
 	if (!mem)
@@ -394,6 +459,13 @@ void videobuf_dma_contig_free(struct vid
 
 	MAGIC_CHECK(mem->magic, MAGIC_DC_MEM);
 
+	/* handle user space pointer case */
+	if (buf->baddr) {
+		videobuf_dma_contig_user_put(mem);
+		return;
+	}
+
+	/* read() method */
 	dma_free_coherent(q->dev, mem->size, mem->vaddr, mem->dma_handle);
 	mem->vaddr = NULL;
 }
--- 0001/mm/memory.c
+++ work/mm/memory.c	2009-04-28 14:56:43.000000000 +0900
@@ -3009,7 +3009,6 @@ int in_gate_area_no_task(unsigned long a
 
 #endif	/* __HAVE_ARCH_GATE_AREA */
 
-#ifdef CONFIG_HAVE_IOREMAP_PROT
 int follow_phys(struct vm_area_struct *vma,
 		unsigned long address, unsigned int flags,
 		unsigned long *prot, resource_size_t *phys)
@@ -3063,7 +3062,9 @@ unlock:
 out:
 	return ret;
 }
+EXPORT_SYMBOL(follow_phys);
 
+#ifdef CONFIG_HAVE_IOREMAP_PROT
 int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 			void *buf, int len, int write)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
