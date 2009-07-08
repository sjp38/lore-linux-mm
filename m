Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7727D6B0062
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 05:39:53 -0400 (EDT)
Date: Wed, 8 Jul 2009 11:46:44 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 2/3] kmemleak: Add callbacks to the bootmem allocator
Message-ID: <20090708094643.GA1956@cmpxchg.org>
References: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com> <20090706105155.16051.59597.stgit@pc1117.cambridge.arm.com> <1246950530.24285.7.camel@penberg-laptop> <20090707165350.GA2782@cmpxchg.org> <1247004586.5710.16.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1247004586.5710.16.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 11:09:46PM +0100, Catalin Marinas wrote:

> It seems that alloc_bootmem_core() is central to all the bootmem
> allocations. Is it OK to place the kmemleak_alloc hook only in this
> function?
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 5a649a0..74cbb34 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -520,6 +520,7 @@ find_block:
>  		region = phys_to_virt(PFN_PHYS(bdata->node_min_pfn) +
>  				start_off);
>  		memset(region, 0, size);
> +		kmemleak_alloc(region, size, 1, 0);
>  		return region;
>  	}

Yes, that should work.

> > > > +	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
> > 
> > These GFP_KERNEL startled me.  We know for sure that this code runs in
> > earlylog mode only and gfp is unused, right?  Can you perhaps just
> > pass 0 for gfp instead?
> 
> Yes, indeed.

Thank you.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
