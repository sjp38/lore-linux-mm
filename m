Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 82A7E8D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 17:50:37 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id oAFMoZXH021218
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 14:50:35 -0800
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by kpbe14.cbf.corp.google.com with ESMTP id oAFMoQ9F001397
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 14:50:34 -0800
Received: by pwj3 with SMTP id 3so9002pwj.26
        for <linux-mm@kvack.org>; Mon, 15 Nov 2010 14:50:34 -0800 (PST)
Date: Mon, 15 Nov 2010 14:50:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
In-Reply-To: <1289859596.13446.151.camel@oralap>
Message-ID: <alpine.DEB.2.00.1011151426360.20468@chino.kir.corp.google.com>
References: <1289421759.11149.59.camel@oralap> <20101111120643.22dcda5b.akpm@linux-foundation.org> <1289512924.428.112.camel@oralap> <20101111142511.c98c3808.akpm@linux-foundation.org> <1289840500.13446.65.camel@oralap> <alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
 <1289859596.13446.151.camel@oralap>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 2010, Ricardo M. Correia wrote:

> > This proposal essentially defines an entirely new method for passing gfp 
> > flags to the page allocator when it isn't strictly needed.
> 
> I don't see it as a way of passing gfp flags to the page allocator, but
> rather as a way of restricting which gfp flags can be used (on a
> per-thread basis). I agree it's not strictly needed.
> 

It restricts the flags that can be used in the current context, but that's 
the whole purpose of gfp arguments such as __GFP_FS, __GFP_IO, and 
__GFP_WAIT that control the reclaim behavior of the page allocator in the 
first place: we want to use all strategies at our disposal that are 
allowed in the current context to allocate the memory.  Using this 
interface to restrict only to __GFP_WAIT, for example, is the same as 
passing __GFP_WAIT.

> > The first option really addresses the bug that you're running into and can 
> > be addressed in a relatively simple way by redefining current users of 
> > pmd_alloc_one(), for instance, as a form of a new lower-level 
> > __pmd_alloc_one():
> > 
> > 	static inline pmd_t *__pmd_alloc_one(struct mm_struct *mm,
> > 					unsigned long addr, gfp_t flags)
> > 	{
> >         	return (pmd_t *)get_zeroed_page(flags);
> > 	}
> > 
> > 	static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
> > 	{
> >         	return __pmd_alloc_one(GFP_KERNEL|__GFP_REPEAT);
> > 	}
> > 
> > and then using __pmd_alloc_one() in the vmalloc path with the passed mask 
> > rather than pmd_alloc_one(). 
> 
> Ok, this sounds OK in theory (I'd have to change all these
> implementations for all architectures, but oh well..). But I have a
> question about your proposal.. the call chain seems to go:
> 

Yes, all architectures would need to be changed because they all 
unconditionally do GFP_KERNEL allocations which is buggy in the vmalloc 
case, so the breadth of the change is certainly warranted.

> vmap_pmd_range()
>   pmd_alloc()
>     __pmd_alloc()
>       pmd_alloc_one()
> 
> So you want to change this so that vmap_pmd_range() calls your new
> __pmd_alloc_one() instead of pmd_alloc_one().
> 

Yes, with the gfp flags that were passed to __vmalloc() to restrict the 
lower-level allocations that you cited in your original email 
(pmd_alloc_one() and pte_alloc_one_kernel()).

> But this means that pmd_alloc() and __pmd_alloc() would need to accept
> the flag as well, right?
> 
> Probably we should define an alias for pmd_alloc() so that we don't have
> to change all its callers to pass a flag. But __pmd_alloc() is already
> taken, so what would you suggest we call it? _pmd_alloc()? :-)
> 

Yeah, that's why I said it's slightly more intrusive than the single 
example I gave, you need to modify the callchain to pass the flags in 
other functions as well.  Instead of extending the __*() functions with 
more underscores like other places in the kernel (see mm/slab.c, for 
instance), I'd suggest just appending _gfp() to their name so 
__pmd_alloc() uses a new __pmd_alloc_gfp().

> Indeed... I don't think we can do any better in Lustre either. The
> preallocation also doesn't guarantee anything for us, because the amount
> of memory that we may need to allocate can be huge in the worst case,
> and it would be prohibitive to preallocate it.
> 

I think it really depends on how much memory you plan to allocate without 
allowing direct reclaim (and that also prevents the oom killer from being 
used as well).  The ntfs use, for instance, falls back to vmalloc if the 
size is greater than PAGE_SIZE to avoid high-order allocations from 
failing due to fragmentation and memory compaction can't be used for 
GFP_NOFS either.  The best the VM can do is allocate the order-0 pages 
with GFP_NOFS which has a much higher liklihood that it won't succeed, so 
it's really to gfs2, ntfs, and ceph's detriment that it doesn't have a 
workaround.

> For our case, I'd think it's better to either handle failure or somehow
> retry until the allocation succeeds (if we know for sure that it will,
> eventually).
> 

If your use-case is going to block until this memory is available, there's 
a serious problem that you'll need to address because nothing is going to 
guarantee that memory will be freed unless something else is trying to 
allocate memory and pages get written back or something gets killed as a 
result.  Strictly relying on that behavior is concerning, but it's not 
something that can be fixed in the VM.

> >  but the liklihood of those allocations failing is much 
> > harder than the typical vmalloc() that tries really hard with __GFP_REPEAT 
> > to allocate the memory required.
> 
> Not sure what do you mean by this.. I don't see a typical vmalloc()
> using __GFP_REPEAT anywhere (apart from functions such as
> pmd_alloc_one(), which in the code above you suggested to keep passing
> __GFP_REPEAT).. am I missing something?
> 

__GFP_REPEAT will retry the allocation indefinitely until the needed 
amount of memory is reclaimed without considering the order of the 
allocation; all orders of interest in your case are order-0, so it will 
loop indefinitely until a single page is reclaimed which won't happen with 
GFP_NOFS.  Thus, passing the flag is the equivalent of asking the 
allocator to loop forever until memory is available rather than failing 
and returning to your error handling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
