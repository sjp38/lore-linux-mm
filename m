Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E17AC6B025E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 05:26:09 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o3so44077854wjo.1
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 02:26:09 -0800 (PST)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id kk2si4531883wjb.71.2016.12.02.02.26.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 02:26:08 -0800 (PST)
Message-ID: <1480674362.17003.44.camel@pengutronix.de>
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy
 busy
From: Lucas Stach <l.stach@pengutronix.de>
Date: Fri, 02 Dec 2016 11:26:02 +0100
In-Reply-To: <20161201141125.GB20966@dhcp22.suse.cz>
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net>
	 <20161130092239.GD18437@dhcp22.suse.cz> <xa1ty4012k0f.fsf@mina86.com>
	 <20161130132848.GG18432@dhcp22.suse.cz>
	 <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
	 <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
	 <20161201071507.GC18272@dhcp22.suse.cz>
	 <20161201072119.GD18272@dhcp22.suse.cz>
	 <9f2aa4e4-d7d5-e24f-112e-a4b43f0a0ccc@suse.cz>
	 <20161201141125.GB20966@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>

Am Donnerstag, den 01.12.2016, 15:11 +0100 schrieb Michal Hocko:
> Let's also CC Marek
> 
> On Thu 01-12-16 08:43:40, Vlastimil Babka wrote:
> > On 12/01/2016 08:21 AM, Michal Hocko wrote:
> > > Forgot to CC Joonsoo. The email thread starts more or less here
> > > http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz
> > > 
> > > On Thu 01-12-16 08:15:07, Michal Hocko wrote:
> > > > On Wed 30-11-16 20:19:03, Robin H. Johnson wrote:
> > > > [...]
> > > > > alloc_contig_range: [83f2a3, 83f2a4) PFNs busy
> > > > 
> > > > Huh, do I get it right that the request was for a _single_ page? Why do
> > > > we need CMA for that?
> > 
> > Ugh, good point. I assumed that was just the PFNs that it failed to migrate
> > away, but it seems that's indeed the whole requested range. Yeah sounds some
> > part of the dma-cma chain could be smarter and attempt CMA only for e.g.
> > costly orders.
> 
> Is there any reason why the DMA api doesn't try the page allocator first
> before falling back to the CMA? I simply have a hard time to see why the
> CMA should be used (and fragment) for small requests size.

On x86 that is true, but on ARM CMA is the only (low memory) region that
can change the memory attributes, by being excluded from the lowmem
section mapping. Changing the memory attributes to
uncached/writecombined for DMA is crucial on ARM to fulfill the
requirement that no there aren't any conflicting mappings of the same
physical page.

On ARM we can possibly do the optimization of asking the page allocator,
but only if we can request _only_ highmem pages.

Regards,
Lucas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
