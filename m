Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AA2EB6B005D
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 21:40:18 -0400 (EDT)
Date: Tue, 14 Jul 2009 03:07:47 +0100 (BST)
From: Alexey Korolev <akorolev@infradead.org>
Subject: HugeTLB mapping for drivers (sample driver)
Message-ID: <alpine.LFD.2.00.0907140258100.25576@casper.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This is a sample driver which provides huge page mapping to user space.
It might be useful for understanding purposes.

Here we defined file operations for device driver.

We must call htlbfs get_unmapped_area and hugetlbfs_file_mmap functions to
 done some HTLB mapping preparations. (If proposed approach is more 
or less Ok, it will be more accurate to avoid hugetlbfs calls at all - and 
substitute them with htlb functions). 
Allocated page get assiciated with mapping via add_to_page_cache call in
file->open.

---
diff -Naurp empty/hpage_map.c hpage_map/hpage_map.c
--- empty/hpage_map.c	1970-01-01 12:00:00.000000000 +1200
+++ hpage_map/hpage_map.c	2009-07-13 18:40:28.000000000 +1200
@@ -0,0 +1,137 @@
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/file.h>
+#include <linux/pagemap.h>
+#include <linux/hugetlb.h>
+#include <linux/pagevec.h>
+#include <linux/miscdevice.h>
+
+static void make_file_empty(struct file *file)
+{
+    struct address_space *mapping = file->f_mapping;
+    struct pagevec pvec;
+    pgoff_t next = 0;
+    int i;
+
+    pagevec_init(&pvec, 0);
+    while (1) {
+	if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+	    if (!next)
+		break;
+	    next = 0;
+	    continue;
+	}
+
+	for (i = 0; i < pagevec_count(&pvec); ++i) {
+	    struct page *page = pvec.pages[i];
+
+	    lock_page(page);
+	    if (page->index > next)
+		next = page->index;
+	    ++next;
+	    remove_from_page_cache(page);
+	    unlock_page(page);
+	    hugetlb_free_pages(page);
+	}
+    }
+    BUG_ON(mapping->nrpages);
+}
+
+
+static int hpage_map_mmap(struct file *file, struct vm_area_struct
*vma)
+{
+	unsigned long idx;
+	struct address_space *mapping;
+	int ret = VM_FAULT_SIGBUS;
+
+	idx = vma->vm_pgoff >> huge_page_order(h);
+	mapping = file->f_mapping;
+	ret = hugetlbfs_file_mmap(file, vma);
+
+	return ret;
+}
+
+
+static unsigned long hpage_map_get_unmapped_area(struct file *file,
+	unsigned long addr, unsigned long len, unsigned long pgoff,
+	unsigned long flags)
+{
+	return hugetlb_get_unmapped_area(file, addr, len, pgoff, flags);
+}
+
+static int hpage_map_open(struct inode * inode, struct file * file)
+{
+    struct page *page;
+    int num_hpages = 10, cnt = 0;
+    int ret = 0;
+    
+    /* Announce  hugetlb file mapping */
+    mapping_set_hugetlb(file->f_mapping);
+    
+    for (cnt = 0; cnt < num_hpages; cnt++ ) {
+	page = hugetlb_alloc_pages_node(0,GFP_KERNEL);
+	if (IS_ERR(page)) {
+	    ret = -PTR_ERR(page);
+	    goto out_err;	
+	}	
+	ret = add_to_page_cache(page, file->f_mapping, cnt, GFP_KERNEL);
+	if (ret) {
+	    hugetlb_free_pages(page);
+	    goto out_err;
+	}
+	SetPageUptodate(page);
+	unlock_page(page);
+    }
+    return 0;
+out_err:
+    printk(KERN_ERR"%s : Error %d \n",__func__, ret);
+    make_file_empty(file);
+    return ret;
+}
+
+
+static int hpage_map_release(struct inode * inode, struct file * file)
+{
+    make_file_empty(file);
+    return 0;
+}
+/*
+ * The file operations for /dev/hpage_map
+ */
+static const struct file_operations hpage_map_fops = {
+	.owner		= THIS_MODULE,
+	.mmap		= hpage_map_mmap,
+	.open 		= hpage_map_open,
+	.release	= hpage_map_release,
+	.get_unmapped_area	= hpage_map_get_unmapped_area,
+};
+
+static struct miscdevice hpage_map_dev = {
+	MISC_DYNAMIC_MINOR,
+	"hpage_map",
+	&hpage_map_fops
+};
+
+static int __init
+hpage_map_init(void)
+{
+	/* Create the device in the /sys/class/misc directory. */
+	if (misc_register(&hpage_map_dev))
+		return -EIO;
+	return 0;
+}
+
+module_init(hpage_map_init);
+
+static void __exit
+hpage_map_exit(void)
+{
+	misc_deregister(&hpage_map_dev);
+}
+
+module_exit(hpage_map_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Alexey Korolev");
+MODULE_DESCRIPTION("Example of driver with hugetlb mapping");
+MODULE_VERSION("1.0");
diff -Naurp empty/Makefile hpage_map/Makefile
--- empty/Makefile	1970-01-01 12:00:00.000000000 +1200
+++ hpage_map/Makefile	2009-07-13 18:31:27.000000000 +1200
@@ -0,0 +1,7 @@
+obj-m := hpage_map.o 
+
+KDIR  := /lib/modules/$(shell uname -r)/build
+PWD   := $(shell pwd)
+
+default:
+	$(MAKE) -C $(KDIR) M=$(PWD) modules

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
