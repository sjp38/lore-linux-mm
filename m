Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id CCB156B0071
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 12:11:54 -0400 (EDT)
Date: Thu, 30 Aug 2012 12:11:43 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] staging: zcache: fix cleancache race condition with
 shrinker
Message-ID: <20120830161143.GB9907@localhost.localdomain>
References: <1346277525-22062-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346277525-22062-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, Aug 29, 2012 at 04:58:45PM -0500, Seth Jennings wrote:
> This patch fixes a race condition that results in memory
> corruption when using cleancache.
> 
> The race exists between the zcache shrinker handler,
> shrink_zcache_memory() and cleancache_get_page().
> 
> In most cases, the shrinker will both evict a zbpg
> from its buddy list and flush it from tmem before a
> cleancache_get_page() occurs on that page. A subsequent
> cleancache_get_page() will fail in the tmem layer.
> 
> In the rare case that two occur together and the
> cleancache_get_page() path gets through the tmem
> layer before the shrinker path can flush tmem,
> zbud_decompress() does a check to see if the zbpg is a
> "zombie", i.e. not on a buddy list, which means the shrinker
> is in the process of reclaiming it. If the zbpg is a zombie,
> zbud_decompress() returns -EINVAL.
> 
> However, this return code is being ignored by the caller,
> zcache_pampd_get_data_and_free(), which results in the
> caller of cleancache_get_page() thinking that the page has
> been properly retrieved when it has not.
> 
> This patch modifies zcache_pampd_get_data_and_free() to
> convey the failure up the stack so that the caller of
> cleancache_get_page() knows the page retrieval failed.
> 
> ---
> Based on v3.6-rc3.
> 
> This needs to be applied to stable trees as well.
> zcache-main.c was named zcache.c before v3.1, so
> I'm not sure how you want to handle trees earlier
> than that.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Thanks for tracking this down!
> ---
>  drivers/staging/zcache/zcache-main.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index c214977..52b43b7 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1251,13 +1251,12 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *bufsize, bool raw,
>  					void *pampd, struct tmem_pool *pool,
>  					struct tmem_oid *oid, uint32_t index)
>  {
> -	int ret = 0;
> -
>  	BUG_ON(!is_ephemeral(pool));
> -	zbud_decompress((struct page *)(data), pampd);
> +	if (zbud_decompress((struct page *)(data), pampd) < 0)
> +		return -EINVAL;
>  	zbud_free_and_delist((struct zbud_hdr *)pampd);
>  	atomic_dec(&zcache_curr_eph_pampd_count);
> -	return ret;
> +	return 0;
>  }
>  
>  /*
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
