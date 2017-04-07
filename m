Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D51746B03AA
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 12:26:42 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f133so3309891qke.19
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 09:26:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r6si5259858qkb.41.2017.04.07.09.26.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 09:26:41 -0700 (PDT)
Date: Fri, 7 Apr 2017 12:26:37 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 14/16] mm/hmm/devmem: device memory hotplug using
 ZONE_DEVICE
Message-ID: <20170407162636.GB15945@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
 <20170405204026.3940-15-jglisse@redhat.com>
 <1491529054.12351.16.camel@gmail.com>
 <20170407020254.GA13927@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170407020254.GA13927@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Thu, Apr 06, 2017 at 10:02:55PM -0400, Jerome Glisse wrote:
> On Fri, Apr 07, 2017 at 11:37:34AM +1000, Balbir Singh wrote:
> > On Wed, 2017-04-05 at 16:40 -0400, Jerome Glisse wrote:
> > > This introduce a simple struct and associated helpers for device driver
> > > to use when hotpluging un-addressable device memory as ZONE_DEVICE. It
> > > will find a unuse physical address range and trigger memory hotplug for
> > > it which allocates and initialize struct page for the device memory.
> > > 
> > > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > > Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
> > > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> > > Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> > > Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> > > Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> > > ---
> > >  include/linux/hmm.h | 114 +++++++++++++++
> > >  mm/Kconfig          |   9 ++
> > >  mm/hmm.c            | 398 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> > >  3 files changed, 521 insertions(+)
> > > 
> > > +/*
> > > + * To add (hotplug) device memory, HMM assumes that there is no real resource
> > > + * that reserves a range in the physical address space (this is intended to be
> > > + * use by unaddressable device memory). It will reserve a physical range big
> > > + * enough and allocate struct page for it.
> > 
> > I've found that the implementation of this is quite non-portable, in that
> > starting from iomem_resource.end+1-size (which is effectively -size) on
> > my platform (powerpc) does not give expected results. It could be that
> > additional changes are needed to arch_add_memory() to support this
> > use case.
> 
> The CDM version does not use that part, that being said isn't -size a valid
> value we care only about unsigned here ? What is the end value on powerpc ?
> In any case this sounds more like a unsigned/signed arithmetic issue, i will
> look into it.
> 
> > 
> > > +
> > > +	size = ALIGN(size, SECTION_SIZE);
> > > +	addr = (iomem_resource.end + 1ULL) - size;
> > 
> > 
> > Why don't we allocate_resource() with the right constraints and get a new
> > unused region?
> 
> The issue with allocate_resource() is that it does scan the resource tree
> from lower address to higher ones. I was told that it was less likely to
> have hotplug issue conflict if i pick highest physicall address for the
> device memory hence why i do my own scan from the end toward the start.
> 
> Again all this function does not apply to PPC, it can be hidden behind
> x86 config if you prefer it.

Ok so i have look into it and there is no arithmetic bug in my code the
issue is simpler than that. It seems only x86 clamp iomem_resource.end to
MAX_PHYSMEM_BITS so using allocate_resource() would just hide the issue.

It is fine not to clamp if you know that you won't get resource with
funky physical address but in case of UNADDRESSABLE i do not get any
physical address so i have to pick one and i want to pick one that is
unlikely to cause trouble latter on with someone hotpluging memory.

If we care about the UNADDRESSABLE case on powerpc i see 2 way to fix
this. Clamp iomem_resource.end to MAX_PHYSMEM_BITS or restrict my scan
in hmm to MIN(iomem_resource.end, 1UL << MAX_PHYSMEM_BITS) the latter
is probably safer and more bullet proof in respect to other arch getting
interested in this.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
