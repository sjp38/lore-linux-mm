Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 2F95B6B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 18:39:11 -0500 (EST)
Date: Tue, 22 Jan 2013 08:39:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3] zram: get rid of lockdep warning
Message-ID: <20130121233909.GG3666@blaptop>
References: <1358388769-30112-1-git-send-email-minchan@kernel.org>
 <1358388769-30112-3-git-send-email-minchan@kernel.org>
 <CAPkvG_dm_uFXfSeh_pVsHNZxUUA1_y65gRA2h1=C3wNB3ewNEQ@mail.gmail.com>
 <20130121051843.GB3666@blaptop>
 <50FDC1D3.2060707@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FDC1D3.2060707@vflare.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jerome Marchand <jmarchan@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Mon, Jan 21, 2013 at 02:31:47PM -0800, Nitin Gupta wrote:
> On 01/20/2013 09:18 PM, Minchan Kim wrote:
> >On Fri, Jan 18, 2013 at 01:34:18PM -0800, Nitin Gupta wrote:
> >>On Wed, Jan 16, 2013 at 6:12 PM, Minchan Kim <minchan@kernel.org> wrote:
> >>>Lockdep complains about recursive deadlock of zram->init_lock.
> >>>[1] made it false positive because we can't request IO to zram
> >>>before setting disksize. Anyway, we should shut lockdep up to
> >>>avoid many reporting from user.
> >>>
> >>>This patch allocates zram's metadata out of lock so we can fix it.
> >>>In addition, this patch replace GFP_KERNEL with GFP_NOIO/GFP_ATOMIC
> >>>in request handle path for partial I/O.
> >>>
> >>>[1] zram: give up lazy initialization of zram metadata
> >>>
> >>>Signed-off-by: Minchan Kim <minchan@kernel.org>
> >>>---
> >>>  drivers/staging/zram/zram_drv.c   |  194 +++++++++++++++++++------------------
> >>>  drivers/staging/zram/zram_drv.h   |   12 ++-
> >>>  drivers/staging/zram/zram_sysfs.c |   13 ++-
> >>>  3 files changed, 118 insertions(+), 101 deletions(-)
> >>>
> >>>diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> >>>index 3693780..eb1bc37 100644
> >>>--- a/drivers/staging/zram/zram_drv.c
> >>>+++ b/drivers/staging/zram/zram_drv.c
> >>>@@ -71,22 +71,22 @@ static void zram_stat64_inc(struct zram *zram, u64 *v)
> >>>         zram_stat64_add(zram, v, 1);
> >>>  }
> >>>
> >>>-static int zram_test_flag(struct zram *zram, u32 index,
> >>>+static int zram_test_flag(struct zram_meta *meta, u32 index,
> >>>                         enum zram_pageflags flag)
> >>>  {
> >>>-       return zram->table[index].flags & BIT(flag);
> >>>+       return meta->table[index].flags & BIT(flag);
> >>>  }
> >>>
> >>>-static void zram_set_flag(struct zram *zram, u32 index,
> >>>+static void zram_set_flag(struct zram_meta *meta, u32 index,
> >>>                         enum zram_pageflags flag)
> >>>  {
> >>>-       zram->table[index].flags |= BIT(flag);
> >>>+       meta->table[index].flags |= BIT(flag);
> >>>  }
> >>>
> >>>-static void zram_clear_flag(struct zram *zram, u32 index,
> >>>+static void zram_clear_flag(struct zram_meta *meta, u32 index,
> >>>                         enum zram_pageflags flag)
> >>>  {
> >>>-       zram->table[index].flags &= ~BIT(flag);
> >>>+       meta->table[index].flags &= ~BIT(flag);
> >>>  }
> >>>
> >>>  static int page_zero_filled(void *ptr)
> >>>@@ -106,16 +106,17 @@ static int page_zero_filled(void *ptr)
> >>>
> >>>  static void zram_free_page(struct zram *zram, size_t index)
> >>>  {
> >>>-       unsigned long handle = zram->table[index].handle;
> >>>-       u16 size = zram->table[index].size;
> >>>+       struct zram_meta *meta = zram->meta;
> >>>+       unsigned long handle = meta->table[index].handle;
> >>>+       u16 size = meta->table[index].size;
> >>>
> >>>         if (unlikely(!handle)) {
> >>>                 /*
> >>>                  * No memory is allocated for zero filled pages.
> >>>                  * Simply clear zero page flag.
> >>>                  */
> >>>-               if (zram_test_flag(zram, index, ZRAM_ZERO)) {
> >>>-                       zram_clear_flag(zram, index, ZRAM_ZERO);
> >>>+               if (zram_test_flag(meta, index, ZRAM_ZERO)) {
> >>>+                       zram_clear_flag(meta, index, ZRAM_ZERO);
> >>>                         zram_stat_dec(&zram->stats.pages_zero);
> >>>                 }
> >>>                 return;
> >>>@@ -124,17 +125,17 @@ static void zram_free_page(struct zram *zram, size_t index)
> >>>         if (unlikely(size > max_zpage_size))
> >>>                 zram_stat_dec(&zram->stats.bad_compress);
> >>>
> >>>-       zs_free(zram->mem_pool, handle);
> >>>+       zs_free(meta->mem_pool, handle);
> >>>
> >>>         if (size <= PAGE_SIZE / 2)
> >>>                 zram_stat_dec(&zram->stats.good_compress);
> >>>
> >>>         zram_stat64_sub(zram, &zram->stats.compr_size,
> >>>-                       zram->table[index].size);
> >>>+                       meta->table[index].size);
> >>>         zram_stat_dec(&zram->stats.pages_stored);
> >>>
> >>>-       zram->table[index].handle = 0;
> >>>-       zram->table[index].size = 0;
> >>>+       meta->table[index].handle = 0;
> >>>+       meta->table[index].size = 0;
> >>>  }
> >>>
> >>>  static void handle_zero_page(struct bio_vec *bvec)
> >>>@@ -159,20 +160,21 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
> >>>         int ret = LZO_E_OK;
> >>>         size_t clen = PAGE_SIZE;
> >>>         unsigned char *cmem;
> >>>-       unsigned long handle = zram->table[index].handle;
> >>>+       struct zram_meta *meta = zram->meta;
> >>>+       unsigned long handle = meta->table[index].handle;
> >>>
> >>>-       if (!handle || zram_test_flag(zram, index, ZRAM_ZERO)) {
> >>>+       if (!handle || zram_test_flag(meta, index, ZRAM_ZERO)) {
> >>>                 memset(mem, 0, PAGE_SIZE);
> >>>                 return 0;
> >>>         }
> >>>
> >>>-       cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_RO);
> >>>-       if (zram->table[index].size == PAGE_SIZE)
> >>>+       cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_RO);
> >>>+       if (meta->table[index].size == PAGE_SIZE)
> >>>                 memcpy(mem, cmem, PAGE_SIZE);
> >>>         else
> >>>-               ret = lzo1x_decompress_safe(cmem, zram->table[index].size,
> >>>+               ret = lzo1x_decompress_safe(cmem, meta->table[index].size,
> >>>                                                 mem, &clen);
> >>>-       zs_unmap_object(zram->mem_pool, handle);
> >>>+       zs_unmap_object(meta->mem_pool, handle);
> >>>
> >>>         /* Should NEVER happen. Return bio error if it does. */
> >>>         if (unlikely(ret != LZO_E_OK)) {
> >>>@@ -190,11 +192,11 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
> >>>         int ret;
> >>>         struct page *page;
> >>>         unsigned char *user_mem, *uncmem = NULL;
> >>>-
> >>>+       struct zram_meta *meta = zram->meta;
> >>>         page = bvec->bv_page;
> >>>
> >>>-       if (unlikely(!zram->table[index].handle) ||
> >>>-                       zram_test_flag(zram, index, ZRAM_ZERO)) {
> >>>+       if (unlikely(!meta->table[index].handle) ||
> >>>+                       zram_test_flag(meta, index, ZRAM_ZERO)) {
> >>>                 handle_zero_page(bvec);
> >>>                 return 0;
> >>>         }
> >>>@@ -202,7 +204,7 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
> >>>         user_mem = kmap_atomic(page);
> >>>         if (is_partial_io(bvec))
> >>>                 /* Use  a temporary buffer to decompress the page */
> >>>-               uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
> >>>+               uncmem = kmalloc(PAGE_SIZE, GFP_ATOMIC);
> >>>         else
> >>>                 uncmem = user_mem;
> >>>
> >>>@@ -241,16 +243,17 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >>>         unsigned long handle;
> >>>         struct page *page;
> >>>         unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
> >>>+       struct zram_meta *meta = zram->meta;
> >>>
> >>>         page = bvec->bv_page;
> >>>-       src = zram->compress_buffer;
> >>>+       src = meta->compress_buffer;
> >>>
> >>>         if (is_partial_io(bvec)) {
> >>>                 /*
> >>>                  * This is a partial IO. We need to read the full page
> >>>                  * before to write the changes.
> >>>                  */
> >>>-               uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
> >>>+               uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
> >>>                 if (!uncmem) {
> >>>                         pr_info("Error allocating temp memory!\n");
> >>>                         ret = -ENOMEM;
> >>>@@ -265,8 +268,8 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >>>          * System overwrites unused sectors. Free memory associated
> >>>          * with this sector now.
> >>>          */
> >>>-       if (zram->table[index].handle ||
> >>>-           zram_test_flag(zram, index, ZRAM_ZERO))
> >>>+       if (meta->table[index].handle ||
> >>>+           zram_test_flag(meta, index, ZRAM_ZERO))
> >>>                 zram_free_page(zram, index);
> >>>
> >>>         user_mem = kmap_atomic(page);
> >>>@@ -284,13 +287,13 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >>>                 if (!is_partial_io(bvec))
> >>>                         kunmap_atomic(user_mem);
> >>>                 zram_stat_inc(&zram->stats.pages_zero);
> >>>-               zram_set_flag(zram, index, ZRAM_ZERO);
> >>>+               zram_set_flag(meta, index, ZRAM_ZERO);
> >>>                 ret = 0;
> >>>                 goto out;
> >>>         }
> >>>
> >>>         ret = lzo1x_1_compress(uncmem, PAGE_SIZE, src, &clen,
> >>>-                              zram->compress_workmem);
> >>>+                              meta->compress_workmem);
> >>>
> >>>         if (!is_partial_io(bvec)) {
> >>>                 kunmap_atomic(user_mem);
> >>>@@ -311,14 +314,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >>>                         src = uncmem;
> >>>         }
> >>>
> >>>-       handle = zs_malloc(zram->mem_pool, clen);
> >>>+       handle = zs_malloc(meta->mem_pool, clen);
> >>>         if (!handle) {
> >>>                 pr_info("Error allocating memory for compressed "
> >>>                         "page: %u, size=%zu\n", index, clen);
> >>>                 ret = -ENOMEM;
> >>>                 goto out;
> >>>         }
> >>>-       cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_WO);
> >>>+       cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> >>>
> >>>         if ((clen == PAGE_SIZE) && !is_partial_io(bvec))
> >>>                 src = kmap_atomic(page);
> >>>@@ -326,10 +329,10 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >>>         if ((clen == PAGE_SIZE) && !is_partial_io(bvec))
> >>>                 kunmap_atomic(src);
> >>>
> >>>-       zs_unmap_object(zram->mem_pool, handle);
> >>>+       zs_unmap_object(meta->mem_pool, handle);
> >>>
> >>>-       zram->table[index].handle = handle;
> >>>-       zram->table[index].size = clen;
> >>>+       meta->table[index].handle = handle;
> >>>+       meta->table[index].size = clen;
> >>>
> >>>         /* Update stats */
> >>>         zram_stat64_add(zram, &zram->stats.compr_size, clen);
> >>>@@ -472,33 +475,24 @@ error:
> >>>  void __zram_reset_device(struct zram *zram)
> >>>  {
> >>>         size_t index;
> >>>+       struct zram_meta *meta;
> >>>
> >>>         if (!zram->init_done)
> >>>                 goto out;
> >>>
> >>>+       meta = zram->meta;
> >>>         zram->init_done = 0;
> >>>-
> >>>-       /* Free various per-device buffers */
> >>>-       kfree(zram->compress_workmem);
> >>>-       free_pages((unsigned long)zram->compress_buffer, 1);
> >>>-
> >>>-       zram->compress_workmem = NULL;
> >>>-       zram->compress_buffer = NULL;
> >>>-
> >>>         /* Free all pages that are still in this zram device */
> >>>         for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
> >>>-               unsigned long handle = zram->table[index].handle;
> >>>+               unsigned long handle = meta->table[index].handle;
> >>>                 if (!handle)
> >>>                         continue;
> >>>
> >>>-               zs_free(zram->mem_pool, handle);
> >>>+               zs_free(meta->mem_pool, handle);
> >>>         }
> >>>
> >>>-       vfree(zram->table);
> >>>-       zram->table = NULL;
> >>>-
> >>>-       zs_destroy_pool(zram->mem_pool);
> >>>-       zram->mem_pool = NULL;
> >>>+       zram_meta_free(zram->meta);
> >>>+       zram->meta = NULL;
> >>>
> >>>         /* Reset stats */
> >>>         memset(&zram->stats, 0, sizeof(zram->stats));
> >>>@@ -514,12 +508,64 @@ void zram_reset_device(struct zram *zram)
> >>>         up_write(&zram->init_lock);
> >>>  }
> >>>
> >>>-/* zram->init_lock should be held */
> >>>-int zram_init_device(struct zram *zram)
> >>>+void zram_meta_free(struct zram_meta *meta)
> >>>  {
> >>>-       int ret;
> >>>-       size_t num_pages;
> >>>+       zs_destroy_pool(meta->mem_pool);
> >>>+       kfree(meta->compress_workmem);
> >>>+       free_pages((unsigned long)meta->compress_buffer, 1);
> >>>+       vfree(meta->table);
> >>>+       kfree(meta);
> >>>+}
> >>>+
> >>>+struct zram_meta *zram_meta_alloc(u64 disksize)
> >>>+{
> >>>+       size_t num_pages;
> >>>+       struct zram_meta *meta = kmalloc(sizeof(*meta), GFP_KERNEL);
> >>>+       if (!meta)
> >>>+               goto out;
> >>>+
> >>>+       meta->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
> >>>+       if (!meta->compress_workmem) {
> >>>+               pr_err("Error allocating compressor working memory!\n");
> >>>+               goto free_meta;
> >>>+       }
> >>>+
> >>>+       meta->compress_buffer = (void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, 1);
> >>>+       if (!meta->compress_buffer) {
> >>>+               pr_err("Error allocating compressor buffer space\n");
> >>>+               goto free_workmem;
> >>>+       }
> >>>+
> >>>+       num_pages = disksize >> PAGE_SHIFT;
> >>>+       meta->table = vzalloc(num_pages * sizeof(*meta->table));
> >>>+       if (!meta->table) {
> >>>+               pr_err("Error allocating zram address table\n");
> >>>+               goto free_buffer;
> >>>+       }
> >>>+
> >>>+       meta->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM);
> >>>+       if (!meta->mem_pool) {
> >>>+               pr_err("Error creating memory pool\n");
> >>>+               goto free_table;
> >>>+       }
> >>>+
> >>>+       return meta;
> >>>+
> >>>+free_table:
> >>>+       vfree(meta->table);
> >>>+free_buffer:
> >>>+       free_pages((unsigned long)meta->compress_buffer, 1);
> >>>+free_workmem:
> >>>+       kfree(meta->compress_workmem);
> >>>+free_meta:
> >>>+       kfree(meta);
> >>>+       meta = NULL;
> >>>+out:
> >>>+       return meta;
> >>>+}
> >>>
> >>>+void zram_init_device(struct zram *zram, struct zram_meta *meta)
> >>>+{
> >>>         if (zram->disksize > 2 * (totalram_pages << PAGE_SHIFT)) {
> >>>                 pr_info(
> >>>                 "There is little point creating a zram of greater than "
> >>>@@ -534,51 +580,13 @@ int zram_init_device(struct zram *zram)
> >>>                 );
> >>>         }
> >>>
> >>>-       zram->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
> >>>-       if (!zram->compress_workmem) {
> >>>-               pr_err("Error allocating compressor working memory!\n");
> >>>-               ret = -ENOMEM;
> >>>-               goto fail_no_table;
> >>>-       }
> >>>-
> >>>-       zram->compress_buffer =
> >>>-               (void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, 1);
> >>>-       if (!zram->compress_buffer) {
> >>>-               pr_err("Error allocating compressor buffer space\n");
> >>>-               ret = -ENOMEM;
> >>>-               goto fail_no_table;
> >>>-       }
> >>>-
> >>>-       num_pages = zram->disksize >> PAGE_SHIFT;
> >>>-       zram->table = vzalloc(num_pages * sizeof(*zram->table));
> >>>-       if (!zram->table) {
> >>>-               pr_err("Error allocating zram address table\n");
> >>>-               ret = -ENOMEM;
> >>>-               goto fail_no_table;
> >>>-       }
> >>>-
> >>>         /* zram devices sort of resembles non-rotational disks */
> >>>         queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
> >>>
> >>>-       zram->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM);
> >>>-       if (!zram->mem_pool) {
> >>>-               pr_err("Error creating memory pool\n");
> >>>-               ret = -ENOMEM;
> >>>-               goto fail;
> >>>-       }
> >>>-
> >>>+       zram->meta = meta;
> >>>         zram->init_done = 1;
> >>>
> >>>         pr_debug("Initialization done!\n");
> >>>-       return 0;
> >>>-
> >>>-fail_no_table:
> >>>-       /* To prevent accessing table entries during cleanup */
> >>>-       zram->disksize = 0;
> >>>-fail:
> >>>-       __zram_reset_device(zram);
> >>>-       pr_err("Initialization failed: err=%d\n", ret);
> >>>-       return ret;
> >>>  }
> >>>
> >>>  static void zram_slot_free_notify(struct block_device *bdev,
> >>>diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
> >>>index 5b671d1..2d1a3f1 100644
> >>>--- a/drivers/staging/zram/zram_drv.h
> >>>+++ b/drivers/staging/zram/zram_drv.h
> >>>@@ -83,11 +83,15 @@ struct zram_stats {
> >>>         u32 bad_compress;       /* % of pages with compression ratio>=75% */
> >>>  };
> >>>
> >>>-struct zram {
> >>>-       struct zs_pool *mem_pool;
> >>>+struct zram_meta {
> >>>         void *compress_workmem;
> >>>         void *compress_buffer;
> >>>         struct table *table;
> >>>+       struct zs_pool *mem_pool;
> >>>+};
> >>>+
> >>>+struct zram {
> >>>+       struct zram_meta *meta;
> >>>         spinlock_t stat64_lock; /* protect 64-bit stats */
> >>>         struct rw_semaphore lock; /* protect compression buffers and table
> >>>                                    * against concurrent read and writes */
> >>>@@ -111,7 +115,9 @@ unsigned int zram_get_num_devices(void);
> >>>  extern struct attribute_group zram_disk_attr_group;
> >>>  #endif
> >>>
> >>>-extern int zram_init_device(struct zram *zram);
> >>>  extern void zram_reset_device(struct zram *zram);
> >>>+extern struct zram_meta *zram_meta_alloc(u64 disksize);
> >>>+extern void zram_meta_free(struct zram_meta *meta);
> >>>+extern void zram_init_device(struct zram *zram, struct zram_meta *meta);
> >>>
> >>
> >>This separation of zram and zram_meta looks weird and unncessary. I
> >>would prefer just having
> >>a single struct zram as before.
> >
> >Separation would make code very simple but I admit it has unnecessary
> >allo/free overhead of zram_meta and dereferencing in hot path.
> >So I removed it in hotpath but keep it in slow path to make code simple.
> >
> 
> I meant to check if we can get rid of zram_meta entirely, by open
> coding zram_meta_alloc in disksize_store itself. But looks like that
> will be very error prone with so many goto's.

That's why I remained struct zram_meta. :)

> 
> Otherwise, I prefer struct zram->meta declaration, as is done in
> this patch, instead of duplicating those four fields in both struct
> zram and struct zram_meta and there's no point worrying about that
> extra dereference.

If I understand correctly, you like this version rather than v3?
Okay. I will cook it.

> 
> Thanks,
> Nitin
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
