Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 758336B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 16:17:32 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id m198so11824807oig.20
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 13:17:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d21sor3414044otf.333.2017.10.10.13.17.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 13:17:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171010180512.GA31734@obsidianresearch.com>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732935473.22363.1853399637339625023.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171009185840.GB15336@obsidianresearch.com> <CAPcyv4gXzC8OUgO_PciQ2phyq0YtmXjMGWvoPSVVuuZR7ohVCg@mail.gmail.com>
 <20171009191820.GD15336@obsidianresearch.com> <CAPcyv4h_uQGBAX6-bMkkZLO_YyQ6t4n_b8tH8wU_P0Jh23N5MQ@mail.gmail.com>
 <20171010172516.GA29915@obsidianresearch.com> <CAPcyv4jL5fN7jjXkQum8ERQ45eW63dCYp5Pm6aHY4OPudz4Wsw@mail.gmail.com>
 <20171010180512.GA31734@obsidianresearch.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Oct 2017 13:17:26 -0700
Message-ID: <CAPcyv4gCBu5ptmWyof+Z-p7NbuCygEs2rMe2wdL0n3QQbXhrzA@mail.gmail.com>
Subject: Re: [PATCH v7 07/12] dma-mapping: introduce dma_has_iommu()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux API <linux-api@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Oct 10, 2017 at 11:05 AM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> On Tue, Oct 10, 2017 at 10:39:27AM -0700, Dan Williams wrote:
>> On Tue, Oct 10, 2017 at 10:25 AM, Jason Gunthorpe
>
>> >> Have a look at the patch [1], I don't touch the ODP path.
>> >
>> > But, does ODP work OK already? I'm not clear on that..
>>
>> It had better. If the mapping is invalidated I would hope that
>> generates an io fault that gets handled by the driver to setup the new
>> mapping. I don't see how it can work otherwise.
>
> I would assume so too...
>
>> > This is why ODP should be the focus because this cannot work fully
>> > reliably otherwise..
>>
>> The lease break time is configurable. If that application can't
>> respond to a stop request within a timeout of its own choosing then it
>> should not be using DAX mappings.
>
> Well, no RDMA application can really do this, unless you set the
> timeout to multiple minutes, on par with network timeouts.

The default lease break timeout is 45 seconds on my system, so minutes
does not seem out of the question.

Also keep in mind that what triggers the lease break is another
application trying to write or punch holes in a file that is mapped
for RDMA. So, if the hardware can't handle the iommu mapping getting
invalidated asynchronously and the application can't react in the
lease break timeout period then the administrator should arrange for
the file to not be written or truncated while it is mapped.

It's already the case that get_user_pages() does not lock down file
associations, so if your application is contending with these types of
file changes it likely already has a problem keeping transactions in
sync with the file state even without DAX.

> Again, these details are why I think this kind of DAX and non ODP-MRs
> are probably practically not too useful for a production system. Great
> for test of course, but in that case SIGKILL would be fine too...
>
>> > Well, what about using SIGKILL if the lease-break-time hits? The
>> > kernel will clean up the MRs when the process exits and this will
>> > fence DMA to that memory.
>>
>> Can you point me to where the MR cleanup code fences DMA and quiesces
>> the device?
>
> Yes. The MR's are associated with an fd. When the fd is closed
> ib_uverbs_close triggers ib_uverbs_cleanup_ucontext which runs through
> all the objects, including MRs, and deletes them.
>
> The specification for deleting a MR requires a synchronous fence with
> the hardware. After MR deletion the hardware will not DMA to any pages
> described by the old MR, and those pages will be unpinned.
>
>> > But, still, if you really want to be fined graned, then I think
>> > invalidating the impacted MR's is a better solution for RDMA than
>> > trying to do it with the IOMMU...
>>
>> If there's a better routine for handling ib_umem_lease_break() I'd
>> love to use it. Right now I'm reaching for the only tool I know for
>> kernel enforced revocation of DMA access.
>
> Well, you'd have to code something in the MR code to keep track of DAX
> MRs and issue an out of band invalidate to impacted MRs to create the
> fence.
>
> This probably needs some driver work, I'm not sure if all the hardware
> can do out of band invalidate to any MR or not..

Ok.

>
> Generally speaking, in RDMA, when a new feature like this comes along
> we have to push a lot of the work down to the driver authors, and the
> approach has historically been that new features only work on some
> hardware (as much as I dislike this, it is pragmatic)
>
> So, not being able to support DAX on certain RDMA hardware is not
> an unreasonable situation in our space.

That makes sense, but it still seems to me that this proposed solution
allows more than enough ways to avoid that worst case scenario where
hardware reacts badly to iommu invalidation. Drivers that can do
better than iommu invalidation can arrange for a callback to do their
driver-specific action at lease break time. Hardware that can't should
be blacklisted from supporting DAX altogether. In other words this is
a starting point to incrementally enhance or disable specific drivers,
but with the assurance that the kernel can always do the safe thing
when / if the driver is missing a finer grained solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
