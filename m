Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 0E4146B0038
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 09:07:26 -0400 (EDT)
Received: by mail-ve0-f169.google.com with SMTP id 15so3346177vea.28
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 06:07:26 -0700 (PDT)
Date: Sat, 16 Mar 2013 09:07:21 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH v2 2/4] zero-filled pages awareness
Message-ID: <20130316130720.GC5987@konrad-lan.dumpdata.com>
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363255697-19674-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363255697-19674-3-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 14, 2013 at 06:08:15PM +0800, Wanpeng Li wrote:
> Compression of zero-filled pages can unneccessarily cause internal
> fragmentation, and thus waste memory. This special case can be
> optimized.
> 
> This patch captures zero-filled pages, and marks their corresponding
> zcache backing page entry as zero-filled. Whenever such zero-filled
> page is retrieved, we fill the page frame with zero.
> 
> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/zcache-main.c |   86 +++++++++++++++++++++++++++++++--
>  1 files changed, 80 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index b71e033..db200b4 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -59,6 +59,11 @@ static inline void frontswap_tmem_exclusive_gets(bool b)
>  }
>  #endif
>  
> +/*
> + * mark pampd to special value in order that later
> + * retrieve will identify zero-filled pages
> + */
> +
>  /* enable (or fix code) when Seth's patches are accepted upstream */
>  #define zcache_writeback_enabled 0
>  
> @@ -543,7 +548,23 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
>  {
>  	void *pampd = NULL, *cdata = data;
>  	unsigned clen = size;
> +	bool zero_filled = false;
>  	struct page *page = (struct page *)(data), *newpage;
> +	char *user_mem;
> +
> +	user_mem = kmap_atomic(page);
> +
> +	/*
> +	 * Compressing zero-filled pages will waste memory and introduce
> +	 * serious fragmentation, skip it to avoid overhead
> +	 */
> +	if (page_zero_filled(user_mem)) {
> +		kunmap_atomic(user_mem);
> +		clen = 0;
> +		zero_filled = true;
> +		goto got_pampd;
> +	}
> +	kunmap_atomic(user_mem);
>  
>  	if (!raw) {
>  		zcache_compress(page, &cdata, &clen);
> @@ -592,6 +613,8 @@ got_pampd:
>  		zcache_eph_zpages_max = zcache_eph_zpages;
>  	if (ramster_enabled && raw)
>  		ramster_count_foreign_pages(true, 1);
> +	if (zero_filled)
> +		pampd = (void *)ZERO_FILLED;
>  out:
>  	return pampd;
>  }
> @@ -601,14 +624,31 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
>  {
>  	void *pampd = NULL, *cdata = data;
>  	unsigned clen = size;
> +	bool zero_filled = false;
>  	struct page *page = (struct page *)(data), *newpage;
>  	unsigned long zbud_mean_zsize;
>  	unsigned long curr_pers_zpages, total_zsize;
> +	char *user_mem;
>  
>  	if (data == NULL) {
>  		BUG_ON(!ramster_enabled);
>  		goto create_pampd;
>  	}
> +
> +	user_mem = kmap_atomic(page);
> +
> +	/*
> +	 * Compressing zero-filled pages will waste memory and introduce
> +	 * serious fragmentation, skip it to avoid overhead
> +	 */
> +	if (page_zero_filled(page)) {
> +		kunmap_atomic(user_mem);
> +		clen = 0;
> +		zero_filled = true;
> +		goto got_pampd;
> +	}
> +	kunmap_atomic(user_mem);
> +
>  	curr_pers_zpages = zcache_pers_zpages;
>  /* FIXME CONFIG_RAMSTER... subtract atomic remote_pers_pages here? */
>  	if (!raw)
> @@ -674,6 +714,8 @@ got_pampd:
>  		zcache_pers_zbytes_max = zcache_pers_zbytes;
>  	if (ramster_enabled && raw)
>  		ramster_count_foreign_pages(false, 1);
> +	if (zero_filled)
> +		pampd = (void *)ZERO_FILLED;
>  out:
>  	return pampd;
>  }
> @@ -735,7 +777,8 @@ out:
>   */
>  void zcache_pampd_create_finish(void *pampd, bool eph)
>  {
> -	zbud_create_finish((struct zbudref *)pampd, eph);
> +	if (pampd != (void *)ZERO_FILLED)
> +		zbud_create_finish((struct zbudref *)pampd, eph);
>  }
>  
>  /*
> @@ -780,6 +823,14 @@ static int zcache_pampd_get_data(char *data, size_t *sizep, bool raw,
>  	BUG_ON(preemptible());
>  	BUG_ON(eph);	/* fix later if shared pools get implemented */
>  	BUG_ON(pampd_is_remote(pampd));
> +
> +	if (pampd == (void *)ZERO_FILLED) {
> +		handle_zero_page(data);
> +		if (!raw)
> +			*sizep = PAGE_SIZE;
> +		return 0;
> +	}
> +
>  	if (raw)
>  		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
>  						sizep, eph);
> @@ -801,12 +852,23 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
>  					struct tmem_oid *oid, uint32_t index)
>  {
>  	int ret;
> -	bool eph = !is_persistent(pool);
> +	bool eph = !is_persistent(pool), zero_filled = false;
>  	struct page *page = NULL;
>  	unsigned int zsize, zpages;
>  
>  	BUG_ON(preemptible());
>  	BUG_ON(pampd_is_remote(pampd));
> +
> +	if (pampd == (void *)ZERO_FILLED) {
> +		handle_zero_page(data);
> +		zero_filled = true;
> +		zsize = 0;
> +		zpages = 0;
> +		if (!raw)
> +			*sizep = PAGE_SIZE;
> +		goto zero_fill;
> +	}
> +
>  	if (raw)
>  		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
>  						sizep, eph);
> @@ -818,6 +880,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
>  	}
>  	page = zbud_free_and_delist((struct zbudref *)pampd, eph,
>  					&zsize, &zpages);
> +zero_fill:
>  	if (eph) {
>  		if (page)
>  			zcache_eph_pageframes =
> @@ -837,7 +900,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
>  	}
>  	if (!is_local_client(pool->client))
>  		ramster_count_foreign_pages(eph, -1);
> -	if (page)
> +	if (page && !zero_filled)
>  		zcache_free_page(page);
>  	return ret;
>  }
> @@ -851,16 +914,27 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>  {
>  	struct page *page = NULL;
>  	unsigned int zsize, zpages;
> +	bool zero_filled = false;
>  
>  	BUG_ON(preemptible());
> -	if (pampd_is_remote(pampd)) {
> +
> +	if (pampd == (void *)ZERO_FILLED) {
> +		zero_filled = true;
> +		zsize = 0;
> +		zpages = 0;
> +	}
> +
> +	if (pampd_is_remote(pampd) && !zero_filled) {
> +
>  		BUG_ON(!ramster_enabled);
>  		pampd = ramster_pampd_free(pampd, pool, oid, index, acct);
>  		if (pampd == NULL)
>  			return;
>  	}
>  	if (is_ephemeral(pool)) {
> -		page = zbud_free_and_delist((struct zbudref *)pampd,
> +		if (!zero_filled)
> +			page = zbud_free_and_delist((struct zbudref *)pampd,
> +
>  						true, &zsize, &zpages);
>  		if (page)
>  			zcache_eph_pageframes =
> @@ -883,7 +957,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>  	}
>  	if (!is_local_client(pool->client))
>  		ramster_count_foreign_pages(is_ephemeral(pool), -1);
> -	if (page)
> +	if (page && !zero_filled)
>  		zcache_free_page(page);
>  }
>  
> -- 
> 1.7.7.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
