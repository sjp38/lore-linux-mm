Received: from shaolinmicro.com (cm61-15-171-82.hkcable.com.hk [61.15.171.82])
	by mail.shaolinmicro.com (8.12.8/8.12.5) with ESMTP id h5NFpgG0007128
	for <linux-mm@kvack.org>; Mon, 23 Jun 2003 23:51:42 +0800
Message-ID: <3EF7220E.1080308@shaolinmicro.com>
Date: Mon, 23 Jun 2003 23:51:42 +0800
From: David Chow <davidchow@shaolinmicro.com>
MIME-Version: 1.0
Subject: (corrected) swap modules
References: <3EF71713.90706@shaolinmicro.com>
Content-Type: multipart/mixed;
 boundary="------------010907050108070002010902"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010907050108070002010902
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Please ignore the previous patch, the file drivers/scsi/sim710_d.h was 
accidentally patched. This is the correct one instead.

regards,
David Chow

David Chow wrote:

> Dear linux-mm team,
>
> This patch is for patching the mm and fs stuff to make the Linux 
> 2.4.21 swap code to allow a concept of modularized swap methods. This 
> concept and swap code is originally from Justus Heine who created the 
> NFS swap patch for 2.2 and 2.4 . I've extracted the code and modified 
> to make it as a generic swap module code. The vanilla kernel swap code 
> is been moved to a file fs/blkdev_swap.c which is for normal plain 
> block device swaps. Users can configure the kernel to include the 
> local block device swap code or compile it as a module. Developers can 
> also develop their own swap methods instead of using the plain swap 
> code (may be some crypto for security reasons) . I've been using this 
> API to develop NFS swap and netswap code for a year an more. This 
> patch has been tested for more than a year in a production environment 
> on smp and non-smp (I think it is quite stable though). Please find it 
> useful.
>
> regards,
> David Chow


--------------010907050108070002010902
Content-Type: text/plain;
 name="swap_module-2.4.21.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="swap_module-2.4.21.diff"

diff -uaNr linux-2.4.21/Documentation/Configure.help linux-2.4.21-1APTUS/Documentation/Configure.help
--- linux-2.4.21/Documentation/Configure.help	2003-06-22 18:34:45.000000000 +0800
+++ linux-2.4.21-1APTUS/Documentation/Configure.help	2003-06-22 19:57:04.000000000 +0800
@@ -12784,6 +12784,16 @@
   If you are running Linux on an IBM iSeries system and you want to
   read a CD drive owned by OS/400, say Y here.
 
+Swapping to block device and local filesystems
+CONFIG_BLOCKDEV_SWAP
+  Say yes to enable virtual memory swap to block devices. If you have
+  a local disk drive and wish to use swap say 'Y', otherwise say 'N'.
+  
+  If local swaping is option to your system, say 'M' and compile it
+  as a module.
+
+  If unsure, choose 'M' to compile it as a module for safe.
+
 Quota support
 CONFIG_QUOTA
   If you say Y here, you will be able to set per user limits for disk
