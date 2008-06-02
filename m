Date: Mon, 2 Jun 2008 12:15:47 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] 2.6.26-rc: x86: pci-dma.c: use __GFP_NO_OOM instead of
	__GFP_NORETRY
Message-ID: <20080602101547.GD7459@elte.hu>
References: <20080526234940.GA1376@xs4all.net> <20080527014720.6db68517.akpm@linux-foundation.org> <20080528024727.GB20824@one.firstfloor.org> <1211963485.28138.14.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1211963485.28138.14.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miquel van Smoorenburg <mikevs@xs4all.net>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <gcosta@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Miquel van Smoorenburg <mikevs@xs4all.net> wrote:

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

applied to tip/pci-for-jesse for more testing. Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
