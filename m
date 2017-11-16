Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE106B0033
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 16:29:10 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id b189so230738oia.10
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 13:29:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g84si638797oia.409.2017.11.16.13.29.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 13:29:09 -0800 (PST)
Date: Thu, 16 Nov 2017 16:29:04 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Message-ID: <20171116212904.GA4823@redhat.com>
References: <CAA_GA1ff4mGKfxxRpjYCRjXOvbUuksM0K2gmH1VrhL4qtGWFbw@mail.gmail.com>
 <20170926161635.GA3216@redhat.com>
 <0d7273c3-181c-6d68-3c5f-fa518e782374@huawei.com>
 <20170930224927.GC6775@redhat.com>
 <CAA_GA1dhrs7n-ewZmW4bNtouK8rKnF1_TWv0z+2vrUgJjWpnMQ@mail.gmail.com>
 <20171012153721.GA2986@redhat.com>
 <CAAsGZS7JeH-cxrmZAVraLm5RjSVHJLXMdwZQ7Cxm91KGdVQocg@mail.gmail.com>
 <20171116024425.GC2934@redhat.com>
 <CAAsGZS5eoSK=Hd5av2bkw=chPGyfOYYNbrdizzCqq2gZ7+XH_g@mail.gmail.com>
 <CAAsGZS43n2_f9sQXGH5Ap=eEx2f099CDwHC0aTTgOEbw7Dc=zg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAAsGZS43n2_f9sQXGH5Ap=eEx2f099CDwHC0aTTgOEbw7Dc=zg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chetan L <loke.chetan@gmail.com>
Cc: Bob Liu <lliubbo@gmail.com>, David Nellans <dnellans@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-accelerators@lists.ozlabs.org

On Wed, Nov 15, 2017 at 07:29:10PM -0800, chetan L wrote:
> On Wed, Nov 15, 2017 at 7:23 PM, chetan L <loke.chetan@gmail.com> wrote:
> > On Wed, Nov 15, 2017 at 6:44 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> >> On Wed, Nov 15, 2017 at 06:10:08PM -0800, chet l wrote:
> >>> >> You may think it as a CCIX device or CAPI device.
> >>> >> The requirement is eliminate any extra copy.
> >>> >> A typical usecase/requirement is malloc() and madvise() allocate from
> >>> >> device memory, then CPU write data to device memory directly and
> >>> >> trigger device to read the data/do calculation.
> >>> >
> >>> > I suggest you rely on the device driver userspace API to do a migration after malloc
> >>> > then. Something like:
> >>> >   ptr = malloc(size);
> >>> >   my_device_migrate(ptr, size);
> >>> >
> >>> > Which would call an ioctl of the device driver which itself would migrate memory or
> >>> > allocate device memory for the range if pointer return by malloc is not yet back by
> >>> > any pages.
> >>> >
> >>>
> >>> So for CCIX, I don't think there is going to be an inline device
> >>> driver that would allocate any memory for you. The expansion memory
> >>> will become part of the system memory as part of the boot process. So,
> >>> if the host DDR is 256GB and the CCIX expansion memory is 4GB, the
> >>> total system mem will be 260GB.
> >>>
> >>> Assume that the 'mm' is taught to mark/anoint the ZONE_DEVICE(or
> >>> ZONE_XXX) range from 256 to 260 GB. Then, for kmalloc it(mm) won't use
> >>> the ZONE_DEV range. But for a malloc, it will/can use that range.
> >>
> >> HMM zone device memory would work with that, you just need to teach the
> >> platform to identify this memory zone and not hotplug it. Again you
> >> should rely on specific device driver API to allocate this memory.
> >>
> >
> > @Jerome - a new linux-accelerator's list has just been created. I have
> > CC'd that list since we have overlapping interests w.r.t CCIX.
> >
> > I cannot comment on surprise add/remove as of now ... will cross the
> > bridge later.

Note that this is not hotplug strictly speaking. Design today is that it
is the device driver that register the memory. From kernel point of view
this is an hotplug but for many of the target architecture there is no
real hotplug ie device and its memory was present at boot time.

Like i said i think for now we are better of having each device manage and
register its memory. HMM provide a toolbox for that. If we see common trend
accross multiple devices then we can think about making something more
generic.


For the NUMA discussion this is related to CPU less node ie not wanting
to add any more CPU less node (node with only memory) and they are other
aspect too. For instance you do not necessarily have good informations
from the device to know if a page is access a lot by the device (this
kind of information is often only accessible by the device driver). Thus
the automatic NUMA placement is useless here. Not mentioning that for it
to work we would need to change how it currently work (iirc there is
issue when you not have a CPU id you can use).

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
