Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52BB66B0260
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:48:41 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m30so6182304pgn.2
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:48:41 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g2si63932pgf.680.2017.09.20.08.48.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 08:48:39 -0700 (PDT)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <34454a32-72c2-c62e-546c-1837e05327e1@intel.com>
Date: Wed, 20 Sep 2017 08:48:36 -0700
MIME-Version: 1.0
In-Reply-To: <20170907173609.22696-4-tycho@docker.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

On 09/07/2017 10:36 AM, Tycho Andersen wrote:
...
> Whenever a page destined for userspace is allocated, it is
> unmapped from physmap (the kernel's page table). When such a page is
> reclaimed from userspace, it is mapped back to physmap.

I'm looking for the code where it's unmapped at allocation to userspace.
 I see TLB flushing and 'struct xpfo' manipulation, but I don't see the
unmapping.  Where is that occurring?

How badly does this hurt performance?  Since we (generally) have
different migrate types for user and kernel allocation, I can imagine
that a given page *generally* doesn't oscillate between user and
kernel-allocated, but I'm curious how it works in practice.  Doesn't the
IPI load from the TLB flushes eat you alive?

It's a bit scary to have such a deep code path under the main allocator.

This all seems insanely expensive.  It will *barely* work on an
allocation-heavy workload on a desktop.  I'm pretty sure the locking
will just fall over entirely on any reasonably-sized server.

I really have to wonder whether there are better ret2dir defenses than
this.  The allocator just seems like the *wrong* place to be doing this
because it's such a hot path.

> +		cpa.vaddr = kaddr;
> +		cpa.pages = &page;
> +		cpa.mask_set = prot;
> +		cpa.mask_clr = msk_clr;
> +		cpa.numpages = 1;
> +		cpa.flags = 0;
> +		cpa.curpage = 0;
> +		cpa.force_split = 0;
> +
> +
> +		do_split = try_preserve_large_page(pte, (unsigned 

Is this safe to do without a TLB flush?  I thought we had plenty of bugs
in CPUs around having multiple entries for the same page in the TLB at
once.  We're *REALLY* careful when we split large pages for THP, and I'm
surprised we don't do the same here.

Why do you even bother keeping large pages around?  Won't the entire
kernel just degrade to using 4k everywhere, eventually?

> +		if (do_split) {
> +			struct page *base;
> +
> +			base = alloc_pages(GFP_ATOMIC | __GFP_NOTRACK, 

Ugh, GFP_ATOMIC.  That's nasty.  Do you really want this allocation to
fail all the time?  GFP_ATOMIC could really be called
GFP_YOU_BETTER_BE_OK_WITH_THIS_FAILING. :)

You probably want to do what the THP code does here and keep a spare
page around, then allocate it before you take the locks.

> +inline void xpfo_flush_kernel_tlb(struct page *page, int order)
> +{
> +	int level;
> +	unsigned long size, kaddr;
> +
> +	kaddr = (unsigned long)page_address(page);
> +
> +	if (unlikely(!lookup_address(kaddr, &level))) {
> +		WARN(1, "xpfo: invalid address to flush %lx %d\n", kaddr, level);
> +		return;
> +	}
> +
> +	switch (level) {
> +	case PG_LEVEL_4K:
> +		size = PAGE_SIZE;
> +		break;
> +	case PG_LEVEL_2M:
> +		size = PMD_SIZE;
> +		break;
> +	case PG_LEVEL_1G:
> +		size = PUD_SIZE;
> +		break;
> +	default:
> +		WARN(1, "xpfo: unsupported page level %x\n", level);
> +		return;
> +	}
> +
> +	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
> +}

I'm not sure flush_tlb_kernel_range() is the best primitive to be
calling here.

Let's say you walk the page tables and find level=PG_LEVEL_1G.  You call
flush_tlb_kernel_range(), you will be above
tlb_single_page_flush_ceiling, and you will do a full TLB flush.  But,
with a 1GB page, you could have just used a single INVLPG and skipped
the global flush.

I guess the cost of the IPI is way more than the flush itself, but it's
still a shame to toss the entire TLB when you don't have to.

I also think the TLB flush should be done closer to the page table
manipulation that it is connected to.  It's hard to figure out whether
the flush is the right one otherwise.

Also, the "(1 << order) * size" thing looks goofy to me.  Let's say you
are flushing a order=1 (8k) page and its mapped in a 1GB mapping.  You
flush 2GB.  Is that intentional?

> +
> +void xpfo_free_pages(struct page *page, int order)
> +{
...
> +		/*
> +		 * Map the page back into the kernel if it was previously
> +		 * allocated to user space.
> +		 */
> +		if (test_and_clear_bit(XPFO_PAGE_USER, &xpfo->flags)) {
> +			clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
> +			set_kpte(page_address(page + i), page + i,
> +				 PAGE_KERNEL);
> +		}
> +	}
> +}

This seems like a bad idea, performance-wise.  Kernel and userspace
pages tend to be separated by migrate types.  So, a given physical page
will tend to be used as kernel *or* for userspace.  With this nugget,
every time a userspace page is freed, we will go to the trouble of
making it *back* into a kernel page.  Then, when it is allocated again
(probably as userspace), we will re-make it into a userspace page.  That
seems horribly inefficient.

Also, this weakens the security guarantees.  Let's say you're mounting a
ret2dir attack.  You populate a page with your evil data and you know
the kernel address for the page.  All you have to do is coordinate your
attack with freeing the page.  You can control when it gets freed.  Now,
the xpfo_free_pages() helpfully just mapped your attack code back into
the kernel.

Why not *just* do these moves at allocation time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
