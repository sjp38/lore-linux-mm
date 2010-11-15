Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7AFCE8D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 16:29:05 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id oAFLSwOF009898
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 13:28:58 -0800
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by kpbe20.cbf.corp.google.com with ESMTP id oAFLSvw2008678
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 13:28:57 -0800
Received: by pvh11 with SMTP id 11so1469935pvh.18
        for <linux-mm@kvack.org>; Mon, 15 Nov 2010 13:28:56 -0800 (PST)
Date: Mon, 15 Nov 2010 13:28:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
In-Reply-To: <1289840500.13446.65.camel@oralap>
Message-ID: <alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
References: <1289421759.11149.59.camel@oralap> <20101111120643.22dcda5b.akpm@linux-foundation.org> <1289512924.428.112.camel@oralap> <20101111142511.c98c3808.akpm@linux-foundation.org> <1289840500.13446.65.camel@oralap>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 2010, Ricardo M. Correia wrote:

> When __vmalloc() / __vmalloc_area_node() calls map_vm_area(), the latter can
> allocate pages with GFP_KERNEL despite the caller of __vmalloc having requested
> a more strict gfp mask.
> 
> We fix this by introducing a per-thread gfp_mask, similar to gfp_allowed_mask
> but which only applies to the current thread. __vmalloc_area_node() will now
> temporarily restrict the per-thread gfp_mask when it calls map_vm_area().
> 
> This new per-thread gfp mask may also be used for other useful purposes, for
> example, after thread creation, to make sure that certain threads
> (e.g. filesystem I/O threads) never allocate memory with certain flags (e.g.
> __GFP_FS or __GFP_IO).

I dislike this approach not only for its performance degradation in core 
areas like the page and slab allocators, but also because it requires full 
knowledge of the callchain to determine the gfp flags of the allocation.  
This will become nasty very quickly.

This proposal essentially defines an entirely new method for passing gfp 
flags to the page allocator when it isn't strictly needed.  I think the 
problem you're addressing can be done in one of two ways:

 - create lower-level functions in each arch that pass a gfp argument to 
   the allocator rather than hard-coded GFP_KERNEL, or

 - avoid doing anything other than GFP_KERNEL allocations for __vmalloc():
   the only current users are gfs2, ntfs, and ceph (the page allocator
   __vmalloc() can be discounted since it's done at boot and GFP_ATOMIC
   here has almost no chance of failing since the size is determined based 
   on what is available).

The first option really addresses the bug that you're running into and can 
be addressed in a relatively simple way by redefining current users of 
pmd_alloc_one(), for instance, as a form of a new lower-level 
__pmd_alloc_one():

	static inline pmd_t *__pmd_alloc_one(struct mm_struct *mm,
					unsigned long addr, gfp_t flags)
	{
        	return (pmd_t *)get_zeroed_page(flags);
	}

	static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
	{
        	return __pmd_alloc_one(GFP_KERNEL|__GFP_REPEAT);
	}

and then using __pmd_alloc_one() in the vmalloc path with the passed mask 
rather than pmd_alloc_one().  This _will_ be slightly intrusive because it 
will require fixing up some short callchains to pass the appropriate mask, 
that will be limited to the vmalloc code and arch code that currently does 
unconditional GFP_KERNEL allocations.  Both are bugs that you'll be 
addressing for each architecture, so the intrusiveness of that change has 
merit (and be sure to cc linux-arch@vger.kernel.org on it as well).

I only mention the second option because passing GFP_NOFS to __vmalloc() 
for sufficiently large sizes has a much higher probability of failing if 
you're running into issues where GFP_KERNEL is causing synchronous 
reclaim.  We may not be able to do any better in the contexts in which 
gfs2, ntfs, and ceph use it without some sort of preallocation at an 
earlier time, but the liklihood of those allocations failing is much 
harder than the typical vmalloc() that tries really hard with __GFP_REPEAT 
to allocate the memory required.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