diff -uaNr linux-2.4.21/fs/blkdev_swap.c linux-2.4.21-1APTUS/fs/blkdev_swap.c
--- linux-2.4.21/fs/blkdev_swap.c	1970-01-01 08:00:00.000000000 +0800
+++ linux-2.4.21-1APTUS/fs/blkdev_swap.c	2003-06-23 01:55:01.000000000 +0800
@@ -0,0 +1,327 @@
+/*
+ *  Copyright (c) 2000-2002 Shaolin Microsystems Ltd.
+ *
+ * Swapping to partitions or files on local disk partitions.
+ * 
+ * David Chow <davidchow@shaolinmicro.com>
+ *
+ * Copied from the original fs/buffer.c
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/locks.h>
+#include <linux/blkdev.h>
+#include <linux/pagemap.h>
+#include <linux/swap.h>
+#include <linux/fs.h>
+
+#ifdef DEBUG_BLKDEV_SWAP
+# define dprintk(fmt...) printk(##fmt)
+#else
+# define dprintk(fmt...) do { /* */ } while (0)
+#endif
+
+#define BLKDEV_SWAP_ID  	"blockdev"
+#define BLKDEV_FILE_SWAP_ID "blockdev file"
+
+/*
+ * Helper function, copied here from buffer.c
+ */
+
+/*
+ * Start I/O on a page.
+ * This function expects the page to be locked and may return
+ * before I/O is complete. You then have to check page->locked,
+ * page->uptodate, and maybe wait on page->wait.
+ *
+ * brw_swap_page() is SMP-safe, although it's being called with the
+ * kernel lock held - but the code is ready.
+ *
+ * FIXME: we need a swapper_inode->get_block function to remove
+ *  	  some of the bmap kludges and interface ugliness here.
+ */
+int brw_swap_page(int rw, struct page *page, kdev_t dev, int b[], int size)
+{
+   struct buffer_head *head, *bh;
+
+   if (!PageLocked(page))
+	   panic("brw_swap_page: page not locked for I/O");
+
+   if (!page->buffers)
+	   create_empty_buffers(page, dev, size);
+   head = bh = page->buffers;
+
+   /* Stage 1: lock all the buffers */
+   do {
+	   lock_buffer(bh);
+	   bh->b_blocknr = *(b++);
+	   set_bit(BH_Mapped, &bh->b_state);
+	   set_buffer_async_io(bh);
+	   bh = bh->b_this_page;
+   } while (bh != head);
+
+   /* Stage 2: start the IO */
+   do {
+	   struct buffer_head *next = bh->b_this_page;
+	   submit_bh(rw, bh);
+	   bh = next;
+   } while (bh != head);
+   return 0;
+}
+
+/*
+ * We implement to methods: swapping to partitions, and swapping to files
+ * located on partitions.
+ */
+
+struct blkdev_swap_data {
+   kdev_t dev;
+};
+
+struct test_data {
+   struct file * filp;
+   kdev_t dev;
+};
+
+static int is_blkdev_swapping(unsigned int flags,
+				 struct file * swapf,
+				 void *data)
+{
+   struct test_data *testdata = (struct test_data *) data;
+   struct file * filp = testdata->filp;
+   kdev_t dev = testdata->dev;
+
+   /* Only check filp's that don't match the one already opened
+	* for us by sys_swapon(). Otherwise, we will always flag a
+	* busy swap file.
+	*/
+
+   if (swapf != filp) {
+	   if (dev == swapf->f_dentry->d_inode->i_rdev)
+		   return 1;
+   }
+   return 0;
+}
+
+static int blkdev_swap_open(struct file * filp, void **dptr)
+{
+	int swapfilesize;
+	kdev_t dev;
+	struct blkdev_swap_data *data;
+	int error;
+	struct test_data testdata;
+
+	MOD_INC_USE_COUNT;
+
+	if (!S_ISBLK(filp->f_dentry->d_inode->i_mode)) {
+	 	dprintk(__FUNCTION__": can't handle this swap file: %s\n",
+	 		   swapf->d_name.name);
+	 	error = 0; /* not for us */
+	 	goto bad_swap;
+	}
+
+	dev = filp->f_dentry->d_inode->i_rdev;
+	set_blocksize(dev, PAGE_SIZE);
+	error = -ENODEV;
+	if (!dev ||
+	 	(blk_size[MAJOR(dev)] && !blk_size[MAJOR(dev)][MINOR(dev)])) {
+	 	printk("blkdev_swap_open: blkdev weirdness for %s\n",
+	 		   filp->f_dentry->d_name.name);
+	 	goto bad_swap;
+	}
+	 	
+	error = -EBUSY;
+	/* Check to see if the device is mounted */
+	if (S_ISBLK(filp->f_dentry->d_inode->i_mode) && is_mounted(dev)) {
+	 	printk("blkdev_swap_open: device already mounted, please unmount %s\n",
+			filp->f_dentry->d_name.name);
+		goto bad_swap;
+	}
+	
+	/* Check to make sure that we aren't already swapping. */
+	testdata.filp = filp;
+	testdata.dev = dev;
+	if (swap_run_test(is_blkdev_swapping, &testdata)) {
+	 	printk("blkdev_swap_open: already swapping to %s\n",
+	 		   filp->f_dentry->d_name.name);
+	 	goto bad_swap;
+	}
+
+	/* Check to make sure that we aren't already swapping. */
+	testdata.filp = filp;
+	testdata.dev = dev;
+	if (swap_run_test(is_blkdev_swapping, &testdata)) {
+	 	printk("blkdev_swap_open: already swapping to %s\n",
+	 		   filp->f_dentry->d_name.name);
+	 	goto bad_swap;
+	}
+
+	swapfilesize = 0;
+	if (blk_size[MAJOR(dev)])
+	 	swapfilesize = blk_size[MAJOR(dev)][MINOR(dev)]
+	 		>> (PAGE_SHIFT - 10);
+
+	if ((data = kmalloc(sizeof(*data), GFP_KERNEL)) == NULL) {
+	 	printk("blkdev_swap_open: can't allocate data for %s\n",
+	 		   filp->f_dentry->d_name.name);
+	 	error = -ENOMEM;
+	 	goto bad_swap;
+	}
+	data->dev = dev;
+	*dptr = data;
+
+	dprintk("blkdev_swap_open: returning %d\n", swapfilesize);
+	return swapfilesize;
+
+ bad_swap:
+	MOD_DEC_USE_COUNT;
+	return error; /* this swap thing is not for us */   
+}
+
+static int blkdev_swap_release(struct file * filp, void *data)
+{
+   dprintk("blkdev_swap_release: releasing swap device %s\n",
+	   filp->f_dentry->d_name.name);
+   kfree(data);
+   MOD_DEC_USE_COUNT;
+   return 0;
+}
+
+static int blkdev_rw_page(int rw, struct page *page, unsigned long offset,
+			 void *ptr)
+{
+   struct blkdev_swap_data *data = (struct blkdev_swap_data *)ptr;
+   brw_swap_page(rw, page, data->dev, (int *)&offset, PAGE_SIZE);
+   return 1;
+}
+
+static struct swap_ops blkdev_swap_ops = {
+   blkdev_swap_open,
+   blkdev_swap_release,
+   blkdev_rw_page
+};
+
+struct blkdevfile_swap_data {
+   struct inode *swapf;
+};
+
+static int is_blkdevfile_swapping(unsigned int flags,
+				 struct file * swapf,
+				 void * data)
+{
+   struct file * filp = (struct file *) data;
+
+   /* Only check filp's that don't match the one already opened
+	* for us by sys_swapon(). Otherwise, we will always flag a
+	* busy swap file.
+	*/
+
+   if (swapf != filp) {
+	   if (filp->f_dentry->d_inode == swapf->f_dentry->d_inode)
+		   return 1;
+   }
+   return 0;
+}
+
+static int blkdevfile_swap_open(struct file *swapf, void **dptr)
+{
+   int error = 0;
+   int swapfilesize;
+   struct blkdevfile_swap_data *data;
+
+   MOD_INC_USE_COUNT;
+
+   /* first check whether this is a regular file located on a local 
+	* hard disk
+	*/
+   if (!S_ISREG(swapf->f_dentry->d_inode->i_mode)) {
+	   dprintk("blkdevfile_swap_open: "
+		   "can't handle this swap file: %s\n",
+		   swapf->d_name.name);
+	   error = 0; /* not for us */
+	   goto bad_swap;
+   }
+   if (!swapf->f_dentry->d_inode->i_mapping->a_ops->bmap) {
+	   dprintk("blkdevfile_swap_open: no bmap for file: %s\n",
+		   swapf->d_name.name);
+	   error = 0; /* not for us */
+	   goto bad_swap;
+   }
+
+   if (swap_run_test(is_blkdevfile_swapping, swapf)) {
+	   dprintk("blkdevfile_swap_open: already swapping to %s\n",
+		   swapf->d_name.name);
+	   error = -EBUSY;
+	   goto bad_swap;
+   }
+   swapfilesize = swapf->f_dentry->d_inode->i_size >> PAGE_SHIFT;
+   if ((data = kmalloc(sizeof(*data), GFP_KERNEL)) == NULL) {
+	   error = -ENOMEM;
+	   goto bad_swap;
+   }
+   data->swapf = swapf->f_dentry->d_inode;
+   *dptr = data;
+   return swapfilesize;
+
+ bad_swap:
+   MOD_DEC_USE_COUNT;
+   return error;
+}
+
+static int blkdevfile_swap_release(struct file *swapf, void *data)
+{
+   kfree(data);
+   MOD_DEC_USE_COUNT;
+   return 0;
+}
+
+static int blkdevfile_rw_page(int rw, struct page *page, unsigned long offset,
+				 void *ptr)
+{
+   struct blkdevfile_swap_data *data = (struct blkdevfile_swap_data *)ptr;
+   struct inode * swapf = data->swapf;
+   int i, j;
+   unsigned int block = offset
+	   << (PAGE_SHIFT - swapf->i_sb->s_blocksize_bits);
+   kdev_t dev = swapf->i_dev;
+   int block_size;
+   int zones[PAGE_SIZE/512];
+   int zones_used;
+
+   block_size = swapf->i_sb->s_blocksize;
+   for (i=0, j=0; j< PAGE_SIZE ; i++, j += block_size)
+	   if (!(zones[i] = bmap(swapf,block++))) {
+		   printk("blkdevfile_rw_page: bad swap file\n");
+		   return 0;
+		   }
+   zones_used = i;
+   
+   /* block_size == PAGE_SIZE/zones_used */
+   brw_swap_page(rw, page, dev, zones, block_size);
+   return 1;
+}
+
+static struct swap_ops blkdevfile_swap_ops = {
+   blkdevfile_swap_open,
+   blkdevfile_swap_release,
+   blkdevfile_rw_page
+ };
+
+int __init blkdev_swap_init(void)
+{
+   (void)register_swap_method(BLKDEV_SWAP_ID, &blkdev_swap_ops);
+   (void)register_swap_method(BLKDEV_FILE_SWAP_ID, &blkdevfile_swap_ops);
+   return 0;
+}
+
+void __exit blkdev_swap_exit(void)
+{
+   unregister_swap_method(BLKDEV_SWAP_ID);
+   unregister_swap_method(BLKDEV_FILE_SWAP_ID);
+}
+
+module_init(blkdev_swap_init)
+module_exit(blkdev_swap_exit)
diff -uaNr linux-2.4.21/fs/buffer.c linux-2.4.21-1APTUS/fs/buffer.c
--- linux-2.4.21/fs/buffer.c	2003-06-22 17:35:00.000000000 +0800
+++ linux-2.4.21-1APTUS/fs/buffer.c	2003-06-23 01:57:44.000000000 +0800
@@ -737,7 +737,7 @@
 	bh->b_private = private;
 }
 
