Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 603BF6B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:53:09 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so3973127pab.14
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 06:53:09 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id pk4si6033475pbc.252.2014.07.24.06.53.07
        for <linux-mm@kvack.org>;
        Thu, 24 Jul 2014 06:53:08 -0700 (PDT)
Date: Thu, 24 Jul 2014 14:52:38 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv4 3/5] common: dma-mapping: Introduce common remapping
 functions
Message-ID: <20140724135238.GC13371@arm.com>
References: <1406079308-5232-1-git-send-email-lauraa@codeaurora.org>
 <1406079308-5232-4-git-send-email-lauraa@codeaurora.org>
 <20140723104554.GB1366@localhost>
 <53D02F7B.5020309@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53D02F7B.5020309@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <Will.Deacon@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>

On Wed, Jul 23, 2014 at 10:56:11PM +0100, Laura Abbott wrote:
> On 7/23/2014 3:45 AM, Catalin Marinas wrote:
> > On Wed, Jul 23, 2014 at 02:35:06AM +0100, Laura Abbott wrote:
> >> --- a/drivers/base/dma-mapping.c
> >> +++ b/drivers/base/dma-mapping.c
> > [...]
> >> +void *dma_common_contiguous_remap(struct page *page, size_t size,
> >> +			unsigned long vm_flags,
> >> +			pgprot_t prot, const void *caller)
> >> +{
> >> +	int i;
> >> +	struct page **pages;
> >> +	void *ptr;
> >> +
> >> +	pages = kmalloc(sizeof(struct page *) << get_order(size), GFP_KERNEL);
> >> +	if (!pages)
> >> +		return NULL;
> >> +
> >> +	for (i = 0; i < (size >> PAGE_SHIFT); i++)
> >> +		pages[i] = page + i;
> >> +
> >> +	ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
> >> +
> >> +	kfree(pages);
> >> +
> >> +	return ptr;
> >> +}
> > 
> > You could avoid the dma_common_page_remap() here (and kmalloc) and
> > simply use ioremap_page_range(). We know that
> > dma_common_contiguous_remap() is only called with contiguous physical
> > range, so ioremap_page_range() is suitable. It also makes it a
> > non-functional change for arch/arm.
> 
> My original thought with using map_vm_area vs. ioremap_page_range was
> that ioremap_page_range is really intended for mapping io devices and
> the like into the kernel virtual address space. map_vm_area is designed
> to handle pages of kernel managed memory. Perhaps it's too nit-picky
> a distinction though.

I think you are right. We had a discussion in the past about using
ioremap on valid RAM addresses and decided not to allow this. This would
be similar with the ioremap_page_range() here.

>From my perspective, you can leave the code as is (wouldn't be any
functional change for arm64 since it was using vmap() already). But
please add a comment in the commit log about this change.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
