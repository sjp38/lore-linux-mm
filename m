Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 333756B00B9
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 13:06:09 -0400 (EDT)
Date: Mon, 27 Apr 2009 19:04:28 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] MM: Rewrite some tests with is_power_of_2() for clarity.
Message-ID: <20090427170428.GA1890@cmpxchg.org>
References: <alpine.LFD.2.00.0904240834270.22152@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0904240834270.22152@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: "Robert P. J. Day" <rpjday@crashcourse.ca>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 24, 2009 at 08:46:15AM -0400, Robert P. J. Day wrote:
> 
> Replace some conditional tests with the semantically clearer call to
> is_power_of_2().
> 
> Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
>
> ---
> 
>   there are other tests of the form "n & (n - 1)" in mm/, but they are
> testing for single bitness so they should be left alone.
> 
>   compile-tested on x86_64 with "make defconfig".
> 
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index daf9271..5b379c2 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -12,6 +12,7 @@
>  #include <linux/pfn.h>
>  #include <linux/bootmem.h>
>  #include <linux/module.h>
> +#include <linux/log2.h>
> 
>  #include <asm/bug.h>
>  #include <asm/io.h>
> @@ -438,7 +439,7 @@ static void * __init alloc_bootmem_core(struct bootmem_data *bdata,
>  		align, goal, limit);
> 
>  	BUG_ON(!size);
> -	BUG_ON(align & (align - 1));
> +	BUG_ON(!is_power_of_2(align));

Note that this is no 1:1 translation.  align could be zero before but
not anymore.  Have you checked whether all callsites are ready for
this?  The common bootmem macros use alignment to cacheline or page
boundary.  I haven't checked all callsites that might use __api,
though.

OTOH, it's doubtful that 'no alignment' should be expressed as 0
instead of 1.

Still, it probably makes sense to express this change in semantics in
the changelog.

> diff --git a/mm/slub.c b/mm/slub.c
> index 7ab54ec..640831a 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -26,6 +26,7 @@
>  #include <linux/memory.h>
>  #include <linux/math64.h>
>  #include <linux/fault-inject.h>
> +#include <linux/log2.h>
> 
>  /*
>   * Lock order:
> @@ -3056,7 +3057,7 @@ void __init kmem_cache_init(void)
>  	 * around with ARCH_KMALLOC_MINALIGN
>  	 */
>  	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
> -		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
> +		(!is_power_of_2(KMALLOC_MIN_SIZE)));

Maybe you can remove the parens here.  But that's probably optional.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
