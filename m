Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69D836B02CE
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 18:34:57 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u2so6375311itb.7
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 15:34:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o186sor1375881oib.280.2017.09.20.15.34.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 15:34:55 -0700 (PDT)
Date: Wed, 20 Sep 2017 16:34:52 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20170920223452.vam3egenc533rcta@smitten>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <34454a32-72c2-c62e-546c-1837e05327e1@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <34454a32-72c2-c62e-546c-1837e05327e1@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

Hi Dave,

Thanks for taking a look!

On Wed, Sep 20, 2017 at 08:48:36AM -0700, Dave Hansen wrote:
> On 09/07/2017 10:36 AM, Tycho Andersen wrote:
> ...
> > Whenever a page destined for userspace is allocated, it is
> > unmapped from physmap (the kernel's page table). When such a page is
> > reclaimed from userspace, it is mapped back to physmap.
> 
> I'm looking for the code where it's unmapped at allocation to userspace.
>  I see TLB flushing and 'struct xpfo' manipulation, but I don't see the
> unmapping.  Where is that occurring?

This is discussed here: https://lkml.org/lkml/2017/9/11/289 but,
you're right that it's wrong in some cases. I've fixed it up for v7:
https://lkml.org/lkml/2017/9/12/512

> How badly does this hurt performance?  Since we (generally) have
> different migrate types for user and kernel allocation, I can imagine
> that a given page *generally* doesn't oscillate between user and
> kernel-allocated, but I'm curious how it works in practice.  Doesn't the
> IPI load from the TLB flushes eat you alive?
>
> It's a bit scary to have such a deep code path under the main allocator.
> 
> This all seems insanely expensive.  It will *barely* work on an
> allocation-heavy workload on a desktop.  I'm pretty sure the locking
> will just fall over entirely on any reasonably-sized server.

Basically, yes :(. I presented some numbers at LSS, but the gist was
on a 2.4x slowdown on a 24 core/48 thread Xeon E5-2650, and a 1.4x
slowdown on a 4 core/8 thread E3-1240. The story seems a little bit
better on ARM, but I'm struggling to get it to boot on a box with more
than 4 cores, so I can't draw a better picture yet.

> I really have to wonder whether there are better ret2dir defenses than
> this.  The allocator just seems like the *wrong* place to be doing this
> because it's such a hot path.

This might be crazy, but what if we defer flushing of the kernel
ranges until just before we return to userspace? We'd still manipulate
the prot/xpfo bits for the pages, but then just keep a list of which
ranges need to be flushed, and do the right thing before we return.
This leaves a little window between the actual allocation and the
flush, but userspace would need another thread in its threadgroup to
predict the next allocation, write the bad stuff there, and do the
exploit all in that window.

I'm of course open to other suggestions. I'm new :)

> > +		cpa.vaddr = kaddr;
> > +		cpa.pages = &page;
> > +		cpa.mask_set = prot;
> > +		cpa.mask_clr = msk_clr;
> > +		cpa.numpages = 1;
> > +		cpa.flags = 0;
> > +		cpa.curpage = 0;
> > +		cpa.force_split = 0;
> > +
> > +
> > +		do_split = try_preserve_large_page(pte, (unsigned 
> 
> Is this safe to do without a TLB flush?  I thought we had plenty of bugs
> in CPUs around having multiple entries for the same page in the TLB at
> once.  We're *REALLY* careful when we split large pages for THP, and I'm
> surprised we don't do the same here.

It looks like on some code paths we do flush, and some we don't.
Sounds like it's not safe to do without a flush, so I'll see about
adding one.

> Why do you even bother keeping large pages around?  Won't the entire
> kernel just degrade to using 4k everywhere, eventually?

Isn't that true of large pages in general? Is there something about
xpfo that makes this worse? I thought this would only split things if
they had already been split somewhere else, and the protection can't
apply to the whole huge page.

> > +		if (do_split) {
> > +			struct page *base;
> > +
> > +			base = alloc_pages(GFP_ATOMIC | __GFP_NOTRACK, 
> 
> Ugh, GFP_ATOMIC.  That's nasty.  Do you really want this allocation to
> fail all the time?  GFP_ATOMIC could really be called
> GFP_YOU_BETTER_BE_OK_WITH_THIS_FAILING. :)
> 
> You probably want to do what the THP code does here and keep a spare
> page around, then allocate it before you take the locks.

Sounds like a good idea, thanks.

> > +inline void xpfo_flush_kernel_tlb(struct page *page, int order)
> > +{
> > +	int level;
> > +	unsigned long size, kaddr;
> > +
> > +	kaddr = (unsigned long)page_address(page);
> > +
> > +	if (unlikely(!lookup_address(kaddr, &level))) {
> > +		WARN(1, "xpfo: invalid address to flush %lx %d\n", kaddr, level);
> > +		return;
> > +	}
> > +
> > +	switch (level) {
> > +	case PG_LEVEL_4K:
> > +		size = PAGE_SIZE;
> > +		break;
> > +	case PG_LEVEL_2M:
> > +		size = PMD_SIZE;
> > +		break;
> > +	case PG_LEVEL_1G:
> > +		size = PUD_SIZE;
> > +		break;
> > +	default:
> > +		WARN(1, "xpfo: unsupported page level %x\n", level);
> > +		return;
> > +	}
> > +
> > +	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
> > +}
> 
> I'm not sure flush_tlb_kernel_range() is the best primitive to be
> calling here.
> 
> Let's say you walk the page tables and find level=PG_LEVEL_1G.  You call
> flush_tlb_kernel_range(), you will be above
> tlb_single_page_flush_ceiling, and you will do a full TLB flush.  But,
> with a 1GB page, you could have just used a single INVLPG and skipped
> the global flush.
> 
> I guess the cost of the IPI is way more than the flush itself, but it's
> still a shame to toss the entire TLB when you don't have to.

Ok, do you think it's worth making a new helper for others to use? Or
should I just keep the logic in this function?

> I also think the TLB flush should be done closer to the page table
> manipulation that it is connected to.  It's hard to figure out whether
> the flush is the right one otherwise.

Yes, sounds good.

> Also, the "(1 << order) * size" thing looks goofy to me.  Let's say you
> are flushing a order=1 (8k) page and its mapped in a 1GB mapping.  You
> flush 2GB.  Is that intentional?

I don't think so; seems like we should be flushing
(1 << order) * PAGE_SIZE instead.

> > +
> > +void xpfo_free_pages(struct page *page, int order)
> > +{
> ...
> > +		/*
> > +		 * Map the page back into the kernel if it was previously
> > +		 * allocated to user space.
> > +		 */
> > +		if (test_and_clear_bit(XPFO_PAGE_USER, &xpfo->flags)) {
> > +			clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
> > +			set_kpte(page_address(page + i), page + i,
> > +				 PAGE_KERNEL);
> > +		}
> > +	}
> > +}
> 
> This seems like a bad idea, performance-wise.  Kernel and userspace
> pages tend to be separated by migrate types.  So, a given physical page
> will tend to be used as kernel *or* for userspace.  With this nugget,
> every time a userspace page is freed, we will go to the trouble of
> making it *back* into a kernel page.  Then, when it is allocated again
> (probably as userspace), we will re-make it into a userspace page.  That
> seems horribly inefficient.
> 
> Also, this weakens the security guarantees.  Let's say you're mounting a
> ret2dir attack.  You populate a page with your evil data and you know
> the kernel address for the page.  All you have to do is coordinate your
> attack with freeing the page.  You can control when it gets freed.  Now,
> the xpfo_free_pages() helpfully just mapped your attack code back into
> the kernel.
> 
> Why not *just* do these moves at allocation time?

Yes, this is a great point, thanks. I think this can be a no-op, and
with the fixed up v7 logic for alloc pages that I linked to above it
should work out correctly.

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
