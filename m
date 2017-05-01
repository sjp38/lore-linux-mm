Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0FD6B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 16:32:42 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c41so12173098qkh.23
        for <linux-mm@kvack.org>; Mon, 01 May 2017 13:32:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r186si14438741qkc.267.2017.05.01.13.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 13:32:41 -0700 (PDT)
Date: Mon, 1 May 2017 16:32:37 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v2] mm, zone_device: replace {get,
 put}_zone_device_page() with a single reference
Message-ID: <20170501203236.GA20927@redhat.com>
References: <1579714997.4315035.1493402406629.JavaMail.zimbra@redhat.com>
 <CAPcyv4hvBKG8t3e3QvUnmkaopeM8eTniz5JPVkrZ5Puu5eaViw@mail.gmail.com>
 <1295710462.4327805.1493406971970.JavaMail.zimbra@redhat.com>
 <CAPcyv4i+iPm=hBviOYABaroz_JJYVy8Qja8Ka=-_uAQNnGjpeg@mail.gmail.com>
 <20170428193305.GA3912@redhat.com>
 <20170429101726.cdczojcjjupb7myy@node.shutemov.name>
 <20170430231421.GA15163@redhat.com>
 <20170501102359.abopw7hpd4eb6x2w@node.shutemov.name>
 <20170501135545.GA16772@redhat.com>
 <CAPcyv4gFMyXhqY9enam5v9nFwjSULLE=PUEqGP0psLMcA9fzDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4gFMyXhqY9enam5v9nFwjSULLE=PUEqGP0psLMcA9fzDA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Mon, May 01, 2017 at 01:19:24PM -0700, Dan Williams wrote:
> On Mon, May 1, 2017 at 6:55 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> > On Mon, May 01, 2017 at 01:23:59PM +0300, Kirill A. Shutemov wrote:
> >> On Sun, Apr 30, 2017 at 07:14:24PM -0400, Jerome Glisse wrote:
> >> > On Sat, Apr 29, 2017 at 01:17:26PM +0300, Kirill A. Shutemov wrote:
> >> > > On Fri, Apr 28, 2017 at 03:33:07PM -0400, Jerome Glisse wrote:
> >> > > > On Fri, Apr 28, 2017 at 12:22:24PM -0700, Dan Williams wrote:
> >> > > > > Are you sure about needing to hook the 2 -> 1 transition? Could we
> >> > > > > change ZONE_DEVICE pages to not have an elevated reference count when
> >> > > > > they are created so you can keep the HMM references out of the mm hot
> >> > > > > path?
> >> > > >
> >> > > > 100% sure on that :) I need to callback into driver for 2->1 transition
> >> > > > no way around that. If we change ZONE_DEVICE to not have an elevated
> >> > > > reference count that you need to make a lot more change to mm so that
> >> > > > ZONE_DEVICE is never use as fallback for memory allocation. Also need
> >> > > > to make change to be sure that ZONE_DEVICE page never endup in one of
> >> > > > the path that try to put them back on lru. There is a lot of place that
> >> > > > would need to be updated and it would be highly intrusive and add a
> >> > > > lot of special cases to other hot code path.
> >> > >
> >> > > Could you explain more on where the requirement comes from or point me to
> >> > > where I can read about this.
> >> > >
> >> >
> >> > HMM ZONE_DEVICE pages are use like other pages (anonymous or file back page)
> >> > in _any_ vma. So i need to know when a page is freed ie either as result of
> >> > unmap, exit or migration or anything that would free the memory. For zone
> >> > device a page is free once its refcount reach 1 so i need to catch refcount
> >> > transition from 2->1
> >>
> >> What if we would rework zone device to have pages with refcount 0 at
> >> start?
> >
> > That is a _lot_ of work from top of my head because it would need changes
> > to a lot of places and likely more hot code path that simply adding some-
> > thing to put_page() note that i only need something in put_page() i do not
> > need anything in the get page path. Is adding a conditional branch for
> > HMM pages in put_page() that much of a problem ?
> >
> >
> >> > This is the only way i can inform the device that the page is now free. See
> >> >
> >> > https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v21&id=52da8fe1a088b87b5321319add79e43b8372ed7d
> >> >
> >> > There is _no_ way around that.
> >>
> >> I'm still not convinced that it's impossible.
> >>
> >> Could you describe lifecycle for pages in case of HMM?
> >
> > Process malloc something, end it over to some function in the program
> > that use the GPU that function call GPU API (OpenCL, CUDA, ...) that
> > trigger a migration to device memory.
> >
> > So in the kernel you get a migration like any existing migration,
> > original page is unmap, if refcount is all ok (no pin) then a device
> > page is allocated and thing are migrated to device memory.
> >
> > What happen after is unknown. Either userspace/kernel driver decide
> > to migrate back to system memory, either there is an munmap, either
> > there is a CPU page fault, ... So from that point on the device page
> > as the exact same life as a regular page.
> >
> > Above i describe the migrate case, but you can also have new memory
> > allocation that directly allocate device memory. For instance if the
> > GPU do a page fault on an address that isn't back by anything then
> > we can directly allocate a device page. No migration involve in that
> > case.
> >
> > HMM pages are like any other pages in most respect. Exception are:
> >   - no GUP
> >   - no KSM
> >   - no lru reclaim
> >   - no NUMA balancing
> >   - no regular migration (existing migrate_page)
> >
> > The fact that minimum refcount for ZONE_DEVICE is 1 already gives
> > us for free most of the above exception. To convert the refcount to
> > be like other pages would mean that all of the above would need to
> > be audited and probably modify to ignore ZONE_DEVICE pages (i am
> > pretty sure Dan do not want any of the above either).
> 
> Right, adding HMM references to get_page() and put_page() seems less
> intrusive. Given how uncommon HMM hardware is (insert grumble about no
> visible upstream user of this functionality) I think the 'static
> branch' approach helps mitigate the impact for everything else.
> Looking back, I should have used that mechanism for the pmem use case,
> but it's moot now.

I do not need anything in get_page() all i need is something in put_page()
to catch the 2 -> 1 refcount transition to know when a page is freed.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
