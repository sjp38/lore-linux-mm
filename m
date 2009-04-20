Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C6DB25F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 06:02:45 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so1399135rvb.26
        for <linux-mm@kvack.org>; Mon, 20 Apr 2009 03:02:46 -0700 (PDT)
From: Magnus Damm <magnus.damm@gmail.com>
Date: Mon, 20 Apr 2009 19:00:03 +0900
Message-Id: <20090420100003.8113.14986.sendpatchset@rx1.opensource.se>
Subject: [PATCH][RFC] videobuf-dma-config: zero copy USERPTR support
Sender: owner-linux-mm@kvack.org
To: linux-media@vger.kernel.org
Cc: hverkuil@xs4all.nl, linux-mm@kvack.org, Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

From: Magnus Damm <damm@igel.co.jp>

Zero copy video frame capture from user space using V4L2 USERPTR.

This patch adds USERPTR support to the videobuf-dma-contig buffer code.
Since videobuf-dma-contig is designed to handle physically contiguous
memory, this patch modifies the videobuf-dma-contig code to only accept
a pointer physically contiguous memory. For now only VM_PFNMAP vmas are
supported, so forget hotplug.

On SuperH Mobile we use this approach for our V4L2 CEU driver together
with various multimedia accelerator blocks that are exported to user 
space using UIO. The UIO kernel code exports physically contiugous memory
to user space and lets the user space application mmap() this memory and
pass a pointer using the USERPTR interface for V4L2 zero copy operation.

With this approach we support zero copy capture, hardware scaling and
various forms of hardware encoding.

Hopefully this patch is useful for other SoCs. For user space example
code I suggest having a look at the USERPTR implementation in capture.c.

Any comments? Does anyone need to use memory backed by struct page?

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/media/video/videobuf-dma-contig.c |  138 +++++++++++++++++++++++++++--
 1 file changed, 131 insertions(+), 7 deletions(-)

--- 0001/drivers/media/video/videobuf-dma-contig.c
+++ work/drivers/media/video/videobuf-dma-contig.c	2009-04-20 18:04:32.000000000 +0900
@@ -17,6 +17,8 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/mm.h>
+#include <linux/hugetlb.h>
+#include <linux/pagemap.h>
 #include <linux/dma-mapping.h>
 #include <media/videobuf-dma-contig.h>
 
@@ -25,6 +27,7 @@ struct videobuf_dma_contig_memory {
 	void *vaddr;
 	dma_addr_t dma_handle;
 	unsigned long size;
+	int is_userptr;
 };
 
 #define MAGIC_DC_MEM 0x0733ac61
@@ -108,6 +111,117 @@ static struct vm_operations_struct video
 	.close    = videobuf_vm_close,
 };
 
+static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
+{
+	mem->is_userptr = 0;
+	mem->dma_handle = 0;
+	mem->size = 0;
+}
+
+/* modelled after follow_phys() in mm/memory.c */
+static int get_pfn(struct vm_area_struct *vma,
+		   unsigned long address, unsigned long *pfnp)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep, pte;
+	spinlock_t *ptl;
+
+	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP)))
+		goto no_page_table;
+
+	pgd = pgd_offset(mm, address);
+	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
+		goto no_page_table;
+
+	pud = pud_offset(pgd, address);
+	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
+		goto no_page_table;
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
+		goto no_page_table;
+
+	/* We cannot handle huge page PFN maps. Luckily they don't exist. */
+	if (pmd_huge(*pmd))
+		goto no_page_table;
+
+	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!ptep)
+		goto no_page_table;
+
+	pte = *ptep;
+	if (!pte_present(pte))
+		goto unlock;
+
+	*pfnp = pte_pfn(pte);
+	pte_unmap_unlock(ptep, ptl);
+	return 0;
+unlock:
+	pte_unmap_unlock(ptep, ptl);
+no_page_table:
+	return -EINVAL;
+}
+
+
+static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
+					struct videobuf_buffer *vb)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	unsigned long prev_pfn, this_pfn;
+	unsigned long pages_done, user_address;
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
+		ret = get_pfn(vma, user_address, &this_pfn);
+		if (ret)
+			break;
+
+		if (pages_done == 0) {
+			prev_pfn = this_pfn;
+			mem->dma_handle = this_pfn << PAGE_SHIFT;
+		} else {
+			if (this_pfn != (prev_pfn + 1))
+				ret = -EFAULT;
+		}
+
+		if (ret)
+			break;
+
+		prev_pfn = this_pfn;
+		user_address += PAGE_SIZE;
+		pages_done++;
+	}
+
+	if (!ret && pages_done)
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
@@ -154,11 +268,12 @@ static int __videobuf_iolock(struct vide
 	case V4L2_MEMORY_USERPTR:
 		dev_dbg(q->dev, "%s memory method USERPTR\n", __func__);
 
-		/* The only USERPTR currently supported is the one needed for
-		   read() method.
-		 */
+		/* handle pointer from user space */
+
 		if (vb->baddr)
-			return -EINVAL;
+			return videobuf_dma_contig_user_get(mem, vb);
+
+		/* allocate memory for the read() method */
 
 		mem->size = PAGE_ALIGN(vb->size);
 		mem->vaddr = dma_alloc_coherent(q->dev, mem->size,
@@ -190,8 +305,9 @@ static int __videobuf_sync(struct videob
 	BUG_ON(!mem);
 	MAGIC_CHECK(mem->magic, MAGIC_DC_MEM);
 
-	dma_sync_single_for_cpu(q->dev, mem->dma_handle, mem->size,
-				DMA_FROM_DEVICE);
+	if (!mem->is_userptr)
+		dma_sync_single_for_cpu(q->dev, mem->dma_handle, mem->size,
+					DMA_FROM_DEVICE);
 	return 0;
 }
 
@@ -400,7 +516,7 @@ void videobuf_dma_contig_free(struct vid
 	   So, it should free memory only if the memory were allocated for
 	   read() operation.
 	 */
-	if ((buf->memory != V4L2_MEMORY_USERPTR) || buf->baddr)
+	if (buf->memory != V4L2_MEMORY_USERPTR)
 		return;
 
 	if (!mem)
@@ -408,6 +524,14 @@ void videobuf_dma_contig_free(struct vid
 
 	MAGIC_CHECK(mem->magic, MAGIC_DC_MEM);
 
+	/* handle user space pointer case */
+	if (buf->baddr) {
+		videobuf_dma_contig_user_put(mem);
+		return;
+	}
+
+	/* read() method */
+
 	dma_free_coherent(q->dev, mem->size, mem->vaddr, mem->dma_handle);
 	mem->vaddr = NULL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
