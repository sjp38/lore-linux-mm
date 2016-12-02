Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 39BA06B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 10:17:32 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id g193so207037939qke.2
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 07:17:32 -0800 (PST)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id c123si3214960qkb.20.2016.12.02.07.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 07:17:31 -0800 (PST)
Received: by mail-qk0-x244.google.com with SMTP id n204so30819128qke.2
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 07:17:31 -0800 (PST)
Date: Fri, 2 Dec 2016 10:17:19 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
Message-ID: <20161202151651.GA8811@gmail.com>
References: <20161130092239.GD18437@dhcp22.suse.cz>
 <xa1ty4012k0f.fsf@mina86.com>
 <20161130132848.GG18432@dhcp22.suse.cz>
 <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
 <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
 <20161201071507.GC18272@dhcp22.suse.cz>
 <20161201072119.GD18272@dhcp22.suse.cz>
 <9f2aa4e4-d7d5-e24f-112e-a4b43f0a0ccc@suse.cz>
 <20161201141125.GB20966@dhcp22.suse.cz>
 <1480674362.17003.44.camel@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1480674362.17003.44.camel@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Vlastimil Babka <vbabka@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>

On Fri, Dec 02, 2016 at 11:26:02AM +0100, Lucas Stach wrote:
> Am Donnerstag, den 01.12.2016, 15:11 +0100 schrieb Michal Hocko:
> > Let's also CC Marek
> > 
> > On Thu 01-12-16 08:43:40, Vlastimil Babka wrote:
> > > On 12/01/2016 08:21 AM, Michal Hocko wrote:
> > > > Forgot to CC Joonsoo. The email thread starts more or less here
> > > > http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz
> > > > 
> > > > On Thu 01-12-16 08:15:07, Michal Hocko wrote:
> > > > > On Wed 30-11-16 20:19:03, Robin H. Johnson wrote:
> > > > > [...]
> > > > > > alloc_contig_range: [83f2a3, 83f2a4) PFNs busy
> > > > > 
> > > > > Huh, do I get it right that the request was for a _single_ page? Why do
> > > > > we need CMA for that?
> > > 
> > > Ugh, good point. I assumed that was just the PFNs that it failed to migrate
> > > away, but it seems that's indeed the whole requested range. Yeah sounds some
> > > part of the dma-cma chain could be smarter and attempt CMA only for e.g.
> > > costly orders.
> > 
> > Is there any reason why the DMA api doesn't try the page allocator first
> > before falling back to the CMA? I simply have a hard time to see why the
> > CMA should be used (and fragment) for small requests size.
> 
> On x86 that is true, but on ARM CMA is the only (low memory) region that
> can change the memory attributes, by being excluded from the lowmem
> section mapping. Changing the memory attributes to
> uncached/writecombined for DMA is crucial on ARM to fulfill the
> requirement that no there aren't any conflicting mappings of the same
> physical page.
> 
> On ARM we can possibly do the optimization of asking the page allocator,
> but only if we can request _only_ highmem pages.
> 

So this memory allocation strategy should only apply to ARM and not x86 we
already had fall out couple year ago when Ubuntu decided to enable CMA on
x86 where it does not make sense as i don't think we have any single device
we care that is not behind an IOMMU and thus does not require contiguous
memory allocation.

The DMA API should only use CMA on architecture where it is necessary not
on all of them.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
