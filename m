Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 405396B0003
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 10:29:12 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 99-v6so17229022qkr.14
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 07:29:12 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r41-v6si4374658qtj.307.2018.08.13.07.29.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 07:29:10 -0700 (PDT)
Date: Mon, 13 Aug 2018 10:29:06 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH V3 3/4] mm: add a function to differentiate the pages is
 from DAX device memory
Message-ID: <20180813142906.GA3451@redhat.com>
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
 <2b7856596e519130946c834d5d61b00b7f592770.1533811181.git.yi.z.zhang@linux.intel.com>
 <872818364.892078.1533806608252.JavaMail.zimbra@redhat.com>
 <5ea50e63-b55a-c1e1-50be-6e2d951c04cf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5ea50e63-b55a-c1e1-50be-6e2d951c04cf@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Zhang,Yi" <yi.z.zhang@linux.intel.com>
Cc: Pankaj Gupta <pagupta@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, jack@suse.cz, hch@lst.de, yu c zhang <yu.c.zhang@intel.com>, linux-mm@kvack.org, rkrcmar@redhat.com, yi z zhang <yi.z.zhang@intel.com>

On Tue, Aug 14, 2018 at 01:41:40AM +0800, Zhang,Yi wrote:
> 
> 
> On 2018a1'08ae??09ae?JPY 17:23, Pankaj Gupta wrote:
> >> DAX driver hotplug the device memory and move it to memory zone, these
> >> pages will be marked reserved flag, however, some other kernel componet
> >> will misconceive these pages are reserved mmio (ex: we map these dev_dax
> >> or fs_dax pages to kvm for DIMM/NVDIMM backend). Together with the type
> >> MEMORY_DEVICE_FS_DAX, we can use is_dax_page() to differentiate the pages
> >> is DAX device memory or not.
> >>
> >> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
> >> Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
> >> ---
> >>  include/linux/mm.h | 12 ++++++++++++
> >>  1 file changed, 12 insertions(+)
> >>
> >> diff --git a/include/linux/mm.h b/include/linux/mm.h
> >> index 68a5121..de5cbc3 100644
> >> --- a/include/linux/mm.h
> >> +++ b/include/linux/mm.h
> >> @@ -889,6 +889,13 @@ static inline bool is_device_public_page(const struct
> >> page *page)
> >>  		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
> >>  }
> >>  
> >> +static inline bool is_dax_page(const struct page *page)
> >> +{
> >> +	return is_zone_device_page(page) &&
> >> +		(page->pgmap->type == MEMORY_DEVICE_FS_DAX ||
> >> +		page->pgmap->type == MEMORY_DEVICE_DEV_DAX);
> >> +}
> > I think question from Dan for KVM VM with 'MEMORY_DEVICE_PUBLIC' still holds?
> > I am also interested to know if there is any use-case.
> >
> > Thanks,
> > Pankaj
> Yes, it is, thanks for your remind, Pankaj.
> Adding Jerome for Dan's questions on V1:
> [Dan]:
> 
> Jerome, might there be any use case to pass MEMORY_DEVICE_PUBLIC
> memory to a guest vm?

Yes and no, i am not sure how we are going to do it. But being able to
share GPU among multiple VM is on TODO list and those GPU will have
MEMORY_DEVICE_PUBLIC|PRIVATE depending on the platform. So either we
pass down the real underlying resource to the guest, or we will pass
down a fake one and have guest and host driver talk to each other so
that the host driver can do overall resource management accross multiple
guests.

So i would say that for now you can ignore MEMORY_DEVICE_PUBLIC and when
we get to the KVM guest sharing of those and decide how we want to do
it then we can update kvm to properly interpret those.

Cheers,
JA(C)rA'me
