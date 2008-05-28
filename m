Date: Wed, 28 May 2008 14:54:01 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] 2.6.26-rc: x86: pci-dma.c: use __GFP_NO_OOM instead of __GFP_NORETRY
Message-ID: <20080528125401.GC20824@one.firstfloor.org>
References: <20080526234940.GA1376@xs4all.net> <20080527014720.6db68517.akpm@linux-foundation.org> <20080528024727.GB20824@one.firstfloor.org> <1211963485.28138.14.camel@localhost.localdomain> <20080528014017.9b3d116f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080528014017.9b3d116f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miquel van Smoorenburg <mikevs@xs4all.net>, Andi Kleen <andi@firstfloor.org>, Glauber Costa <gcosta@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> > -	page = dma_alloc_pages(dev, gfp, get_order(size));
> > +	/* Don't invoke OOM killer or retry in lower 16MB DMA zone */
> > +	page = dma_alloc_pages(dev,
> > +		(gfp & GFP_DMA) ? gfp | __GFP_NORETRY : gfp, get_order(size));
> >  	if (page == NULL)
> >  		return NULL;
> 
> I guess that's more specifally solving that-which-we-wish-to-solve.

Then the allocator could still be stuck in ZONE_DMA32 on 64bit.

Also d_a_c() does one "speculative" allocation, as in an allocation
where it knows the zone is too large for the mask but it tries anyways
because it often works. In that case too much trying is also not good.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
