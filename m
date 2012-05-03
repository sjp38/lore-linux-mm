Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 31D556B0083
	for <linux-mm@kvack.org>; Thu,  3 May 2012 09:58:22 -0400 (EDT)
Received: by qafl39 with SMTP id l39so305217qaf.9
        for <linux-mm@kvack.org>; Thu, 03 May 2012 06:58:21 -0700 (PDT)
Message-ID: <4FA28EFD.5070002@vflare.org>
Date: Thu, 03 May 2012 09:58:21 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] zsmalloc: zsmalloc: align cache line size
References: <1336027242-372-1-git-send-email-minchan@kernel.org> <1336027242-372-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1336027242-372-4-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 5/3/12 2:40 AM, Minchan Kim wrote:
> It's a overkill to align pool size with PAGE_SIZE to avoid
> false-sharing. This patch aligns it with just cache line size.
>
> Signed-off-by: Minchan Kim<minchan@kernel.org>
> ---
>   drivers/staging/zsmalloc/zsmalloc-main.c |    6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index 51074fa..3991b03 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -489,14 +489,14 @@ fail:
>
>   struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>   {
> -	int i, error, ovhd_size;
> +	int i, error;
>   	struct zs_pool *pool;
>
>   	if (!name)
>   		return NULL;
>
> -	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
> -	pool = kzalloc(ovhd_size, GFP_KERNEL);
> +	pool = kzalloc(ALIGN(sizeof(*pool), cache_line_size()),
> +				GFP_KERNEL);

a basic question:
  Is rounding off allocation size to cache_line_size enough to ensure 
that the object is cache-line-aligned? Isn't it possible that even 
though the object size is multiple of cache-line, it may still not be 
properly aligned and end up sharing cache line with some other 
read-mostly object?

Thanks,
Nitin


>   	if (!pool)
>   		return NULL;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
