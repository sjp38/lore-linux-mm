Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2716B02DC
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 12:59:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e199so16471934pfh.3
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 09:59:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h3sor4127723pgf.203.2017.09.11.09.59.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 09:59:39 -0700 (PDT)
Date: Mon, 11 Sep 2017 09:59:36 -0700
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20170911165936.eeqdwzir3kxkhvza@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <302be94d-7e44-001d-286c-2b0cd6098f7b@huawei.com>
 <20170911145020.fat456njvyagcomu@docker>
 <57e95ad2-81d8-bf83-3e78-1313daa1bb80@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57e95ad2-81d8-bf83-3e78-1313daa1bb80@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@canonical.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, x86@kernel.org

On Mon, Sep 11, 2017 at 06:03:55PM +0200, Juerg Haefliger wrote:
> 
> 
> On 09/11/2017 04:50 PM, Tycho Andersen wrote:
> > Hi Yisheng,
> > 
> > On Mon, Sep 11, 2017 at 03:24:09PM +0800, Yisheng Xie wrote:
> >>> +void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
> >>> +{
> >>> +	int i, flush_tlb = 0;
> >>> +	struct xpfo *xpfo;
> >>> +
> >>> +	if (!static_branch_unlikely(&xpfo_inited))
> >>> +		return;
> >>> +
> >>> +	for (i = 0; i < (1 << order); i++)  {
> >>> +		xpfo = lookup_xpfo(page + i);
> >>> +		if (!xpfo)
> >>> +			continue;
> >>> +
> >>> +		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
> >>> +		     "xpfo: unmapped page being allocated\n");
> >>> +
> >>> +		/* Initialize the map lock and map counter */
> >>> +		if (unlikely(!xpfo->inited)) {
> >>> +			spin_lock_init(&xpfo->maplock);
> >>> +			atomic_set(&xpfo->mapcount, 0);
> >>> +			xpfo->inited = true;
> >>> +		}
> >>> +		WARN(atomic_read(&xpfo->mapcount),
> >>> +		     "xpfo: already mapped page being allocated\n");
> >>> +
> >>> +		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
> >>> +			/*
> >>> +			 * Tag the page as a user page and flush the TLB if it
> >>> +			 * was previously allocated to the kernel.
> >>> +			 */
> >>> +			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
> >>> +				flush_tlb = 1;
> >>
> >> I'm not sure whether I am miss anything, however, when the page was previously allocated
> >> to kernel,  should we unmap the physmap (the kernel's page table) here? For we allocate
> >> the page to user now
> >> 
> > Yes, I think you're right. Oddly, the XPFO_READ_USER test works
> > correctly for me, but I think (?) should not because of this bug...
> 
> IIRC, this is an optimization carried forward from the initial
> implementation. The assumption is that the kernel will map the user
> buffer so it's not unmapped on allocation but only on the first (and

Does the kernel always map it, though? e.g. in the case of
XPFO_READ_USER, I'm not sure where the kernel would do a kmap() of the
test's user buffer.

Tycho

> subsequent) call of kunmap. I.e.:
>  - alloc  -> noop
>  - kmap   -> noop
>  - kunmap -> unmapped from the kernel
>  - kmap   -> mapped into the kernel
>  - kunmap -> unmapped from the kernel
> and so on until:
>  - free   -> mapped back into the kernel
> 
> I'm not sure if that make sense though since it leaves a window.
> 
> ...Juerg
> 
> 
> 
> > Tycho
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
