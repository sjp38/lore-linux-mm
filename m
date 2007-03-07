Subject: Re: [SLUB 2/3] Large kmalloc pass through. Removal of large
	general slabs
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070307023513.19658.81228.sendpatchset@schroedinger.engr.sgi.com>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
	 <20070307023513.19658.81228.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 07 Mar 2007 10:01:17 +0100
Message-Id: <1173258077.6374.120.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-03-06 at 18:35 -0800, Christoph Lameter wrote:
> Unlimited kmalloc size and removal of general caches >=4.
> 
> We can directly use the page allocator for all allocations 4K and larger. This
> means that no general slabs are necessary and the size of the allocation passed
> to kmalloc() can be arbitrarily large. Remove the useless general caches over 4k.
> 

> Index: linux-2.6.21-rc2-mm1/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.21-rc2-mm1.orig/include/linux/slub_def.h	2007-03-06 17:56:14.000000000 -0800
> +++ linux-2.6.21-rc2-mm1/include/linux/slub_def.h	2007-03-06 17:57:11.000000000 -0800
> @@ -55,7 +55,7 @@ struct kmem_cache {
>   */
>  #define KMALLOC_SHIFT_LOW 3
>  
> -#define KMALLOC_SHIFT_HIGH 18
> +#define KMALLOC_SHIFT_HIGH 11
>  
>  #if L1_CACHE_BYTES <= 64
>  #define KMALLOC_EXTRAS 2
> @@ -93,13 +93,6 @@ static inline int kmalloc_index(int size
>  	if (size <=  512) return 9;
>  	if (size <= 1024) return 10;
>  	if (size <= 2048) return 11;
> -	if (size <= 4096) return 12;
> -	if (size <=   8 * 1024) return 13;
> -	if (size <=  16 * 1024) return 14;
> -	if (size <=  32 * 1024) return 15;
> -	if (size <=  64 * 1024) return 16;
> -	if (size <= 128 * 1024) return 17;
> -	if (size <= 256 * 1024) return 18;
>  	return -1;
>  }

Perhaps so something with PAGE_SIZE here, as you know there are
platforms/configs where PAGE_SIZE != 4k :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
