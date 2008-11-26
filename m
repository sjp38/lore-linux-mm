Date: Wed, 26 Nov 2008 18:17:57 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RESEND:PATCH] [ARM] clearpage: provide our own clear_user_highpage()
In-Reply-To: <20081126171321.GA4719@dyn-67.arm.linux.org.uk>
Message-ID: <Pine.LNX.4.64.0811261811180.5305@blonde.site>
References: <20081126171321.GA4719@dyn-67.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk+lkml@arm.linux.org.uk>
Cc: linux-arch@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Nov 2008, Russell King wrote:

> I've not had any response to this, so in liu of any response by this
> coming weekend, I'm going to assume that everyone's happy with this
> change (at which point it's going to become buried under a lot of
> merges with other trees.)
> 
> ----- Forwarded message from Russell King <rmk+lkml@arm.linux.org.uk> -----
> 
> Date: Thu, 20 Nov 2008 17:50:17 +0000
> From: Russell King <rmk+lkml@arm.linux.org.uk>
> To: linux-arch@vger.kernel.org,
> 	Linux Kernel List <linux-kernel@vger.kernel.org>,
> 	linux-mm@kvack.org
> Subject: [PATCH] [ARM] clearpage: provide our own clear_user_highpage()
> 
> This patch is part of a larger ARM specific patch set cleaning up
> aliasing VIPT cache support.
> 
> With aliasing VIPT cache support, our implementation of clear_user_page()
> and copy_user_page() sets up a temporary kernel space mapping such that
> we have the same cache colour as the userspace page.  This avoids having
> to consider any userspace aliases from this operation.
> 
> However, when highmem is enabled, kmap_atomic() have to setup mappings.
> The copy_user_highpage() and clear_user_highpage() call these functions
> before delegating the copies to copy_user_page() and clear_user_page().
> 
> The effect of this is that each of the *_user_highpage() functions setup
> their own kmap mapping, followed by the *_user_page() functions setting
> up another mapping.  This is rather wasteful.
> 
> Thankfully, copy_user_highpage() can be overriden by architectures by
> defining __HAVE_ARCH_COPY_USER_HIGHPAGE.  However, replacement of 
> clear_user_highpage() is more difficult because its inline definition
> is not conditional.  It seems that you're expected to define
> __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE and provide a replacement
> __alloc_zeroed_user_highpage() implementation instead.
> 
> The allocation itself is fine, so we don't want to override that.  What
> we really want to do is to override clear_user_highpage() with our own
> version which doesn't kmap_atomic() unnecessarily.
> 
> However, there are two drivers (drivers/media/video/videobuf-dma-sg.c
> and drivers/staging/go7007/go7007-v4l2.c) which want to provide non-
> highmem clear_user_page()'d pages to userspace.
> 
> Requiring an architecture to provide __alloc_zeroed_user_highpage(),
> a sub-optimal clear_user_page(), and keep the sub-optimal
> clear_user_highpage() around seems rather silly and potentially
> error prone.
> 
> So, what this patch below does is allow clear_user_highpage() itself
> to be overriden by architectures, so that they can provide just one
> implementation.
> 
> What needs to follow on from this is converting those two drivers to
> use clear_user_highpage() instead of clear_user_page() - that should
> be a trivial patch.
> 
> Are there any objections to this approach?  Can I get any acked-by's
> from any MM folk for the include/linux/highmem.h change?

Looks eminently sensible to me, and the #define clear_user_highpage
style you've chosen is indeed our favoured technique these days.

I expect we might want to get away from that mixture of __HAVE_ARCH..
and #define actual_function_name all in the same highmem.h, but
no reason why you should have to be the one to do such cleanup.

> From: Russell King <rmk+lkml@arm.linux.org.uk>
> Date: Mon, 17 Nov 2008 14:08:49 +0000
> Subject: Re: [PATCH] [ARM] clearpage: provide our own clear_user_highpage()
> 
> From: Russell King <rmk@dyn-67.arm.linux.org.uk>
> 
> For similar reasons as copy_user_page(), we want to avoid the
> additional kmap_atomic if it's unnecessary.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Acked-by: Hugh Dickins <hugh@veritas.com>

> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -63,12 +63,14 @@ static inline void *kmap_atomic(struct page *page, enum km_type idx)
>  #endif /* CONFIG_HIGHMEM */
>  
>  /* when CONFIG_HIGHMEM is not set these will be plain clear/copy_page */
> +#ifndef clear_user_highpage
>  static inline void clear_user_highpage(struct page *page, unsigned long vaddr)
>  {
>  	void *addr = kmap_atomic(page, KM_USER0);
>  	clear_user_page(addr, vaddr, page);
>  	kunmap_atomic(addr, KM_USER0);
>  }
> +#endif
>  
>  #ifndef __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
>  /**
> 
> ----- End forwarded message -----
> 
> ----- End forwarded message -----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
