Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 4E29B6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 08:53:48 -0400 (EDT)
Received: by qabg27 with SMTP id g27so1394318qab.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 05:53:47 -0700 (PDT)
Message-ID: <4F97F3D6.8000404@vflare.org>
Date: Wed, 25 Apr 2012 08:53:42 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] zsmalloc: remove unnecessary alignment
References: <1335334994-22138-1-git-send-email-minchan@kernel.org> <1335334994-22138-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1335334994-22138-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/25/2012 02:23 AM, Minchan Kim wrote:

> It isn't necessary to align pool size with PAGE_SIZE.
> If I missed something, please let me know it.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zsmalloc/zsmalloc-main.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index 504b6c2..b99ad9e 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -489,14 +489,13 @@ fail:
>  
>  struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>  {
> -	int i, error, ovhd_size;
> +	int i, error;
>  	struct zs_pool *pool;
>  
>  	if (!name)
>  		return NULL;
>  
> -	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
> -	pool = kzalloc(ovhd_size, GFP_KERNEL);
> +	pool = kzalloc(sizeof(*pool), GFP_KERNEL);
>  	if (!pool)
>  		return NULL;
>  


pool metadata is rounded-up to avoid potential false-sharing problem
(though we could just roundup to cache_line_size()).

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
