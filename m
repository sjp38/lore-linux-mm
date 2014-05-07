Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7E28F6B0068
	for <linux-mm@kvack.org>; Wed,  7 May 2014 17:29:28 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id v10so1515022pde.13
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:29:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id hs1si2502332pbc.478.2014.05.07.14.29.27
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 14:29:27 -0700 (PDT)
Date: Wed, 7 May 2014 14:29:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, slab: suppress out of memory warning unless debug
 is enabled
Message-Id: <20140507142925.b0e31514d4cd8d5857b10850@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1405071418410.8389@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405071418410.8389@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 May 2014 14:19:19 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> When the slab or slub allocators cannot allocate additional slab pages, they 
> emit diagnostic information to the kernel log such as current number of slabs, 
> number of objects, active objects, etc.  This is always coupled with a page 
> allocation failure warning since it is controlled by !__GFP_NOWARN.
> 
> Suppress this out of memory warning if the allocator is configured without debug 
> supported.  The page allocation failure warning will indicate it is a failed 
> slab allocation, so this is only useful to diagnose allocator bugs.
> 
> Since CONFIG_SLUB_DEBUG is already enabled by default for the slub allocator, 
> there is no functional change with this patch.  If debug is disabled, however, 
> the warnings are now suppressed.
> 

I'm not seeing any reason for making this change.

> @@ -1621,11 +1621,17 @@ __initcall(cpucache_init);
>  static noinline void
>  slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
>  {
> +#if DEBUG
>  	struct kmem_cache_node *n;
>  	struct page *page;
>  	unsigned long flags;
>  	int node;
>  
> +	if (gfpflags & __GFP_NOWARN)
> +		return;
> +	if (!printk_ratelimit())
> +		return;

printk_ratelimit() is lame - it uses a single global state.  So if
random net driver is using printk_ratelimit(), that driver and slab
will interfere with each other.

We don't appear to presently have a handy macro to do this properly -
you might care to add one and switch printk_ratelimited() and
pr_debug_ratelimited() over to using it.  And various sites in
include/linux/device.h, I guess.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
