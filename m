Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id E46F76B0044
	for <linux-mm@kvack.org>; Mon, 21 May 2012 10:20:48 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 21 May 2012 10:20:47 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 019846E807C
	for <linux-mm@kvack.org>; Mon, 21 May 2012 10:20:22 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4LEKKaF060154
	for <linux-mm@kvack.org>; Mon, 21 May 2012 10:20:20 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4LEJHNe018599
	for <linux-mm@kvack.org>; Mon, 21 May 2012 08:19:17 -0600
Message-ID: <4FBA4EE2.8050308@linux.vnet.ibm.com>
Date: Mon, 21 May 2012 09:19:14 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] zsmalloc: use unsigned long instead of void *
References: <1337567013-4741-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1337567013-4741-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>

On 05/20/2012 09:23 PM, Minchan Kim wrote:

> We should use unsigned long as handle instead of void * to avoid any
> confusion. Without this, users may just treat zs_malloc return value as
> a pointer and try to deference it.


I wouldn't have agreed with you about the need for this change as people
should understand a void * to be the address of some data with unknown
structure.

However, I recently discussed with Dan regarding his RAMster project
where he assumed that the void * would be an address, and as such,
4-byte aligned.  So he has masked two bits into the two LSBs of the
handle for RAMster, which doesn't work with zsmalloc since the handle is
not an address.

So really we do need to convey as explicitly as possible to the user
that the handle is an _opaque_ value about which no assumption can be made.

Also, I wanted to test this but is doesn't apply cleanly on
zsmalloc-main.c on v3.4 or what I have as your latest patch series.
What is the base for this patch?

> 
> This patch passed compile test(zram, zcache and ramster) and zram is
> tested on qemu.
> 
> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> 
> Nitin, Konrad and I discussed and concluded that we should use 'unsigned long'
> instead of 'void *'.
> Look at the lengthy thread if you have a question.
> http://marc.info/?l=linux-mm&m=133716653118566&w=4
> Watch out! it has number of noises.
> 
>  drivers/staging/zcache/zcache-main.c     |   12 ++++++------
>  drivers/staging/zram/zram_drv.c          |   16 ++++++++--------
>  drivers/staging/zram/zram_drv.h          |    2 +-
>  drivers/staging/zsmalloc/zsmalloc-main.c |   24 ++++++++++++------------
>  drivers/staging/zsmalloc/zsmalloc.h      |    8 ++++----
>  5 files changed, 31 insertions(+), 31 deletions(-)
> 
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 2734dac..4c218a7 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -700,7 +700,7 @@ static struct zv_hdr *zv_create(struct zs_pool *pool, uint32_t pool_id,
>  	struct zv_hdr *zv;
>  	u32 size = clen + sizeof(struct zv_hdr);
>  	int chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
> -	void *handle = NULL;
> +	unsigned long handle = 0;
> 
>  	BUG_ON(!irqs_disabled());
>  	BUG_ON(chunks >= NCHUNKS);
> @@ -718,10 +718,10 @@ static struct zv_hdr *zv_create(struct zs_pool *pool, uint32_t pool_id,
>  	memcpy((char *)zv + sizeof(struct zv_hdr), cdata, clen);
>  	zs_unmap_object(pool, handle);
>  out:
> -	return handle;
> +	return (struct zv_hdr *)handle;


This is kind of weird, and somewhat defeats the point, casting it back
to a pointer.  I know you'd have to change it all the way up the stack.
 Just saying.

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


Should we incorporate the union { handle, page } idea we were working on
earlier before doing this?  Might cut down on some the casting below.

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


Putting the union here, as mentioned above.

>  	u16 size;	/* object size (excluding header) */
>  	u8 count;	/* object ref count (not yet used) */
>  	u8 flags;

<snip>

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
