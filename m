Subject: Re: [PATCH 00/28] Swap over NFS -v16
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <84144f020802270005p3bfbd04ar9da2875218ef98c4@mail.gmail.com>
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
	 <18372.64081.995262.986841@notabene.brown>
	 <1204099113.6242.353.camel@lappy>
	 <84144f020802270005p3bfbd04ar9da2875218ef98c4@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 29 Feb 2008 12:51:52 +0100
Message-Id: <1204285912.6243.93.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 2008-02-27 at 10:05 +0200, Pekka Enberg wrote:
> Hi Peter,
> 
> On Wed, Feb 27, 2008 at 9:58 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> >  > 1/ I note there is no way to tell if memory returned by kmalloc is
> >  >   from the emergency reserve - which contrasts with alloc_page
> >  >   which does make that information available through page->reserve.
> >  >   This seems a slightly unfortunate aspect of the interface.
> >
> >  Yes, but alas there is no room to store such information in kmalloc().
> >  That is, in a sane way. I think it was Daniel Phillips who suggested
> >  encoding it in the return pointer by flipping the low bit - but that is
> >  just too ugly and breaks all current kmalloc sites to boot.
> 
> Why can't you add a kmem_is_emergency() to SLUB that looks up the
> cache/slab/page (whatever is the smallest unit of the emergency pool
> here) for the object and use that?

I made page->reserve into PG_emergency and made that bit stick for the
lifetime of that page allocation. I then made kmem_is_emergency() look
up the head page backing that allocation's slab and return
PageEmergency().

This gives a consistent kmem_is_emergency() - that is if during the
lifetime of the kmem allocation it returns true once, it must return
true always.

You can then, using this properly, push the accounting into
kmalloc_reserve() and kfree_reserve() (and
kmem_cache_{alloc,free}_reserve).

Which yields very pretty code all round. (can make public if you like to
see..)

However...

This is a stricter model than I had before, and has one ramification I'm
not entirely sure I like.

It means the page remains a reserve page throughout its lifetime, which
means the slab remains a reserve slab throughout its lifetime. Therefore
it may never be used for !reserve allocations. Which in turn generates
complexities for the partial list.

In my previous model I had the reserve accounting external to the
allocation, which relaxed the strict need for consistency here, and I
dropped the reserve status once we were above the page limits again. 

I managed to complicate the SLUB patch with this extra constraint, by
checking reserve against PageEmergency() when scanning the partial list,
but gave up on SLAB.

Does this sound like something I should pursuit? I feel it might
complicate the slab allocators too much..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
