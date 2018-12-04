Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D578D6B6D64
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 01:59:33 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id l9so11870336plt.7
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 22:59:33 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q8si19106513pli.284.2018.12.03.22.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 22:59:32 -0800 (PST)
Date: Tue, 4 Dec 2018 14:59:15 +0800
From: Yi Zhang <yi.z.zhang@linux.intel.com>
Subject: Re: [PATCH RFC 0/3] Fix KVM misinterpreting Reserved page as an MMIO
 page
Message-ID: <20181204065914.GB73736@tiger-server>
References: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: dan.j.williams@intel.com, pbonzini@redhat.com, brho@google.com, kvm@vger.kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de, rkrcmar@redhat.com, jglisse@redhat.com

On 2018-12-03 at 11:25:20 -0800, Alexander Duyck wrote:
> I have loosely based this patch series off of the following patch series
> from Zhang Yi:
> https://lore.kernel.org/lkml/cover.1536342881.git.yi.z.zhang@linux.intel.com
> 
> The original set had attempted to address the fact that DAX pages were
> treated like MMIO pages which had resulted in reduced performance. It
> attempted to address this by ignoring the PageReserved flag if the page
> was either a DEV_DAX or FS_DAX page.
> 
> I am proposing this as an alternative to that set. The main reason for this
> is because I believe there are a few issues that were overlooked with that
> original set. Specifically KVM seems to have two different uses for the
> PageReserved flag. One being whether or not we can pin the memory, the other
> being if we should be marking the pages as dirty or accessed. I believe
> only the pinning really applies so I have split the uses of
> kvm_is_reserved_pfn and updated the function uses to determine support for
> page pinning to include a check of the pgmap to see if it supports pinning.
kvm is not the only one users of the dax page.

A similar user of PageReserved to look at is:
 drivers/vfio/vfio_iommu_type1.c:is_invalid_reserved_pfn(
vfio is also want to know the page is capable for pinning.

I throught that you have removed the reserved flag on the dax page

in https://patchwork.kernel.org/patch/10707267/

is something I missing here?

> 
> ---
> 
> Alexander Duyck (3):
>       kvm: Split use cases for kvm_is_reserved_pfn to kvm_is_refcounted_pfn
>       mm: Add support for exposing if dev_pagemap supports refcount pinning
>       kvm: Add additional check to determine if a page is refcounted
> 
> 
>  arch/x86/kvm/mmu.c        |    6 +++---
>  drivers/nvdimm/pfn_devs.c |    2 ++
>  include/linux/kvm_host.h  |    2 +-
>  include/linux/memremap.h  |    5 ++++-
>  include/linux/mm.h        |   11 +++++++++++
>  virt/kvm/kvm_main.c       |   34 +++++++++++++++++++++++++---------
>  6 files changed, 46 insertions(+), 14 deletions(-)
> 
> --
