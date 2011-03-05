Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BE86B8D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 16:38:33 -0500 (EST)
Subject: Re: [RFC] memblock; Properly handle overlaps
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <4D728B8C.2080803@kernel.org>
References: <1299297946.8833.931.camel@pasglop>
	 <4D71CE24.1090302@kernel.org> <1299311788.8833.937.camel@pasglop>
	 <4D728B8C.2080803@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 06 Mar 2011 08:37:43 +1100
Message-ID: <1299361063.8833.953.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H.
 Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>

On Sat, 2011-03-05 at 11:14 -0800, Yinghai Lu wrote:
> On 03/04/2011 11:56 PM, Benjamin Herrenschmidt wrote:
> >>
> >> did you try remove and add tricks?
> > 
> > Yes, and it's a band-wait on top of a wooden leg... (didn't even work
> > properly for some real cases I hit with bad FW data, ended up with two
> > regions once reserving a portion of the previous one). It doesn't take
> > long starting at the implementation of remove() to understand why :-)
> > 
> > Also, if something like that happens, you expose yourself to rampant
> > corruption and other very hard to debug problems, because nothing will
> > tell you that the array is corrupted (no longer a monotonic progression)
> > and you might get overlapping allocations, allocations spanning reserved
> > regions etc... all silently.
> > 
> > I think the whole thing was long overdue for an overhaul. Hopefully, my
> > new code is -much- more robust under all circumstances of full overlap,
> > partial overlap, freeing entire regions with multiple blocks in them or
> > reserving regions with multiple holes, etc...
> > 
> > Note that my patch really only rewrite those two low level functions
> > (add and remove of a region to a list), so it's reasonably contained and
> > should be easy to audit.
> > 
> > I want to spend a bit more time next week throwing at my userspace
> > version some nasty test cases involving non-coalesce boundaries, and
> > once that's done, and unless I have some massive bug I haven't seen, I
> > think we should just merge the patch.
> 
> please check changes on top your patch regarding memblock_add_region

Can you reply inline next to the respective code ? It would make things
easier :-)

> 1. after check with bottom, we need to update the size. otherwise when we
> checking with top, we could use wrong size, and increase to extra big.

You mean adding this ?

			/* We continue processing from the end of the
			 * coalesced block.
			 */
			base = rgn->base + rgn->size;
+ 			size = end - base;

I suppose you are right. Interestingly enough I haven't trigged that in
my tests, I'll add an specific scenario to trigger that problem.

> 2. before we calling memblock_remove_region() in the loop, it could render
> blank array. So need to move the special case handle down.

I'm not sure I understand what you mean here.

The blank array always has a count of 1, so memblock_remove_region()
should be safe to call at any time. I can see how __memblock_remove()
can hit the case of a blank array but that seems harmless to me.

Thanks.

Ben.

> Thanks
> 
> Yinghai
> 
> ---
>  mm/memblock.c |   32 +++++++++++++++++++-------------
>  1 file changed, 19 insertions(+), 13 deletions(-)
> 
> Index: linux-2.6/mm/memblock.c
> ===================================================================
> --- linux-2.6.orig/mm/memblock.c
> +++ linux-2.6/mm/memblock.c
> @@ -279,15 +279,6 @@ static long __init_memblock memblock_add
>  	phys_addr_t end = base + size;
>  	long i;
>  
> -	/* If the array is empty, special case, replace the fake
> -	 * filler region and return
> -	 */
> -	if ((type->cnt == 1) && (type->regions[0].size == 0)) {
> -		type->regions[0].base = base;
> -		type->regions[0].size = size;
> -		return 0;
> -	}
> -
>  	/* First try and coalesce this MEMBLOCK with others */
>  	for (i = 0; i < type->cnt; i++) {
>  		struct memblock_region *rgn = &type->regions[i];
> @@ -330,11 +321,17 @@ static long __init_memblock memblock_add
>  			 * coalesced block.
>  			 */
>  			base = rgn->base + rgn->size;
> -		}
>  
> -		/* Check if e have nothing else to allocate (fully coalesced) */
> -		if (base >= end)
> -			return 0;
> +			/*
> +			 * Check if We have nothing else to allocate
> +			 * (fully coalesced)
> +			 */
> +			if (base >= end)
> +				return 0;
> +
> +			/* Update left over size */
> +			size = end - base;
> +		}
>  
>  		/* Now check if we overlap or are adjacent with the
>  		 * top of a block
> @@ -360,6 +357,15 @@ static long __init_memblock memblock_add
>  		}
>  	}
>  
> +	/* If the array is empty, special case, replace the fake
> +	 * filler region and return
> +	 */
> +	if ((type->cnt == 1) && (type->regions[0].size == 0)) {
> +		type->regions[0].base = base;
> +		type->regions[0].size = size;
> +		return 0;
> +	}
> +
>   new_block:
>  	/* If we are out of space, we fail. It's too late to resize the array
>  	 * but then this shouldn't have happened in the first place.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
