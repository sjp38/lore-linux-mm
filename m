Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 9A9D86B0005
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 06:30:57 -0400 (EDT)
Message-ID: <51498FCE.60603@oracle.com>
Date: Wed, 20 Mar 2013 18:30:38 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/8] staging: zcache: zero-filled pages awareness
References: <1363685150-18303-1-git-send-email-liwanp@linux.vnet.ibm.com> <1363685150-18303-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363685150-18303-3-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> @@ -641,16 +691,22 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>  {
>  	struct page *page = NULL;
>  	unsigned int zsize, zpages;
> +	bool zero_filled = false;
>  
>  	BUG_ON(preemptible());
> -	if (pampd_is_remote(pampd)) {
> +
> +	if (pampd == (void *)ZERO_FILLED)
> +		zero_filled = true;
> +
> +	if (pampd_is_remote(pampd) && !zero_filled) {
>  		BUG_ON(!ramster_enabled);
>  		pampd = ramster_pampd_free(pampd, pool, oid, index, acct);
>  		if (pampd == NULL)
>  			return;
>  	}
>  	if (is_ephemeral(pool)) {
> -		page = zbud_free_and_delist((struct zbudref *)pampd,
> +		if (!zero_filled)
> +			page = zbud_free_and_delist((struct zbudref *)pampd,
>  						true, &zsize, &zpages);

This check should also apply for !is_ephemeral(pool).

>  		if (page)
>  			dec_zcache_eph_pageframes();
> @@ -667,7 +723,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>  	}
>  	if (!is_local_client(pool->client))
>  		ramster_count_foreign_pages(is_ephemeral(pool), -1);
> -	if (page)
> +	if (page && !zero_filled)
>  		zcache_free_page(page);
>  }
>  
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
