Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id C9C976B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:14:38 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2765924pbb.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 08:14:38 -0700 (PDT)
Date: Fri, 11 May 2012 00:14:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] drivers: cma: don't fail if migration returns -EAGAIN
Message-ID: <20120510151427.GB2394@barrios>
References: <1333462221-3987-1-git-send-email-m.szyprowski@samsung.com>
 <1336655975-15729-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336655975-15729-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>, Sandeep Patil <psandeep.s@gmail.com>

On Thu, May 10, 2012 at 03:19:35PM +0200, Marek Szyprowski wrote:
> alloc_contig_range() function might return -EAGAIN if migrate_pages() call

migrate_page never return -EAGAIN and I can't find any -EAGAIN return in alloc_contig_range.
Am I seeing different tree? 

> fails for some temporarily locked pages. Such case should not be fatal
> to dma_alloc_from_contiguous(), which should retry allocation like in case
> of -EBUSY error.
> 
> Reported-by: Haojian Zhuang <haojian.zhuang@gmail.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> ---
>  drivers/base/dma-contiguous.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index 78efb03..e46e2fb 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -346,7 +346,7 @@ struct page *dma_alloc_from_contiguous(struct device *dev, int count,
>  		if (ret == 0) {
>  			bitmap_set(cma->bitmap, pageno, count);
>  			break;
> -		} else if (ret != -EBUSY) {
> +		} else if (ret != -EBUSY && ret != -EAGAIN) {
>  			goto error;
>  		}
>  		pr_debug("%s(): memory range at %p is busy, retrying\n",
> -- 
> 1.7.1.569.g6f426
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
