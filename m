Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3828D6B00EC
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 01:06:09 -0500 (EST)
Date: Tue, 5 Feb 2013 15:06:07 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 4/4] zram: get rid of lockdep warning
Message-ID: <20130205060607.GJ2610@blaptop>
References: <1359935171-12749-1-git-send-email-minchan@kernel.org>
 <1359935171-12749-4-git-send-email-minchan@kernel.org>
 <1359963564.1366.0.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359963564.1366.0.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, jmarchan@redhat.com, Andrew Morton <akpm@linux-foundation.org>

On Mon, Feb 04, 2013 at 01:39:24AM -0600, Ric Mason wrote:
> On Mon, 2013-02-04 at 08:46 +0900, Minchan Kim wrote:
> > Lockdep complains about recursive deadlock of zram->init_lock.
> > [1] made it false positive because we can't request IO to zram
> > before setting disksize. Anyway, we should shut lockdep up to
> > avoid many reporting from user.
> > 
> > [1] : zram: force disksize setting before using zram
> > 
> > Acked-by: Jerome Marchand <jmarchan@redhat.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/staging/zram/zram_drv.c   |  189 +++++++++++++++++++------------------
> >  drivers/staging/zram/zram_drv.h   |   12 ++-
> >  drivers/staging/zram/zram_sysfs.c |   11 ++-
> >  3 files changed, 116 insertions(+), 96 deletions(-)
> > 
> > diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> > index 85055c4..56e3203 100644
> > --- a/drivers/staging/zram/zram_drv.c
> > +++ b/drivers/staging/zram/zram_drv.c
> > @@ -61,22 +61,22 @@ static void zram_stat64_inc(struct zram *zram, u64 *v)
> >  	zram_stat64_add(zram, v, 1);
> >  }
> >  
> > -static int zram_test_flag(struct zram *zram, u32 index,
> > +static int zram_test_flag(struct zram_meta *meta, u32 index,
> >  			enum zram_pageflags flag)
> >  {
> > -	return zram->table[index].flags & BIT(flag);
> > +	return meta->table[index].flags & BIT(flag);
> >  }
> >  
> > -static void zram_set_flag(struct zram *zram, u32 index,
> > +static void zram_set_flag(struct zram_meta *meta, u32 index,
> >  			enum zram_pageflags flag)
> >  {
> > -	zram->table[index].flags |= BIT(flag);
> > +	meta->table[index].flags |= BIT(flag);
> >  }
> >  
> > -static void zram_clear_flag(struct zram *zram, u32 index,
> > +static void zram_clear_flag(struct zram_meta *meta, u32 index,
> >  			enum zram_pageflags flag)
> >  {
> > -	zram->table[index].flags &= ~BIT(flag);
> > +	meta->table[index].flags &= ~BIT(flag);
> >  }
> >  
> >  static int page_zero_filled(void *ptr)
> > @@ -96,16 +96,17 @@ static int page_zero_filled(void *ptr)
> >  
> >  static void zram_free_page(struct zram *zram, size_t index)
> >  {
> > -	unsigned long handle = zram->table[index].handle;
> > -	u16 size = zram->table[index].size;
> > +	struct zram_meta *meta = zram->meta;
> > +	unsigned long handle = meta->table[index].handle;
> > +	u16 size = meta->table[index].size;
> >  
> >  	if (unlikely(!handle)) {
> >  		/*
> >  		 * No memory is allocated for zero filled pages.
> >  		 * Simply clear zero page flag.
> >  		 */
> > -		if (zram_test_flag(zram, index, ZRAM_ZERO)) {
> > -			zram_clear_flag(zram, index, ZRAM_ZERO);
> > +		if (zram_test_flag(meta, index, ZRAM_ZERO)) {
> > +			zram_clear_flag(meta, index, ZRAM_ZERO);
> >  			zram->stats.pages_zero--;
> >  		}
> >  		return;
> > @@ -114,17 +115,17 @@ static void zram_free_page(struct zram *zram, size_t index)
> >  	if (unlikely(size > max_zpage_size))
> >  		zram->stats.bad_compress--;
> >  
> > -	zs_free(zram->mem_pool, handle);
> > +	zs_free(meta->mem_pool, handle);
> >  
> >  	if (size <= PAGE_SIZE / 2)
> >  		zram->stats.good_compress--;
> >  
> >  	zram_stat64_sub(zram, &zram->stats.compr_size,
> > -			zram->table[index].size);
> > +			meta->table[index].size);
> >  	zram->stats.pages_stored--;
> >  
> > -	zram->table[index].handle = 0;
> > -	zram->table[index].size = 0;
> > +	meta->table[index].handle = 0;
> > +	meta->table[index].size = 0;
> >  }
> >  
> >  static void handle_zero_page(struct bio_vec *bvec)
> > @@ -149,20 +150,21 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
> >  	int ret = LZO_E_OK;
> >  	size_t clen = PAGE_SIZE;
> >  	unsigned char *cmem;
> > -	unsigned long handle = zram->table[index].handle;
> > +	struct zram_meta *meta = zram->meta;
> > +	unsigned long handle = meta->table[index].handle;
> >  
> > -	if (!handle || zram_test_flag(zram, index, ZRAM_ZERO)) {
> > +	if (!handle || zram_test_flag(meta, index, ZRAM_ZERO)) {
> >  		memset(mem, 0, PAGE_SIZE);
> >  		return 0;
> >  	}
> >  
> > -	cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_RO);
> > -	if (zram->table[index].size == PAGE_SIZE)
> > +	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_RO);
> > +	if (meta->table[index].size == PAGE_SIZE)
> >  		memcpy(mem, cmem, PAGE_SIZE);
> >  	else
> > -		ret = lzo1x_decompress_safe(cmem, zram->table[index].size,
> > +		ret = lzo1x_decompress_safe(cmem, meta->table[index].size,
> >  						mem, &clen);
> > -	zs_unmap_object(zram->mem_pool, handle);
> > +	zs_unmap_object(meta->mem_pool, handle);
> >  
> >  	/* Should NEVER happen. Return bio error if it does. */
> >  	if (unlikely(ret != LZO_E_OK)) {
> > @@ -180,11 +182,11 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
> >  	int ret;
> >  	struct page *page;
> >  	unsigned char *user_mem, *uncmem = NULL;
> > -
> > +	struct zram_meta *meta = zram->meta;
> >  	page = bvec->bv_page;
> >  
> > -	if (unlikely(!zram->table[index].handle) ||
> > -			zram_test_flag(zram, index, ZRAM_ZERO)) {
> > +	if (unlikely(!meta->table[index].handle) ||
> > +			zram_test_flag(meta, index, ZRAM_ZERO)) {
> >  		handle_zero_page(bvec);
> >  		return 0;
> >  	}
> > @@ -232,9 +234,10 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >  	unsigned long handle;
> >  	struct page *page;
> >  	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
> > +	struct zram_meta *meta = zram->meta;
> >  
> >  	page = bvec->bv_page;
> > -	src = zram->compress_buffer;
> > +	src = meta->compress_buffer;
> 
> Could you explain compress_buffer is used for what? Thanks for your
> clarify! 

IMHO, it is used for storing compressed result in write path
while compress_workmem is used for compression temporally.

> 
> >  
> >  	if (is_partial_io(bvec)) {
> >  		/*
> > @@ -256,8 +259,8 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >  	 * System overwrites unused sectors. Free memory associated
> >  	 * with this sector now.
> >  	 */
> > -	if (zram->table[index].handle ||
> > -	    zram_test_flag(zram, index, ZRAM_ZERO))
> > +	if (meta->table[index].handle ||
> > +	    zram_test_flag(meta, index, ZRAM_ZERO))
> >  		zram_free_page(zram, index);
> >  
> >  	user_mem = kmap_atomic(page);
> > @@ -276,13 +279,13 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >  		if (is_partial_io(bvec))
> >  			kfree(uncmem);
> >  		zram->stats.pages_zero++;
> > -		zram_set_flag(zram, index, ZRAM_ZERO);
> > +		zram_set_flag(meta, index, ZRAM_ZERO);
> >  		ret = 0;
> >  		goto out;
> >  	}
> >  
> >  	ret = lzo1x_1_compress(uncmem, PAGE_SIZE, src, &clen,
> > -			       zram->compress_workmem);
> > +			       meta->compress_workmem);
> >  
> >  	if (!is_partial_io(bvec)) {
> >  		kunmap_atomic(user_mem);
> > @@ -303,14 +306,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >  			src = uncmem;
> >  	}
> >  
> > -	handle = zs_malloc(zram->mem_pool, clen);
> > +	handle = zs_malloc(meta->mem_pool, clen);
> >  	if (!handle) {
> >  		pr_info("Error allocating memory for compressed "
> >  			"page: %u, size=%zu\n", index, clen);
> >  		ret = -ENOMEM;
> >  		goto out;
> >  	}
> > -	cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_WO);
> > +	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> >  
> >  	if ((clen == PAGE_SIZE) && !is_partial_io(bvec))
> >  		src = kmap_atomic(page);
> > @@ -318,10 +321,10 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >  	if ((clen == PAGE_SIZE) && !is_partial_io(bvec))
> >  		kunmap_atomic(src);
> >  
> > -	zs_unmap_object(zram->mem_pool, handle);
> > +	zs_unmap_object(meta->mem_pool, handle);
> >  
> > -	zram->table[index].handle = handle;
> > -	zram->table[index].size = clen;
> > +	meta->table[index].handle = handle;
> > +	meta->table[index].size = clen;
> >  
> >  	/* Update stats */
> >  	zram_stat64_add(zram, &zram->stats.compr_size, clen);
> > @@ -464,34 +467,25 @@ error:
> >  void __zram_reset_device(struct zram *zram)
> >  {
> >  	size_t index;
> > +	struct zram_meta *meta;
> >  
> >  	if (!zram->init_done)
> >  		return;
> >  
> > +	meta = zram->meta;
> >  	zram->init_done = 0;
> >  
> > -	/* Free various per-device buffers */
> > -	kfree(zram->compress_workmem);
> > -	free_pages((unsigned long)zram->compress_buffer, 1);
> > -
> > -	zram->compress_workmem = NULL;
> > -	zram->compress_buffer = NULL;
> > -
> >  	/* Free all pages that are still in this zram device */
> >  	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
> > -		unsigned long handle = zram->table[index].handle;
> > +		unsigned long handle = meta->table[index].handle;
> >  		if (!handle)
> >  			continue;
> >  
> > -		zs_free(zram->mem_pool, handle);
> > +		zs_free(meta->mem_pool, handle);
> >  	}
> >  
> > -	vfree(zram->table);
> > -	zram->table = NULL;
> > -
> > -	zs_destroy_pool(zram->mem_pool);
> > -	zram->mem_pool = NULL;
> > -
> > +	zram_meta_free(zram->meta);
> > +	zram->meta = NULL;
> >  	/* Reset stats */
> >  	memset(&zram->stats, 0, sizeof(zram->stats));
> >  
> > @@ -506,12 +500,65 @@ void zram_reset_device(struct zram *zram)
> >  	up_write(&zram->init_lock);
> >  }
> >  
> > -/* zram->init_lock should be held */
> > -int zram_init_device(struct zram *zram)
> > +void zram_meta_free(struct zram_meta *meta)
> > +{
> > +	zs_destroy_pool(meta->mem_pool);
> > +	kfree(meta->compress_workmem);
> > +	free_pages((unsigned long)meta->compress_buffer, 1);
> > +	vfree(meta->table);
> > +	kfree(meta);
> > +}
> > +
> > +struct zram_meta *zram_meta_alloc(u64 disksize)
> >  {
> > -	int ret;
> >  	size_t num_pages;
> > +	struct zram_meta *meta = kmalloc(sizeof(*meta), GFP_KERNEL);
> > +	if (!meta)
> > +		goto out;
> > +
> > +	meta->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
> > +	if (!meta->compress_workmem) {
> > +		pr_err("Error allocating compressor working memory!\n");
> > +		goto free_meta;
> > +	}
> > +
> > +	meta->compress_buffer =
> > +		(void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, 1);
> > +	if (!meta->compress_buffer) {
> > +		pr_err("Error allocating compressor buffer space\n");
> > +		goto free_workmem;
> > +	}
> > +
> > +	num_pages = disksize >> PAGE_SHIFT;
> > +	meta->table = vzalloc(num_pages * sizeof(*meta->table));
> > +	if (!meta->table) {
> > +		pr_err("Error allocating zram address table\n");
> > +		goto free_buffer;
> > +	}
> > +
> > +	meta->mem_pool = zs_create_pool(GFP_NOIO | __GFP_HIGHMEM);
> > +	if (!meta->mem_pool) {
> > +		pr_err("Error creating memory pool\n");
> > +		goto free_table;
> > +	}
> > +
> > +	return meta;
> > +
> > +free_table:
> > +	vfree(meta->table);
> > +free_buffer:
> > +	free_pages((unsigned long)meta->compress_buffer, 1);
> > +free_workmem:
> > +	kfree(meta->compress_workmem);
> > +free_meta:
> > +	kfree(meta);
> > +	meta = NULL;
> > +out:
> > +	return meta;
> > +}
> >  
> > +void zram_init_device(struct zram *zram, struct zram_meta *meta)
> > +{
> >  	if (zram->disksize > 2 * (totalram_pages << PAGE_SHIFT)) {
> >  		pr_info(
> >  		"There is little point creating a zram of greater than "
> > @@ -526,51 +573,13 @@ int zram_init_device(struct zram *zram)
> >  		);
> >  	}
> >  
> > -	zram->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
> > -	if (!zram->compress_workmem) {
> > -		pr_err("Error allocating compressor working memory!\n");
> > -		ret = -ENOMEM;
> > -		goto fail_no_table;
> > -	}
> > -
> > -	zram->compress_buffer =
> > -		(void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, 1);
> > -	if (!zram->compress_buffer) {
> > -		pr_err("Error allocating compressor buffer space\n");
> > -		ret = -ENOMEM;
> > -		goto fail_no_table;
> > -	}
> > -
> > -	num_pages = zram->disksize >> PAGE_SHIFT;
> > -	zram->table = vzalloc(num_pages * sizeof(*zram->table));
> > -	if (!zram->table) {
> > -		pr_err("Error allocating zram address table\n");
> > -		ret = -ENOMEM;
> > -		goto fail_no_table;
> > -	}
> > -
> >  	/* zram devices sort of resembles non-rotational disks */
> >  	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
> >  
> > -	zram->mem_pool = zs_create_pool(GFP_NOIO | __GFP_HIGHMEM);
> > -	if (!zram->mem_pool) {
> > -		pr_err("Error creating memory pool\n");
> > -		ret = -ENOMEM;
> > -		goto fail;
> > -	}
> > -
> > +	zram->meta = meta;
> >  	zram->init_done = 1;
> >  
> >  	pr_debug("Initialization done!\n");
> > -	return 0;
> > -
> > -fail_no_table:
> > -	/* To prevent accessing table entries during cleanup */
> > -	zram->disksize = 0;
> > -fail:
> > -	__zram_reset_device(zram);
> > -	pr_err("Initialization failed: err=%d\n", ret);
> > -	return ret;
> >  }
> >  
> >  static void zram_slot_free_notify(struct block_device *bdev,
> > diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
> > index 5b671d1..2d1a3f1 100644
> > --- a/drivers/staging/zram/zram_drv.h
> > +++ b/drivers/staging/zram/zram_drv.h
> > @@ -83,11 +83,15 @@ struct zram_stats {
> >  	u32 bad_compress;	/* % of pages with compression ratio>=75% */
> >  };
> >  
> > -struct zram {
> > -	struct zs_pool *mem_pool;
> > +struct zram_meta {
> >  	void *compress_workmem;
> >  	void *compress_buffer;
> >  	struct table *table;
> > +	struct zs_pool *mem_pool;
> > +};
> > +
> > +struct zram {
> > +	struct zram_meta *meta;
> >  	spinlock_t stat64_lock;	/* protect 64-bit stats */
> >  	struct rw_semaphore lock; /* protect compression buffers and table
> >  				   * against concurrent read and writes */
> > @@ -111,7 +115,9 @@ unsigned int zram_get_num_devices(void);
> >  extern struct attribute_group zram_disk_attr_group;
> >  #endif
> >  
> > -extern int zram_init_device(struct zram *zram);
> >  extern void zram_reset_device(struct zram *zram);
> > +extern struct zram_meta *zram_meta_alloc(u64 disksize);
> > +extern void zram_meta_free(struct zram_meta *meta);
> > +extern void zram_init_device(struct zram *zram, struct zram_meta *meta);
> >  
> >  #endif
> > diff --git a/drivers/staging/zram/zram_sysfs.c b/drivers/staging/zram/zram_sysfs.c
> > index 369db12..e6a929d 100644
> > --- a/drivers/staging/zram/zram_sysfs.c
> > +++ b/drivers/staging/zram/zram_sysfs.c
> > @@ -56,22 +56,26 @@ static ssize_t disksize_store(struct device *dev,
> >  		struct device_attribute *attr, const char *buf, size_t len)
> >  {
> >  	u64 disksize;
> > +	struct zram_meta *meta;
> >  	struct zram *zram = dev_to_zram(dev);
> >  
> >  	disksize = memparse(buf, NULL);
> >  	if (!disksize)
> >  		return -EINVAL;
> >  
> > +	disksize = PAGE_ALIGN(disksize);
> > +	meta = zram_meta_alloc(disksize);
> >  	down_write(&zram->init_lock);
> >  	if (zram->init_done) {
> >  		up_write(&zram->init_lock);
> > +		zram_meta_free(meta);
> >  		pr_info("Cannot change disksize for initialized device\n");
> >  		return -EBUSY;
> >  	}
> >  
> > -	zram->disksize = PAGE_ALIGN(disksize);
> > +	zram->disksize = disksize;
> >  	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
> > -	zram_init_device(zram);
> > +	zram_init_device(zram, meta);
> >  	up_write(&zram->init_lock);
> >  
> >  	return len;
> > @@ -182,9 +186,10 @@ static ssize_t mem_used_total_show(struct device *dev,
> >  {
> >  	u64 val = 0;
> >  	struct zram *zram = dev_to_zram(dev);
> > +	struct zram_meta *meta = zram->meta;
> >  
> >  	if (zram->init_done)
> > -		val = zs_get_total_size_bytes(zram->mem_pool);
> > +		val = zs_get_total_size_bytes(meta->mem_pool);
> >  
> >  	return sprintf(buf, "%llu\n", val);
> >  }
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
