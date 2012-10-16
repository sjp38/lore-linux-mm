Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id DEB146B0085
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 06:37:20 -0400 (EDT)
Date: Tue, 16 Oct 2012 11:37:02 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] DMA-mapping & IOMMU - physically
	contiguous allocations
Message-ID: <20121016103702.GB21164@n2100.arm.linux.org.uk>
References: <CAAQKjZMYFNMEnb2ue2aR+6AEbOixnQFyggbXrThBCW5VOznePg@mail.gmail.com> <20121016090434.7d5e088152a3e0b0606903c8@nvidia.com> <20121016085928.GV21164@n2100.arm.linux.org.uk> <20121016.132755.661591248175727826.hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121016.132755.661591248175727826.hdoyu@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "inki.dae@samsung.com" <inki.dae@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>

On Tue, Oct 16, 2012 at 12:27:55PM +0200, Hiroshi Doyu wrote:
> Hi Russell,
> 
> Russell King - ARM Linux <linux@arm.linux.org.uk> wrote @ Tue, 16 Oct 2012 10:59:28 +0200:
> 
> > On Tue, Oct 16, 2012 at 09:04:34AM +0300, Hiroshi Doyu wrote:
> > > In addition to those contiguous/discontiguous page allocation, is
> > > there any way to _import_ anonymous pages allocated by a process to be
> > > used in dma-mapping API later?
> > > 
> > > I'm considering the following scenario, an user process allocates a
> > > buffer by malloc() in advance, and then it asks some driver to convert
> > > that buffer into IOMMU'able/DMA'able ones later. In this case, pages
> > > are discouguous and even they may not be yet allocated at
> > > malloc()/mmap().
> > 
> > That situation is covered.  It's the streaming API you're wanting for that.
> > dma_map_sg() - but you may need additional cache handling via
> > flush_dcache_page() to ensure that your code is safe for all CPU cache
> > architectures.
> >
> > Remember that pages allocated into userspace will be cacheable, so a cache
> > flush is required before they can be DMA'd.  Hence the streaming
> > API.
> 
> Is the syscall "cacheflush()" supposed to be the knob for that?
> 
> Or is there any other ones to have more precise control, "clean",
> "invalidate" and "flush", from userland in generic way?

No other syscalls are required - this sequence will do everything you
need to perform DMA on pages mapped into userspace:

	get_user_pages()
	convert array of struct page * to scatterlist
	dma_map_sg()
	perform DMA
	dma_unmap_sg()
	for each page in sg()
		page_cache_release(page);

If you get the list of pages some other way (eg, via shmem_read_mapping_page_gfp)
then additional maintanence may be required (though that may be a bug in
shmem - remember this stuff hasn't been well tested on ARM before.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
