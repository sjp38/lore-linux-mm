From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch][rfc] rewrite ramdisk
References: <200710151028.34407.borntraeger@de.ibm.com>
	<m1abqjirmd.fsf@ebiederm.dsl.xmission.com>
	<200710161808.06405.nickpiggin@yahoo.com.au>
	<200710161747.12968.nickpiggin@yahoo.com.au>
Date: Tue, 16 Oct 2007 03:08:46 -0600
In-Reply-To: <200710161747.12968.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Tue, 16 Oct 2007 17:47:12 +1000")
Message-ID: <m13awbifz5.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

Well on that same tune.  But with a slightly different implementation.
It compiles but I need to head to bed so I haven't had a chance
to test it yet.

Nick it is very similar to yours with the big difference being that
I embedded a struct address_space instead of rolled rerolled it by
hand, which saves a lot of lines of code.

Eric

---
drivers/block/rd.c
/*
 * ramdisk.c - Multiple RAM disk driver - gzip-loading version - v. 0.8 beta.
 *
 * (C) Chad Page, Theodore Ts'o, et. al, 1995.
 *
 * This RAM disk is designed to have filesystems created on it and mounted
 * just like a regular floppy disk.
 *
 * It also does something suggested by Linus: use the buffer cache as the
 * RAM disk data.  This makes it possible to dynamically allocate the RAM disk
 * buffer - with some consequences I have to deal with as I write this.
 *
 * This code is based on the original ramdisk.c, written mostly by
 * Theodore Ts'o (TYT) in 1991.  The code was largely rewritten by
 * Chad Page to use the buffer cache to store the RAM disk data in
 * 1995; Theodore then took over the driver again, and cleaned it up
 * for inclusion in the mainline kernel.
 *
 * The original CRAMDISK code was written by Richard Lyons, and
 * adapted by Chad Page to use the new RAM disk interface.  Theodore
 * Ts'o rewrote it so that both the compressed RAM disk loader and the
 * kernel decompressor uses the same inflate.c codebase.  The RAM disk
 * loader now also loads into a dynamic (buffer cache based) RAM disk,
 * not the old static RAM disk.  Support for the old static RAM disk has
 * been completely removed.
 *
 * Loadable module support added by Tom Dyas.
 *
 * Further cleanups by Chad Page (page0588@sundance.sjsu.edu):
 *	Cosmetic changes in #ifdef MODULE, code movement, etc.
 * 	When the RAM disk module is removed, free the protected buffers
 * 	Default RAM disk size changed to 2.88 MB
 *
 *  Added initrd: Werner Almesberger & Hans Lermen, Feb '96
 *
 * 4/25/96 : Made RAM disk size a parameter (default is now 4 MB)
 *		- Chad Page
 *
 * Add support for fs images split across >1 disk, Paul Gortmaker, Mar '98
 *
 * Make block size and block size shift for RAM disks a global macro
 * and set blk_size for -ENOSPC,     Werner Fink <werner@suse.de>, Apr '99
 */

#include <linux/string.h>
#include <linux/slab.h>
#include <asm/atomic.h>
#include <linux/bio.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/init.h>
#include <linux/pagemap.h>
#include <linux/blkdev.h>
#include <linux/genhd.h>
#include <linux/buffer_head.h>		/* for invalidate_bdev() */
#include <linux/backing-dev.h>
#include <linux/blkpg.h>
#include <linux/writeback.h>

#include <asm/uaccess.h>

#define RAMDISK_MINORS 250

struct ramdisk {
	struct address_space rd_mapping;
	struct gendisk *rd_disk;
	struct request_queue *rd_queue;
	struct list_head rd_list;
};

/* Various static variables go here.  Most are used only in the RAM disk code.
 */

static LIST_HEAD(ramdisks);
static DEFINE_MUTEX(ramdisks_mutex);

/*
 * Parameters for the boot-loading of the RAM disk.  These are set by
 * init/main.c (from arguments to the kernel command line) or from the
 * architecture-specific setup routine (from the stored boot sector
 * information).
 */
int rd_size = CONFIG_BLK_DEV_RAM_SIZE;		/* Size of the RAM disks */
/*
 * It would be very desirable to have a soft-blocksize (that in the case
 * of the ramdisk driver is also the hardblocksize ;) of PAGE_SIZE because
 * doing that we'll achieve a far better MM footprint. Using a rd_blocksize of
 * BLOCK_SIZE in the worst case we'll make PAGE_SIZE/BLOCK_SIZE buffer-pages
 * unfreeable. With a rd_blocksize of PAGE_SIZE instead we are sure that only
 * 1 page will be protected. Depending on the size of the ramdisk you
 * may want to change the ramdisk blocksize to achieve a better or worse MM
 * behaviour. The default is still BLOCK_SIZE (needed by rd_load_image that
 * supposes the filesystem in the image uses a BLOCK_SIZE blocksize).
 */
