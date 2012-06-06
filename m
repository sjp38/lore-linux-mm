Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id EF5106B0062
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 00:00:29 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so10584707pbb.14
        for <linux-mm@kvack.org>; Tue, 05 Jun 2012 21:00:29 -0700 (PDT)
Message-ID: <4FCED5D2.60502@vflare.org>
Date: Tue, 05 Jun 2012 21:00:18 -0700
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] zsmalloc: zsmalloc: use unsigned long instead of
 void *
References: <1338881031-19662-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1338881031-19662-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>

On 06/05/2012 12:23 AM, Minchan Kim wrote:

> We should use unsigned long as handle instead of void * to avoid any
> confusion. Without this, users may just treat zs_malloc return value as
> a pointer and try to deference it.
> 
> This patch passed compile test(zram, zcache and ramster) and zram is
> tested on qemu.
> 
> changelog
>   * from v1
>  	- change zcache's zv_create return value
>         - baesd on next-20120604
> 
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zcache/zcache-main.c     |   12 ++++++------
>  drivers/staging/zram/zram_drv.c          |   16 ++++++++--------
>  drivers/staging/zram/zram_drv.h          |    2 +-
>  drivers/staging/zsmalloc/zsmalloc-main.c |   24 ++++++++++++------------
>  drivers/staging/zsmalloc/zsmalloc.h      |    8 ++++----
>  5 files changed, 31 insertions(+), 31 deletions(-)
> 
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 2734dac..d0141fbc 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -693,14 +693,14 @@ static unsigned int zv_max_mean_zsize = (PAGE_SIZE / 8) * 5;
>  static atomic_t zv_curr_dist_counts[NCHUNKS];
>  static atomic_t zv_cumul_dist_counts[NCHUNKS];
>  
> -static struct zv_hdr *zv_create(struct zs_pool *pool, uint32_t pool_id,
> +static unsigned long zv_create(struct zs_pool *pool, uint32_t pool_id,
>  				struct tmem_oid *oid, uint32_t index,
>  				void *cdata, unsigned clen)
>  {
>  	struct zv_hdr *zv;
>  	u32 size = clen + sizeof(struct zv_hdr);
>  	int chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
> -	void *handle = NULL;
> +	unsigned long handle = 0;
>  
>  	BUG_ON(!irqs_disabled());
>  	BUG_ON(chunks >= NCHUNKS);
> @@ -721,7 +721,7 @@ out:
>  	return handle;
>  }
>  
> -static void zv_free(struct zs_pool *pool, void *handle)
> +static void zv_free(struct zs_pool *pool, unsigned long handle)
>  {
>  	unsigned long flags;
>  	struct zv_hdr *zv;
> @@ -743,7 +743,7 @@ static void zv_free(struct zs_pool *pool, void *handle)
>  	local_irq_restore(flags);
>  }
>  
> -static void zv_decompress(struct page *page, void *handle)
> +static void zv_decompress(struct page *page, unsigned long handle)
>  {
>  	unsigned int clen = PAGE_SIZE;
>  	char *to_va;
> @@ -1247,7 +1247,7 @@ static int zcache_pampd_get_data(char *data, size_t *bufsize, bool raw,
>  	int ret = 0;
>  
>  	BUG_ON(is_ephemeral(pool));
> -	zv_decompress((struct page *)(data), pampd);
> +	zv_decompress((struct page *)(data), (unsigned long)pampd);
>  	return ret;
>  }
>  
> @@ -1282,7 +1282,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>  		atomic_dec(&zcache_curr_eph_pampd_count);
>  		BUG_ON(atomic_read(&zcache_curr_eph_pampd_count) < 0);
>  	} else {
> -		zv_free(cli->zspool, pampd);
> +		zv_free(cli->zspool, (unsigned long)pampd);
>  		atomic_dec(&zcache_curr_pers_pampd_count);
>  		BUG_ON(atomic_read(&zcache_curr_pers_pampd_count) < 0);
>  	}
> diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> index 685d612..abd69d1 100644
> --- a/drivers/staging/zram/zram_drv.c
> +++ b/drivers/staging/zram/zram_drv.c
> @@ -135,7 +135,7 @@ static void zram_set_disksize(struct zram *zram, size_t totalram_bytes)
>  
>  static void zram_free_page(struct zram *zram, size_t index)
>  {
> -	void *handle = zram->table[index].handle;
> +	unsigned long handle = zram->table[index].handle;
>  
>  	if (unlikely(!handle)) {
>  		/*
> @@ -150,7 +150,7 @@ static void zram_free_page(struct zram *zram, size_t index)
>  	}
>  
>  	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
> -		__free_page(handle);
> +		__free_page((struct page *)handle);
>  		zram_clear_flag(zram, index, ZRAM_UNCOMPRESSED);
>  		zram_stat_dec(&zram->stats.pages_expand);
>  		goto out;
> @@ -166,7 +166,7 @@ out:
>  			zram->table[index].size);
>  	zram_stat_dec(&zram->stats.pages_stored);
>  
> -	zram->table[index].handle = NULL;
> +	zram->table[index].handle = 0;
>  	zram->table[index].size = 0;
>  }
>  
> @@ -189,7 +189,7 @@ static void handle_uncompressed_page(struct zram *zram, struct bio_vec *bvec,
>  	unsigned char *user_mem, *cmem;
>  
>  	user_mem = kmap_atomic(page);
> -	cmem = kmap_atomic(zram->table[index].handle);
> +	cmem = kmap_atomic((struct page *)zram->table[index].handle);
>  
>  	memcpy(user_mem + bvec->bv_offset, cmem + offset, bvec->bv_len);
>  	kunmap_atomic(cmem);
> @@ -317,7 +317,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  	int ret;
>  	u32 store_offset;
>  	size_t clen;
> -	void *handle;
> +	unsigned long handle;
>  	struct zobj_header *zheader;
>  	struct page *page, *page_store;
>  	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
> @@ -399,7 +399,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  		store_offset = 0;
>  		zram_set_flag(zram, index, ZRAM_UNCOMPRESSED);
>  		zram_stat_inc(&zram->stats.pages_expand);
> -		handle = page_store;
> +		handle = (unsigned long)page_store;
>  		src = kmap_atomic(page);
>  		cmem = kmap_atomic(page_store);
>  		goto memstore;
> @@ -592,12 +592,12 @@ void __zram_reset_device(struct zram *zram)
>  
>  	/* Free all pages that are still in this zram device */
>  	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
> -		void *handle = zram->table[index].handle;
> +		unsigned long handle = zram->table[index].handle;
>  		if (!handle)
>  			continue;
>  
>  		if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)))
> -			__free_page(handle);
> +			__free_page((struct page *)handle);
>  		else
>  			zs_free(zram->mem_pool, handle);
>  	}
> diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
> index fbe8ac9..7a7e256 100644
> --- a/drivers/staging/zram/zram_drv.h
> +++ b/drivers/staging/zram/zram_drv.h
> @@ -81,7 +81,7 @@ enum zram_pageflags {
>  
>  /* Allocated for each disk page */
>  struct table {
> -	void *handle;
> +	unsigned long handle;
>  	u16 size;	/* object size (excluding header) */
>  	u8 count;	/* object ref count (not yet used) */
>  	u8 flags;
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index 4496737..fcbe83d 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -247,10 +247,10 @@ static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
>  }
>  
>  /* Decode <page, obj_idx> pair from the given object handle */
> -static void obj_handle_to_location(void *handle, struct page **page,
> +static void obj_handle_to_location(unsigned long handle, struct page **page,
>  				unsigned long *obj_idx)
>  {
> -	unsigned long hval = (unsigned long)handle;
> +	unsigned long hval = handle;
>  
>  	*page = pfn_to_page(hval >> OBJ_INDEX_BITS);
>  	*obj_idx = hval & OBJ_INDEX_MASK;


hval looks redundant now.

Rest of the changes look good to me. Thanks!

Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
