Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3486B02D0
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 10:50:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p87so7986296pfj.4
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 07:50:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i8sor4702042plk.123.2017.09.11.07.50.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 07:50:23 -0700 (PDT)
Date: Mon, 11 Sep 2017 07:50:20 -0700
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20170911145020.fat456njvyagcomu@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <302be94d-7e44-001d-286c-2b0cd6098f7b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <302be94d-7e44-001d-286c-2b0cd6098f7b@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

Hi Yisheng,

On Mon, Sep 11, 2017 at 03:24:09PM +0800, Yisheng Xie wrote:
> > +void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
> > +{
> > +	int i, flush_tlb = 0;
> > +	struct xpfo *xpfo;
> > +
> > +	if (!static_branch_unlikely(&xpfo_inited))
> > +		return;
> > +
> > +	for (i = 0; i < (1 << order); i++)  {
> > +		xpfo = lookup_xpfo(page + i);
> > +		if (!xpfo)
> > +			continue;
> > +
> > +		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
> > +		     "xpfo: unmapped page being allocated\n");
> > +
> > +		/* Initialize the map lock and map counter */
> > +		if (unlikely(!xpfo->inited)) {
> > +			spin_lock_init(&xpfo->maplock);
> > +			atomic_set(&xpfo->mapcount, 0);
> > +			xpfo->inited = true;
> > +		}
> > +		WARN(atomic_read(&xpfo->mapcount),
> > +		     "xpfo: already mapped page being allocated\n");
> > +
> > +		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
> > +			/*
> > +			 * Tag the page as a user page and flush the TLB if it
> > +			 * was previously allocated to the kernel.
> > +			 */
> > +			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
> > +				flush_tlb = 1;
> 
> I'm not sure whether I am miss anything, however, when the page was previously allocated
> to kernel,  should we unmap the physmap (the kernel's page table) here? For we allocate
> the page to user now

Yes, I think you're right. Oddly, the XPFO_READ_USER test works
correctly for me, but I think (?) should not because of this bug...

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
