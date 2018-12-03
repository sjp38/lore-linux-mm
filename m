Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A47C6B6AE4
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 15:21:44 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t72so12086441pfi.21
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 12:21:44 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id v3si13360077pgh.305.2018.12.03.12.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 12:21:43 -0800 (PST)
Message-ID: <97943d2ed62e6887f4ba51b985ef4fb5478bc586.camel@linux.intel.com>
Subject: Re: [PATCH RFC 2/3] mm: Add support for exposing if dev_pagemap
 supports refcount pinning
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 03 Dec 2018 12:21:42 -0800
In-Reply-To: <CAPcyv4gZkx9zRsKkVhrmPG7SyjPEycp0neFnECmSADZNLuDOpQ@mail.gmail.com>
References: 
	<154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
	 <154386513120.27193.7977541941078967487.stgit@ahduyck-desk1.amr.corp.intel.com>
	 <CAPcyv4gZkx9zRsKkVhrmPG7SyjPEycp0neFnECmSADZNLuDOpQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Barret Rhoden <brho@google.com>, KVM list <kvm@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, David Hildenbrand <david@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, rkrcmar@redhat.com, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>

On Mon, 2018-12-03 at 11:47 -0800, Dan Williams wrote:
> On Mon, Dec 3, 2018 at 11:25 AM Alexander Duyck
> <alexander.h.duyck@linux.intel.com> wrote:
> > 
> > Add a means of exposing if a pagemap supports refcount pinning. I am doing
> > this to expose if a given pagemap has backing struct pages that will allow
> > for the reference count of the page to be incremented to lock the page
> > into place.
> > 
> > The KVM code already has several spots where it was trying to use a
> > pfn_valid check combined with a PageReserved check to determien if it could
> > take a reference on the page. I am adding this check so in the case of the
> > page having the reserved flag checked we can check the pagemap for the page
> > to determine if we might fall into the special DAX case.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> >  drivers/nvdimm/pfn_devs.c |    2 ++
> >  include/linux/memremap.h  |    5 ++++-
> >  include/linux/mm.h        |   11 +++++++++++
> >  3 files changed, 17 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> > index 6f22272e8d80..7a4a85bcf7f4 100644
> > --- a/drivers/nvdimm/pfn_devs.c
> > +++ b/drivers/nvdimm/pfn_devs.c
> > @@ -640,6 +640,8 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
> >         } else
> >                 return -ENXIO;
> > 
> > +       pgmap->support_refcount_pinning = true;
> > +
> 
> There should be no dev_pagemap instance instance where this isn't
> true, so I'm missing why this is needed?

I thought in the case of HMM there were instances where you couldn't
pin the page, isn't there? Specifically I am thinking of the definition
of MEMORY_DEVICE_PUBLIC:
  Device memory that is cache coherent from device and CPU point of 
  view. This is use on platform that have an advance system bus (like 
  CAPI or CCIX). A driver can hotplug the device memory using 
  ZONE_DEVICE and with that memory type. Any page of a process can be 
  migrated to such memory. However no one should be allow to pin such 
  memory so that it can always be evicted.

It sounds like MEMORY_DEVICE_PUBLIC and MMIO would want to fall into
the same category here in order to allow a hot-plug event to remove the
device and take the memory with it, or is my understanding on this not
correct?

Thanks.

- Alex
