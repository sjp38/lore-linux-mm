Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1873E8D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 17:20:15 -0500 (EST)
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
From: "Ricardo M. Correia" <ricardo.correia@oracle.com>
In-Reply-To: <alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
References: <1289421759.11149.59.camel@oralap>
	 <20101111120643.22dcda5b.akpm@linux-foundation.org>
	 <1289512924.428.112.camel@oralap>
	 <20101111142511.c98c3808.akpm@linux-foundation.org>
	 <1289840500.13446.65.camel@oralap>
	 <alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 15 Nov 2010 23:19:56 +0100
Message-ID: <1289859596.13446.151.camel@oralap>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-15 at 13:28 -0800, David Rientjes wrote:
> This proposal essentially defines an entirely new method for passing gfp 
> flags to the page allocator when it isn't strictly needed.

I don't see it as a way of passing gfp flags to the page allocator, but
rather as a way of restricting which gfp flags can be used (on a
per-thread basis). I agree it's not strictly needed.

>   I think the 
> problem you're addressing can be done in one of two ways:
> 
>  - create lower-level functions in each arch that pass a gfp argument to 
>    the allocator rather than hard-coded GFP_KERNEL, or
> 
>  - avoid doing anything other than GFP_KERNEL allocations for __vmalloc():
>    the only current users are gfs2, ntfs, and ceph (the page allocator
>    __vmalloc() can be discounted since it's done at boot and GFP_ATOMIC
>    here has almost no chance of failing since the size is determined based 
>    on what is available).
>
>
> The first option really addresses the bug that you're running into and can 
> be addressed in a relatively simple way by redefining current users of 
> pmd_alloc_one(), for instance, as a form of a new lower-level 
> __pmd_alloc_one():
> 
> 	static inline pmd_t *__pmd_alloc_one(struct mm_struct *mm,
> 					unsigned long addr, gfp_t flags)
> 	{
>         	return (pmd_t *)get_zeroed_page(flags);
> 	}
> 
> 	static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
> 	{
>         	return __pmd_alloc_one(GFP_KERNEL|__GFP_REPEAT);
> 	}
> 
> and then using __pmd_alloc_one() in the vmalloc path with the passed mask 
> rather than pmd_alloc_one(). 

Ok, this sounds OK in theory (I'd have to change all these
implementations for all architectures, but oh well..). But I have a
question about your proposal.. the call chain seems to go:

vmap_pmd_range()
  pmd_alloc()
    __pmd_alloc()
      pmd_alloc_one()

So you want to change this so that vmap_pmd_range() calls your new
__pmd_alloc_one() instead of pmd_alloc_one().

But this means that pmd_alloc() and __pmd_alloc() would need to accept
the flag as well, right?

Probably we should define an alias for pmd_alloc() so that we don't have
to change all its callers to pass a flag. But __pmd_alloc() is already
taken, so what would you suggest we call it? _pmd_alloc()? :-)

> Both are bugs that you'll be 
> addressing for each architecture, so the intrusiveness of that change has 
> merit (and be sure to cc linux-arch@vger.kernel.org on it as well).

Ok.

> I only mention the second option because passing GFP_NOFS to __vmalloc() 
> for sufficiently large sizes has a much higher probability of failing if 
> you're running into issues where GFP_KERNEL is causing synchronous 
> reclaim.  We may not be able to do any better in the contexts in which 
> gfs2, ntfs, and ceph use it without some sort of preallocation at an 
> earlier time,

Indeed... I don't think we can do any better in Lustre either. The
preallocation also doesn't guarantee anything for us, because the amount
of memory that we may need to allocate can be huge in the worst case,
and it would be prohibitive to preallocate it.

For our case, I'd think it's better to either handle failure or somehow
retry until the allocation succeeds (if we know for sure that it will,
eventually).

>  but the liklihood of those allocations failing is much 
> harder than the typical vmalloc() that tries really hard with __GFP_REPEAT 
> to allocate the memory required.

Not sure what do you mean by this.. I don't see a typical vmalloc()
using __GFP_REPEAT anywhere (apart from functions such as
pmd_alloc_one(), which in the code above you suggested to keep passing
__GFP_REPEAT).. am I missing something?

Thanks,
Ricardo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
