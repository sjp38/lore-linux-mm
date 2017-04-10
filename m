Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE6C6B0038
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 00:31:49 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x125so118578295pgb.5
        for <linux-mm@kvack.org>; Sun, 09 Apr 2017 21:31:49 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id t62si12500608pfd.320.2017.04.09.21.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Apr 2017 21:31:47 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id n11so7515978pfg.2
        for <linux-mm@kvack.org>; Sun, 09 Apr 2017 21:31:47 -0700 (PDT)
Message-ID: <1491798699.26188.1.camel@gmail.com>
Subject: Re: [HMM 14/16] mm/hmm/devmem: device memory hotplug using
 ZONE_DEVICE
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 10 Apr 2017 14:31:39 +1000
In-Reply-To: <20170407162636.GB15945@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
	 <20170405204026.3940-15-jglisse@redhat.com>
	 <1491529054.12351.16.camel@gmail.com> <20170407020254.GA13927@redhat.com>
	 <20170407162636.GB15945@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Fri, 2017-04-07 at 12:26 -0400, Jerome Glisse wrote:
> On Thu, Apr 06, 2017 at 10:02:55PM -0400, Jerome Glisse wrote:
> > On Fri, Apr 07, 2017 at 11:37:34AM +1000, Balbir Singh wrote:
> > > On Wed, 2017-04-05 at 16:40 -0400, JA(C)rA'me Glisse wrote:
> > > > This introduce a simple struct and associated helpers for device driver
> > > > to use when hotpluging un-addressable device memory as ZONE_DEVICE. It
> > > > will find a unuse physical address range and trigger memory hotplug for
> > > > it which allocates and initialize struct page for the device memory.
> > > > 
> > > > Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> > > > Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
> > > > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> > > > Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> > > > Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> > > > Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> > > > ---
> > > >  include/linux/hmm.h | 114 +++++++++++++++
> > > >  mm/Kconfig          |   9 ++
> > > >  mm/hmm.c            | 398 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> > > >  3 files changed, 521 insertions(+)
> > > > 
> > > > +/*
> > > > + * To add (hotplug) device memory, HMM assumes that there is no real resource
> > > > + * that reserves a range in the physical address space (this is intended to be
> > > > + * use by unaddressable device memory). It will reserve a physical range big
> > > > + * enough and allocate struct page for it.
> > > 
> > > I've found that the implementation of this is quite non-portable, in that
> > > starting from iomem_resource.end+1-size (which is effectively -size) on
> > > my platform (powerpc) does not give expected results. It could be that
> > > additional changes are needed to arch_add_memory() to support this
> > > use case.
> > 
> > The CDM version does not use that part, that being said isn't -size a valid
> > value we care only about unsigned here ? What is the end value on powerpc ?
> > In any case this sounds more like a unsigned/signed arithmetic issue, i will
> > look into it.
> > 

Thanks!

> > > 
> > > > +
> > > > +	size = ALIGN(size, SECTION_SIZE);
> > > > +	addr = (iomem_resource.end + 1ULL) - size;
> > > 
> > > 
> > > Why don't we allocate_resource() with the right constraints and get a new
> > > unused region?
> > 
> > The issue with allocate_resource() is that it does scan the resource tree
> > from lower address to higher ones. I was told that it was less likely to
> > have hotplug issue conflict if i pick highest physicall address for the
> > device memory hence why i do my own scan from the end toward the start.
> > 
> > Again all this function does not apply to PPC, it can be hidden behind
> > x86 config if you prefer it.
> 
> Ok so i have look into it and there is no arithmetic bug in my code the
> issue is simpler than that. It seems only x86 clamp iomem_resource.end to
> MAX_PHYSMEM_BITS so using allocate_resource() would just hide the issue.

> 
> It is fine not to clamp if you know that you won't get resource with
> funky physical address but in case of UNADDRESSABLE i do not get any
> physical address so i have to pick one and i want to pick one that is
> unlikely to cause trouble latter on with someone hotpluging memory.
> 
> If we care about the UNADDRESSABLE case on powerpc i see 2 way to fix
> this. Clamp iomem_resource.end to MAX_PHYSMEM_BITS or restrict my scan
> in hmm to MIN(iomem_resource.end, 1UL << MAX_PHYSMEM_BITS) the latter
> is probably safer and more bullet proof in respect to other arch getting
> interested in this.
>

We do care about UNADDRESSABLE for certain platforms on powerpc
 
I think MAX_PHYSMEM_BITS sounds good or we can make it an arch hook. I spoke
to Michael Ellerman and he recommended we do either. We can't clamp down
iomem_resource.end in the arch as we have other things beyond MAX_PHYSMEM_BITS,
but doing the walk in HMM from the end of MAX_PHYSMEM_BITS is a good idea to
begin with.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
