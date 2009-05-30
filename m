Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C89015F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 18:32:24 -0400 (EDT)
Subject: Re: [PATCH] Change ZERO_SIZE_PTR to point at unmapped space
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090530192829.GK6535@oblivion.subreption.com>
References: <20090530192829.GK6535@oblivion.subreption.com>
Content-Type: text/plain
Date: Sun, 31 May 2009 00:32:51 +0200
Message-Id: <1243722771.6645.162.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2009-05-30 at 12:28 -0700, Larry H. wrote:
> [PATCH] Change ZERO_SIZE_PTR to point at unmapped space
> 
> This patch changes the ZERO_SIZE_PTR address to point at top memory
> unmapped space, instead of the original location which could be
> mapped from userland to abuse a NULL (or offset-from-null) pointer
> dereference scenario.

Same goes for the regular NULL pointer, we have bits to disallow
userspace mapping the NULL page, so I'm not exactly seeing what this
patch buys us.

> The ZERO_OR_NULL_PTR macro is changed accordingly. This patch does
> not modify its behavior nor has any performance nor functionality
> impact.

It does generate longer asm.

> The original change was written first by the PaX team for their
> patch.
> 
> Signed-off-by: Larry Highsmith <larry@subreption.com>
> 
> Index: linux-2.6/include/linux/slab.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slab.h
> +++ linux-2.6/include/linux/slab.h
> @@ -73,10 +73,9 @@
>   * ZERO_SIZE_PTR can be passed to kfree though in the same way that NULL can.
>   * Both make kfree a no-op.
>   */
> -#define ZERO_SIZE_PTR ((void *)16)
> +#define ZERO_SIZE_PTR ((void *)-1024L)
>  
> -#define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
> -				(unsigned long)ZERO_SIZE_PTR)
> +#define ZERO_OR_NULL_PTR(x) (!(x) || (x) == ZERO_SIZE_PTR)
>  
>  /*
>   * struct kmem_cache related prototypes
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
