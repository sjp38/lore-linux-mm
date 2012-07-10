Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 409256B0073
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 22:25:46 -0400 (EDT)
Message-ID: <4FFB92A9.4090203@kernel.org>
Date: Tue, 10 Jul 2012 11:25:45 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] zsmalloc: add single-page object fastpath in unmap
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <1341263752-10210-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1341263752-10210-3-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/03/2012 06:15 AM, Seth Jennings wrote:
> Improve zs_unmap_object() performance by adding a fast path for
> objects that don't span pages.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  drivers/staging/zsmalloc/zsmalloc-main.c |   15 ++++++++++-----
>  1 file changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index a7a6f22..4942d41 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -774,6 +774,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle)
>  	}
>  
>  	zs_copy_map_object(area->vm_buf, page, off, class->size);
> +	area->vm_addr = NULL;
>  	return area->vm_buf;
>  }
>  EXPORT_SYMBOL_GPL(zs_map_object);
> @@ -788,6 +789,14 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
>  	struct size_class *class;
>  	struct mapping_area *area;
>  
> +	area = &__get_cpu_var(zs_map_area);
> +	if (area->vm_addr) {
> +		/* single-page object fastpath */
> +		kunmap_atomic(area->vm_addr);
> +		put_cpu_var(zs_map_area);
> +		return;
> +	}
> +

Please locate this after below BUG_ON.
The BUG check is still effective regardless of your fast path patch.

>  	BUG_ON(!handle);
>  
>  	obj_handle_to_location(handle, &page, &obj_idx);
> @@ -795,11 +804,7 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
>  	class = &pool->size_class[class_idx];
>  	off = obj_idx_to_offset(page, obj_idx, class->size);
>  
> -	area = &__get_cpu_var(zs_map_area);
> -	if (off + class->size <= PAGE_SIZE)
> -		kunmap_atomic(area->vm_addr);
> -	else
> -		zs_copy_unmap_object(area->vm_buf, page, off, class->size);
> +	zs_copy_unmap_object(area->vm_buf, page, off, class->size);
>  	put_cpu_var(zs_map_area);
>  }
>  EXPORT_SYMBOL_GPL(zs_unmap_object);
> 


-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
