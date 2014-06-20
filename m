Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 69C446B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 05:33:49 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rq2so2937148pbb.39
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 02:33:49 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id ah3si9122440pad.52.2014.06.20.02.33.47
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 02:33:48 -0700 (PDT)
Date: Fri, 20 Jun 2014 10:33:40 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCHv3 1/5] lib/genalloc.c: Add power aligned algorithm
Message-ID: <20140620093340.GL25104@arm.com>
References: <1402969165-7526-1-git-send-email-lauraa@codeaurora.org>
 <1402969165-7526-2-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402969165-7526-2-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Laura,

On Tue, Jun 17, 2014 at 02:39:21AM +0100, Laura Abbott wrote:
> One of the more common algorithms used for allocation
> is to align the start address of the allocation to
> the order of size requested. Add this as an algorithm
> option for genalloc.

Good idea, I didn't know this even existed!

> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> ---
>  include/linux/genalloc.h |  4 ++++
>  lib/genalloc.c           | 21 +++++++++++++++++++++
>  2 files changed, 25 insertions(+)
> 
> diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
> index 1c2fdaa..3cd0934 100644
> --- a/include/linux/genalloc.h
> +++ b/include/linux/genalloc.h
> @@ -110,6 +110,10 @@ extern void gen_pool_set_algo(struct gen_pool *pool, genpool_algo_t algo,
>  extern unsigned long gen_pool_first_fit(unsigned long *map, unsigned long size,
>  		unsigned long start, unsigned int nr, void *data);
>  
> +extern unsigned long gen_pool_first_fit_order_align(unsigned long *map,
> +		unsigned long size, unsigned long start, unsigned int nr,
> +		void *data);
> +
>  extern unsigned long gen_pool_best_fit(unsigned long *map, unsigned long size,
>  		unsigned long start, unsigned int nr, void *data);
>  
> diff --git a/lib/genalloc.c b/lib/genalloc.c
> index bdb9a45..9758529 100644
> --- a/lib/genalloc.c
> +++ b/lib/genalloc.c
> @@ -481,6 +481,27 @@ unsigned long gen_pool_first_fit(unsigned long *map, unsigned long size,
>  EXPORT_SYMBOL(gen_pool_first_fit);
>  
>  /**
> + * gen_pool_first_fit_order_align - find the first available region
> + * of memory matching the size requirement. The region will be aligned
> + * to the order of the size specified.
> + * @map: The address to base the search on
> + * @size: The bitmap size in bits
> + * @start: The bitnumber to start searching at
> + * @nr: The number of zeroed bits we're looking for
> + * @data: additional data - unused

It doesn't look unused to me.

> + */
> +unsigned long gen_pool_first_fit_order_align(unsigned long *map,
> +		unsigned long size, unsigned long start,
> +		unsigned int nr, void *data)
> +{
> +	unsigned long order = (unsigned long) data;
> +	unsigned long align_mask = (1 << get_order(nr << order)) - 1;

Why isn't the order just order?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
