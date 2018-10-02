Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07BBB6B000E
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 09:55:18 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y7-v6so2253714plp.16
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 06:55:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bj3-v6si16292237plb.12.2018.10.02.06.55.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 06:55:16 -0700 (PDT)
Date: Tue, 2 Oct 2018 15:55:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Introduce new function vm_insert_kmem_page
Message-ID: <20181002135506.GU18290@dhcp22.suse.cz>
References: <20180927175123.GA16367@jordon-HP-15-Notebook-PC>
 <20180927183236.GJ6278@dhcp22.suse.cz>
 <CAFqt6zbnV+wV+O2EMi1mE4qWDjsZ=Y847MFUc+zv6g8OoVM30g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zbnV+wV+O2EMi1mE4qWDjsZ=Y847MFUc+zv6g8OoVM30g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, pasha.tatashin@oracle.com, riel@redhat.com, Matthew Wilcox <willy@infradead.org>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Huang, Ying" <ying.huang@intel.com>, ak@linux.intel.com, rppt@linux.vnet.ibm.com, linux@dominikbrodowski.net, Arnd Bergmann <arnd@arndb.de>, mcgrof@kernel.org, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri 28-09-18 17:57:17, Souptick Joarder wrote:
> On Fri, Sep 28, 2018 at 12:02 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 27-09-18 23:21:23, Souptick Joarder wrote:
> > > vm_insert_kmem_page is similar to vm_insert_page and will
> > > be used by drivers to map kernel (kmalloc/vmalloc/pages)
> > > allocated memory to user vma.
> > >
> > > Previously vm_insert_page is used for both page fault
> > > handlers and outside page fault handlers context. When
> > > vm_insert_page is used in page fault handlers context,
> > > each driver have to map errno to VM_FAULT_CODE in their
> > > own way. But as part of vm_fault_t migration all the
> > > page fault handlers are cleaned up by using new vmf_insert_page.
> > > Going forward, vm_insert_page will be removed by converting
> > > it to vmf_insert_page.
> > >
> > > But their are places where vm_insert_page is used outside
> > > page fault handlers context and converting those to
> > > vmf_insert_page is not a good approach as drivers will end
> > > up with new VM_FAULT_CODE to errno conversion code and it will
> > > make each user more complex.
> > >
> > > So this new vm_insert_kmem_page can be used to map kernel
> > > memory to user vma outside page fault handler context.
> > >
> > > In short, vmf_insert_page will be used in page fault handlers
> > > context and vm_insert_kmem_page will be used to map kernel
> > > memory to user vma outside page fault handlers context.
> > >
> > > We will slowly convert all the user of vm_insert_page to
> > > vm_insert_kmem_page after this API be available in linus tree.
> >
> > In general I do not like patches adding a new exports/functionality
> > without any user added at the same time. I am not going to look at the
> > implementation right now but the above opens more questions than it
> > gives answers. Why do we have to distinguish #PF from other paths?
> 
> Going forward, the plan is to restrict future drivers not to use vm_insert_page
> ( *it will generate new errno to VM_FAULT_CODE mapping code for new drivers
> which were already cleaned up for existing drivers*) in #PF context but to make
> use of vmf_insert_page which returns VMF_FAULT_CODE and that is not possible
> until both vm_insert_page and vmf_insert_page API exists.
> 
> But there are some consumers of vm_insert_page which use it outside #PF context.
> straight forward conversion of vm_insert_page to vmf_insert_page won't
> work there as
> those function calls expects errno not vm_fault_t in return.
> 
> e.g - drivers/auxdisplay/cfag12864bfb.c, line 55
>         drivers/auxdisplay/ht16k33.c, line 227
>         drivers/firewire/core-iso.c, line 115
>         drivers/gpu/drm/rockchip/rockchip_drm_gem.c, line 237
>         drivers/gpu/drm/xen/xen_drm_front_gem.c, line 253
>         drivers/iommu/dma-iommu.c, line 600
>         drivers/media/common/videobuf2/videobuf2-dma-sg.c, line 343
>         drivers/media/usb/usbvision/usbvision-video.c, line 1056
>         drivers/xen/gntalloc.c, line 548
>         drivers/xen/gntdev.c, line 1149
>         drivers/xen/privcmd-buf.c, line 184
>         mm/vmalloc.c, line 2254
>         net/ipv4/tcp.c, line 1806
>         net/packet/af_packet.c, line 4407
> 
> These are the approaches which could have been taken to handle this scenario -
> 
> 1. Replace vm_insert_page with vmf_insert_page and then write few
>    extra lines of code to convert VM_FAULT_CODE to errno which
>    makes driver users more complex ( also the reverse mapping errno to
>    VM_FAULT_CODE have been cleaned up as part of vm_fault_t migration ,
>    not preferred to introduce anything similar again)
> 
> 2. Maintain both vm_insert_page and vmf_insert_page and use it in
>    respective places. But it won't gurantee that vm_insert_page will
>    never be used in #PF context.
> 
> 3. Introduce a similar API like vm_insert_page, convert all non #PF
>    consumer to use it and finally remove vm_insert_page by converting
>    it to vmf_insert_page.
> 
> And the 3rd approach was taken by introducing vm_insert_kmem_page().

OK, the make sure to convert some of those users in the same patch. This
will allow both to review the api and that it serves it purpose. Other
users can also see how the initial conversion has been done and do it in
a similar way.

-- 
Michal Hocko
SUSE Labs
