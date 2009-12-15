Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AEE4A6B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 12:48:08 -0500 (EST)
Message-ID: <4B27CBB6.2030906@agilent.com>
Date: Tue, 15 Dec 2009 09:47:34 -0800
From: Earl Chew <earl_chew@agilent.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
References: <1228379942.5092.14.camel@twins> <4B22DD89.2020901@agilent.com> <20091214192322.GA3245@bluebox.local> <4B27905B.4080006@agilent.com>
In-Reply-To: <4B27905B.4080006@agilent.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Hans J. Koch" <hjk@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, gregkh@suse.de, hugh <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Earl Chew wrote:
> I'd like to proceed by changing struct uio_mem [MAX_UIO_MAPS] to a
> linked list.

Here's my first go at changing to a linked list. I mistakenly
said that I would proceed by modifying struct uio_mem [MAX_UIO_MAPS].

In fact, I think that mem[MAX_UIO_MAPS] in struct uio_info can remain
intact -- thus preserving the client facing API.

The linked list change occurs in struct uio_device which is private
to uio.c ... thus hiding the change from client facing code.


Tying the regions into a linked list held by struct uio_device
simplifies the search-modify code in the rest of uio.c.


Earl


diff -uNpw uio_driver.h.old uio_driver.h
--- c:/tmp/makereview.AGgMh	2009-12-15 09:41:23.146608800 -0800
+++ c:/tmp/makereview.oXYWW	2009-12-15 09:41:23.255983800 -0800
@@ -20,6 +20,8 @@
 
 /**
  * struct uio_mem - description of a UIO memory region
+ * @list_node:		list node for struct uio_device list
+ * @mapid:		mapping number for this region
  * @kobj:		kobject for this mapping
  * @addr:		address of the device's memory
  * @size:		size of IO
@@ -27,6 +29,8 @@
  * @internal_addr:	ioremap-ped version of addr, for driver internal use
  */
 struct uio_mem {
+        struct list_head        list_node;
+        unsigned                map_id;
 	struct kobject		kobj;
 	unsigned long		addr;
 	unsigned long		size;

diff -uNpw uio.c.old uio.c
--- c:/tmp/makereview.O27Xv	2009-12-15 09:41:26.740358800 -0800
+++ c:/tmp/makereview.DAhCY	2009-12-15 09:41:26.834108800 -0800
@@ -35,6 +35,7 @@ struct uio_device {
 	int			vma_count;
 	struct uio_info		*info;
 	struct kset 		map_attr_kset;
+	struct list_head	mem_list;
 };
 
 static int uio_major;
@@ -153,7 +154,7 @@ static int uio_dev_add_attributes(struct
 	if (ret)
 		goto err_group;
 
-	for (mi = 0; mi < MAX_UIO_MAPS; mi++) {
+	for (mi = 0; mi < ARRAY_SIZE(idev->info->mem); mi++) {
 		mem = &idev->info->mem[mi];
 		if (mem->size == 0)
 			break;
@@ -166,6 +167,12 @@ static int uio_dev_add_attributes(struct
 			if (ret)
 				goto err_remove_group;
 		}
+
+		mem->map_id = mi;
+
+		INIT_LIST_HEAD(&mem->list_node);
+		list_add(&mem->list_node, &idev->mem_list);
+
 		kobject_init(&mem->kobj);
 		kobject_set_name(&mem->kobj,"map%d",mi);
 		mem->kobj.parent = &idev->map_attr_kset.kobj;
@@ -180,6 +187,7 @@ static int uio_dev_add_attributes(struct
 err_remove_maps:
 	for (mi--; mi>=0; mi--) {
 		mem = &idev->info->mem[mi];
+		list_del(&mem->list_node);
 		kobject_unregister(&mem->kobj);
 	}
 	kset_unregister(&idev->map_attr_kset); /* Needed ? */
@@ -194,10 +202,11 @@ static void uio_dev_del_attributes(struc
 {
 	int mi;
 	struct uio_mem *mem;
-	for (mi = 0; mi < MAX_UIO_MAPS; mi++) {
+	for (mi = 0; mi < ARRAY_SIZE(idev->info->mem); mi++) {
 		mem = &idev->info->mem[mi];
 		if (mem->size == 0)
 			break;
+		list_del(&mem->list_node);
 		kobject_unregister(&mem->kobj);
 	}
 	kset_unregister(&idev->map_attr_kset);
@@ -386,18 +395,20 @@ static ssize_t uio_read(struct file *fil
 	return retval;
 }
 
-static int uio_find_mem_index(struct vm_area_struct *vma)
+static struct uio_mem *uio_find_mem_index(struct vm_area_struct *vma)
 {
-	int mi;
 	struct uio_device *idev = vma->vm_private_data;
+	struct list_head *mem_list;
+
+	list_for_each(mem_list, &idev->mem_list) {
 
-	for (mi = 0; mi < MAX_UIO_MAPS; mi++) {
-		if (idev->info->mem[mi].size == 0)
-			return -1;
-		if (vma->vm_pgoff == mi)
-			return mi;
+		struct uio_mem *mem =
+			list_entry(mem_list, struct uio_mem, list_node);
+
+		if (vma->vm_pgoff == mem->map_id)
+			return mem;
 	}
-	return -1;
+	return NULL;
 }
 
 static void uio_vma_open(struct vm_area_struct *vma)
@@ -415,17 +426,16 @@ static void uio_vma_close(struct vm_area
 static struct page *uio_vma_nopage(struct vm_area_struct *vma,
 				   unsigned long address, int *type)
 {
-	struct uio_device *idev = vma->vm_private_data;
 	struct page* page = NOPAGE_SIGBUS;
 
-	int mi = uio_find_mem_index(vma);
-	if (mi < 0)
+	struct uio_mem *mem = uio_find_mem_index(vma);
+	if (mem == NULL)
 		return page;
 
-	if (idev->info->mem[mi].memtype == UIO_MEM_LOGICAL)
-		page = virt_to_page(idev->info->mem[mi].addr);
+	if (mem->memtype == UIO_MEM_LOGICAL)
+		page = virt_to_page(mem->addr);
 	else
-		page = vmalloc_to_page((void*)idev->info->mem[mi].addr);
+		page = vmalloc_to_page((void*)mem->addr);
 	get_page(page);
 	if (type)
 		*type = VM_FAULT_MINOR;
@@ -440,16 +450,15 @@ static struct vm_operations_struct uio_v
 
 static int uio_mmap_physical(struct vm_area_struct *vma)
 {
-	struct uio_device *idev = vma->vm_private_data;
-	int mi = uio_find_mem_index(vma);
-	if (mi < 0)
+	struct uio_mem *mem = uio_find_mem_index(vma);
+	if (mem == NULL)
 		return -EINVAL;
 
 	vma->vm_flags |= VM_IO | VM_RESERVED;
 
 	return remap_pfn_range(vma,
 			       vma->vm_start,
-			       idev->info->mem[mi].addr >> PAGE_SHIFT,
+			       mem->addr >> PAGE_SHIFT,
 			       vma->vm_end - vma->vm_start,
 			       vma->vm_page_prot);
 }
@@ -466,7 +475,7 @@ static int uio_mmap(struct file *filep, 
 {
 	struct uio_listener *listener = filep->private_data;
 	struct uio_device *idev = listener->dev;
-	int mi;
+	struct uio_mem *mem;
 	unsigned long requested_pages, actual_pages;
 	int ret = 0;
 
@@ -475,12 +484,12 @@ static int uio_mmap(struct file *filep, 
 
 	vma->vm_private_data = idev;
 
-	mi = uio_find_mem_index(vma);
-	if (mi < 0)
+	mem = uio_find_mem_index(vma);
+	if (mem == NULL)
 		return -EINVAL;
 
 	requested_pages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
-	actual_pages = (idev->info->mem[mi].size + PAGE_SIZE -1) >> PAGE_SHIFT;
+	actual_pages = (mem->size + PAGE_SIZE -1) >> PAGE_SHIFT;
 	if (requested_pages > actual_pages)
 		return -EINVAL;
 
@@ -492,7 +501,7 @@ static int uio_mmap(struct file *filep, 
 		return ret;
 	}
 
-	switch (idev->info->mem[mi].memtype) {
+	switch (mem->memtype) {
 		case UIO_MEM_PHYS:
 			return uio_mmap_physical(vma);
 		case UIO_MEM_LOGICAL:
@@ -613,6 +622,7 @@ int __uio_register_device(struct module 
 	idev->info = info;
 	init_waitqueue_head(&idev->wait);
 	atomic_set(&idev->event, 0);
+	INIT_LIST_HEAD(&idev->mem_list);
 
 	ret = uio_get_minor(idev);
 	if (ret)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