-static void end_buffer_io_async(struct buffer_head * bh, int uptodate)
+void end_buffer_io_async(struct buffer_head * bh, int uptodate)
 {
 	static spinlock_t page_uptodate_lock = SPIN_LOCK_UNLOCKED;
 	unsigned long flags;
diff -uaNr linux-2.4.21/fs/Config.in linux-2.4.21-1APTUS/fs/Config.in
--- linux-2.4.21/fs/Config.in	2002-11-29 07:53:15.000000000 +0800
+++ linux-2.4.21-1APTUS/fs/Config.in	2003-06-23 11:08:34.000000000 +0800
@@ -4,6 +4,8 @@
 mainmenu_option next_comment
 comment 'File systems'
 
+tristate 'Swapping to block devices and local filesystems' CONFIG_BLOCKDEV_SWAP
+
 bool 'Quota support' CONFIG_QUOTA
 tristate 'Kernel automounter support' CONFIG_AUTOFS_FS
 tristate 'Kernel automounter version 4 support (also supports v3)' CONFIG_AUTOFS4_FS
diff -uaNr linux-2.4.21/fs/Makefile linux-2.4.21-1APTUS/fs/Makefile
--- linux-2.4.21/fs/Makefile	2002-11-29 07:53:15.000000000 +0800
+++ linux-2.4.21-1APTUS/fs/Makefile	2003-06-22 19:53:12.000000000 +0800
@@ -82,5 +82,6 @@
 # persistent filesystems
 obj-y += $(join $(subdir-y),$(subdir-y:%=/%.o))
 
+obj-$(CONFIG_BLOCKDEV_SWAP)       += blkdev_swap.o
 
 include $(TOPDIR)/Rules.make
diff -uaNr linux-2.4.21/include/linux/fs.h linux-2.4.21-1APTUS/include/linux/fs.h
--- linux-2.4.21/include/linux/fs.h	2003-06-22 17:35:06.000000000 +0800
+++ linux-2.4.21-1APTUS/include/linux/fs.h	2003-06-23 01:15:04.000000000 +0800
@@ -1128,6 +1128,7 @@
 extern void refile_buffer(struct buffer_head * buf);
 extern void create_empty_buffers(struct page *, kdev_t, unsigned long);
 extern void end_buffer_io_sync(struct buffer_head *bh, int uptodate);
+extern void end_buffer_io_async(struct buffer_head * bh, int uptodate);
 
 /* reiserfs_writepage needs this */
 extern void set_buffer_async_io(struct buffer_head *bh) ;
diff -uaNr linux-2.4.21/include/linux/swap.h linux-2.4.21-1APTUS/include/linux/swap.h
--- linux-2.4.21/include/linux/swap.h	2003-06-22 17:35:07.000000000 +0800
+++ linux-2.4.21-1APTUS/include/linux/swap.h	2003-06-23 01:38:41.000000000 +0800
@@ -58,15 +58,29 @@
 #define SWAP_MAP_MAX	0x7fff
 #define SWAP_MAP_BAD	0x8000
 
+struct swap_ops {
+	int (*open)(struct file *swapf, void **data);
+	int (*release)(struct file *swapf, void *data);
+	int (*rw_page)(int rw,
+		       struct page *page, unsigned long offset, void *data);
+};
+
+struct swap_method {
+	struct swap_method *next;
+	char * name;
+	struct swap_ops *ops;
+	int use_count;
+};
+
 /*
  * The in-memory structure used to track swap areas.
  */
 struct swap_info_struct {
 	unsigned int flags;
-	kdev_t swap_device;
+	struct file *swap_file;
+	struct swap_method *method;
+	void *data;
 	spinlock_t sdev_lock;
-	struct dentry * swap_file;
-	struct vfsmount *swap_vfsmnt;
 	unsigned short * swap_map;
 	unsigned int lowest_bit;
 	unsigned int highest_bit;
@@ -142,10 +156,15 @@
 extern unsigned int nr_swapfiles;
 extern struct swap_info_struct swap_info[];
 extern int is_swap_partition(kdev_t);
+extern int register_swap_method(char *name, struct swap_ops *ops);
+extern int unregister_swap_method(char *name);
+extern int swap_run_test(int (*test_fct)(unsigned int flags,
+					 struct file *swap_file,
+					 void *testdata), void *testdata);
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(void);
-extern void get_swaphandle_info(swp_entry_t, unsigned long *, kdev_t *, 
-					struct inode **);
+struct swap_method *get_swaphandle_info(swp_entry_t entry,
+					unsigned long *offset, void **data);
 extern int swap_duplicate(swp_entry_t);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
 extern void swap_free(swp_entry_t);
diff -uaNr linux-2.4.21/kernel/ksyms.c linux-2.4.21-1APTUS/kernel/ksyms.c
--- linux-2.4.21/kernel/ksyms.c	2003-06-22 18:34:45.000000000 +0800
+++ linux-2.4.21-1APTUS/kernel/ksyms.c	2003-06-23 01:02:29.000000000 +0800
@@ -41,6 +41,7 @@
 #include <linux/mm.h>
 #include <linux/capability.h>
 #include <linux/highuid.h>
+#include <linux/swapctl.h>
 #include <linux/brlock.h>
 #include <linux/fs.h>
 #include <linux/tty.h>
@@ -93,6 +94,10 @@
 EXPORT_SYMBOL(kallsyms_symbol_to_address);
 EXPORT_SYMBOL(kallsyms_address_to_symbol);
 #endif
+EXPORT_SYMBOL(nr_free_pages);
+EXPORT_SYMBOL(register_swap_method);
+EXPORT_SYMBOL(unregister_swap_method);
+EXPORT_SYMBOL(swap_run_test);
 
 /* process memory management */
 EXPORT_SYMBOL(do_mmap_pgoff);
diff -uaNr linux-2.4.21/mm/page_io.c linux-2.4.21-1APTUS/mm/page_io.c
--- linux-2.4.21/mm/page_io.c	2002-11-29 07:53:15.000000000 +0800
+++ linux-2.4.21-1APTUS/mm/page_io.c	2003-06-23 00:32:31.000000000 +0800
@@ -32,15 +32,15 @@
  * atomic, which is particularly important when we are trying to ensure 
  * that shared pages stay shared while being swapped.
  */
-
+/* David: Don't know is this is corrct or not, since 2.4.14, the rw never 
+ * checked for WRITE. Not sure will we cause a problem here if we check for
+ * WRITE and start I/O and wait for completion.
+ */
 static int rw_swap_page_base(int rw, swp_entry_t entry, struct page *page)
 {
 	unsigned long offset;
-	int zones[PAGE_SIZE/512];
-	int zones_used;
-	kdev_t dev = 0;
-	int block_size;
-	struct inode *swapf = 0;
+	struct swap_method *method;
+	void *data;
 
 	if (rw == READ) {
 		ClearPageUptodate(page);
@@ -48,31 +48,21 @@
 	} else
 		kstat.pswpout++;
 
-	get_swaphandle_info(entry, &offset, &dev, &swapf);
-	if (dev) {
-		zones[0] = offset;
-		zones_used = 1;
-		block_size = PAGE_SIZE;
-	} else if (swapf) {
-		int i, j;
-		unsigned int block = offset
-			<< (PAGE_SHIFT - swapf->i_sb->s_blocksize_bits);
-
-		block_size = swapf->i_sb->s_blocksize;
-		for (i=0, j=0; j< PAGE_SIZE ; i++, j += block_size)
-			if (!(zones[i] = bmap(swapf,block++))) {
-				printk("rw_swap_page: bad swap file\n");
-				return 0;
-			}
-		zones_used = i;
-		dev = swapf->i_dev;
-	} else {
-		return 0;
+	method = get_swaphandle_info(entry, &offset, &data);
+
+	if (method) {
+ 		if (!method->ops->rw_page(rw, page, offset, data)) {
+	 		return 0;
+	 	}
+	/* Note! For consistency we do all of the logic,
+	 * decrementing the page count, and unlocking the page in the
+	 * swap lock map - in the IO completion handler.
+	 */
+	 	return 1;
+
 	}
 
- 	/* block_size == PAGE_SIZE/zones_used */
- 	brw_page(rw, page, dev, zones, block_size);
-	return 1;
+	return 0;
 }
 
 /*
diff -uaNr linux-2.4.21/mm/swapfile.c linux-2.4.21-1APTUS/mm/swapfile.c
--- linux-2.4.21/mm/swapfile.c	2003-06-22 17:35:08.000000000 +0800
+++ linux-2.4.21-1APTUS/mm/swapfile.c	2003-06-23 11:09:17.000000000 +0800
@@ -14,9 +14,15 @@
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/shm.h>
-
+#include <linux/file.h>
+#include <linux/compiler.h>
+#include <linux/nfs_fs.h>
 #include <asm/pgtable.h>
 
+#ifdef CONFIG_KMOD
+#include <linux/kmod.h>
+#endif
+
 spinlock_t swaplock = SPIN_LOCK_UNLOCKED;
 unsigned int nr_swapfiles;
 int total_swap_pages;
@@ -31,8 +37,78 @@
 
 struct swap_info_struct swap_info[MAX_SWAPFILES];
 
+static struct swap_method *swap_methods = NULL;
+
 #define SWAPFILE_CLUSTER 256
 
+int register_swap_method(char *name, struct swap_ops *ops)
+{
+	struct swap_method *pos;
+	struct swap_method *new;
+	int result = 0;
+
+	lock_kernel();
+
+	for (pos = swap_methods; pos; pos = pos->next) {
+		if (strcmp(pos->name, name) == 0) {
+			printk(KERN_ERR "register_swap_method: "
+			       "method %s already registered\n", name);
+			result = -EBUSY;
+			goto out;
+		}
+	}
+
+	if (!(new = kmalloc(sizeof(*new), GFP_KERNEL))) {
+		printk(KERN_ERR "register_swap_method: "
+		       "no memory for new method \"%s\"\n", name);
+		result = -ENOMEM;
+		goto out;
+	}
+
+	new->name      = name;
+	new->ops       = ops;
+	new->use_count = 0;
+
+	/* ok, insert at top of list */
+	printk("register_swap_method: method %s\n", name);
+	new->next    = swap_methods;
+	swap_methods = new;
+ out:
+	unlock_kernel();
+	return result;
+}
+
+int unregister_swap_method(char *name)
+{
+	struct swap_method **method, *next;
+	int result = 0;
+
+	lock_kernel();
+
+	for (method = &swap_methods; *method; method = &(*method)->next) {
+		if (strcmp((*method)->name, name) == 0) {
+			if ((*method)->use_count > 0) {
+				printk(KERN_ERR "unregister_swap_method: "
+				       "method \"%s\" is in use\n", name);
+				result = -EBUSY;
+				goto out;
+			}
+
+			next = (*method)->next;
+			kfree(*method);
+			*method = next;			
+			printk("unregister_swap_method: method %s\n", name);
+			goto out;
+		}
+	}
+	/* not found */
+	printk("unregister_swap_method: no such method %s\n", name);
+	result = -ENOENT;
+ out:
+	unlock_kernel();
+	return result;
+}
+
 static inline int scan_swap_map(struct swap_info_struct *si)
 {
 	unsigned long offset;
@@ -717,7 +793,7 @@
 
 	err = user_path_walk(specialfile, &nd);
 	if (err)
-		goto out;
+		return err;
 
 	lock_kernel();
 	prev = -1;
@@ -725,15 +801,20 @@
 	for (type = swap_list.head; type >= 0; type = swap_info[type].next) {
 		p = swap_info + type;
 		if ((p->flags & SWP_WRITEOK) == SWP_WRITEOK) {
-			if (p->swap_file == nd.dentry)
-			  break;
+			if (p->swap_file &&
+			    p->swap_file->f_dentry == nd.dentry)
+				break;
 		}
 		prev = type;
 	}
 	err = -EINVAL;
+	/* p->swap_file contains all needed info, no need to keep nd, so
+	 * release it now.
+	 */
+	path_release(&nd);
 	if (type < 0) {
 		swap_list_unlock();
-		goto out_dput;
+		goto out;
 	}
 
 	if (prev < 0) {
@@ -767,19 +848,18 @@
 		total_swap_pages += p->pages;
 		p->flags = SWP_WRITEOK;
 		swap_list_unlock();
-		goto out_dput;
+		goto out;
 	}
-	if (p->swap_device)
-		blkdev_put(p->swap_file->d_inode->i_bdev, BDEV_SWAP);
-	path_release(&nd);
 
+	if (p->method->ops->release)
+		p->method->ops->release(p->swap_file, p->data);
 	swap_list_lock();
 	swap_device_lock(p);
-	nd.mnt = p->swap_vfsmnt;
-	nd.dentry = p->swap_file;
-	p->swap_vfsmnt = NULL;
+	p->method->use_count --;
+	p->method = NULL;
+	p->data   = NULL;
+	filp_close(p->swap_file, NULL);
 	p->swap_file = NULL;
-	p->swap_device = 0;
 	p->max = 0;
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
@@ -789,10 +869,8 @@
 	vfree(swap_map);
 	err = 0;
 
-out_dput:
-	unlock_kernel();
-	path_release(&nd);
 out:
+	unlock_kernel();
 	return err;
 }
 
@@ -805,18 +883,17 @@
 	if (!page)
 		return -ENOMEM;
 
-	len += sprintf(buf, "Filename\t\t\tType\t\tSize\tUsed\tPriority\n");
+	len += sprintf(buf, "%-32s%-16s%-8s%-8sPriority\n",
+		       "Filename", "Type", "Size", "Used");
 	for (i = 0 ; i < nr_swapfiles ; i++, ptr++) {
 		if ((ptr->flags & SWP_USED) && ptr->swap_map) {
-			char * path = d_path(ptr->swap_file, ptr->swap_vfsmnt,
-						page, PAGE_SIZE);
+			char * path = d_path(ptr->swap_file->f_dentry,
+					     ptr->swap_file->f_vfsmnt,
+					     page, PAGE_SIZE);
 
 			len += sprintf(buf + len, "%-31s ", path);
 
-			if (!ptr->swap_device)
-				len += sprintf(buf + len, "file\t\t");
-			else
-				len += sprintf(buf + len, "partition\t");
+			len += sprintf(buf + len, "%-15s ", ptr->method->name);
 
 			usedswap = 0;
 			for (j = 0; j < ptr->max; ++j)
@@ -827,7 +904,7 @@
 					default:
 						usedswap++;
 				}
-			len += sprintf(buf + len, "%d\t%d\t%d\n", ptr->pages << (PAGE_SHIFT - 10), 
+			len += sprintf(buf + len, "%-8d%-8d%d\n", ptr->pages << (PAGE_SHIFT - 10), 
 				usedswap << (PAGE_SHIFT - 10), ptr->prio);
 		}
 	}
@@ -835,28 +912,89 @@
 	return len;
 }
 
-int is_swap_partition(kdev_t dev) {
+/* apply a test function to all active swap objects. E.g. for checking
+ * whether a partition is used for swapping
+ */
+int swap_run_test(int (*test_fct)(unsigned int flags,
+				  struct file * swap_file,
+				  void *testdata), void *testdata)
+{
 	struct swap_info_struct *ptr = swap_info;
 	int i;
 
 	for (i = 0 ; i < nr_swapfiles ; i++, ptr++) {
-		if (ptr->flags & SWP_USED)
-			if (ptr->swap_device == dev)
-				return 1;
+		if (ptr->swap_file && 
+		    test_fct(ptr->flags, ptr->swap_file, testdata))
+			return 1;
 	}
 	return 0;
 }
 
+/* Walk through the list of known swap method until somebody wants to
+ * handle this file. Pick the first one which claims to be able to
+ * swap to this kind of file.
+ *
+ * return value: < 0: error, 0: not found, > 0: swapfilesize
+ */
+int find_swap_method(struct file *swap_file,
+		     struct swap_info_struct *p)
+{
+	int swapfilesize = 0;
+	struct swap_method *method;
+
+	p->method = NULL;
+	for (method = swap_methods; method; method = method->next) {
+		swapfilesize = method->ops->open(swap_file, &p->data);
+		if (swapfilesize == 0) {
+			continue;
+		}
+		if (swapfilesize > 0) {
+			p->method = method;
+			p->method->use_count ++;
+			p->swap_file = swap_file;
+			break;
+		}
+		if (swapfilesize < 0) {
+			break;
+		}
+	}
+	return swapfilesize;
+}
+
+/* swap_run_test() applies this hook to all swapfiles until it returns
+ * "1".  If it never return "1", the result of swap_run_test() is "0",
+ * otherwise "1".
+ */
+static int is_swap_partition_hook(unsigned int flags, struct file *swap_file,
+				  void *testdata)
+{
+	kdev_t swap_dev = S_ISBLK(swap_file->f_dentry->d_inode->i_mode)
+		? swap_file->f_dentry->d_inode->i_rdev : 0;
+	kdev_t dev = *((kdev_t *)testdata);
+	
+	if (flags & SWP_USED && dev == swap_dev) {
+		return 1;
+	} else {
+		return 0;
+	}
+}
+
+/* A wrapper to the swap_run_test() which test for swap methods
+ */
+int is_swap_partition(kdev_t dev) {
+	return swap_run_test(is_swap_partition_hook, &dev);
+}
+
 /*
  * Written 01/25/92 by Simmule Turner, heavily changed by Linus.
+ * 22nd June 2003 David Chow <davidchow@shaolinmicro.com>
+ * Modified to enable the swap method hooks
  *
  * The swapon system call
  */
 asmlinkage long sys_swapon(const char * specialfile, int swap_flags)
 {
 	struct swap_info_struct * p;
-	struct nameidata nd;
-	struct inode * swap_inode;
 	unsigned int type;
 	int i, j, prev;
 	int error;
@@ -866,9 +1004,9 @@
 	int nr_good_pages = 0;
 	unsigned long maxpages = 1;
 	int swapfilesize;
-	struct block_device *bdev = NULL;
 	unsigned short *swap_map;
-	
+	char * tmp_specialfile;
+
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 	lock_kernel();
@@ -886,8 +1024,7 @@
 		nr_swapfiles = type+1;
 	p->flags = SWP_USED;
 	p->swap_file = NULL;
-	p->swap_vfsmnt = NULL;
-	p->swap_device = 0;
+	p->method = NULL;
 	p->swap_map = NULL;
 	p->lowest_bit = 0;
 	p->highest_bit = 0;
@@ -901,58 +1038,69 @@
 		p->prio = --least_priority;
 	}
 	swap_list_unlock();
-	error = user_path_walk(specialfile, &nd);
-	if (error)
-		goto bad_swap_2;
-
-	p->swap_file = nd.dentry;
-	p->swap_vfsmnt = nd.mnt;
-	swap_inode = nd.dentry->d_inode;
-	error = -EINVAL;
+	/* Open the swap using filp_open. Bail out on any errors. */
+	tmp_specialfile = getname(specialfile);
+	if (IS_ERR(tmp_specialfile)) {
+	    error = PTR_ERR(tmp_specialfile);
+	    	goto bad_swap_2;
+	}
+	p->swap_file = filp_open(tmp_specialfile, O_RDWR, 0600);
+	putname(tmp_specialfile);
+	if (IS_ERR(p->swap_file)) {
+	    error = PTR_ERR(p->swap_file);
+	    goto bad_swap_1;
+	}
 
-	if (S_ISBLK(swap_inode->i_mode)) {
-		kdev_t dev = swap_inode->i_rdev;
-		struct block_device_operations *bdops;
-		devfs_handle_t de;
-
-		if (is_mounted(dev)) {
-			error = -EBUSY;
-			goto bad_swap_2;
-		}
+	error = -EINVAL;
 
-		p->swap_device = dev;
-		set_blocksize(dev, PAGE_SIZE);
-		
-		bd_acquire(swap_inode);
-		bdev = swap_inode->i_bdev;
-		de = devfs_get_handle_from_inode(swap_inode);
-		bdops = devfs_get_ops(de);  /*  Increments module use count  */
-		if (bdops) bdev->bd_op = bdops;
-
-		error = blkdev_get(bdev, FMODE_READ|FMODE_WRITE, 0, BDEV_SWAP);
-		devfs_put_ops(de);/*Decrement module use count now we're safe*/
-		if (error)
-			goto bad_swap_2;
-		set_blocksize(dev, PAGE_SIZE);
-		error = -ENODEV;
-		if (!dev || (blk_size[MAJOR(dev)] &&
-		     !blk_size[MAJOR(dev)][MINOR(dev)]))
-			goto bad_swap;
-		swapfilesize = 0;
-		if (blk_size[MAJOR(dev)])
-			swapfilesize = blk_size[MAJOR(dev)][MINOR(dev)]
-				>> (PAGE_SHIFT - 10);
-	} else if (S_ISREG(swap_inode->i_mode))
-		swapfilesize = swap_inode->i_size >> PAGE_SHIFT;
-	else
-		goto bad_swap;
+	swapfilesize = find_swap_method(p->swap_file, p);
+	if (swapfilesize < 0) {
+	    error = swapfilesize;
+	    filp_close(p->swap_file, NULL);
+	    goto bad_swap_1;
+	}
+
+#ifdef CONFIG_KMOD
+	if (swapfilesize == 0) {
+		if ((p->swap_file->f_dentry->d_sb
+	    	&& (p->swap_file->f_dentry->d_sb->s_type->fs_flags & FS_REQUIRES_DEV)) 
+	    	|| (p->swap_file->f_dentry->d_inode 
+	    	&& S_ISBLK(p->swap_file->f_dentry->d_inode->i_mode))) {
+	    	/* It looks like a block device filesystem */
+	    	(void)request_module("blkdev_swap");
+	    } else {
+			/* User may specify which swap module it use */
+	    	(void)request_module("swapfile-mod");
+	    }
+	    
+	    swapfilesize = find_swap_method(p->swap_file, p);
+	    if (swapfilesize < 0) {
+	    	error = swapfilesize;
+	    	filp_close(p->swap_file, NULL);
+	    	goto bad_swap_1;
+	    }
+	}
+#endif  	  
+	if (swapfilesize == 0) {
+	    printk("Invalid swap file\n");
+	    filp_close(p->swap_file, NULL);
+	    goto bad_swap_1; /* free swap map */
+	}
+
+	/* After this point, the swap-file has been opened by the swap
+	 * method. We must make sure to use the bad_swap label for any
+	 * errors.
+	 */
 
 	error = -EBUSY;
+
 	for (i = 0 ; i < nr_swapfiles ; i++) {
 		struct swap_info_struct *q = &swap_info[i];
 		if (i == type || !q->swap_file)
 			continue;
-		if (swap_inode->i_mapping == q->swap_file->d_inode->i_mapping)
+		if (p->swap_file->f_dentry->d_inode->i_mapping
+		    ==
+		    q->swap_file->f_dentry->d_inode->i_mapping)
 			goto bad_swap;
 	}
 
@@ -1088,17 +1236,25 @@
 	swap_list_unlock();
 	error = 0;
 	goto out;
+
 bad_swap:
-	if (bdev)
-		blkdev_put(bdev, BDEV_SWAP);
+	if (p->method->ops->release)
+		p->method->ops->release(p->swap_file, p->data);
+	swap_list_lock();
+	p->method->use_count --;
+	p->method = NULL;
+	p->data = NULL;
+	swap_list_unlock();
+
+bad_swap_1:
+	swap_list_lock();
+	p->swap_file = NULL;
+	swap_list_unlock();
+	
 bad_swap_2:
+
 	swap_list_lock();
 	swap_map = p->swap_map;
-	nd.mnt = p->swap_vfsmnt;
-	nd.dentry = p->swap_file;
-	p->swap_device = 0;
-	p->swap_file = NULL;
-	p->swap_vfsmnt = NULL;
 	p->swap_map = NULL;
 	p->flags = 0;
 	if (!(swap_flags & SWAP_FLAG_PREFER))
@@ -1106,7 +1262,7 @@
 	swap_list_unlock();
 	if (swap_map)
 		vfree(swap_map);
-	path_release(&nd);
+
 out:
 	if (swap_header)
 		free_page((long) swap_header);
@@ -1181,8 +1337,8 @@
 /*
  * Prior swap_duplicate protects against swap device deletion.
  */
-void get_swaphandle_info(swp_entry_t entry, unsigned long *offset, 
-			kdev_t *dev, struct inode **swapf)
+struct swap_method *get_swaphandle_info(swp_entry_t entry,
+					unsigned long *offset, void **data)
 {
 	unsigned long type;
 	struct swap_info_struct *p;
@@ -1190,32 +1346,26 @@
 	type = SWP_TYPE(entry);
 	if (type >= nr_swapfiles) {
 		printk(KERN_ERR "rw_swap_page: %s%08lx\n", Bad_file, entry.val);
-		return;
+		return NULL;
 	}
 
 	p = &swap_info[type];
 	*offset = SWP_OFFSET(entry);
 	if (*offset >= p->max && *offset != 0) {
 		printk(KERN_ERR "rw_swap_page: %s%08lx\n", Bad_offset, entry.val);
-		return;
+		return NULL;
 	}
 	if (p->swap_map && !p->swap_map[*offset]) {
 		printk(KERN_ERR "rw_swap_page: %s%08lx\n", Unused_offset, entry.val);
-		return;
+		return NULL;
 	}
 	if (!(p->flags & SWP_USED)) {
 		printk(KERN_ERR "rw_swap_page: %s%08lx\n", Unused_file, entry.val);
-		return;
+		return NULL;
 	}
 
-	if (p->swap_device) {
-		*dev = p->swap_device;
-	} else if (p->swap_file) {
-		*swapf = p->swap_file->d_inode;
-	} else {
-		printk(KERN_ERR "rw_swap_page: no swap file or device\n");
-	}
-	return;
+	*data = p->data;
+	return p->method;
 }
 
 /*

--------------010907050108070002010902--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
