Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 886E56B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 20:08:28 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id b195-v6so4248427qkc.8
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 17:08:28 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j62-v6si2032559qte.255.2018.06.05.17.08.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 17:08:27 -0700 (PDT)
Date: Tue, 5 Jun 2018 20:08:23 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/5] mm: rework hmm to use devm_memremap_pages
Message-ID: <20180606000822.GE4423@redhat.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180524001026.GA3527@redhat.com>
 <CAPcyv4hVERZoqWrCxwOkmM075OP_ada7FiYsQgokijuWyC1MbA@mail.gmail.com>
 <CAPM=9tzMJq=KC+ijoj-JGmc1R3wbshdwtfR3Zpmyaw3jYJ9+gw@mail.gmail.com>
 <CAPcyv4g2XQtuYGPu8HMbPj6wXqGwxiL5jDRznf5fmW4WgC2DTw@mail.gmail.com>
 <CAPM=9twm=17t=2=M27ELB=vZWzpqM7GuwCUsC891jJ0t3JM4vg@mail.gmail.com>
 <CAPcyv4jTty4k1xXCOWbeRjzv-KjxNH1L4oOkWW1EbJt66jF4_w@mail.gmail.com>
 <20180605184811.GC4423@redhat.com>
 <CAPM=9twgL_tzkPO=V2mmecSzLjKJkEsJ8A4426fO2Nuus0N_UQ@mail.gmail.com>
 <CAPcyv4gSEYdnJKd=D-_yc3M=sY0HWjYzYhh5ha-v7KA4-40dsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4gSEYdnJKd=D-_yc3M=sY0HWjYzYhh5ha-v7KA4-40dsg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Airlie <airlied@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Jun 05, 2018 at 04:06:12PM -0700, Dan Williams wrote:
> On Tue, Jun 5, 2018 at 3:19 PM, Dave Airlie <airlied@gmail.com> wrote:
> > On 6 June 2018 at 04:48, Jerome Glisse <jglisse@redhat.com> wrote:
> >> On Tue, May 29, 2018 at 04:33:49PM -0700, Dan Williams wrote:
> >>> On Tue, May 29, 2018 at 4:00 PM, Dave Airlie <airlied@gmail.com> wrote:
> >>> > On 30 May 2018 at 08:31, Dan Williams <dan.j.williams@intel.com> wrote:

[...]

> >>> It honestly was an oversight, and as we've gone on to add deeper and
> >>> deeper ties into the mm and filesystems [1] I realized this symbol was
> >>> mis-labeled.  It would be one thing if this was just some random
> >>> kernel leaf / library function, but this capability when turned on
> >>> causes the entire kernel to be recompiled as things like the
> >>> definition of put_page() changes. It's deeply integrated with how
> >>> Linux manages memory.
> >>
> >> I am personaly on the fence on deciding GPL versus non GPL export
> >> base on subjective view of what is deeply integrated and what is
> >> not. I think one can argue that every single linux kernel function
> >> is deeply integrated within the kernel, starting with all device
> >> drivers functions. One could similarly argue that nothing is ...
> >
> > This is the point I wasn't making so well, the whole deciding on a derived
> > work from the pov of one of the works isn't really going to be how a court
> > looks at it.
> >
> > At day 0, you have a Linux kernel, and a separate Windows kernel driver,
> > clearly they are not derived works.
> >
> > You add interfaces to the Windows kernel driver and it becomes a Linux
> > kernel driver, you never ship them together, derived work only if those
> > interfaces are GPL only? or derived work only if shipped together?
> > only shipped together and GPL only? Clearly not a clearcut case here.
> >
> > The code base is 99% the same, the kernel changes an export to a GPL
> > export, the external driver hasn't changed one line of code, and it suddenly
> > becomes a derived work?
> >
> > Oversights happen, but 3 years of advertising an interface under the non-GPL
> > and changing it doesn't change whether the external driver is derived or not,
> > nor will it change anyone's legal position.
> 
> My concern is the long term health and maintainability of the Linux
> kernel. HMM exports deep Linux internals out to proprietary drivers
> with no way for folks in the wider kernel community to validate that
> the interfaces are necessary or sufficient besides "take Jerome's word
> for it". Every time I've pushed back on any HMM feature the response
> is something to the effect of, "no, out of tree drivers need this".
> HMM needs to grow upstream users and the functionality needs to be
> limited to whatever those upstream users exploit. Since there are no
> upstream users of HMM, we should delete it unless / until those users
> arrive.

The raison d'etre of HMM is to isolate driver from mm internal gut and
thus provide a clear contract and API to device driver. I tried to spell
that contract in include/linux/hmm.h which i can re-formulate shortly in:
  - provide call back when CPU try to access a device page so that
    memory can be migrated back to CPU accessible page under the
    control of the device driver for device synchronization reasons
    (the whole gory mm details is still in mm/migrate.c it just does
    provide way point in the migration process so that the device
    driver can synchronize and update the hardware along the way too)
  - provide a 64bits storage inside struct page so that the device
    driver can store either pointer to its internal data structure
    or store necessary informations there while page is in use in a
    process
  - inform device driver once a page is freed (ie no longer use in a
    process address space)

This virtualy isolate device driver from the inner gut of mm and allow
mm to change as long as we can keep this contract in place. As long as
device driver only use HMM API to perform any of the above and this is
my intention to push for that and try to enforce it as strongly as i
can.

Nouveau patchset have been posted and i will post newer updated version
this month and i hope this can get upstream in 4.19 abidding by the drm
sub-system requirement of having open source userspace upstream in mesa
project too (which have been under work for last few months).

This whole thing have been a big chicken and egg nightmare with moving
pieces everywhere. I wish i was better at getting all the pieces ready
at the same time but alas i was not.

> 
> I want the EXPORT_SYMBOL_GPL on devm_memremap_pages() primarily for
> development purposes. Any new users of devm_memremap_pages() should be
> aware that they are subscribing to the whims of the core-VM, i.e. the
> ongoing evolution of 'struct page', and encourage those drivers to be
> upstream to improve the implementation, and consolidate use cases. I'm
> not qualified to comment on your "nor will it change anyone's legal
> position.", but I'm saying it's in the Linux kernel's best interest
> that new users of this interface assume they need to be GPL.

Note that HMM isolate the device driver from struct page as long as
the driver only use HMM helpers to get to the information it needs.
I intend to be pedantic about that with any driver using HMM. I want
HMM to be an impedance layer that provide stable and simple API to
device driver while preserving freedom of change to mm.

Cheers,
Jerome
