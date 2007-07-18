Date: Tue, 17 Jul 2007 23:33:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmalloc_32 should use GFP_KERNEL
Message-Id: <20070717233358.2edeaac0.akpm@linux-foundation.org>
In-Reply-To: <1184739934.25235.220.camel@localhost.localdomain>
References: <1184739934.25235.220.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Dave Airlie <airlied@gmail.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jul 2007 16:25:34 +1000 Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> I've noticed lots of failures of vmalloc_32 on machines where it
> shouldn't have failed unless it was doing an atomic operation.
> 
> Looking closely, I noticed that:
> 
> #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
> #define GFP_VMALLOC32 GFP_DMA32
> #elif defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA)
> #define GFP_VMALLOC32 GFP_DMA
> #else
> #define GFP_VMALLOC32 GFP_KERNEL
> #endif
> 
> Which seems to be incorrect, it should always -or- in the DMA flags
> on top of GFP_KERNEL, thus this patch.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 
> This fixes frequent errors launchin X with the nouveau DRM for example.
> 
> Index: linux-work/mm/vmalloc.c
> ===================================================================
> --- linux-work.orig/mm/vmalloc.c	2007-07-18 16:22:00.000000000 +1000
> +++ linux-work/mm/vmalloc.c	2007-07-18 16:22:11.000000000 +1000
> @@ -578,9 +578,9 @@ void *vmalloc_exec(unsigned long size)
>  }
>  
>  #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
> -#define GFP_VMALLOC32 GFP_DMA32
> +#define GFP_VMALLOC32 GFP_DMA32 | GFP_KERNEL
>  #elif defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA)
> -#define GFP_VMALLOC32 GFP_DMA
> +#define GFP_VMALLOC32 GFP_DMA | GFP_KERNEL
>  #else
>  #define GFP_VMALLOC32 GFP_KERNEL
>  #endif
> 

whoops, yes.

Are those errors serious and common enough for 2.6.22.x?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
