Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4F24E6B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 01:13:47 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8O5DnAp029566
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 24 Sep 2009 14:13:49 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 215B345DE55
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 14:13:49 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CEEE845DE54
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 14:13:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 99D76E1800F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 14:13:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 305F21DB805A
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 14:13:48 +0900 (JST)
Date: Thu, 24 Sep 2009 14:11:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] virtual block device driver (ramzswap)
Message-Id: <20090924141135.833474ad.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1253595414-2855-3-git-send-email-ngupta@vflare.org>
References: <1253595414-2855-1-git-send-email-ngupta@vflare.org>
	<1253595414-2855-3-git-send-email-ngupta@vflare.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, Marcin Slusarz <marcin.slusarz@gmail.com>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Sep 2009 10:26:53 +0530
Nitin Gupta <ngupta@vflare.org> wrote:

> Creates RAM based block devices (/dev/ramzswapX) which can be
> used (only) as swap disks. Pages swapped to these are compressed
> and stored in memory itself.
> 
> The module is called ramzswap.ko. It depends on:
>  - xvmalloc memory allocator (compiled with this driver)
>  - lzo_compress.ko
>  - lzo_decompress.ko
> 
> See ramzswap.txt for usage details.
> 
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> 

Hm...some concerns.

<snip>
> +	if (unlikely(clen > max_zpage_size)) {
> +		if (rzs->backing_swap) {
> +			mutex_unlock(&rzs->lock);
> +			fwd_write_request = 1;
> +			goto out;
> +		}
> +
> +		clen = PAGE_SIZE;
> +		page_store = alloc_page(GFP_NOIO | __GFP_HIGHMEM);
Here, and...

> +		if (unlikely(!page_store)) {
> +			mutex_unlock(&rzs->lock);
> +			pr_info("Error allocating memory for incompressible "
> +				"page: %u\n", index);
> +			stat_inc(rzs->stats.failed_writes);
> +			goto out;
> +		}
> +
> +		offset = 0;
> +		rzs_set_flag(rzs, index, RZS_UNCOMPRESSED);
> +		stat_inc(rzs->stats.pages_expand);
> +		rzs->table[index].page = page_store;
> +		src = kmap_atomic(page, KM_USER0);
> +		goto memstore;
> +	}
> +
> +	if (xv_malloc(rzs->mem_pool, clen + sizeof(*zheader),
> +			&rzs->table[index].page, &offset,
> +			GFP_NOIO | __GFP_HIGHMEM)) {

Here.
    
Do we need to wait until here for detecting page-allocation-failure ?
Detecting it here means -EIO for end_swap_bio_write()....unhappy
ALERT messages etc..

Can't we add a hook to get_swap_page() for preparing this ("do we have
enough pool?") and use only GFP_ATOMIC throughout codes ?
(memory pool for this swap should be big to some extent.)

>From my user support experience for heavy swap customers,  extra memory allocation for swapping out is just bad...in many cases.
(*) I know GFP_IO works well to some extent.

Thanks,
-Kame




> +		mutex_unlock(&rzs->lock);
> +		pr_info("Error allocating memory for compressed "
> +			"page: %u, size=%zu\n", index, clen);
> +		stat_inc(rzs->stats.failed_writes);
> +		if (rzs->backing_swap)
> +			fwd_write_request = 1;
> +		goto out;
> +	}
> +
> +memstore:
> +	rzs->table[index].offset = offset;
> +
> +	cmem = kmap_atomic(rzs->table[index].page, KM_USER1) +
> +			rzs->table[index].offset;
> +
> +#if 0
> +	/* Back-reference needed for memory defragmentation */
> +	if (!rzs_test_flag(rzs, index, RZS_UNCOMPRESSED)) {
> +		zheader = (struct zobj_header *)cmem;
> +		zheader->table_idx = index;
> +		cmem += sizeof(*zheader);
> +	}
> +#endif
> +
> +	memcpy(cmem, src, clen);
> +
> +	kunmap_atomic(cmem, KM_USER1);
> +	if (unlikely(rzs_test_flag(rzs, index, RZS_UNCOMPRESSED)))
> +		kunmap_atomic(src, KM_USER0);
> +
> +	/* Update stats */
> +	rzs->stats.compr_size += clen;
> +	stat_inc(rzs->stats.pages_stored);
> +	if (clen <= PAGE_SIZE / 2)
> +		stat_inc(rzs->stats.good_compress);
> +
> +	mutex_unlock(&rzs->lock);
> +
> +	set_bit(BIO_UPTODATE, &bio->bi_flags);
> +	bio_endio(bio, 0);
> +	return 0;
> +
> +out:
> +	if (fwd_write_request) {
> +		stat_inc(rzs->stats.bdev_num_writes);
> +		bio->bi_bdev = rzs->backing_swap;
> +#if 0
> +		/*
> +		 * TODO: We currently have linear mapping of ramzswap and
> +		 * backing swap sectors. This is not desired since we want
> +		 * to optimize writes to backing swap to minimize disk seeks
> +		 * or have effective wear leveling (for SSDs). Also, a
> +		 * non-linear mapping is required to implement compressed
> +		 * on-disk swapping.
> +		 */
> +		 bio->bi_sector = get_backing_swap_page()
> +					<< SECTORS_PER_PAGE_SHIFT;
> +#endif
> +		/*
> +		 * In case backing swap is a file, find the right offset within
> +		 * the file corresponding to logical position 'index'. For block
> +		 * device, this is a nop.
> +		 */
> +		bio->bi_sector = map_backing_swap_page(rzs, index)
> +					<< SECTORS_PER_PAGE_SHIFT;
> +		return 1;
> +	}
> +
> +	bio_io_error(bio);
> +	return 0;
> +}
> +
> +
> +/*
> + * Check if request is within bounds and page aligned.
> + */
> +static inline int valid_swap_request(struct ramzswap *rzs, struct bio *bio)
> +{
> +	if (unlikely(
> +		(bio->bi_sector >= (rzs->disksize >> SECTOR_SHIFT)) ||
> +		(bio->bi_sector & (SECTORS_PER_PAGE - 1)) ||
> +		(bio->bi_vcnt != 1) ||
> +		(bio->bi_size != PAGE_SIZE) ||
> +		(bio->bi_io_vec[0].bv_offset != 0))) {
> +
> +		return 0;
> +	}
> +
> +	/* swap request is valid */
> +	return 1;
> +}
> +
> +/*
> + * Handler function for all ramzswap I/O requests.
> + */
> +static int ramzswap_make_request(struct request_queue *queue, struct bio *bio)
> +{
> +	int ret = 0;
> +	struct ramzswap *rzs = queue->queuedata;
> +
> +	if (unlikely(!rzs->init_done)) {
> +		bio_io_error(bio);
> +		return 0;
> +	}
> +
> +	if (!valid_swap_request(rzs, bio)) {
> +		stat_inc(rzs->stats.invalid_io);
> +		bio_io_error(bio);
> +		return 0;
> +	}
> +
> +	switch (bio_data_dir(bio)) {
> +	case READ:
> +		ret = ramzswap_read(rzs, bio);
> +		break;
> +
> +	case WRITE:
> +		ret = ramzswap_write(rzs, bio);
> +		break;
> +	}
> +
> +	return ret;
> +}
> +
> +static void reset_device(struct ramzswap *rzs)
> +{
> +	int is_backing_blkdev = 0;
> +	size_t index, num_pages;
> +	unsigned entries_per_page;
> +	unsigned long num_table_pages, entry = 0;
> +
> +	if (rzs->backing_swap && !rzs->num_extents)
> +		is_backing_blkdev = 1;
> +
> +	num_pages = rzs->disksize >> PAGE_SHIFT;
> +
> +	/* Free various per-device buffers */
> +	kfree(rzs->compress_workmem);
> +	free_pages((unsigned long)rzs->compress_buffer, 1);
> +
> +	rzs->compress_workmem = NULL;
> +	rzs->compress_buffer = NULL;
> +
> +	/* Free all pages that are still in this ramzswap device */
> +	for (index = 0; index < num_pages; index++) {
> +		struct page *page;
> +		u16 offset;
> +
> +		page = rzs->table[index].page;
> +		offset = rzs->table[index].offset;
> +
> +		if (!page)
> +			continue;
> +
> +		if (unlikely(rzs_test_flag(rzs, index, RZS_UNCOMPRESSED)))
> +			__free_page(page);
> +		else
> +			xv_free(rzs->mem_pool, page, offset);
> +	}
> +
> +	entries_per_page = PAGE_SIZE / sizeof(*rzs->table);
> +	num_table_pages = DIV_ROUND_UP(num_pages * sizeof(*rzs->table),
> +					PAGE_SIZE);
> +	/*
> +	 * Set page->mapping to NULL for every table page.
> +	 * Otherwise, we will hit bad_page() during free.
> +	 */
> +	while (rzs->num_extents && num_table_pages--) {
> +		struct page *page;
> +		page = vmalloc_to_page(&rzs->table[entry]);
> +		page->mapping = NULL;
> +		entry += entries_per_page;
> +	}
> +	vfree(rzs->table);
> +	rzs->table = NULL;
> +
> +	xv_destroy_pool(rzs->mem_pool);
> +	rzs->mem_pool = NULL;
> +
> +	/* Free all swap extent pages */
> +	while (!list_empty(&rzs->backing_swap_extent_list)) {
> +		struct page *page;
> +		struct list_head *entry;
> +		entry = rzs->backing_swap_extent_list.next;
> +		page = list_entry(entry, struct page, lru);
> +		list_del(entry);
> +		__free_page(page);
> +	}
> +	INIT_LIST_HEAD(&rzs->backing_swap_extent_list);
> +	rzs->num_extents = 0;
> +
> +	/* Close backing swap device, if present */
> +	if (rzs->backing_swap) {
> +		if (is_backing_blkdev)
> +			bd_release(rzs->backing_swap);
> +		filp_close(rzs->swap_file, NULL);
> +		rzs->backing_swap = NULL;
> +	}
> +
> +	/* Reset stats */
> +	memset(&rzs->stats, 0, sizeof(rzs->stats));
> +
> +	rzs->disksize = 0;
> +	rzs->memlimit = 0;
> +
> +	/* Back to uninitialized state */
> +	rzs->init_done = 0;
> +}
> +
> +static int ramzswap_ioctl_init_device(struct ramzswap *rzs)
> +{
> +	int ret;
> +	size_t num_pages;
> +	struct page *page;
> +	union swap_header *swap_header;
> +
> +	if (rzs->init_done) {
> +		pr_info("Device already initialized!\n");
> +		return -EBUSY;
> +	}
> +
> +	ret = setup_backing_swap(rzs);
> +	if (ret)
> +		goto fail;
> +
> +	if (rzs->backing_swap)
> +		ramzswap_set_memlimit(rzs, totalram_pages << PAGE_SHIFT);
> +	else
> +		ramzswap_set_disksize(rzs, totalram_pages << PAGE_SHIFT);
> +
> +	rzs->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
> +	if (!rzs->compress_workmem) {
> +		pr_err("Error allocating compressor working memory!\n");
> +		ret = -ENOMEM;
> +		goto fail;
> +	}
> +
> +	rzs->compress_buffer = (void *)__get_free_pages(__GFP_ZERO, 1);
> +	if (!rzs->compress_buffer) {
> +		pr_err("Error allocating compressor buffer space\n");
> +		ret = -ENOMEM;
> +		goto fail;
> +	}
> +
> +	num_pages = rzs->disksize >> PAGE_SHIFT;
> +	rzs->table = vmalloc(num_pages * sizeof(*rzs->table));
> +	if (!rzs->table) {
> +		pr_err("Error allocating ramzswap address table\n");
> +		/* To prevent accessing table entries during cleanup */
> +		rzs->disksize = 0;
> +		ret = -ENOMEM;
> +		goto fail;
> +	}
> +	memset(rzs->table, 0, num_pages * sizeof(*rzs->table));
> +
> +	map_backing_swap_extents(rzs);
> +
> +	page = alloc_page(__GFP_ZERO);
> +	if (!page) {
> +		pr_err("Error allocating swap header page\n");
> +		ret = -ENOMEM;
> +		goto fail;
> +	}
> +	rzs->table[0].page = page;
> +	rzs_set_flag(rzs, 0, RZS_UNCOMPRESSED);
> +
> +	swap_header = kmap(page);
> +	ret = setup_swap_header(rzs, swap_header);
> +	kunmap(page);
> +	if (ret) {
> +		pr_err("Error setting swap header\n");
> +		goto fail;
> +	}
> +
> +	set_capacity(rzs->disk, rzs->disksize >> SECTOR_SHIFT);
> +
> +	/*
> +	 * We have ident mapping of sectors for ramzswap and
> +	 * and the backing swap device. So, this queue flag
> +	 * should be according to backing dev.
> +	 */
> +	if (!rzs->backing_swap ||
> +			blk_queue_nonrot(rzs->backing_swap->bd_disk->queue))
> +		queue_flag_set_unlocked(QUEUE_FLAG_NONROT, rzs->disk->queue);
> +
> +	rzs->mem_pool = xv_create_pool();
> +	if (!rzs->mem_pool) {
> +		pr_err("Error creating memory pool\n");
> +		ret = -ENOMEM;
> +		goto fail;
> +	}
> +
> +	/*
> +	 * Pages that compress to size greater than this are forwarded
> +	 * to physical swap disk (if backing dev is provided)
> +	 * TODO: make this configurable
> +	 */
> +	if (rzs->backing_swap)
> +		max_zpage_size = max_zpage_size_bdev;
> +	else
> +		max_zpage_size = max_zpage_size_nobdev;
> +	pr_debug("Max compressed page size: %u bytes\n", max_zpage_size);
> +
> +	rzs->init_done = 1;
> +
> +	pr_debug("Initialization done!\n");
> +	return 0;
> +
> +fail:
> +	reset_device(rzs);
> +
> +	pr_err("Initialization failed: err=%d\n", ret);
> +	return ret;
> +}
> +
> +static int ramzswap_ioctl_reset_device(struct ramzswap *rzs)
> +{
> +	if (rzs->init_done)
> +		reset_device(rzs);
> +
> +	return 0;
> +}
> +
> +static int ramzswap_ioctl(struct block_device *bdev, fmode_t mode,
> +			unsigned int cmd, unsigned long arg)
> +{
> +	int ret = 0;
> +	size_t disksize_kb, memlimit_kb;
> +
> +	struct ramzswap *rzs = bdev->bd_disk->private_data;
> +
> +	switch (cmd) {
> +	case RZSIO_SET_DISKSIZE_KB:
> +		if (rzs->init_done) {
> +			ret = -EBUSY;
> +			goto out;
> +		}
> +		if (copy_from_user(&disksize_kb, (void *)arg,
> +						_IOC_SIZE(cmd))) {
> +			ret = -EFAULT;
> +			goto out;
> +		}
> +		rzs->disksize = disksize_kb << 10;
> +		pr_info("Disk size set to %zu kB\n", disksize_kb);
> +		break;
> +
> +	case RZSIO_SET_MEMLIMIT_KB:
> +		if (rzs->init_done) {
> +			/* TODO: allow changing memlimit */
> +			ret = -EBUSY;
> +			goto out;
> +		}
> +		if (copy_from_user(&memlimit_kb, (void *)arg,
> +						_IOC_SIZE(cmd))) {
> +			ret = -EFAULT;
> +			goto out;
> +		}
> +		rzs->memlimit = memlimit_kb << 10;
> +		pr_info("Memory limit set to %zu kB\n", memlimit_kb);
> +		break;
> +
> +	case RZSIO_SET_BACKING_SWAP:
> +		if (rzs->init_done) {
> +			ret = -EBUSY;
> +			goto out;
> +		}
> +
> +		if (copy_from_user(&rzs->backing_swap_name, (void *)arg,
> +						_IOC_SIZE(cmd))) {
> +			ret = -EFAULT;
> +			goto out;
> +		}
> +		rzs->backing_swap_name[MAX_SWAP_NAME_LEN - 1] = '\0';
> +		pr_info("Backing swap set to %s\n", rzs->backing_swap_name);
> +		break;
> +
> +	case RZSIO_GET_STATS:
> +	{
> +		struct ramzswap_ioctl_stats *stats;
> +		if (!rzs->init_done) {
> +			ret = -ENOTTY;
> +			goto out;
> +		}
> +		stats = kzalloc(sizeof(*stats), GFP_KERNEL);
> +		if (!stats) {
> +			ret = -ENOMEM;
> +			goto out;
> +		}
> +		ramzswap_ioctl_get_stats(rzs, stats);
> +		if (copy_to_user((void *)arg, stats, sizeof(*stats))) {
> +			kfree(stats);
> +			ret = -EFAULT;
> +			goto out;
> +		}
> +		kfree(stats);
> +		break;
> +	}
> +	case RZSIO_INIT:
> +		ret = ramzswap_ioctl_init_device(rzs);
> +		break;
> +
> +	case RZSIO_RESET:
> +		/* Do not reset an active device! */
> +		if (bdev->bd_holders) {
> +			ret = -EBUSY;
> +			goto out;
> +		}
> +		ret = ramzswap_ioctl_reset_device(rzs);
> +		break;
> +
> +	default:
> +		pr_info("Invalid ioctl %u\n", cmd);
> +		ret = -ENOTTY;
> +	}
> +
> +out:
> +	return ret;
> +}
> +
> +static struct block_device_operations ramzswap_devops = {
> +	.ioctl = ramzswap_ioctl,
> +	.owner = THIS_MODULE,
> +};
> +
> +static void create_device(struct ramzswap *rzs, int device_id)
> +{
> +	mutex_init(&rzs->lock);
> +	INIT_LIST_HEAD(&rzs->backing_swap_extent_list);
> +
> +	rzs->queue = blk_alloc_queue(GFP_KERNEL);
> +	if (!rzs->queue) {
> +		pr_err("Error allocating disk queue for device %d\n",
> +			device_id);
> +		return;
> +	}
> +
> +	blk_queue_make_request(rzs->queue, ramzswap_make_request);
> +	rzs->queue->queuedata = rzs;
> +
> +	 /* gendisk structure */
> +	rzs->disk = alloc_disk(1);
> +	if (!rzs->disk) {
> +		blk_cleanup_queue(rzs->queue);
> +		pr_warning("Error allocating disk structure for device %d\n",
> +			device_id);
> +		return;
> +	}
> +
> +	rzs->disk->major = ramzswap_major;
> +	rzs->disk->first_minor = device_id;
> +	rzs->disk->fops = &ramzswap_devops;
> +	rzs->disk->queue = rzs->queue;
> +	rzs->disk->private_data = rzs;
> +	snprintf(rzs->disk->disk_name, 16, "ramzswap%d", device_id);
> +
> +	/*
> +	 * Actual capacity set using RZSIO_SET_DISKSIZE_KB ioctl
> +	 * or set equal to backing swap device (if provided)
> +	 */
> +	set_capacity(rzs->disk, 0);
> +	add_disk(rzs->disk);
> +
> +	rzs->init_done = 0;
> +}
> +
> +static void destroy_device(struct ramzswap *rzs)
> +{
> +	if (rzs->disk) {
> +		del_gendisk(rzs->disk);
> +		put_disk(rzs->disk);
> +	}
> +
> +	if (rzs->queue)
> +		blk_cleanup_queue(rzs->queue);
> +}
> +
> +static int __init ramzswap_init(void)
> +{
> +	int i, ret;
> +
> +	if (num_devices > max_num_devices) {
> +		pr_warning("Invalid value for num_devices: %u\n",
> +				num_devices);
> +		return -EINVAL;
> +	}
> +
> +	ramzswap_major = register_blkdev(0, "ramzswap");
> +	if (ramzswap_major <= 0) {
> +		pr_warning("Unable to get major number\n");
> +		return -EBUSY;
> +	}
> +
> +	if (!num_devices) {
> +		pr_info("num_devices not specified. Using default: 1\n");
> +		num_devices = 1;
> +	}
> +
> +	/* Allocate the device array and initialize each one */
> +	pr_info("Creating %u devices ...\n", num_devices);
> +	devices = kzalloc(num_devices * sizeof(struct ramzswap), GFP_KERNEL);
> +	if (!devices) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	for (i = 0; i < num_devices; i++)
> +		create_device(&devices[i], i);
> +
> +	return 0;
> +out:
> +	unregister_blkdev(ramzswap_major, "ramzswap");
> +	return ret;
> +}
> +
> +static void __exit ramzswap_exit(void)
> +{
> +	int i;
> +	struct ramzswap *rzs;
> +
> +	for (i = 0; i < num_devices; i++) {
> +		rzs = &devices[i];
> +
> +		destroy_device(rzs);
> +		if (rzs->init_done)
> +			reset_device(rzs);
> +	}
> +
> +	unregister_blkdev(ramzswap_major, "ramzswap");
> +
> +	kfree(devices);
> +	pr_debug("Cleanup done!\n");
> +}
> +
> +module_param(num_devices, uint, 0);
> +MODULE_PARM_DESC(num_devices, "Number of ramzswap devices");
> +
> +module_init(ramzswap_init);
> +module_exit(ramzswap_exit);
> +
> +MODULE_LICENSE("Dual BSD/GPL");
> +MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
> +MODULE_DESCRIPTION("Compressed RAM Based Swap Device");
> diff --git a/drivers/staging/ramzswap/ramzswap_drv.h b/drivers/staging/ramzswap/ramzswap_drv.h
> new file mode 100644
> index 0000000..a6ea240
> --- /dev/null
> +++ b/drivers/staging/ramzswap/ramzswap_drv.h
> @@ -0,0 +1,171 @@
> +/*
> + * Compressed RAM based swap device
> + *
> + * Copyright (C) 2008, 2009  Nitin Gupta
> + *
> + * This code is released using a dual license strategy: BSD/GPL
> + * You can choose the licence that better fits your requirements.
> + *
> + * Released under the terms of 3-clause BSD License
> + * Released under the terms of GNU General Public License Version 2.0
> + *
> + * Project home: http://compcache.googlecode.com
> + */
> +
> +#ifndef _RAMZSWAP_DRV_H_
> +#define _RAMZSWAP_DRV_H_
> +
> +#include "ramzswap_ioctl.h"
> +#include "xvmalloc.h"
> +
> +/*
> + * Some arbitrary value. This is just to catch
> + * invalid value for num_devices module parameter.
> + */
> +static const unsigned max_num_devices = 32;
> +
> +/*
> + * Stored at beginning of each compressed object.
> + *
> + * It stores back-reference to table entry which points to this
> + * object. This is required to support memory defragmentation or
> + * migrating compressed pages to backing swap disk.
> + */
> +struct zobj_header {
> +#if 0
> +	u32 table_idx;
> +#endif
> +};
> +
> +/*-- Configurable parameters */
> +
> +/* Default ramzswap disk size: 25% of total RAM */
> +static const unsigned default_disksize_perc_ram = 25;
> +static const unsigned default_memlimit_perc_ram = 15;
> +
> +/*
> + * Max compressed page size when backing device is provided.
> + * Pages that compress to size greater than this are sent to
> + * physical swap disk.
> + */
> +static const unsigned max_zpage_size_bdev = PAGE_SIZE / 2;
> +
> +/*
> + * Max compressed page size when there is no backing dev.
> + * Pages that compress to size greater than this are stored
> + * uncompressed in memory.
> + */
> +static const unsigned max_zpage_size_nobdev = PAGE_SIZE / 4 * 3;
> +
> +/*
> + * NOTE: max_zpage_size_{bdev,nobdev} sizes must be
> + * less than or equal to:
> + *   XV_MAX_ALLOC_SIZE - sizeof(struct zobj_header)
> + * since otherwise xv_malloc would always return failure.
> + */
> +
> +/*-- End of configurable params */
> +
> +#define SECTOR_SHIFT		9
> +#define SECTOR_SIZE		(1 << SECTOR_SHIFT)
> +#define SECTORS_PER_PAGE_SHIFT	(PAGE_SHIFT - SECTOR_SHIFT)
> +#define SECTORS_PER_PAGE	(1 << SECTORS_PER_PAGE_SHIFT)
> +
> +/* Debugging and Stats */
> +#if defined(CONFIG_RAMZSWAP_STATS)
> +#define stat_inc(stat)	((stat)++)
> +#define stat_dec(stat)	((stat)--)
> +#else
> +#define stat_inc(x)
> +#define stat_dec(x)
> +#endif
> +
> +/* Flags for ramzswap pages (table[page_no].flags) */
> +enum rzs_pageflags {
> +	/* Page is stored uncompressed */
> +	RZS_UNCOMPRESSED,
> +
> +	/* Page consists entirely of zeros */
> +	RZS_ZERO,
> +
> +	__NR_RZS_PAGEFLAGS,
> +};
> +
> +/*-- Data structures */
> +
> +/*
> + * Allocated for each swap slot, indexed by page no.
> + * These table entries must fit exactly in a page.
> + */
> +struct table {
> +	struct page *page;
> +	u16 offset;
> +	u8 count;	/* object ref count (not yet used) */
> +	u8 flags;
> +} __attribute__((aligned(4)));;
> +
> +/*
> + * Swap extent information in case backing swap is a regular
> + * file. These extent entries must fit exactly in a page.
> + */
> +struct ramzswap_backing_extent {
> +	pgoff_t phy_pagenum;
> +	pgoff_t num_pages;
> +} __attribute__((aligned(4)));
> +
> +struct ramzswap_stats {
> +	/* basic stats */
> +	size_t compr_size;	/* compressed size of pages stored -
> +				 * needed to enforce memlimit */
> +	/* more stats */
> +#if defined(CONFIG_RAMZSWAP_STATS)
> +	u64 num_reads;		/* failed + successful */
> +	u64 num_writes;		/* --do-- */
> +	u64 failed_reads;	/* can happen when memory is too low */
> +	u64 failed_writes;	/* should NEVER! happen */
> +	u64 invalid_io;		/* non-swap I/O requests */
> +	u32 pages_zero;		/* no. of zero filled pages */
> +	u32 pages_stored;	/* no. of pages currently stored */
> +	u32 good_compress;	/* % of pages with compression ratio<=50% */
> +	u32 pages_expand;	/* % of incompressible pages */
> +	u64 bdev_num_reads;	/* no. of reads on backing dev */
> +	u64 bdev_num_writes;	/* no. of writes on backing dev */
> +#endif
> +};
> +
> +struct ramzswap {
> +	struct xv_pool *mem_pool;
> +	void *compress_workmem;
> +	void *compress_buffer;
> +	struct table *table;
> +	struct mutex lock;
> +	struct request_queue *queue;
> +	struct gendisk *disk;
> +	int init_done;
> +	/*
> +	 * This is limit on compressed data size (stats.compr_size)
> +	 * Its applicable only when backing swap device is present.
> +	 */
> +	size_t memlimit;	/* bytes */
> +	/*
> +	 * This is limit on amount of *uncompressed* worth of data
> +	 * we can hold. When backing swap device is provided, it is
> +	 * set equal to device size.
> +	 */
> +	size_t disksize;	/* bytes */
> +
> +	struct ramzswap_stats stats;
> +
> +	/* backing swap device info */
> +	struct ramzswap_backing_extent *curr_extent;
> +	struct list_head backing_swap_extent_list;
> +	unsigned long num_extents;
> +	char backing_swap_name[MAX_SWAP_NAME_LEN];
> +	struct block_device *backing_swap;
> +	struct file *swap_file;
> +};
> +
> +/*-- */
> +
> +#endif
> +
> diff --git a/drivers/staging/ramzswap/ramzswap_ioctl.h b/drivers/staging/ramzswap/ramzswap_ioctl.h
> new file mode 100644
> index 0000000..c713a09
> --- /dev/null
> +++ b/drivers/staging/ramzswap/ramzswap_ioctl.h
> @@ -0,0 +1,49 @@
> +/*
> + * Compressed RAM based swap device
> + *
> + * Copyright (C) 2008, 2009  Nitin Gupta
> + *
> + * This code is released using a dual license strategy: BSD/GPL
> + * You can choose the licence that better fits your requirements.
> + *
> + * Released under the terms of 3-clause BSD License
> + * Released under the terms of GNU General Public License Version 2.0
> + *
> + * Project home: http://compcache.googlecode.com
> + */
> +
> +#ifndef _RAMZSWAP_IOCTL_H_
> +#define _RAMZSWAP_IOCTL_H_
> +
> +#define MAX_SWAP_NAME_LEN 128
> +
> +struct ramzswap_ioctl_stats {
> +	char backing_swap_name[MAX_SWAP_NAME_LEN];
> +	u64 memlimit;		/* only applicable if backing swap present */
> +	u64 disksize;		/* user specified or equal to backing swap
> +				 * size (if present) */
> +	u64 num_reads;		/* failed + successful */
> +	u64 num_writes;		/* --do-- */
> +	u64 failed_reads;	/* can happen when memory is too low */
> +	u64 failed_writes;	/* should NEVER! happen */
> +	u64 invalid_io;		/* non-swap I/O requests */
> +	u32 pages_zero;		/* no. of zero filled pages */
> +	u32 good_compress_pct;	/* no. of pages with compression ratio<=50% */
> +	u32 pages_expand_pct;	/* no. of incompressible pages */
> +	u32 pages_stored;
> +	u32 pages_used;
> +	u64 orig_data_size;
> +	u64 compr_data_size;
> +	u64 mem_used_total;
> +	u64 bdev_num_reads;	/* no. of reads on backing dev */
> +	u64 bdev_num_writes;	/* no. of writes on backing dev */
> +} __attribute__ ((packed, aligned(4)));
> +
> +#define RZSIO_SET_DISKSIZE_KB	_IOW('z', 0, size_t)
> +#define RZSIO_SET_MEMLIMIT_KB	_IOW('z', 1, size_t)
> +#define RZSIO_SET_BACKING_SWAP	_IOW('z', 2, unsigned char[MAX_SWAP_NAME_LEN])
> +#define RZSIO_GET_STATS		_IOR('z', 3, struct ramzswap_ioctl_stats)
> +#define RZSIO_INIT		_IO('z', 4)
> +#define RZSIO_RESET		_IO('z', 5)
> +
> +#endif
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
