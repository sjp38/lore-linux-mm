Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64E0F6B0033
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 13:32:12 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 14so2949797oii.6
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 10:32:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s8sor2730919ota.152.2017.10.09.10.32.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 10:32:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8161efa8-a315-3b0b-4159-9bdf3bfb98aa@arm.com>
References: <150732935473.22363.1853399637339625023.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150743420333.12880.6968831423519457797.stgit@dwillia2-desk3.amr.corp.intel.com>
 <8161efa8-a315-3b0b-4159-9bdf3bfb98aa@arm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 9 Oct 2017 10:32:10 -0700
Message-ID: <CAPcyv4jU0L-LocP7ZKWcUoft+h5rpMYsvgO_dEWfkrSxrQxJOA@mail.gmail.com>
Subject: Re: [PATCH v8] dma-mapping: introduce dma_get_iommu_domain()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux API <linux-api@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>

On Mon, Oct 9, 2017 at 3:37 AM, Robin Murphy <robin.murphy@arm.com> wrote:
> Hi Dan,
>
> On 08/10/17 04:45, Dan Williams wrote:
>> Add a dma-mapping api helper to retrieve the generic iommu_domain for a device.
>> The motivation for this interface is making RDMA transfers to DAX mappings
>> safe. If the DAX file's block map changes we need to be to reliably stop
>> accesses to blocks that have been freed or re-assigned to a new file.
>
> ...which is also going to require some way to force the IOMMU drivers
> (on x86 at least) to do a fully-synchronous unmap, instead of just
> throwing the IOVA onto a flush queue to invalidate the TLBs at some
> point in the future.

Isn't that the difference between iommu_unmap() and
iommu_unmap_fast()? As far as I can tell amd-iommu and intel-iommu
both flush iotlbs on iommu_unmap() and don't support fast unmaps.

> Assuming of course that there's an IOMMU both
> present and performing DMA translation in the first place.

That's why I want to call through the dma api to see if the iommu is
being used to satisfy dma mappings.

>> With the
>> iommu_domain and a callback from the DAX filesystem the kernel can safely
>> revoke access to a DMA device. The process that performed the RDMA memory
>> registration is also notified of this revocation event, but the kernel can not
>> otherwise be in the position of waiting for userspace to quiesce the device.
>
> OK, but why reinvent iommu_get_domain_for_dev()?

How do I know if the iommu returned from that routine is the one being
used for dma mapping operations for the device? Specifically, how
would I discover that the result of dma_map_sg() can be passed as an
IOVA range to iommu_unmap()?

>> Since PMEM+DAX is currently only enabled for x86, we only update the x86
>> iommu drivers.
>
> Note in particular that those two drivers happen to be the *only* place
> this approach could work - everyone else is going to have to fall back
> to the generic IOMMU API function anyway.

I want to make this functionality generic, but I'm not familiar with
the iommu sub-system. How are dma mapping operations routed to the
iommu driver in those other imlementations?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
