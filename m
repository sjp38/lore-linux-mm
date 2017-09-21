Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C59AE6B02E6
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 20:02:14 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g32so7151494ioj.0
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 17:02:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a9sor57421oih.253.2017.09.20.17.02.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 17:02:13 -0700 (PDT)
Date: Wed, 20 Sep 2017 18:02:10 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20170921000210.drjiywtp4n75yovk@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <302be94d-7e44-001d-286c-2b0cd6098f7b@huawei.com>
 <20170911145020.fat456njvyagcomu@docker>
 <57e95ad2-81d8-bf83-3e78-1313daa1bb80@canonical.com>
 <431e2567-7600-3186-1489-93b855c395bd@huawei.com>
 <20170912143636.avc3ponnervs43kj@docker>
 <20170912181303.aqjj5ri3mhscw63t@docker>
 <91923595-7f02-3be0-9c59-9c1fd20c82a8@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <91923595-7f02-3be0-9c59-9c1fd20c82a8@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, x86@kernel.org

On Wed, Sep 20, 2017 at 04:46:41PM -0700, Dave Hansen wrote:
> On 09/12/2017 11:13 AM, Tycho Andersen wrote:
> > -void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
> > +void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp, bool will_map)
> >  {
> >  	int i, flush_tlb = 0;
> >  	struct xpfo *xpfo;
> > @@ -116,8 +116,14 @@ void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
> >  			 * Tag the page as a user page and flush the TLB if it
> >  			 * was previously allocated to the kernel.
> >  			 */
> > -			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
> > +			bool was_user = !test_and_set_bit(XPFO_PAGE_USER,
> > +							  &xpfo->flags);
> > +
> > +			if (was_user || !will_map) {
> > +				set_kpte(page_address(page + i), page + i,
> > +					 __pgprot(0));
> >  				flush_tlb = 1;
> > +			}
> 
> Shouldn't the "was_user" be "was_kernel"?

Oof, yes, thanks.

> Also, the way this now works, let's say we have a nice, 2MB pmd_t (page
> table entry) mapping a nice, 2MB page in the allocator.  Then it gets
> allocated to userspace.  We do
> 
> 	for (i = 0; i < (1 << order); i++)  {
> 		...
> 		set_kpte(page_address(page + i), page+i, __pgprot(0));
> 	}
> 
> The set_kpte() will take the nice, 2MB mapping and break it down into
> 512 4k mappings, all pointing to a non-present PTE, in a newly-allocated
> PTE page.  So, you get the same result and waste 4k of memory in the
> process, *AND* make it slower because we added a level to the page tables.
> 
> I think you actually want to make a single set_kpte() call at the end of
> the function.  That's faster and preserves the large page in the direct
> mapping.

...and makes it easier to pair tlb flushes with changing the
protections. I guess we still need the for loop, because we need to
set/unset the xpfo bits as necessary, but I'll switch it to a single
set_kpte(). This also implies that the xpfo bits should all be the
same on every page in the mapping, which I think is true.

This will be a nice change, thanks!

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
