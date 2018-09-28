Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8546F8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 11:50:59 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id c18-v6so1791130oiy.3
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 08:50:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d22-v6sor3142751otj.43.2018.09.28.08.50.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 08:50:58 -0700 (PDT)
MIME-Version: 1.0
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain> <20180926075540.GD6278@dhcp22.suse.cz>
 <6f87a5d7-05e2-00f4-8568-bb3521869cea@linux.intel.com> <20180927110926.GE6278@dhcp22.suse.cz>
 <20180927122537.GA20378@techadventures.net> <20180927131329.GI6278@dhcp22.suse.cz>
 <20180928081224.GA25561@techadventures.net> <20180928084433.GB25561@techadventures.net>
In-Reply-To: <20180928084433.GB25561@techadventures.net>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Sep 2018 08:50:46 -0700
Message-ID: <CAPcyv4hY97wL53Pa8oaq4UK6OS4R48_35nJhbY4SYmoMSctQHA@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Michal Hocko <mhocko@kernel.org>, alexander.h.duyck@linux.intel.com, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Jiang <dave.jiang@intel.com>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Logan Gunthorpe <logang@deltatee.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Sep 28, 2018 at 1:45 AM Oscar Salvador
<osalvador@techadventures.net> wrote:
>
> On Fri, Sep 28, 2018 at 10:12:24AM +0200, Oscar Salvador wrote:
> > Although I am not sure about leaving memmap_init_zone unprotected.
> > For the normal memory, that is not a problem since the memblock's lock
> > protects us from touching the same pages at the same time in online/offline_pages,
> > but for HMM/devm the story is different.
> >
> > I am totally unaware of HMM/devm, so I am not sure if its protected somehow.
> > e.g: what happens if devm_memremap_pages and devm_memremap_pages_release are running
> > at the same time for the same memory-range (with the assumption that the hotplug-lock
> > does not protect move_pfn_range_to_zone anymore).
>
> I guess that this could not happen since the device is not linked to devm_memremap_pages_release
> until the end with:
>
> devm_add_action(dev, devm_memremap_pages_release, pgmap)

It's a bug if devm_memremap_pages and devm_memremap_pages_release are
running simultaneously for the same range. This is enforced by the
requirement that the caller has done a successful request_region() on
the range before the call to map pages.