static int rd_blocksize = CONFIG_BLK_DEV_RAM_BLOCKSIZE;

/*
 * Copyright (C) 2000 Linus Torvalds.
 *               2000 Transmeta Corp.
 * aops copied from ramfs.
 */

static const struct address_space_operations ramdisk_aops = {
	.readpage	= simple_readpage,
	.set_page_dirty	= __set_page_dirty_no_writeback,
};

static struct ramdisk *bdev_ramdisk(struct block_device *bdev)
{
	return bdev->bd_disk->private_data;
}

static int rd_blkdev_pagecache_IO(int rw, struct bio_vec *vec, sector_t sector,
				struct address_space *mapping)
{
	pgoff_t index = sector >> (PAGE_CACHE_SHIFT - 9);
	unsigned int vec_offset = vec->bv_offset;
	int offset = (sector << 9) & ~PAGE_CACHE_MASK;
	int size = vec->bv_len;
	int err = 0;

	do {
		int count;
		struct page *page;
		char *src;
		char *dst;

		count = PAGE_CACHE_SIZE - offset;
		if (count > size)
			count = size;
		size -= count;

		page = grab_cache_page(mapping, index);
		if (!page) {
			err = -ENOMEM;
			goto out;
		}

		if (!PageUptodate(page)) {
			clear_highpage(page);
			SetPageUptodate(page);
		}

		index++;

		if (rw == READ) {
			src = kmap_atomic(page, KM_USER0) + offset;
			dst = kmap_atomic(vec->bv_page, KM_USER1) + vec_offset;
		} else {
			src = kmap_atomic(vec->bv_page, KM_USER0) + vec_offset;
			dst = kmap_atomic(page, KM_USER1) + offset;
		}
		offset = 0;
		vec_offset += count;

		memcpy(dst, src, count);

		kunmap_atomic(src, KM_USER0);
		kunmap_atomic(dst, KM_USER1);

		if (rw == WRITE)
			set_page_dirty(page);
		unlock_page(page);
		put_page(page);
	} while (size);

 out:
	return err;
}

/*
 *  Basically, my strategy here is to set up a buffer-head which can't be
 *  deleted, and make that my Ramdisk.  If the request is outside of the
 *  allocated size, we must get rid of it...
 *
 * 19-JAN-1998  Richard Gooch <rgooch@atnf.csiro.au>  Added devfs support
 *
 */
static int rd_make_request(struct request_queue *q, struct bio *bio)
{
	struct block_device *bdev = bio->bi_bdev;
	struct ramdisk *rd = bdev_ramdisk(bdev);
	struct address_space * mapping = &rd->rd_mapping;
	sector_t sector = bio->bi_sector;
	unsigned long len = bio->bi_size >> 9;
	int rw = bio_data_dir(bio);
	struct bio_vec *bvec;
	int ret = 0, i;

	if (sector + len > get_capacity(bdev->bd_disk))
		goto fail;

	if (rw==READA)
		rw=READ;

	bio_for_each_segment(bvec, bio, i) {
		ret |= rd_blkdev_pagecache_IO(rw, bvec, sector, mapping);
		sector += bvec->bv_len >> 9;
	}
	if (ret)
		goto fail;

	bio_endio(bio, 0);
	return 0;
fail:
	bio_io_error(bio);
	return 0;
} 

static int rd_ioctl(struct inode *inode, struct file *file,
			unsigned int cmd, unsigned long arg)
{
	int error;
	struct block_device *bdev = inode->i_bdev;
	struct ramdisk *rd = bdev_ramdisk(bdev);

	if (cmd != BLKFLSBUF)
		return -ENOTTY;

	/*
	 * special: we want to release the ramdisk memory, it's not like with
	 * the other blockdevices where this ioctl only flushes away the buffer
	 * cache
	 */
	error = -EBUSY;
	mutex_lock(&bdev->bd_mutex);
	if (bdev->bd_openers <= 1) {
		truncate_inode_pages(&rd->rd_mapping, 0);
		error = 0;
	}
	mutex_unlock(&bdev->bd_mutex);
	return error;
}

/*
 * This is the backing_dev_info for the blockdev inode itself.  It doesn't need
 * writeback and it does not contribute to dirty memory accounting.
 */
static struct backing_dev_info rd_backing_dev_info = {
	.ra_pages	= 0,	/* No readahead */
	.capabilities	= BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_WRITEBACK,
	.unplug_io_fn	= default_unplug_io_fn,
};

static struct block_device_operations rd_bd_op = {
	.owner =	THIS_MODULE,
	.ioctl =	rd_ioctl,
};

static struct ramdisk *rd_alloc(int i)
{
	struct ramdisk *rd;
	struct request_queue *queue;
	struct gendisk *disk;
	struct address_space *mapping;

	rd = kzalloc(sizeof(*rd), GFP_KERNEL);
	if (!rd)
		goto out;

