Date: Tue, 3 Jul 2007 23:47:46 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: [PATCH] Re: Sparc32: random invalid instruction occourances on
 sparc32 (sun4c)
In-Reply-To: <1183499781.29081.46.camel@shinybook.infradead.org>
Message-ID: <Pine.LNX.4.61.0707032317590.30376@mtfhpc.demon.co.uk>
References: <468A7D14.1050505@googlemail.com>  <Pine.LNX.4.61.0707031817050.29930@mtfhpc.demon.co.uk>
  <Pine.LNX.4.61.0707031910280.29930@mtfhpc.demon.co.uk>
 <1183490778.29081.35.camel@shinybook.infradead.org>
 <Pine.LNX.4.61.0707032209230.30376@mtfhpc.demon.co.uk>
 <1183499781.29081.46.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, David Miller <davem@davemloft.net>, Christoph Lameter <clameter@engr.sgi.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hi David,

I will try out your patch shortly.

On Tue, 3 Jul 2007, David Woodhouse wrote:

> On Tue, 2007-07-03 at 22:25 +0100, Mark Fortescue wrote:
>> The problem is that sun4c Sparc32 can't handle un-aligned variables so
>> having a 64bit readzone word that is not aligned on a 64bit boundary is a
>> problem.
>
> Surely, it can. You just have to tell the compiler that it's not
> properly aligned, and it'll emit code to cope. Hence the suggestion that
> you use 'unsigned long long __attribute__((aligned(BYTES_PER_WORD))'.
> But it's probably better just to make sure it remains aligned; you're
> right.
>
>> In addition, having looked at the size calculations, it looks to me as if
>> not all of them got updated to handle 64bit redzone words.
>
> Really? Other than the alignment of the second redzone, what's wrong?
> Remember that the 'user word' is still not necessarily 64-bit. And in
> fact I suspect that's what is causing the problem -- your object _size_
> will be aligned to 8 bytes, including the user word, and then we look
> for the second redzone word 12 bytes before the end of the object.
>

Yes, the user word is a 32bit word and this is part of the issue.

I may be wrong about the size calculations but if you take a look at lines 
2174 to 2188 and 2207 to 2203, reading the comments suggest to me that 
these need to be changed to match the changes to the RedZone words. 
Failing to change these means that 32bit aligned access of the 64bit 
RedZone words is still posible and this will kill sun4c.

For the 64bit RedZone word to be 64bit aligned (required by sun4c), the 
User word must be 64bit aligned. I don't see where in your patch, this is 
enforced.

> Does this fix it?
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 6d65cf4..3b15671 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -547,7 +547,7 @@ static unsigned long long *dbg_redzone2(struct kmem_cache *cachep, void *objp)
> 	if (cachep->flags & SLAB_STORE_USER)
> 		return (unsigned long long *)(objp + cachep->buffer_size -
> 					      sizeof(unsigned long long) -
> -					      BYTES_PER_WORD);
> +					      max(BYTES_PER_WORD, __alignof__(unsigned long long)));
> 	return (unsigned long long *) (objp + cachep->buffer_size -
> 				       sizeof(unsigned long long));
> }
> @@ -2262,9 +2262,14 @@ kmem_cache_create (const char *name, size_t size, size_t align,
> 	}
> 	if (flags & SLAB_STORE_USER) {
> 		/* user store requires one word storage behind the end of
> -		 * the real object.
> +		 * the real object. But if the second red zone must be
> +		 * aligned 'better' than that, allow for it.
> 		 */
> -		size += BYTES_PER_WORD;
> +		if (flags & SLAB_RED_ZONE
> +		    && BYTES_PER_WORD < __alignof__(unsigned long long))
> +			size += __alignof__(unsigned long long);
> +		else
> +			size += BYTES_PER_WORD;
> 	}
> #if FORCED_DEBUG && defined(CONFIG_DEBUG_PAGEALLOC)
> 	if (size >= malloc_sizes[INDEX_L3 + 1].cs_size
>
>
> -- 
> dwmw2
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
