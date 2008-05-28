Date: Wed, 28 May 2008 01:40:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] 2.6.26-rc: x86: pci-dma.c: use __GFP_NO_OOM instead of
 __GFP_NORETRY
Message-Id: <20080528014017.9b3d116f.akpm@linux-foundation.org>
In-Reply-To: <1211963485.28138.14.camel@localhost.localdomain>
References: <20080526234940.GA1376@xs4all.net>
	<20080527014720.6db68517.akpm@linux-foundation.org>
	<20080528024727.GB20824@one.firstfloor.org>
	<1211963485.28138.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miquel van Smoorenburg <mikevs@xs4all.net>
Cc: Andi Kleen <andi@firstfloor.org>, Glauber Costa <gcosta@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 28 May 2008 10:31:25 +0200 Miquel van Smoorenburg <mikevs@xs4all.net> wrote:

> > When the 16MB zone overflows (which can be common in some workloads)
> > calling the OOM killer is pretty useless because it has barely any 
> > real user data [only exception would be the "only 16MB" case Alan
> > mentioned]. Killing random processes in this case is bad. 
> > 
> > I think for 16MB __GFP_NORETRY is ok because there should be 
> > nothing freeable in there so looping is useless. Only exception would be the 
> > "only 16MB total" case again but I'm not sure 2.6 supports that at all
> > on x86.
> > 
> > On the other hand d_a_c() does more allocations than just 16MB, especially
> > on 64bit and the other zones need different strategies.
> 
> Okay, so how about this then ?
> 
> --- linux-2.6.26-rc4.orig/arch/x86/kernel/pci-dma.c	2008-05-26 20:08:11.000000000 +0200
> +++ linux-2.6.26-rc4/arch/x86/kernel/pci-dma.c	2008-05-28 10:27:41.000000000 +0200
> @@ -397,9 +397,6 @@
>  	if (dev->dma_mask == NULL)
>  		return NULL;
>  
> -	/* Don't invoke OOM killer */
> -	gfp |= __GFP_NORETRY;
> -
>  #ifdef CONFIG_X86_64
>  	/* Why <=? Even when the mask is smaller than 4GB it is often
>  	   larger than 16MB and in this case we have a chance of
> @@ -410,7 +407,9 @@
>  #endif
>  
>   again:
> -	page = dma_alloc_pages(dev, gfp, get_order(size));
> +	/* Don't invoke OOM killer or retry in lower 16MB DMA zone */
> +	page = dma_alloc_pages(dev,
> +		(gfp & GFP_DMA) ? gfp | __GFP_NORETRY : gfp, get_order(size));
>  	if (page == NULL)
>  		return NULL;

I guess that's more specifally solving that-which-we-wish-to-solve.

Formally we should be testing __GFP_DMA here, not GFP_DMA - just the
zone selector field.  They're presently equal, but someone could
legitimately come along and do

#define GFP_DMA (__GFP_DMA|__GFP_HIGH)

or similar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
