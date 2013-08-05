Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 01F286B0033
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 04:53:54 -0400 (EDT)
Date: Mon, 5 Aug 2013 16:55:12 +0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/2] cma: adjust goto branch in function cma_create_area()
Message-ID: <20130805085512.GB22170@kroah.com>
References: <51FF62CB.3090906@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51FF62CB.3090906@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 05, 2013 at 04:31:07PM +0800, Xishi Qiu wrote:
> Adjust the function structure, one for the success path, 
> the other for the failure path.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  drivers/base/dma-contiguous.c |   16 +++++++++-------
>  1 files changed, 9 insertions(+), 7 deletions(-)

Ick, no, you just added 2 lines for no reason, and made the code harder
to follow.

> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index 1bcfaed..aa72f93 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -167,26 +167,28 @@ static __init struct cma *cma_create_area(unsigned long base_pfn,
>  
>  	cma = kmalloc(sizeof *cma, GFP_KERNEL);
>  	if (!cma)
> -		return ERR_PTR(-ENOMEM);
> +		goto err;
>  
>  	cma->base_pfn = base_pfn;
>  	cma->count = count;
>  	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
>  
>  	if (!cma->bitmap)
> -		goto no_mem;
> +		goto err;
>  
>  	ret = cma_activate_area(base_pfn, count);
>  	if (ret)
> -		goto error;
> +		goto err;
>  
>  	pr_debug("%s: returned %p\n", __func__, (void *)cma);
>  	return cma;
>  
> -error:
> -	kfree(cma->bitmap);
> -no_mem:
> -	kfree(cma);
> +err:
> +	if (cma) {
> +		if (cma->bitmap)
> +			kfree(cma->bitmap);
> +		kfree(cma);
> +	}

kfree() can accept NULL just fine.  I think the code looks acceptable
as-is, so this isn't needed.

sorry,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