	rd->rd_queue = queue = blk_alloc_queue(GFP_KERNEL);
	if (!rd->rd_queue)
		goto out_free_dev;

	disk = rd->rd_disk = alloc_disk(1);
	if (!disk)
		goto out_free_queue;

	mapping = &rd->rd_mapping;
	mapping->a_ops = &ramdisk_aops;
	mapping->backing_dev_info = &rd_backing_dev_info;
	mapping_set_gfp_mask(mapping, __GFP_WAIT | __GFP_HIGH | __GFP_HIGHMEM);

	blk_queue_make_request(queue, &rd_make_request);
	blk_queue_hardsect_size(queue, rd_blocksize);

	/* rd_size is given in kB */
	disk->major = RAMDISK_MAJOR;
	disk->first_minor = i;
	disk->fops = &rd_bd_op;
	disk->queue = queue;
	disk->flags |= GENHD_FL_SUPPRESS_PARTITION_INFO;
	sprintf(disk->disk_name, "ram%d", i);
	set_capacity(disk, rd_size * 2);
	disk->private_data = rd;
	add_disk(rd->rd_disk);
	list_add_tail(&rd->rd_list, &ramdisks);
	return rd;

out_free_queue:
	blk_cleanup_queue(queue);
out_free_dev:
	kfree(rd);
out:
	return NULL;
}

static void rd_free(struct ramdisk *rd)
{
	del_gendisk(rd->rd_disk);
	put_disk(rd->rd_disk);
	blk_cleanup_queue(rd->rd_queue);
	truncate_inode_pages(&rd->rd_mapping, 0);
	list_del(&rd->rd_list);
	kfree(rd);
}

static struct kobject *rd_probe(dev_t dev, int *part, void *data)
{
	struct ramdisk *rd;
	struct kobject *kobj;
	unsigned int unit;

	kobj = ERR_PTR(-ENOMEM);
	unit = MINOR(dev);

	mutex_lock(&ramdisks_mutex);
	list_for_each_entry(rd, &ramdisks, rd_list) {
		if (rd->rd_disk->first_minor == unit)
			goto found;
	}
	rd = rd_alloc(MINOR(dev));
found:
	if (rd)
		kobj = get_disk(rd->rd_disk);
	mutex_unlock(&ramdisks_mutex);

	*part = 0;
	return kobj;
}

/*
 * Before freeing the module, invalidate all of the protected buffers!
 */
static void __exit rd_cleanup(void)
{
	struct ramdisk *rd, *next;

	list_for_each_entry_safe(rd, next, &ramdisks, rd_list)
		rd_free(rd);

	blk_unregister_region(MKDEV(RAMDISK_MAJOR, 0), RAMDISK_MINORS);
	unregister_blkdev(RAMDISK_MAJOR, "ramdisk");
}

/*
 * This is the registration and initialization section of the RAM disk driver
 */
static int __init rd_init(void)
{
	if (rd_blocksize > PAGE_SIZE || rd_blocksize < 512 ||
			(rd_blocksize & (rd_blocksize-1))) {
		printk("RAMDISK: wrong blocksize %d, reverting to defaults\n",
		       rd_blocksize);
		rd_blocksize = BLOCK_SIZE;
	}

	if (register_blkdev(RAMDISK_MAJOR, "ramdisk"))
		return -EIO;

	blk_register_region(MKDEV(RAMDISK_MAJOR, 0), RAMDISK_MINORS,
				THIS_MODULE, rd_probe, NULL, NULL);

	/* rd_size is given in kB */
	printk("RAMDISK driver initialized: "
		"%d RAM disks of %dK size %d blocksize\n",
		CONFIG_BLK_DEV_RAM_COUNT, rd_size, rd_blocksize);

	return 0;
}

module_init(rd_init);
module_exit(rd_cleanup);

/* options - nonmodular */
#ifndef MODULE
static int __init ramdisk_size(char *str)
{
	rd_size = simple_strtol(str,NULL,0);
	return 1;
}
static int __init ramdisk_size2(char *str)	/* kludge */
{
	return ramdisk_size(str);
}
static int __init ramdisk_blocksize(char *str)
{
	rd_blocksize = simple_strtol(str,NULL,0);
	return 1;
}
__setup("ramdisk=", ramdisk_size);
__setup("ramdisk_size=", ramdisk_size2);
__setup("ramdisk_blocksize=", ramdisk_blocksize);
#endif

/* options - modular */
module_param(rd_size, int, 0);
MODULE_PARM_DESC(rd_size, "Size of each RAM disk in kbytes.");
module_param(rd_blocksize, int, 0);
MODULE_PARM_DESC(rd_blocksize, "Blocksize of each RAM disk in bytes.");
MODULE_ALIAS_BLOCKDEV_MAJOR(RAMDISK_MAJOR);

MODULE_LICENSE("GPL");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
