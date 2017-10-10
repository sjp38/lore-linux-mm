Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9743B6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 13:39:30 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j126so9920026oib.9
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:39:30 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k13sor1379451oih.294.2017.10.10.10.39.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 10:39:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171010172516.GA29915@obsidianresearch.com>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732935473.22363.1853399637339625023.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171009185840.GB15336@obsidianresearch.com> <CAPcyv4gXzC8OUgO_PciQ2phyq0YtmXjMGWvoPSVVuuZR7ohVCg@mail.gmail.com>
 <20171009191820.GD15336@obsidianresearch.com> <CAPcyv4h_uQGBAX6-bMkkZLO_YyQ6t4n_b8tH8wU_P0Jh23N5MQ@mail.gmail.com>
 <20171010172516.GA29915@obsidianresearch.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Oct 2017 10:39:27 -0700
Message-ID: <CAPcyv4jL5fN7jjXkQum8ERQ45eW63dCYp5Pm6aHY4OPudz4Wsw@mail.gmail.com>
Subject: Re: [PATCH v7 07/12] dma-mapping: introduce dma_has_iommu()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux API <linux-api@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Oct 10, 2017 at 10:25 AM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> On Mon, Oct 09, 2017 at 12:28:29PM -0700, Dan Williams wrote:
>
>> > I don't think this has ever come up in the context of an all-device MR
>> > invalidate requirement. Drivers already have code to invalidate
>> > specifc MRs, but to find all MRs that touch certain pages and then
>> > invalidate them would be new code.
>> >
>> > We also have ODP aware drivers that can retarget a MR to new
>> > physical pages. If the block map changes DAX should synchronously
>> > retarget the ODP MR, not halt DMA.
>>
>> Have a look at the patch [1], I don't touch the ODP path.
>
> But, does ODP work OK already? I'm not clear on that..

It had better. If the mapping is invalidated I would hope that
generates an io fault that gets handled by the driver to setup the new
mapping. I don't see how it can work otherwise.

>> > Most likely ODP & DAX would need to be used together to get robust
>> > user applications, as having the user QP's go to an error state at
>> > random times (due to DMA failures) during operation is never going to
>> > be acceptable...
>>
>> It's not random. The process that set up the mapping and registered
>> the memory gets SIGIO when someone else tries to modify the file map.
>> That process then gets /proc/sys/fs/lease-break-time seconds to fix
>> the problem before the kernel force revokes the DMA access.
>
> Well, the process can't fix the problem in bounded time, so it is
> random if it will fail or not.
>
> MR life time is under the control of the remote side, and time to
> complete the network exchanges required to release the MRs is hard to
> bound. So even if I implement SIGIO properly my app will still likely
> have random QP failures under various cases and work loads. :(
>
> This is why ODP should be the focus because this cannot work fully
> reliably otherwise..

The lease break time is configurable. If that application can't
respond to a stop request within a timeout of its own choosing then it
should not be using DAX mappings.

>
>> > Perhaps you might want to initially only support ODP MR mappings with
>> > DAX and then the DMA fencing issue goes away?
>>
>> I'd rather try to fix the non-ODP DAX case instead of just turning it off.
>
> Well, what about using SIGKILL if the lease-break-time hits? The
> kernel will clean up the MRs when the process exits and this will
> fence DMA to that memory.

Can you point me to where the MR cleanup code fences DMA and quiesces
the device?

> But, still, if you really want to be fined graned, then I think
> invalidating the impacted MR's is a better solution for RDMA than
> trying to do it with the IOMMU...

If there's a better routine for handling ib_umem_lease_break() I'd
love to use it. Right now I'm reaching for the only tool I know for
kernel enforced revocation of DMA access.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
