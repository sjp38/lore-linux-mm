Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ADF108D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 16:50:52 -0500 (EST)
Subject: Re: [RFC] memblock; Properly handle overlaps
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1299361063.8833.953.camel@pasglop>
References: <1299297946.8833.931.camel@pasglop>
	 <4D71CE24.1090302@kernel.org> <1299311788.8833.937.camel@pasglop>
	 <4D728B8C.2080803@kernel.org>  <1299361063.8833.953.camel@pasglop>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 06 Mar 2011 08:50:19 +1100
Message-ID: <1299361819.8833.954.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H.
 Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>


> Can you reply inline next to the respective code ? It would make things
> easier :-)
> 
> > 1. after check with bottom, we need to update the size. otherwise when we
> > checking with top, we could use wrong size, and increase to extra big.
> 
> You mean adding this ?
> 
> 			/* We continue processing from the end of the
> 			 * coalesced block.
> 			 */
> 			base = rgn->base + rgn->size;
> + 			size = end - base;
> 
> I suppose you are right. Interestingly enough I haven't trigged that in
> my tests, I'll add an specific scenario to trigger that problem.
> 
> > 2. before we calling memblock_remove_region() in the loop, it could render
> > blank array. So need to move the special case handle down.
> 
> I'm not sure I understand what you mean here.
> 
> The blank array always has a count of 1, so memblock_remove_region()
> should be safe to call at any time. I can see how __memblock_remove()
> can hit the case of a blank array but that seems harmless to me.

Ok, I see there is indeed a problem as we do an i-- in this case and so
end up in an infinite loop trying to remove the fake entry. I'll fix
that too. Thanks.

Cheers,
Ben.

> Thanks.
> 
> Ben.
> 
> > Thanks
> > 
> > Yinghai
> > 
> > ---
> >  mm/memblock.c |   32 +++++++++++++++++++-------------
> >  1 file changed, 19 insertions(+), 13 deletions(-)
> > 
> > Index: linux-2.6/mm/memblock.c
> > ===================================================================
> > --- linux-2.6.orig/mm/memblock.c
> > +++ linux-2.6/mm/memblock.c
> > @@ -279,15 +279,6 @@ static long __init_memblock memblock_add
> >  	phys_addr_t end = base + size;
> >  	long i;
> >  
> > -	/* If the array is empty, special case, replace the fake
> > -	 * filler region and return
> > -	 */
> > -	if ((type->cnt == 1) && (type->regions[0].size == 0)) {
> > -		type->regions[0].base = base;
> > -		type->regions[0].size = size;
> > -		return 0;
> > -	}
> > -
> >  	/* First try and coalesce this MEMBLOCK with others */
> >  	for (i = 0; i < type->cnt; i++) {
> >  		struct memblock_region *rgn = &type->regions[i];
> > @@ -330,11 +321,17 @@ static long __init_memblock memblock_add
> >  			 * coalesced block.
> >  			 */
> >  			base = rgn->base + rgn->size;
> > -		}
> >  
> > -		/* Check if e have nothing else to allocate (fully coalesced) */
> > -		if (base >= end)
> > -			return 0;
> > +			/*
> > +			 * Check if We have nothing else to allocate
> > +			 * (fully coalesced)
> > +			 */
> > +			if (base >= end)
> > +				return 0;
> > +
> > +			/* Update left over size */
> > +			size = end - base;
> > +		}
> >  
> >  		/* Now check if we overlap or are adjacent with the
> >  		 * top of a block
> > @@ -360,6 +357,15 @@ static long __init_memblock memblock_add
> >  		}
> >  	}
> >  
> > +	/* If the array is empty, special case, replace the fake
> > +	 * filler region and return
> > +	 */
> > +	if ((type->cnt == 1) && (type->regions[0].size == 0)) {
> > +		type->regions[0].base = base;
> > +		type->regions[0].size = size;
> > +		return 0;
> > +	}
> > +
> >   new_block:
> >  	/* If we are out of space, we fail. It's too late to resize the array
> >  	 * but then this shouldn't have happened in the first place.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
