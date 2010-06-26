Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DEA9A6B01B6
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 19:39:05 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o5QNd1OJ018220
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:39:01 -0700
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by wpaz24.hot.corp.google.com with ESMTP id o5QNd0lg026708
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:39:00 -0700
Received: by pwi10 with SMTP id 10so685443pwi.6
        for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:38:59 -0700 (PDT)
Date: Sat, 26 Jun 2010 16:38:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
In-Reply-To: <20100625212106.384650677@quilx.com>
Message-ID: <alpine.DEB.2.00.1006261636000.27174@chino.kir.corp.google.com>
References: <20100625212026.810557229@quilx.com> <20100625212106.384650677@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, tj@kernel.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010, Christoph Lameter wrote:

> allocpercpu() may be used during early boot after the page allocator
> has been bootstrapped but when interrupts are still off. Make sure
> that we do not do GFP_KERNEL allocations if this occurs.
> 

Why isn't this being handled at a lower level, specifically in the slab 
allocator to prevent GFP_KERNEL from being used when irqs are disabled?  
We'll otherwise need to audit all slab allocations from the boot cpu for 
correctness.

> Cc: tj@kernel.org
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  mm/percpu.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/mm/percpu.c
> ===================================================================
> --- linux-2.6.orig/mm/percpu.c	2010-06-23 14:43:54.000000000 -0500
> +++ linux-2.6/mm/percpu.c	2010-06-23 14:44:05.000000000 -0500
> @@ -275,7 +275,8 @@ static void __maybe_unused pcpu_next_pop
>   * memory is always zeroed.
>   *
>   * CONTEXT:
> - * Does GFP_KERNEL allocation.
> + * Does GFP_KERNEL allocation (May be called early in boot when
> + * interrupts are still disabled. Will then do GFP_NOWAIT alloc).
>   *
>   * RETURNS:
>   * Pointer to the allocated area on success, NULL on failure.
> @@ -286,7 +287,7 @@ static void *pcpu_mem_alloc(size_t size)
>  		return NULL;
>  
>  	if (size <= PAGE_SIZE)
> -		return kzalloc(size, GFP_KERNEL);
> +		return kzalloc(size, GFP_KERNEL & gfp_allowed_mask);
>  	else {
>  		void *ptr = vmalloc(size);
>  		if (ptr)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
