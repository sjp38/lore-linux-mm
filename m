Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2096B7025
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 13:45:11 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id m16so9549341pgd.0
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 10:45:11 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c11si16433967pgh.18.2018.12.04.10.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 10:45:09 -0800 (PST)
Message-ID: <b8841553115fb63b348e466995338a4d4b13b6f5.camel@linux.intel.com>
Subject: Re: [PATCH RFC 0/3] Fix KVM misinterpreting Reserved page as an
 MMIO page
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Tue, 04 Dec 2018 10:45:08 -0800
In-Reply-To: <20181204065914.GB73736@tiger-server>
References: 
	<154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
	 <20181204065914.GB73736@tiger-server>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yi Zhang <yi.z.zhang@linux.intel.com>
Cc: dan.j.williams@intel.com, pbonzini@redhat.com, brho@google.com, kvm@vger.kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de, rkrcmar@redhat.com, jglisse@redhat.com

On Tue, 2018-12-04 at 14:59 +0800, Yi Zhang wrote:
> On 2018-12-03 at 11:25:20 -0800, Alexander Duyck wrote:
> > I have loosely based this patch series off of the following patch series
> > from Zhang Yi:
> > https://lore.kernel.org/lkml/cover.1536342881.git.yi.z.zhang@linux.intel.com
> > 
> > The original set had attempted to address the fact that DAX pages were
> > treated like MMIO pages which had resulted in reduced performance. It
> > attempted to address this by ignoring the PageReserved flag if the page
> > was either a DEV_DAX or FS_DAX page.
> > 
> > I am proposing this as an alternative to that set. The main reason for this
> > is because I believe there are a few issues that were overlooked with that
> > original set. Specifically KVM seems to have two different uses for the
> > PageReserved flag. One being whether or not we can pin the memory, the other
> > being if we should be marking the pages as dirty or accessed. I believe
> > only the pinning really applies so I have split the uses of
> > kvm_is_reserved_pfn and updated the function uses to determine support for
> > page pinning to include a check of the pgmap to see if it supports pinning.
> 
> kvm is not the only one users of the dax page.

Yes, but KVM and virtualization in general seems to be the place where
the code carrying the assumption that PageReserved == MMIO exists.

> A similar user of PageReserved to look at is:
>  drivers/vfio/vfio_iommu_type1.c:is_invalid_reserved_pfn(
> vfio is also want to know the page is capable for pinning.

I would lump vfio in with virtualization as I said above.

A quick search also shows that there is also
arch/x86/kvm/mmu.c:kvm_is_mmio_pfn() which had a similar assumption but
is already carrying workarounds.

> I throught that you have removed the reserved flag on the dax page
> 
> in https://patchwork.kernel.org/patch/10707267/
> 
> is something I missing here?

That patch wasn't about DAX memory. That patch was about the fact that
the reserved flag was expensive as a __set_bit operation. I was leaving
the bit set for DAX and all other hot-plug memory and not setting it
for deferred memory init.

The reserved bit is essentially meant to flag everything that is not
standard system RAM page. Historically speaking most of that was MMIO,
now that isn't necessarily the case with the introduction of
ZONE_DEVICE pages.

The issue is DAX isn't necessarily system RAM either. So if we don't
set the reserved bit for DAX then we have to go through and start
adding exception cases to the paths that handle system RAM to split it
off from DAX. Dan had pointed out one such example in
kernel/power/snapshot.c:saveable_page() as I recall.

> > 
> > ---
> > 
> > Alexander Duyck (3):
> >       kvm: Split use cases for kvm_is_reserved_pfn to kvm_is_refcounted_pfn
> >       mm: Add support for exposing if dev_pagemap supports refcount pinning
> >       kvm: Add additional check to determine if a page is refcounted
> > 
> > 
> >  arch/x86/kvm/mmu.c        |    6 +++---
> >  drivers/nvdimm/pfn_devs.c |    2 ++
> >  include/linux/kvm_host.h  |    2 +-
> >  include/linux/memremap.h  |    5 ++++-
> >  include/linux/mm.h        |   11 +++++++++++
> >  virt/kvm/kvm_main.c       |   34 +++++++++++++++++++++++++---------
> >  6 files changed, 46 insertions(+), 14 deletions(-)
> > 
> > --
