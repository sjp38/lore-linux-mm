Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1651D6B0006
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:39:14 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g72-v6so6551525pfk.9
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 18:39:14 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v14-v6si25607777plo.208.2018.10.10.18.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 18:39:12 -0700 (PDT)
Date: Thu, 11 Oct 2018 16:17:54 +0800
From: Yi Zhang <yi.z.zhang@linux.intel.com>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20181011081754.GA51021@tiger-server>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20181009170051.GA40606@tiger-server>
 <CAPcyv4g99_rJJSn0kWv5YO0Mzj90q1LH1wC3XrjCh1=x6mo7BQ@mail.gmail.com>
 <25092df0-b7b4-d456-8409-9c004cb6e422@linux.intel.com>
 <CAPcyv4gZV_V=iY0mHiiAWwbynqtPxLTwdZ0j0vQ0F95ZZ4nTZg@mail.gmail.com>
 <20181010125211.GA45572@tiger-server>
 <deb1264e-5a42-3467-9073-e829b8eab8ca@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <deb1264e-5a42-3467-9073-e829b8eab8ca@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 2018-10-10 at 08:27:58 -0700, Alexander Duyck wrote:
> 
> 
> On 10/10/2018 5:52 AM, Yi Zhang wrote:
> >On 2018-10-09 at 14:19:32 -0700, Dan Williams wrote:
> >>On Tue, Oct 9, 2018 at 1:34 PM Alexander Duyck
> >><alexander.h.duyck@linux.intel.com> wrote:
> >>>
> >>>On 10/9/2018 11:04 AM, Dan Williams wrote:
> >>>>On Tue, Oct 9, 2018 at 3:21 AM Yi Zhang <yi.z.zhang@linux.intel.com> wrote:
> >>[..]
> >>>>That comment is incorrect, device-pages are never onlined. So I think
> >>>>we can just skip that call to __SetPageReserved() unless the memory
> >>>>range is MEMORY_DEVICE_{PRIVATE,PUBLIC}.
> >>>>
> >>>
> >>>When pages are "onlined" via __free_pages_boot_core they clear the
> >>>reserved bit, that is the reason for the comment. The reserved bit is
> >>>meant to indicate that the page cannot be swapped out or moved based on
> >>>the description of the bit.
> >>
> >>...but ZONE_DEVICE pages are never onlined so I would expect
> >>memmap_init_zone_device() to know that detail.
> >>
> >>>I would think with that being the case we still probably need the call
> >>>to __SetPageReserved to set the bit with the expectation that it will
> >>>not be cleared for device-pages since the pages are not onlined.
> >>>Removing the call to __SetPageReserved would probably introduce a number
> >>>of regressions as there are multiple spots that use the reserved bit to
> >>>determine if a page can be swapped out to disk, mapped as system memory,
> >>>or migrated.
> >
> >Another things, it seems page_init/set_reserved already been done in the
> >move_pfn_range_to_zone
> >     |-->memmap_init_zone
> >     	|-->for_each_page_in_pfn
> >		|-->__init_single_page
> >		|-->SetPageReserved
> >
> >Why we haven't remove these redundant initial in memmap_init_zone?
> >
> >Correct me if I missed something.
> 
> In this case it isn't redundant as only the vmmemmap pages are initialized
> in memmap_init_zone now. So all of the pages that are going to be used as
> device pages are not initialized until the call to memmap_init_zone_device.
> What I did is split the initialization of the pages into two parts in order
> to allow us to initialize the pages outside of the hotplug lock.
Ah.. I saw that, Thanks the explanation, so that is we only need to
care about the device pages reserved flag, and plan to remove that.
> 
> >>
> >>Right, this is what Yi is working on... the PageReserved flag is
> >>problematic for KVM. Auditing those locations it seems as long as we
> >>teach hibernation to avoid ZONE_DEVICE ranges we can safely not set
> >>the reserved flag for DAX pages. What I'm trying to avoid is a local
> >>KVM hack to check for DAX pages when the Reserved flag is not
> >>otherwise needed.
> >Thanks Dan. Provide the patch link.
> >
> >https://lore.kernel.org/lkml/cover.1536342881.git.yi.z.zhang@linux.intel.com
> 
> So it looks like your current logic is just working around the bit then
> since it just allows for reserved DAX pages.
> 
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
