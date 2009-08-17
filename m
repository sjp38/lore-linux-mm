Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C35AE6B0055
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 18:57:20 -0400 (EDT)
Date: Mon, 17 Aug 2009 23:57:26 +0100 (BST)
From: Alexey Korolev <akorolev@infradead.org>
Subject: HTLB mapping for drivers. Driver example
Message-ID: <alpine.LFD.2.00.0908172346460.32114@casper.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,
This message contains driver example which mmaps huge pages to user level applications. 
The Init procedure does the the following:
* Allocates several hugepages, 
* Creates hugetlbfs file on vfs mount. When we create file we specify VM_NORESERVE flag in order to prevent memory reservation 
by hugetlbfs as pages will be added by driver. (It is also possible to use pages reserved by hugetlbfs in this case we need ask to reservation)
* Add allocated pages to page cache mapping of hugetlbfs file. So page_fault procedure can find and provide these pages to user level.

File operations of /dev/hpage_map do the following:

In file open we  associate mappings of /dev/xxx with the file on hugetlbfs (like it is done in ipc/shm.c)
	file->f_mapping = h_file->f_mapping;

In get_unmapped_area we should tell about addressing constraints in case of huge pages by calling hugetlbfs procedures. (as in ipc/shm.c)
	return get_unmapped_area(h_file, addr, len, pgoff, flags);

We need to let hugetlbfs do architecture specific operations with mapping in mmap call. This driver does not reserve any memory for private mappings 
so driver requests reservation from hugetlbfs. (Actually driver can do this as well but it will make it more complex)

The exit procedure:
* removes memory from page cache
* deletes file on hugetlbfs vfs mount
*  free pages

Application example is not shown here but it is very simple. It does the following: open file /dev/hpage_map, mmap a region, read/write memory, unmap file, close file.

#include <linux/module.h>
#include <linux/mm.h>
#include <linux/file.h>
#include <linux/pagemap.h>
#include <linux/hugetlb.h>
#include <linux/pagevec.h>
#include <linux/miscdevice.h>

#define NUM_HPAGES 10

static struct page	*data_pages[NUM_HPAGES];
static struct file	*h_file;
static struct hstate	*h;

static int hpage_map_mmap(struct file *file, struct vm_area_struct *vma)
{
	int ret;
	struct inode* host = h_file->f_mapping->host;
	unsigned long vsize, off;

	/* Check offsets and len */
	off = vma->vm_pgoff * huge_page_size(h);
	vsize = vma->vm_end - vma->vm_start;
	if (off + vsize > host->i_size) {
		return -EINVAL;
	}
	/* Do not reserve memory from hugetlb pools for shared mappings
	 * because pages from page cache will be used*/
	if (vma->vm_flags & VM_SHARED)
		vma->vm_flags |= VM_NORESERVE;
	ret = h_file->f_op->mmap(h_file, vma);
	return ret;
}


static unsigned long hpage_map_get_unmapped_area(struct file *file,
	unsigned long addr, unsigned long len, unsigned long pgoff,
	unsigned long flags)
{
	/* Tell about addressing constrains in case of huge pages, 
	 * hugetlbfs knows how to do this */
	return get_unmapped_area(h_file, addr, len, pgoff, flags);
}

static int hpage_map_open(struct inode * inode, struct file * file)
{
	/* Associate mappings of /dev/xxx with the file on hugetlbfs 
	 * like it is done in ipc/shm.c */
	file->f_mapping = h_file->f_mapping;
	return 0;
}

/*
 * The file operations for /dev/hpage_map
 */
static const struct file_operations hpage_map_fops = {
	.owner		= THIS_MODULE,
	.mmap		= hpage_map_mmap,
	.open 		= hpage_map_open,
	.release	= hpage_map_release,
	.get_unmapped_area	= hpage_map_get_unmapped_area,
};

static struct miscdevice hpage_map_dev = {
	MISC_DYNAMIC_MINOR,
	"hpage_map",
	&hpage_map_fops
};

static int hpage_map_alloc(void)
{
	int cnt;

	/* Just allocates some hugetlb pages for further mapping */
	memset(data_pages, 0x0, sizeof(data_pages));
	for (cnt = 0; cnt < NUM_HPAGES; cnt++ ) {
		if (!(data_pages[cnt] = hugetlb_alloc_pages_immediate(h, 0, GFP_KERNEL)))
			return -ENOMEM;
	}
	return 0;
}

static int hpage_map_add_pgcache(void)
{
	int cnt, ret = -EIO;

	/* Add our pages to page cache manualy */
	for (cnt = 0; cnt < NUM_HPAGES; cnt++ ) {
		ret = add_to_page_cache(data_pages[cnt], 
				h_file->f_mapping, cnt, GFP_KERNEL);
		if (ret) 
			goto out_failed;
		SetPageUptodate(data_pages[cnt]);
		unlock_page(data_pages[cnt]);
	} mapping based
	return 0;

out_failed:
	while (cnt > 0) {
		cnt--;
		lock_page(data_pages[cnt]);
		remove_from_page_cache(data_pages[cnt]);
		unlock_page(data_pages[cnt]);
	}
	return ret;
}

static void hpage_map_free()
{
	int cnt;

	for (cnt = 0; cnt < NUM_HPAGES; cnt++ ) {
	if (data_pages[cnt]) 
		hugetlb_free_pages_immediate(h, data_pages[cnt]);
	}
}

static void hpage_map_remove_pgcache(void)
{
	int cnt;
	struct page *page;    
	/* Clean up page cache */
	for (cnt = 0; cnt < NUM_HPAGES; cnt++ ) {
		page = data_pages[cnt];
		lock_page(page);
		remove_from_page_cache(page);
		unlock_page(page);
	}
}

static int __init
hpage_map_init(void)
{
	int ret;
	/* Obtain hstate correspondent to hugetlbfs vfs mount*/
	h = hugetlb_vfsmount_hstate();

	/* Check if order is suitable for driver use */
	if (!h || huge_page_order(h) > (MAX_ORDER - 1) )
		return -EIO;

	/* Create the device in the /sys/class/misc directory. */
	if ((ret = misc_register(&hpage_map_dev)))
		return ret;

	/* Allocate some memory */
	if ((ret = hpage_map_alloc()))
		goto out_mem;

	/* Create file on hugetlbfs */
	h_file = hugetlb_file_setup("hpage_map_dev",
			huge_page_size(h) * NUM_HPAGES, VM_NORESERVE);
	if (IS_ERR(h_file)) {
		ret = -ENOENT;
		goto out_mem;
	}

	/* Add allocated pages to page cache */
	if ((ret = hpage_map_add_pgcache())
		goto out_file
out_file:
	fput(h_file);
out_mem:
	hpage_map_free();
	return ret;
}

module_init(hpage_map_init);

static void __exit
hpage_map_exit(void)
{
	hpage_map_remove_pgcache();
	fput(h_file);
	hpage_map_free();
	misc_deregister(&hpage_map_dev);
}

module_exit(hpage_map_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Alexey Korolev");
MODULE_DESCRIPTION("Example of driver with hugetlb mapping");
MODULE_VERSION("1.0");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
