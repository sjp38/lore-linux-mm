Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A554B6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 16:10:35 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id h200so4424920oib.18
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 13:10:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z34sor5329509otz.250.2017.10.12.13.10.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 13:10:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171012182712.GA5772@obsidianresearch.com>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732935473.22363.1853399637339625023.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171009185840.GB15336@obsidianresearch.com> <CAPcyv4gXzC8OUgO_PciQ2phyq0YtmXjMGWvoPSVVuuZR7ohVCg@mail.gmail.com>
 <20171009191820.GD15336@obsidianresearch.com> <CAPcyv4h_uQGBAX6-bMkkZLO_YyQ6t4n_b8tH8wU_P0Jh23N5MQ@mail.gmail.com>
 <20171010172516.GA29915@obsidianresearch.com> <CAPcyv4jL5fN7jjXkQum8ERQ45eW63dCYp5Pm6aHY4OPudz4Wsw@mail.gmail.com>
 <20171010180512.GA31734@obsidianresearch.com> <CAPcyv4gCBu5ptmWyof+Z-p7NbuCygEs2rMe2wdL0n3QQbXhrzA@mail.gmail.com>
 <20171012182712.GA5772@obsidianresearch.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 12 Oct 2017 13:10:33 -0700
Message-ID: <CAPcyv4g1zXq7MbtivoviHEME6Oi8YJOnVG3jBah3YpHXPAhg6Q@mail.gmail.com>
Subject: Re: [PATCH v7 07/12] dma-mapping: introduce dma_has_iommu()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux API <linux-api@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Oct 12, 2017 at 11:27 AM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> On Tue, Oct 10, 2017 at 01:17:26PM -0700, Dan Williams wrote:
>
>> Also keep in mind that what triggers the lease break is another
>> application trying to write or punch holes in a file that is mapped
>> for RDMA. So, if the hardware can't handle the iommu mapping getting
>> invalidated asynchronously and the application can't react in the
>> lease break timeout period then the administrator should arrange for
>> the file to not be written or truncated while it is mapped.
>
> That makes sense, but why not return ENOSYS or something to the app
> trying to alter the file if the RDMA hardware can't support this
> instead of having the RDMA app deal with this lease break weirdness?

That's where I started, an inode flag that said "hands off, this file
is busy", but Christoph pointed out that we should reuse the same
mechanisms that pnfs is using. The pnfs protection scheme uses file
leases, and once the kernel decides that a lease needs to be broken /
layout needs to be recalled there is no stopping it, only delaying.

>> It's already the case that get_user_pages() does not lock down file
>> associations, so if your application is contending with these types of
>> file changes it likely already has a problem keeping transactions in
>> sync with the file state even without DAX.
>
> Yes, things go weird in non-ODP RDMA cases like this..
>
> Also, just to clear, I would expect an app using the SIGIO interface
> to basically halt ongoing RDMA, wait for MRs to become unused locally
> and remotely, destroy the MRs, then somehow, establish new MRs that
> cover the same logical map (eg what ODP would do transparently) after
> the lease breaker has made their changes, then restart their IO.
>
> Does your SIGIO approach have a race-free way to do that last steps?

After the SIGIO that's becomes a userspace / driver problem to quiesce
the I/O...

However, chatting this over with a few more people I have an alternate
solution that effectively behaves the same as how non-ODP hardware
handles this case of hole punch / truncation today. So, today if this
scenario happens on a page-cache backed mapping, the file blocks are
unmapped and the RDMA continues into pinned pages that are no longer
part of the file. We can achieve the same thing with the iommu, just
re-target the I/O into memory that isn't part of the file. That way
hardware does not see I/O errors and the DAX data consistency model is
no worse than the page-cache case.

>> > So, not being able to support DAX on certain RDMA hardware is not
>> > an unreasonable situation in our space.
>>
>> That makes sense, but it still seems to me that this proposed solution
>> allows more than enough ways to avoid that worst case scenario where
>> hardware reacts badly to iommu invalidation.
>
> Yes, although I am concerned that returning PCI-E errors is such an
> unusual and untested path for some of our RDMA drivers that they may
> malfunction badly...
>
> Again, going back to the question of who would ever use this, I would
> be very relucant to deploy a production configuration relying on the iommu
> invalidate or SIGIO techniques, when ODP HW is available and works
> flawlessly.

I don't think it is reasonable to tell people you need to throw away
your old hardware just because you want to target a DAX mapping.

>> be blacklisted from supporting DAX altogether. In other words this is
>> a starting point to incrementally enhance or disable specific drivers,
>> but with the assurance that the kernel can always do the safe thing
>> when / if the driver is missing a finer grained solution.
>
> Seems reasonable.. I think existing HW will have an easier time adding
> invalidate, while new hardware really should implement ODP.
>

Yeah, so if we go with 'remap' instead of 'invalidate' does that
address your concerns?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
