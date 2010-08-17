Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2B36B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 14:02:22 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o7HI2Jc3029271
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 11:02:19 -0700
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by hpaq13.eem.corp.google.com with ESMTP id o7HI2HLu002328
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 11:02:18 -0700
Received: by pxi19 with SMTP id 19so2677080pxi.30
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 11:02:17 -0700 (PDT)
Date: Tue, 17 Aug 2010 11:02:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q3 00/23] SLUB: The Unified slab allocator (V3)
In-Reply-To: <alpine.DEB.2.00.1008171217440.11915@router.home>
Message-ID: <alpine.DEB.2.00.1008171052500.6486@chino.kir.corp.google.com>
References: <20100804024514.139976032@linux.com> <alpine.DEB.2.00.1008032138160.20049@chino.kir.corp.google.com> <alpine.DEB.2.00.1008041115500.11084@router.home> <alpine.DEB.2.00.1008050136340.30889@chino.kir.corp.google.com> <alpine.DEB.2.00.1008051231400.6787@router.home>
 <alpine.DEB.2.00.1008151627450.27137@chino.kir.corp.google.com> <alpine.DEB.2.00.1008171217440.11915@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, Christoph Lameter wrote:

> > Ok, so this is panicking because of the error handling when trying to
> > create sysfs directories with the same name (in this case, :dt-0000064).
> > I'll look into while this isn't failing gracefully later, but I isolated
> > this to the new code that statically allocates the DMA caches in
> > kmem_cache_init_late().
> 
> Hmm.... Strange. The DMA caches should create a distinct pattern there.
> 

They do after patch 11 when you introduce dynamically sized kmalloc 
caches, but not after only patches 1-8 were applied.  Since this wasn't 
booting on my system, I bisected the problem to patch 8 where 
kmem_cache_init_late() would create two DMA caches of size 64 bytes: one 
becauses of kmalloc_caches[0] (kmem_cache_node) and one because of 
kmalloc_caches[6] (2^6 = 64).  So my fixes are necessary for patch 8 but 
obsoleted later, and then the shared cache support panics on memset().

> >  - the entire iteration in kmem_cache_init_late() needs to be protected by
> >    slub_lock.  The comment in create_kmalloc_cache() should be revised
> >    since you're no longer calling it only with irqs disabled.
> >    kmem_cache_init_late() has irqs enabled and, thus, slab_caches must be
> >    protected.
> 
> I moved it to kmem_cache_init() which is run when we only have one
> execution thread. That takes care of the issue and ensures that the dma
> caches are available as early as before.
> 

I didn't know if that was a debugging patch for me or if you wanted to 
push that as part of your series, I'm not sure if you actually need to 
move it to kmem_cache_init() now that slub_state is protected by 
slub_lock.  I'm not sure if we want to allocate DMA objects between 
kmem_cache_init() and kmem_cache_init_late().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
