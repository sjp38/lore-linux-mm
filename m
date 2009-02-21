Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B9C416B008C
	for <linux-mm@kvack.org>; Sat, 21 Feb 2009 11:38:29 -0500 (EST)
Message-ID: <49A02D08.7040509@cs.helsinki.fi>
Date: Sat, 21 Feb 2009 18:34:16 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] kmemcheck: add hooks for the page allocator
References: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com> <1235223364-2097-5-git-send-email-vegard.nossum@gmail.com>
In-Reply-To: <1235223364-2097-5-git-send-email-vegard.nossum@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Vegard Nossum wrote:
> This adds support for tracking the initializedness of memory that
> was allocated with the page allocator. Highmem requests are not
> tracked.
> 
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

> +void kmemcheck_pagealloc_alloc(struct page *page, unsigned int order,
> +			       gfp_t gfpflags)
> +{
> +	int pages;
> +
> +	if (gfpflags & (__GFP_HIGHMEM | __GFP_NOTRACK))
> +		return;
> +
> +	pages = 1 << order;
> +
> +	/*
> +	 * NOTE: We choose to track GFP_ZERO pages too; in fact, they
> +	 * can become uninitialized by copying uninitialized memory
> +	 * into them.
> +	 */
> +
> +	/* XXX: Can use zone->node for node? */
> +	kmemcheck_alloc_shadow(page, order, gfpflags, -1);

Yes, you can.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
