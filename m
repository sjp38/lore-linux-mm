Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 5DC9E6B0037
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 09:11:11 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id ht11so1922250vcb.27
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 06:11:10 -0700 (PDT)
Date: Sat, 16 Mar 2013 09:11:06 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH v3 3/5] handle zcache_[eph|pers]_zpages for zero-filled
 page
Message-ID: <20130316131104.GE5987@konrad-lan.dumpdata.com>
References: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363314860-22731-4-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363314860-22731-4-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 10:34:18AM +0800, Wanpeng Li wrote:
> Increment/decrement zcache_[eph|pers]_zpages for zero-filled pages,
> the main point of the counters for zpages and pageframes is to be 
> able to calculate density == zpages/pageframes. A zero-filled page 
> becomes a zpage that "compresses" to zero bytes and, as a result, 
> requires zero pageframes for storage. So the zpages counter should 
> be increased but the pageframes counter should not.
> 
> [Dan Magenheimer <dan.magenheimer@oracle.com>: patch description]
> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/zcache-main.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 6c35c7d..ef8c960 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -863,6 +863,8 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
>  	if (pampd == (void *)ZERO_FILLED) {
>  		handle_zero_filled_page(data);
>  		zero_filled = true;
> +		zsize = 0;
> +		zpages = 1;
>  		if (!raw)
>  			*sizep = PAGE_SIZE;
>  		goto zero_fill;
> @@ -917,8 +919,11 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
>  
>  	BUG_ON(preemptible());
>  
> -	if (pampd == (void *)ZERO_FILLED)
> +	if (pampd == (void *)ZERO_FILLED) {
>  		zero_filled = true;
> +		zsize = 0;
> +		zpages = 1;
> +	}
>  
>  	if (pampd_is_remote(pampd) && !zero_filled) {
>  
> -- 
> 1.7.7.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
