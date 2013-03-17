From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2/5] zero-filled pages awareness
Date: Sun, 17 Mar 2013 08:04:04 +0800
Message-ID: <28856.2847803862$1363478686@news.gmane.org>
References: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363314860-22731-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <51447DC9.5070701@oracle.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UH15f-00006Q-1M
	for glkm-linux-mm-2@m.gmane.org; Sun, 17 Mar 2013 01:04:43 +0100
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 5616F6B0005
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 20:04:17 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 17 Mar 2013 05:30:35 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 1DCDCE0059
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 05:35:31 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2H043dQ65142970
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 05:34:04 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2H046b8013467
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 00:04:06 GMT
Content-Disposition: inline
In-Reply-To: <51447DC9.5070701@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Mar 16, 2013 at 10:12:25PM +0800, Bob Liu wrote:
>
>On 03/15/2013 10:34 AM, Wanpeng Li wrote:
>> Compression of zero-filled pages can unneccessarily cause internal
>> fragmentation, and thus waste memory. This special case can be
>> optimized.
>> 
>> This patch captures zero-filled pages, and marks their corresponding
>> zcache backing page entry as zero-filled. Whenever such zero-filled
>> page is retrieved, we fill the page frame with zero.
>> 
>> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zcache/zcache-main.c |   81 +++++++++++++++++++++++++++++++---
>>  1 files changed, 75 insertions(+), 6 deletions(-)
>> 
>> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
>> index d73dd4b..6c35c7d 100644
>> --- a/drivers/staging/zcache/zcache-main.c
>> +++ b/drivers/staging/zcache/zcache-main.c
>> @@ -59,6 +59,12 @@ static inline void frontswap_tmem_exclusive_gets(bool b)
>>  }
>>  #endif
>>  
>> +/*
>> + * mark pampd to special value in order that later
>> + * retrieve will identify zero-filled pages
>> + */
>> +#define ZERO_FILLED 0x2
>> +
>>  /* enable (or fix code) when Seth's patches are accepted upstream */
>>  #define zcache_writeback_enabled 0
>>  
>> @@ -543,7 +549,23 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
>>  {
>>  	void *pampd = NULL, *cdata = data;
>>  	unsigned clen = size;
>> +	bool zero_filled = false;
>>  	struct page *page = (struct page *)(data), *newpage;
>> +	char *user_mem;
>> +
>> +	user_mem = kmap_atomic(page);
>> +
>> +	/*
>> +	 * Compressing zero-filled pages will waste memory and introduce
>> +	 * serious fragmentation, skip it to avoid overhead
>> +	 */
>> +	if (page_is_zero_filled(user_mem)) {
>> +		kunmap_atomic(user_mem);
>> +		clen = 0;
>> +		zero_filled = true;
>> +		goto got_pampd;
>> +	}
>> +	kunmap_atomic(user_mem);
>>  
>>  	if (!raw) {
>>  		zcache_compress(page, &cdata, &clen);
>> @@ -592,6 +614,8 @@ got_pampd:
>>  		zcache_eph_zpages_max = zcache_eph_zpages;
>>  	if (ramster_enabled && raw)
>>  		ramster_count_foreign_pages(true, 1);
>> +	if (zero_filled)
>> +		pampd = (void *)ZERO_FILLED;
>>  out:
>>  	return pampd;
>>  }
>> @@ -601,14 +625,31 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
>>  {
>>  	void *pampd = NULL, *cdata = data;
>>  	unsigned clen = size;
>> +	bool zero_filled = false;
>>  	struct page *page = (struct page *)(data), *newpage;
>>  	unsigned long zbud_mean_zsize;
>>  	unsigned long curr_pers_zpages, total_zsize;
>> +	char *user_mem;
>>  
>>  	if (data == NULL) {
>>  		BUG_ON(!ramster_enabled);
>>  		goto create_pampd;
>>  	}
>> +
>> +	user_mem = kmap_atomic(page);
>> +
>> +	/*
>> +	 * Compressing zero-filled pages will waste memory and introduce
>> +	 * serious fragmentation, skip it to avoid overhead
>> +	 */
>> +	if (page_is_zero_filled(page)) {
>> +		kunmap_atomic(user_mem);
>> +		clen = 0;
>> +		zero_filled = true;
>> +		goto got_pampd;
>> +	}
>> +	kunmap_atomic(user_mem);
>> +
>

Hi Bob,

>Maybe we can add a function for this code? It seems a bit duplicated.
>

Great point! I will introduce a separate function to handle zero filled
capture stuff. 

Regards,
Wanpeng Li 

>>  	curr_pers_zpages = zcache_pers_zpages;
>>  /* FIXME CONFIG_RAMSTER... subtract atomic remote_pers_pages here? */
>>  	if (!raw)
>> @@ -674,6 +715,8 @@ got_pampd:
>>  		zcache_pers_zbytes_max = zcache_pers_zbytes;
>>  	if (ramster_enabled && raw)
>>  		ramster_count_foreign_pages(false, 1);
>> +	if (zero_filled)
>> +		pampd = (void *)ZERO_FILLED;
>>  out:
>>  	return pampd;
>>  }
>> @@ -735,7 +778,8 @@ out:
>>   */
>>  void zcache_pampd_create_finish(void *pampd, bool eph)
>>  {
>> -	zbud_create_finish((struct zbudref *)pampd, eph);
>> +	if (pampd != (void *)ZERO_FILLED)
>> +		zbud_create_finish((struct zbudref *)pampd, eph);
>>  }
>>  
>>  /*
>> @@ -780,6 +824,14 @@ static int zcache_pampd_get_data(char *data, size_t *sizep, bool raw,
>>  	BUG_ON(preemptible());
>>  	BUG_ON(eph);	/* fix later if shared pools get implemented */
>>  	BUG_ON(pampd_is_remote(pampd));
>> +
>> +	if (pampd == (void *)ZERO_FILLED) {
>> +		handle_zero_filled_page(data);
>> +		if (!raw)
>> +			*sizep = PAGE_SIZE;
>> +		return 0;
>> +	}
>> +
>>  	if (raw)
>>  		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
>>  						sizep, eph);
>> @@ -801,12 +853,21 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
>>  					struct tmem_oid *oid, uint32_t index)
>>  {
>>  	int ret;
>> -	bool eph = !is_persistent(pool);
>> +	bool eph = !is_persistent(pool), zero_filled = false;
>>  	struct page *page = NULL;
>>  	unsigned int zsize, zpages;
>>  
>>  	BUG_ON(preemptible());
>>  	BUG_ON(pampd_is_remote(pampd));
>> +
>> +	if (pampd == (void *)ZERO_FILLED) {
>> +		handle_zero_filled_page(data);
>> +		zero_filled = true;
>> +		if (!raw)
>> +			*sizep = PAGE_SIZE;
>> +		goto zero_fill;
>> +	}
>> +
>>  	if (raw)
>>  		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
>>  						sizep, eph);
>> @@ -818,6 +879,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
>>  	}
>>  	page = zbud_free_and_delist((struct zbudref *)pampd, eph,
>>  					&zsize, &zpages);
>> +zero_fill:
>>  	if (eph) {
>>  		if (page)
>>  			zcache_eph_pageframes =
>> @@ -837,7 +899,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
>>  	}
>>  	if (!is_local_client(pool->client))
>>  		ramster_count_foreign_pages(eph, -1);
>> -	if (page)
>> +	if (page && !zero_filled)
>>  		zcache_free_page(page);
>>  	return ret;
>>  }
>> @@ -851,16 +913,23 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>>  {
>>  	struct page *page = NULL;
>>  	unsigned int zsize, zpages;
>> +	bool zero_filled = false;
>>  
>>  	BUG_ON(preemptible());
>> -	if (pampd_is_remote(pampd)) {
>> +
>> +	if (pampd == (void *)ZERO_FILLED)
>> +		zero_filled = true;
>> +
>> +	if (pampd_is_remote(pampd) && !zero_filled) {
>> +
>>  		BUG_ON(!ramster_enabled);
>>  		pampd = ramster_pampd_free(pampd, pool, oid, index, acct);
>>  		if (pampd == NULL)
>>  			return;
>>  	}
>>  	if (is_ephemeral(pool)) {
>> -		page = zbud_free_and_delist((struct zbudref *)pampd,
>> +		if (!zero_filled)
>> +			page = zbud_free_and_delist((struct zbudref *)pampd,
>>  						true, &zsize, &zpages);
>>  		if (page)
>>  			zcache_eph_pageframes =
>> @@ -883,7 +952,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>>  	}
>>  	if (!is_local_client(pool->client))
>>  		ramster_count_foreign_pages(is_ephemeral(pool), -1);
>> -	if (page)
>> +	if (page && !zero_filled)
>>  		zcache_free_page(page);
>>  }
>>  
>> 
>
>-- 
>Regards,
>-Bob
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
