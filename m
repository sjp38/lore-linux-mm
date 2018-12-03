Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 656C56B6AEF
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 15:31:21 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id s140so8995578oih.4
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 12:31:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m7sor6727998oic.162.2018.12.03.12.31.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 12:31:20 -0800 (PST)
MIME-Version: 1.0
References: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
 <154386513120.27193.7977541941078967487.stgit@ahduyck-desk1.amr.corp.intel.com>
 <CAPcyv4gZkx9zRsKkVhrmPG7SyjPEycp0neFnECmSADZNLuDOpQ@mail.gmail.com> <97943d2ed62e6887f4ba51b985ef4fb5478bc586.camel@linux.intel.com>
In-Reply-To: <97943d2ed62e6887f4ba51b985ef4fb5478bc586.camel@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 3 Dec 2018 12:31:08 -0800
Message-ID: <CAPcyv4i=FL4f34H2_1mgWMk=UyyaXFaKPh5zJSnFNyN3cBoJhA@mail.gmail.com>
Subject: Re: [PATCH RFC 2/3] mm: Add support for exposing if dev_pagemap
 supports refcount pinning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@linux.intel.com
Cc: Paolo Bonzini <pbonzini@redhat.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Barret Rhoden <brho@google.com>, KVM list <kvm@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, David Hildenbrand <david@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, rkrcmar@redhat.com, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Mon, Dec 3, 2018 at 12:21 PM Alexander Duyck
<alexander.h.duyck@linux.intel.com> wrote:
>
> On Mon, 2018-12-03 at 11:47 -0800, Dan Williams wrote:
> > On Mon, Dec 3, 2018 at 11:25 AM Alexander Duyck
> > <alexander.h.duyck@linux.intel.com> wrote:
> > >
> > > Add a means of exposing if a pagemap supports refcount pinning. I am doing
> > > this to expose if a given pagemap has backing struct pages that will allow
> > > for the reference count of the page to be incremented to lock the page
> > > into place.
> > >
> > > The KVM code already has several spots where it was trying to use a
> > > pfn_valid check combined with a PageReserved check to determien if it could
> > > take a reference on the page. I am adding this check so in the case of the
> > > page having the reserved flag checked we can check the pagemap for the page
> > > to determine if we might fall into the special DAX case.
> > >
> > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > ---
> > >  drivers/nvdimm/pfn_devs.c |    2 ++
> > >  include/linux/memremap.h  |    5 ++++-
> > >  include/linux/mm.h        |   11 +++++++++++
> > >  3 files changed, 17 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> > > index 6f22272e8d80..7a4a85bcf7f4 100644
> > > --- a/drivers/nvdimm/pfn_devs.c
> > > +++ b/drivers/nvdimm/pfn_devs.c
> > > @@ -640,6 +640,8 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
> > >         } else
> > >                 return -ENXIO;
> > >
> > > +       pgmap->support_refcount_pinning = true;
> > > +
> >
> > There should be no dev_pagemap instance instance where this isn't
> > true, so I'm missing why this is needed?
>
> I thought in the case of HMM there were instances where you couldn't
> pin the page, isn't there? Specifically I am thinking of the definition
> of MEMORY_DEVICE_PUBLIC:
>   Device memory that is cache coherent from device and CPU point of
>   view. This is use on platform that have an advance system bus (like
>   CAPI or CCIX). A driver can hotplug the device memory using
>   ZONE_DEVICE and with that memory type. Any page of a process can be
>   migrated to such memory. However no one should be allow to pin such
>   memory so that it can always be evicted.
>
> It sounds like MEMORY_DEVICE_PUBLIC and MMIO would want to fall into
> the same category here in order to allow a hot-plug event to remove the
> device and take the memory with it, or is my understanding on this not
> correct?

I don't understand how HMM expects to enforce no pinning, but in any
event it should always be the expectation an elevated reference count
on a page prevents that page from disappearing. Anything else is
broken.
