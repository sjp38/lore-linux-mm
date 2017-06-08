Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB7416B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 02:47:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n81so11859428pfb.14
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 23:47:01 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 20si3771472pft.334.2017.06.07.23.47.00
        for <linux-mm@kvack.org>;
        Wed, 07 Jun 2017 23:47:01 -0700 (PDT)
Date: Thu, 8 Jun 2017 15:46:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: correct the comment when reclaimed pages exceed the
 scanned pages
Message-ID: <20170608064658.GA9190@bbox>
References: <1496824266-25235-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496824266-25235-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vinayakm.list@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 07, 2017 at 04:31:06PM +0800, zhongjiang wrote:
> The commit e1587a494540 ("mm: vmpressure: fix sending wrong events on
> underflow") declare that reclaimed pages exceed the scanned pages due
> to the thp reclaim. it is incorrect because THP will be spilt to normal
> page and loop again. which will result in the scanned pages increment.
> 
> Signed-off-by: zhongjiang <zhongjiang@huawei.com>
> ---
>  mm/vmpressure.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 6063581..0e91ba3 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -116,8 +116,9 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  
>  	/*
>  	 * reclaimed can be greater than scanned in cases
> -	 * like THP, where the scanned is 1 and reclaimed
> -	 * could be 512
> +	 * like reclaimed slab pages, shrink_node just add
> +	 * reclaimed page without a related increment to
> +	 * scanned pages.
>  	 */
>  	if (reclaimed >= scanned)
>  		goto out;

Thanks for the fixing my fault!

Acked-by: Minchan Kim <minchan@kernel.org>

Frankly speaking, I'm not sure we need such comment in there at the cost
of maintainance because it would be fragile but easy to fix by above simple
condition so I think it would be better to remove that comment but others
might be different. So, don't have any objection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
