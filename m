Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C72856B02E1
	for <linux-mm@kvack.org>; Tue,  2 May 2017 07:48:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b20so1437684wma.11
        for <linux-mm@kvack.org>; Tue, 02 May 2017 04:48:08 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id p12si2562616wmb.36.2017.05.02.04.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 04:48:07 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id u65so3750024wmu.3
        for <linux-mm@kvack.org>; Tue, 02 May 2017 04:48:07 -0700 (PDT)
Date: Tue, 2 May 2017 14:37:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm, zone_device: replace {get,
 put}_zone_device_page() with a single reference
Message-ID: <20170502113746.5ybuix3lnvlk7kxt@node.shutemov.name>
References: <CAPcyv4jCfMwthPwbE-iuvef1KkMYUtA=qAydgfJzH0_otXoAOg@mail.gmail.com>
 <1579714997.4315035.1493402406629.JavaMail.zimbra@redhat.com>
 <CAPcyv4hvBKG8t3e3QvUnmkaopeM8eTniz5JPVkrZ5Puu5eaViw@mail.gmail.com>
 <1295710462.4327805.1493406971970.JavaMail.zimbra@redhat.com>
 <CAPcyv4i+iPm=hBviOYABaroz_JJYVy8Qja8Ka=-_uAQNnGjpeg@mail.gmail.com>
 <20170428193305.GA3912@redhat.com>
 <20170429101726.cdczojcjjupb7myy@node.shutemov.name>
 <20170430231421.GA15163@redhat.com>
 <20170501102359.abopw7hpd4eb6x2w@node.shutemov.name>
 <20170501135545.GA16772@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170501135545.GA16772@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Mon, May 01, 2017 at 09:55:48AM -0400, Jerome Glisse wrote:
> On Mon, May 01, 2017 at 01:23:59PM +0300, Kirill A. Shutemov wrote:
> > On Sun, Apr 30, 2017 at 07:14:24PM -0400, Jerome Glisse wrote:
> > > On Sat, Apr 29, 2017 at 01:17:26PM +0300, Kirill A. Shutemov wrote:
> > > > On Fri, Apr 28, 2017 at 03:33:07PM -0400, Jerome Glisse wrote:
> > > > > On Fri, Apr 28, 2017 at 12:22:24PM -0700, Dan Williams wrote:
> > > > > > Are you sure about needing to hook the 2 -> 1 transition? Could we
> > > > > > change ZONE_DEVICE pages to not have an elevated reference count when
> > > > > > they are created so you can keep the HMM references out of the mm hot
> > > > > > path?
> > > > > 
> > > > > 100% sure on that :) I need to callback into driver for 2->1 transition
> > > > > no way around that. If we change ZONE_DEVICE to not have an elevated
> > > > > reference count that you need to make a lot more change to mm so that
> > > > > ZONE_DEVICE is never use as fallback for memory allocation. Also need
> > > > > to make change to be sure that ZONE_DEVICE page never endup in one of
> > > > > the path that try to put them back on lru. There is a lot of place that
> > > > > would need to be updated and it would be highly intrusive and add a
> > > > > lot of special cases to other hot code path.
> > > > 
> > > > Could you explain more on where the requirement comes from or point me to
> > > > where I can read about this.
> > > > 
> > > 
> > > HMM ZONE_DEVICE pages are use like other pages (anonymous or file back page)
> > > in _any_ vma. So i need to know when a page is freed ie either as result of
> > > unmap, exit or migration or anything that would free the memory. For zone
> > > device a page is free once its refcount reach 1 so i need to catch refcount
> > > transition from 2->1
> > 
> > What if we would rework zone device to have pages with refcount 0 at
> > start?
> 
> That is a _lot_ of work from top of my head because it would need changes
> to a lot of places and likely more hot code path that simply adding some-
> thing to put_page() note that i only need something in put_page() i do not
> need anything in the get page path. Is adding a conditional branch for
> HMM pages in put_page() that much of a problem ?

Well, it gets inlined everywhere. Removing zone_device code from
get_page() and put_page() saved non-trivial ~140k in vmlinux for
allyesconfig.

Re-introducing part this bloat would be unfortunate.

> > > This is the only way i can inform the device that the page is now free. See
> > > 
> > > https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v21&id=52da8fe1a088b87b5321319add79e43b8372ed7d
> > > 
> > > There is _no_ way around that.
> > 
> > I'm still not convinced that it's impossible.
> > 
> > Could you describe lifecycle for pages in case of HMM?
> 
> Process malloc something, end it over to some function in the program
> that use the GPU that function call GPU API (OpenCL, CUDA, ...) that
> trigger a migration to device memory.
> 
> So in the kernel you get a migration like any existing migration,
> original page is unmap, if refcount is all ok (no pin) then a device
> page is allocated and thing are migrated to device memory.
> 
> What happen after is unknown. Either userspace/kernel driver decide
> to migrate back to system memory, either there is an munmap, either
> there is a CPU page fault, ... So from that point on the device page
> as the exact same life as a regular page.
> 
> Above i describe the migrate case, but you can also have new memory
> allocation that directly allocate device memory. For instance if the
> GPU do a page fault on an address that isn't back by anything then
> we can directly allocate a device page. No migration involve in that
> case.
> 
> HMM pages are like any other pages in most respect. Exception are:
>   - no GUP

Hm. How do you exclude GUP? And why is it required?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
