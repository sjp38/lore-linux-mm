Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A2EA96B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 13:23:08 -0400 (EDT)
Date: Tue, 17 Aug 2010 12:23:04 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q3 00/23] SLUB: The Unified slab allocator (V3)
In-Reply-To: <alpine.DEB.2.00.1008151627450.27137@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008171217440.11915@router.home>
References: <20100804024514.139976032@linux.com> <alpine.DEB.2.00.1008032138160.20049@chino.kir.corp.google.com> <alpine.DEB.2.00.1008041115500.11084@router.home> <alpine.DEB.2.00.1008050136340.30889@chino.kir.corp.google.com> <alpine.DEB.2.00.1008051231400.6787@router.home>
 <alpine.DEB.2.00.1008151627450.27137@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 2010, David Rientjes wrote:

> Ok, so this is panicking because of the error handling when trying to
> create sysfs directories with the same name (in this case, :dt-0000064).
> I'll look into while this isn't failing gracefully later, but I isolated
> this to the new code that statically allocates the DMA caches in
> kmem_cache_init_late().

Hmm.... Strange. The DMA caches should create a distinct pattern there.

> The iteration runs from 0 to SLUB_PAGE_SHIFT; that's actually incorrect
> since the kmem_cache_node cache occupies the first spot in the
> kmalloc_caches array and has a size, 64 bytes, equal to a power of two
> that is duplicated later.  So this patch tries creating two DMA kmalloc
> caches with 64 byte object size which triggers a BUG_ON() during
> kmem_cache_release() in the error handling later.

The kmem_cache_node cache is no longer at position 0.
kmalloc_caches[0] should be NULL and therefore be skipped.

> The fix is to start the iteration at 1 instead of 0 so that all other
> caches have their equivalent DMA caches created and the special-case
> kmem_cache_node cache is excluded (see below).
>
> I'm really curious why nobody else ran into this problem before,
> especially if they have CONFIG_SLUB_DEBUG enabled so
> struct kmem_cache_node has the same size.  Perhaps my early bug report
> caused people not to test the series...

Which patches were applied?

>  - the entire iteration in kmem_cache_init_late() needs to be protected by
>    slub_lock.  The comment in create_kmalloc_cache() should be revised
>    since you're no longer calling it only with irqs disabled.
>    kmem_cache_init_late() has irqs enabled and, thus, slab_caches must be
>    protected.

I moved it to kmem_cache_init() which is run when we only have one
execution thread. That takes care of the issue and ensures that the dma
caches are available as early as before.

>  - a BUG_ON(!name) needs to be added in kmem_cache_init_late() when
>    kasprintf() returns NULL.  This isn't checked in kmem_cache_open() so
>    it'll only encounter a problem in the sysfs layer.  Adding a BUG_ON()
>    will help track those down.

Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
