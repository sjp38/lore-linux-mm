Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PI8nIe023414
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 14:08:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PI8lWY103692
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:08:48 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PI8l7j003600
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:08:47 -0600
Subject: Re: RFC/POC Make Page Tables Relocatable
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 11:08:45 -0700
Message-Id: <1193335725.24087.19.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 13:40 -0400, Ross Biro wrote: 
> On 10/25/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> > On Thu, 2007-10-25 at 11:16 -0400, Ross Biro wrote:
> > > 1) Add a separate meta-data allocation to the slab and slub allocator
> > > and allocate full pages through kmem_cache_alloc instead of get_page.
> > > The primary motivation of this is that we could shrink struct page by
> > > using kmem_cache_alloc to allocate whole pages and put the supported
> > > data in the meta_data area instead of struct page.
> >
> > The idea seems cool, but I think I'm missing a lot of your motivation
> > here.
> >
> > First of all, which meta-data, exactly, is causing 'struct page' to be
> > larger than it could be?  Which meta-data can be moved?
> 
> Almost all of it.  Most of struct page isn't about the kernel manging
> pages in general, but about managing particular types of pages.
> Although it's been cleaned up over the years, there are still
> some things:
> 
>         union {
>                 atomic_t _mapcount;     /* Count of ptes mapped in mms,
>                                          * to show when page is mapped
>                                          * & limit reverse map searches.
>                                          */
>                 struct {        /* SLUB uses */
>                         short unsigned int inuse;
>                         short unsigned int offset;
>                 };
>         };
> 
> mapcount is only used when the page is mapped via a pte, while the
> other part is only used when the page is part of a SLUB cache.
> Neither of which is always true and not 100% needed as part of struct
> page.  There is just currently no better place to put them.  The rest
> of the unions don't really belong in struct page.  Similarly the lru
> list only applies to pages which could go on the lru list.  So why not
> make a better place to put them.

Right, but we're talking about pagetable pages here, right?  What fields
in 'struct page' are used by pagetable pages, but will allow 'struct
page' to shrink in size if pagetables pages stop using them?

On a more general note: so it's all about saving memory in the end?
Making 'struct page' smaller?  If I were you, I'd be very conerned about
the pathological cases.  We may get the lru pointers out of 'struct
page', so we'll need some parallel lookup to get from physical page to
LRU, right?   Although the bootup footprint of mem_map[] (and friends)
smaller, what happens on a machine with virtually all its memory used by
pages on the LRU (which I would guess is actually quite common).  Will
the memory footprint even be close to the two pointers per physical page
that it cost us for the current implementation?

That doesn't even consider the runtime overhead of such a scheme.  Right
now, if you touch any part of 'struct page' on a 32-bit machine, you
generally bring the entire thing into a single cacheline.  Every other
subsequent access is essentially free.  Any ideas what the ballpark
number of cachelines are that would have to be brought in with another
lookup method for 'struct page' to lru?

I dunno.  I'm highly skeptical this can work.

I've heard rumors in the past that the Windows' 'struct page' is much
smaller than the Linux one.  But, I've also heard that this weighs
heavily in other areas such as page reclamation.  Could be _completely_
bogus, but it might be worth a search or two to see if there have been
any papers on the subject.  

> > get a pte page back, I might simply hold the page table lock, walk the
> > pagetables to the pmd, lock and invalidate the pmd, copy the pagetable
> > contents into a new page, update the pmd, and be on my merry way.  Why
> > doesn't this work?  I'm just fishing for a good explanation why we need
> > all the slab silliness.
> 
> This would almost work, but to do it properly, you find you'll need
> some more locks and a couple of extra pointers and such.

Could you be specific?

> With out all
> the slab silliness you would need to add them to struct page. It would
> have needlessly bloated struct page hence the previous change.  I've
> also managed to convince myself that using the slab/slub allocator
> will tend to clump the page tables together which should reduce
> fragmentation and make more memory available for huge pages.  In fact,
> I've got this idea that by using slab/slub, we can stop allocating
> individual pages and only allocate huge pages on systems that have
> them.

You may want to have a talk with Mel about memory fragmentation, and
whether there is any lower hanging fruit (cc'd). :)

> > You might also want to run checkpatch.pl on your patch.  It has some
> > style issues that also need to get worked out.
> 
> That patch isn't meant to be applied, but is there because it's easier
> to point to code to try to explain what I'm mean than to explain in
> words.  I didn't think a few style issues would be an issue.  And just
> to reiterate, if you actually use the code I posted, you get what you
> deserve.  It was only meant to illustrate what I'm trying to say.

In general, the reason to run such a script (and to have coding
standards in the first place) is so that others can more easily read
your code.  The posted patch is hard to understand in some areas because
of indenting bracketing.  If you'd like people to read, review, and give
suggestions on what they see, I'd suggest trying to make it as easy as
possible to understand.

Check out Documentation/CodingStyle.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
