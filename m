Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id l9PHe9t0031141
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 10:40:09 -0700
Received: from nf-out-0910.google.com (nfbd21.prod.google.com [10.48.80.21])
	by zps35.corp.google.com with ESMTP id l9PHe8rh015366
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 10:40:09 -0700
Received: by nf-out-0910.google.com with SMTP id d21so502145nfb
        for <linux-mm@kvack.org>; Thu, 25 Oct 2007 10:40:07 -0700 (PDT)
Message-ID: <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
Date: Thu, 25 Oct 2007 13:40:07 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: RFC/POC Make Page Tables Relocatable
In-Reply-To: <1193330774.4039.136.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/25/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Thu, 2007-10-25 at 11:16 -0400, Ross Biro wrote:
> > 1) Add a separate meta-data allocation to the slab and slub allocator
> > and allocate full pages through kmem_cache_alloc instead of get_page.
> > The primary motivation of this is that we could shrink struct page by
> > using kmem_cache_alloc to allocate whole pages and put the supported
> > data in the meta_data area instead of struct page.
>
> The idea seems cool, but I think I'm missing a lot of your motivation
> here.
>
> First of all, which meta-data, exactly, is causing 'struct page' to be
> larger than it could be?  Which meta-data can be moved?

Almost all of it.  Most of struct page isn't about the kernel manging
pages in general, but about managing particular types of pages.
Although it's been cleaned up over the years, there are still
some things:

        union {
                atomic_t _mapcount;     /* Count of ptes mapped in mms,
                                         * to show when page is mapped
                                         * & limit reverse map searches.
                                         */
                struct {        /* SLUB uses */
                        short unsigned int inuse;
                        short unsigned int offset;
                };
        };

mapcount is only used when the page is mapped via a pte, while the
other part is only used when the page is part of a SLUB cache.
Neither of which is always true and not 100% needed as part of struct
page.  There is just currently no better place to put them.  The rest
of the unions don't really belong in struct page.  Similarly the lru
list only applies to pages which could go on the lru list.  So why not
make a better place to put them.

>
> > 2) Add support for relocating memory allocated via kmem_cache_alloc.
> > When a cache is created, optional relocation information can be
> > provided.  If a relocation function is provided, caches can be
> > defragmented and overall memory consumption can be reduced.
>
> We may truly need this some day, but I'm not sure we need it for
> pagetables.  If I were a stupid, naive kernel developer and I wanted to

I chose to start with page tables because I figured they would be the
hardest to properly relocate.

> get a pte page back, I might simply hold the page table lock, walk the
> pagetables to the pmd, lock and invalidate the pmd, copy the pagetable
> contents into a new page, update the pmd, and be on my merry way.  Why
> doesn't this work?  I'm just fishing for a good explanation why we need
> all the slab silliness.

This would almost work, but to do it properly, you find you'll need
some more locks and a couple of extra pointers and such.  With out all
the slab silliness you would need to add them to struct page. It would
have needlessly bloated struct page hence the previous change.  I've
also managed to convince myself that using the slab/slub allocator
will tend to clump the page tables together which should reduce
fragmentation and make more memory available for huge pages.  In fact,
I've got this idea that by using slab/slub, we can stop allocating
individual pages and only allocate huge pages on systems that have
them.

>
> I applaud you for posting early and posting often, but there is an
> absolute ton of code in your patch.  For your subsequent postings, I'd
> highly recommend trying to break it up in some logical ways.  Your 4
> steps would be an excellent start.

I don't think any of the four changes stand on their own, but only
when you see them together.  If there is enough agreement in principle
to go forward, then for real patches you are correct.   Remember, that
patch was only meant as a proof of concept.

> You might also want to run checkpatch.pl on your patch.  It has some
> style issues that also need to get worked out.

That patch isn't meant to be applied, but is there because it's easier
to point to code to try to explain what I'm mean than to explain in
words.  I didn't think a few style issues would be an issue.  And just
to reiterate, if you actually use the code I posted, you get what you
deserve.  It was only meant to illustrate what I'm trying to say.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
