Date: Tue, 11 Mar 2008 18:35:40 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/13] General DMA zone rework
Message-ID: <20080311173540.GG27593@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <20080307175148.3a49d8d3@mandriva.com.br> <20080308004654.GQ7365@one.firstfloor.org> <20080310150316.752e4489@mandriva.com.br> <20080310180843.GC28780@one.firstfloor.org> <20080311142624.1dbd3af5@mandriva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080311142624.1dbd3af5@mandriva.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 11, 2008 at 02:26:24PM -0300, Luiz Fernando N. Capitulino wrote:
> ===================================================================
> --- linux-2.6.24.orig/sound/core/memalloc.c
> +++ linux-2.6.24/sound/core/memalloc.c
> @@ -218,7 +218,6 @@ static void *snd_malloc_dev_pages(struct
>  	snd_assert(dma != NULL, return NULL);
>  	pg = get_order(size);
>  	gfp_flags = GFP_KERNEL
> -		| __GFP_COMP	/* compound page lets parts be mapped */

Oops. Thanks. I'll double check that. mask allocator indeed doesn't
handle __GFP_COMP and nobody should be passing that into dma_alloc_coherent
anyways. But the bug you got was for the small size wasn't it?

>  		| __GFP_NORETRY /* don't trigger OOM-killer */
>  		| __GFP_NOWARN; /* no stack trace print - this call is non-critical */
>  	res = dma_alloc_coherent(dev, PAGE_SIZE << pg, dma, gfp_flags);
> """
> 
>  Also, I think you forgot to protect the __free_pages_mask()
> call with "#ifdef CONFIG_MASK_ALLOC" in patch mask-compat.

PageMaskAlloc() returns constant 0 in this case so the compiler should e
liminate it.

> 
>  Question: let's say that the devices I have consumes only
> 5MB of the whole reserved pool (16MB), of course that it's

It's likely less than 16MB because there are already some users in there
like the kernel text. The default sizing without swiotlb just grabs anything 
left over up to the 16Mb boundary.

> ok to reduce the pool to 5MB, right?

Yes, but not leaving any free over is a little risky, someone might need
more later. But e.g. going down to 8-9MB would be likely possible.

The long term plan (but that is some time off and a little vague still) 
would be to let the various subsystem size the mask zone dynamically for 
their need.

Then especially on 64bit swiotlb machines who allocate 64MB by default
for swiotlb that would save significant memory.

> 
>  I have more machines to test this stuff...

Thanks. Keep me posted.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
