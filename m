Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BB6466B0082
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 04:39:46 -0400 (EDT)
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1244792745.30512.13.camel@penberg-laptop>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>
	 <1244770230.7172.4.camel@pasglop>  <1244779009.7172.52.camel@pasglop>
	 <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop>
	 <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
	 <1244792079.7172.74.camel@pasglop>
	 <1244792745.30512.13.camel@penberg-laptop>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 18:40:45 +1000
Message-Id: <1244796045.7172.82.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-12 at 10:45 +0300, Pekka Enberg wrote:
> Hi Ben,

> The call-sites I fixed up are all boot code AFAICT. And I like I said,
> we can't really _miss_ any of those places, they must be checking for
> slab_is_available() _anyway_; otherwise they have no business using
> kmalloc(). And note: all call-sites that _unconditionally_ use
> kmalloc(GFP_KERNEL) are safe because they worked before.

No. The check for slab_is_available() can be levels higher, for example
the vmalloc case. I'm sure I can find a whole bunch more :-) Besides
I find the approach fragile, and it will suck for things that can be
rightfully called also later on.

> Again, I audited the call-sites and they all should be boot-time code.
> The only borderline case I could see is in s390 arch code which is why I
> droppped that hunk for now.

And the vmalloc case, and some page table handling code in arch/powerpc,
and I'm sure we can find bazillion of them more if we look closely.

> Sure, I think we can do what you want with the patch below.
> 
> But I still think we need my patch regardless. The call sites I
> converted are all init code and should be using GFP_NOWAIT. Does it fix
> your boot on powerpc?

Not all init code needs to call GFP_NOWAIT. But again, my main worry
isn't necessary init code call sites, it's things that can themselves be
called from both init and later.

But to get a step back, I do prefer not having to bother in every call
site. It seems a lot more natural to me in this case to have the
allocator itself degrade, avoiding the burden on the callers, the risk
of error, the damage when we change and move things around etc...

Cheers,
Ben.

> 			Pekka
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 9a90b00..722beb5 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2791,6 +2791,13 @@ static int cache_grow(struct kmem_cache *cachep,
>  
>  	offset *= cachep->colour_off;
>  
> +	/*
> +	 * Lets not wait if we're booting up or suspending even if the user
> +	 * asks for it.
> +	 */
> +	if (system_state != SYSTEM_RUNNING)
> +		local_flags &= ~__GFP_WAIT;
> +
>  	if (local_flags & __GFP_WAIT)
>  		local_irq_enable();
>  
> diff --git a/mm/slub.c b/mm/slub.c
> index 65ffda5..f9a6bc8 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1547,6 +1547,13 @@ new_slab:
>  		goto load_freelist;
>  	}
>  
> +	/*
> +	 * Lets not wait if we're booting up or suspending even if the user
> +	 * asks for it.
> +	 */
> +	if (system_state != SYSTEM_RUNNING)
> +		gfpflags &= ~__GFP_WAIT;
> +
>  	if (gfpflags & __GFP_WAIT)
>  		local_irq_enable();
>  
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
