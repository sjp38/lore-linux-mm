Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id F2C706B0039
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 17:04:22 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so266352pde.9
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 14:04:22 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id no12si108191pdb.199.2014.07.22.14.04.21
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 14:04:21 -0700 (PDT)
Date: Tue, 22 Jul 2014 22:03:52 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv4 5/5] arm64: Add atomic pool for non-coherent and CMA
 allocations.
Message-ID: <20140722210352.GA10604@arm.com>
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
 <1404324218-4743-6-git-send-email-lauraa@codeaurora.org>
 <201407222006.44666.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201407222006.44666.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Laura Abbott <lauraa@codeaurora.org>, Will Deacon <Will.Deacon@arm.com>, David Riley <davidriley@chromium.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ritesh Harjain <ritesh.harjani@gmail.com>

On Tue, Jul 22, 2014 at 07:06:44PM +0100, Arnd Bergmann wrote:
> On Wednesday 02 July 2014, Laura Abbott wrote:
> > +       pgprot_t prot = __pgprot(PROT_NORMAL_NC);
> > +       unsigned long nr_pages = atomic_pool_size >> PAGE_SHIFT;
> > +       struct page *page;
> > +       void *addr;
> > +
> > +
> > +       if (dev_get_cma_area(NULL))
> > +               page = dma_alloc_from_contiguous(NULL, nr_pages,
> > +                                       get_order(atomic_pool_size));
> > +       else
> > +               page = alloc_pages(GFP_KERNEL, get_order(atomic_pool_size));
> > +
> > +
> > +       if (page) {
> > +               int ret;
> > +
> > +               atomic_pool = gen_pool_create(PAGE_SHIFT, -1);
> > +               if (!atomic_pool)
> > +                       goto free_page;
> > +
> > +               addr = dma_common_contiguous_remap(page, atomic_pool_size,
> > +                                       VM_USERMAP, prot, atomic_pool_init);
> > +
> 
> I just stumbled over this thread and noticed the code here: When you do
> alloc_pages() above, you actually get pages that are already mapped into
> the linear kernel mapping as cacheable pages. Your new
> dma_common_contiguous_remap tries to map them as noncacheable. This
> seems broken because it allows the CPU to treat both mappings as
> cacheable, and that won't be coherent with device DMA.

It does *not* allow the CPU to treat both as cacheable. It treats the
non-cacheable mapping as non-cacheable (and the cacheable one as
cacheable). The only requirements the ARM ARM makes in this situation
(B2.9 point 5 in the ARMv8 ARM):

- Before writing to a location not using the Write-Back attribute,
  software must invalidate, or clean, a location from the caches if any
  agent might have written to the location with the Write-Back
  attribute. This avoids the possibility of overwriting the location
  with stale data.
- After writing to a location with the Write-Back attribute, software
  must clean the location from the caches, to make the write visible to
  external memory.
- Before reading the location with a cacheable attribute, software must
  invalidate the location from the caches, to ensure that any value held
  in the caches reflects the last value made visible in external memory.

So we as long as the CPU accesses such memory only via the non-cacheable
mapping, the only requirement is to flush the cache so that there are no
dirty lines that could be evicted.

(if the mismatched attributes were for example Normal vs Device, the
Device guarantees would be lost but in the cacheable vs non-cacheable
it's not too bad; same for ARMv7).

> > +               if (!addr)
> > +                       goto destroy_genpool;
> > +
> > +               memset(addr, 0, atomic_pool_size);
> > +               __dma_flush_range(addr, addr + atomic_pool_size);
> 
> It also seems weird to flush the cache on a virtual address of
> an uncacheable mapping. Is that well-defined?

Yes. According to D5.8.1 (Data and unified caches), "if cache
maintenance is performed on a memory location, the effect of that cache
maintenance is visible to all aliases of that physical memory location.
These properties are consistent with implementing all caches that can
handle data accesses as Physically-indexed, physically-tagged (PIPT)
caches".

> In the CMA case, the
> original mapping should already be uncached here, so you don't need
> to flush it.

I don't think it is non-cacheable already, at least not for arm64 (CMA
can be used on coherent architectures as well).

> In the alloc_pages() case, I think you need to unmap
> the pages from the linear mapping instead.

Even if unmapped, it would not remove dirty cache lines (which are
associated with physical addresses anyway). But we don't need to worry
about unmapping anyway, see above (that's unless we find some
architecture implementation where having such cacheable/non-cacheable
aliases is not efficient enough, the efficiency is not guaranteed by the
ARM ARM, just the correct behaviour).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
