Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id D5B426B0038
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 18:36:38 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so6971941iec.23
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 15:36:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id om4si6084149igb.14.2014.08.08.15.36.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Aug 2014 15:36:37 -0700 (PDT)
Date: Fri, 8 Aug 2014 15:36:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv6 1/5] lib/genalloc.c: Add power aligned algorithm
Message-Id: <20140808153635.36f27a4fbfbd8f715e51d15e@linux-foundation.org>
In-Reply-To: <1407529397-6642-1-git-send-email-lauraa@codeaurora.org>
References: <1407529397-6642-1-git-send-email-lauraa@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Russell King <linux@arm.linux.org.uk>, David Riley <davidriley@chromium.org>, linux-arm-kernel@lists.infradead.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>

On Fri,  8 Aug 2014 13:23:13 -0700 Laura Abbott <lauraa@codeaurora.org> wrote:

> 
> One of the more common algorithms used for allocation
> is to align the start address of the allocation to
> the order of size requested. Add this as an algorithm
> option for genalloc.
> 
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

`data' is used.

> + */
> +unsigned long gen_pool_first_fit_order_align(unsigned long *map,
> +		unsigned long size, unsigned long start,
> +		unsigned int nr, void *data)
> +{
> +	unsigned long order = (unsigned long) data;

Why pass a void*?  Why not pass "unsigned order;"?

> +	unsigned long align_mask = (1 << get_order(nr << order)) - 1;
> +
> +	return bitmap_find_next_zero_area(map, size, start, nr, align_mask);
> +}
> +EXPORT_SYMBOL(gen_pool_first_fit_order_align);
> +
> +/**
>   * gen_pool_best_fit - find the best fitting region of memory
>   * macthing the size requirement (no alignment constraint)
>   * @map: The address to base the search on

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
