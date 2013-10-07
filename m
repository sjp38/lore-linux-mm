Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E57C76B0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 11:38:05 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so7378457pab.8
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 08:38:05 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Mon, 7 Oct 2013 09:38:03 -0600
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B72DA38C804F
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 11:37:59 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r97Fc0qp54198316
	for <linux-mm@kvack.org>; Mon, 7 Oct 2013 15:38:00 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r97FbvV7002750
	for <linux-mm@kvack.org>; Mon, 7 Oct 2013 12:37:58 -0300
Date: Mon, 7 Oct 2013 10:37:56 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH] frontswap: enable call to invalidate area on swapoff
Message-ID: <20131007153756.GA4473@variantweb.net>
References: <1381159541-13981-1-git-send-email-k.kozlowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381159541-13981-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On Mon, Oct 07, 2013 at 05:25:41PM +0200, Krzysztof Kozlowski wrote:
> During swapoff the frontswap_map was NULL-ified before calling
> frontswap_invalidate_area(). However the frontswap_invalidate_area()
> exits early if frontswap_map is NULL. Invalidate was never called during
> swapoff.
> 
> This patch moves frontswap_map_set() in swapoff just after calling
> frontswap_invalidate_area() so outside of locks
> (swap_lock and swap_info_struct->lock). This shouldn't be a problem as
> during swapon the frontswap_map_set() is called also outside of any
> locks.
> 
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Nice catch!

Reviewed-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

> ---
>  mm/swapfile.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 3963fc2..3a4896b 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1922,10 +1922,10 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	p->cluster_info = NULL;
>  	p->flags = 0;
>  	frontswap_map = frontswap_map_get(p);
> -	frontswap_map_set(p, NULL);
>  	spin_unlock(&p->lock);
>  	spin_unlock(&swap_lock);
>  	frontswap_invalidate_area(type);
> +	frontswap_map_set(p, NULL);
>  	mutex_unlock(&swapon_mutex);
>  	free_percpu(p->percpu_cluster);
>  	p->percpu_cluster = NULL;
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
