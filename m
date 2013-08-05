Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 8CDB56B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 15:58:12 -0400 (EDT)
Date: Mon, 5 Aug 2013 15:58:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V2] cma: use macro PFN_DOWN when converting size to pages
Message-ID: <20130805195805.GE1845@cmpxchg.org>
References: <51FF6BBD.2090606@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51FF6BBD.2090606@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 05, 2013 at 05:09:17PM +0800, Xishi Qiu wrote:
> Use "PFN_DOWN(r->size)" instead of "r->size >> PAGE_SHIFT".
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  drivers/base/dma-contiguous.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index 0ca5442..b3d711d 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -206,8 +206,7 @@ static int __init cma_init_reserved_areas(void)
>  
>  	for (; i; --i, ++r) {
>  		struct cma *cma;
> -		cma = cma_create_area(PFN_DOWN(r->start),
> -				      r->size >> PAGE_SHIFT);
> +		cma = cma_create_area(PFN_DOWN(r->start), PFN_DOWN(r->size));

PFN_DOWN(r->start) makes sense because you are dividing and rounding a
byte-granular address to a PFN.

r->size >> PAGE_SHIFT translates number of bytes into number of pages.

It ends up being the same arithmetic operation to do both things, but
the units are different; the result of the second expression is not a
PFN.  I think this change actually worsens readability of the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
