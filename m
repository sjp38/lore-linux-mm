Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F32E6B0009
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 06:30:22 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k14so7360808wrc.14
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 03:30:22 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:8b0:10b:1236::1])
        by mx.google.com with ESMTPS id i136si2493807wme.39.2018.02.11.03.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 11 Feb 2018 03:30:21 -0800 (PST)
Date: Sun, 11 Feb 2018 03:28:08 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Regression after commit 19809c2da28a ("mm, vmalloc: use
 __GFP_HIGHMEM implicitly")
Message-ID: <20180211112808.GA4551@bombadil.infradead.org>
References: <627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com>
 <20180208130649.GA15846@bombadil.infradead.org>
 <20180208232004.GA21027@bombadil.infradead.org>
 <20180211092652.GV21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180211092652.GV21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kai Heng Feng <kai.heng.feng@canonical.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, Feb 11, 2018 at 10:26:52AM +0100, Michal Hocko wrote:
> On Thu 08-02-18 15:20:04, Matthew Wilcox wrote:
> > ... nevertheless, 19809c2da28a does in fact break vmalloc_32 on 32-bit.  Look:
> > 
> > #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
> > #define GFP_VMALLOC32 GFP_DMA32 | GFP_KERNEL
> > #elif defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA)
> > #define GFP_VMALLOC32 GFP_DMA | GFP_KERNEL
> > #else
> > #define GFP_VMALLOC32 GFP_KERNEL
> > #endif
> > 
> > So we pass in GFP_KERNEL to __vmalloc_node, which calls __vmalloc_node_range
> > which calls __vmalloc_area_node, which ORs in __GFP_HIGHMEM.
> 
> Dohh. I have missed this. I was convinced that we always add GFP_DMA32
> when doing vmalloc_32. Sorry about that. The above definition looks
> quite weird to be honest. First of all do we have any 64b system without
> both DMA and DMA32 zones? If yes, what is the actual semantic of
> vmalloc_32? Or is there any magic forcing GFP_KERNEL into low 32b?

mmzone.h has the following, which may be inaccurate / out of date:

         * parisc, ia64, sparc  <4G
         * s390                 <2G
         * arm                  Various
         * alpha                Unlimited or 0-16MB.
         *
         * i386, x86_64 and multiple other arches
         *                      <16M.

It claims ZONE_DMA32 is x86-64 only, which is incorrect; it's now used
by arm64, ia64, mips, powerpc, tile.

> Also I would expect that __GFP_DMA32 should do the right thing on 32b
> systems. So something like the below should do the trick

Oh, I see.  Because we have:

#ifdef CONFIG_ZONE_DMA32
#define OPT_ZONE_DMA32 ZONE_DMA32
#else
#define OPT_ZONE_DMA32 ZONE_NORMAL
#endif

we'll end up allocating from ZONE_NORMAL if a non-DMA32 architecture asks
for GFP_DMA32 memory.  Thanks; I missed that.

I'd recommend this instead then:

#if defined(CONFIG_64BIT) && !defined(CONFIG_ZONE_DMA32)
#define GFP_VMALLOC32 GFP_DMA | GFP_KERNEL
#else
#define GFP_VMALLOC32 GFP_DMA32 | GFP_KERNEL
#endif

I think it's clearer than the three-way #if.

Now, longer-term, perhaps we should do the following:

#ifdef CONFIG_ZONE_DMA32
#define OPT_ZONE_DMA32	ZONE_DMA32
#elif defined(CONFIG_64BIT)
#define OPT_ZONE_DMA	OPT_ZONE_DMA
#else
#define OPT_ZONE_DMA32 ZONE_NORMAL
#endif

Then we wouldn't need the ifdef here and could always use GFP_DMA32
| GFP_KERNEL.  Would need to audit current users and make sure they
wouldn't be broken by such a change.

I noticed a mistake in 704b862f9efd;

-               pages = __vmalloc_node(array_size, 1, nested_gfp|__GFP_HIGHMEM,
+               pages = __vmalloc_node(array_size, 1, nested_gfp|highmem_mask,

We should unconditionally use __GFP_HIGHMEM here instead of highmem_mask
because this is where we allocate the array to hold the struct page
pointers.  This can be allocated from highmem, and does not need to be
allocated from ZONE_NORMAL.

Similarly,

-               if (gfpflags_allow_blocking(gfp_mask))
+               if (gfpflags_allow_blocking(gfp_mask|highmem_mask))

is not needed (it's not *wrong*, it was just an unnecessary change).

> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 673942094328..2eab5d1ef548 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1947,7 +1947,8 @@ void *vmalloc_exec(unsigned long size)
>  #elif defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA)
>  #define GFP_VMALLOC32 GFP_DMA | GFP_KERNEL
>  #else
> -#define GFP_VMALLOC32 GFP_KERNEL
> +/* This should be only 32b systems */
> +#define GFP_VMALLOC32 GFP_DMA32 | GFP_KERNEL
>  #endif
>  
>  /**
> 
> -- 
> Michal Hocko
> SUSE Labs
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
