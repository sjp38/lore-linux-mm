Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4A26B0033
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 15:28:31 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p1so6642966qtg.18
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 12:28:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n26sor2052347otd.198.2017.10.09.12.28.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 12:28:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171009191820.GD15336@obsidianresearch.com>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732935473.22363.1853399637339625023.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171009185840.GB15336@obsidianresearch.com> <CAPcyv4gXzC8OUgO_PciQ2phyq0YtmXjMGWvoPSVVuuZR7ohVCg@mail.gmail.com>
 <20171009191820.GD15336@obsidianresearch.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 9 Oct 2017 12:28:29 -0700
Message-ID: <CAPcyv4h_uQGBAX6-bMkkZLO_YyQ6t4n_b8tH8wU_P0Jh23N5MQ@mail.gmail.com>
Subject: Re: [PATCH v7 07/12] dma-mapping: introduce dma_has_iommu()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux API <linux-api@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>

On Mon, Oct 9, 2017 at 12:18 PM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> On Mon, Oct 09, 2017 at 12:05:30PM -0700, Dan Williams wrote:
>> On Mon, Oct 9, 2017 at 11:58 AM, Jason Gunthorpe
>> <jgunthorpe@obsidianresearch.com> wrote:
>> > On Fri, Oct 06, 2017 at 03:35:54PM -0700, Dan Williams wrote:
>> >> otherwise be quiesced. The need for this knowledge is driven by a need
>> >> to make RDMA transfers to DAX mappings safe. If the DAX file's block map
>> >> changes we need to be to reliably stop accesses to blocks that have been
>> >> freed or re-assigned to a new file.
>> >
>> > If RDMA is driving this need, why not invalidate backing RDMA MRs
>> > instead of requiring a IOMMU to do it? RDMA MR are finer grained and
>> > do not suffer from the re-use problem David W. brought up with IOVAs..
>>
>> Sounds promising. All I want in the end is to be sure that the kernel
>> is enabled to stop any in-flight RDMA at will without asking
>> userspace. Does this require per-RDMA driver opt-in or is there a
>> common call that can be made?
>
> I don't think this has ever come up in the context of an all-device MR
> invalidate requirement. Drivers already have code to invalidate
> specifc MRs, but to find all MRs that touch certain pages and then
> invalidate them would be new code.
>
> We also have ODP aware drivers that can retarget a MR to new
> physical pages. If the block map changes DAX should synchronously
> retarget the ODP MR, not halt DMA.

Have a look at the patch [1], I don't touch the ODP path.

> Most likely ODP & DAX would need to be used together to get robust
> user applications, as having the user QP's go to an error state at
> random times (due to DMA failures) during operation is never going to
> be acceptable...

It's not random. The process that set up the mapping and registered
the memory gets SIGIO when someone else tries to modify the file map.
That process then gets /proc/sys/fs/lease-break-time seconds to fix
the problem before the kernel force revokes the DMA access.

It's otherwise not acceptable to allow DMA into random locations when
the file map changes.

> Perhaps you might want to initially only support ODP MR mappings with
> DAX and then the DMA fencing issue goes away?

I'd rather try to fix the non-ODP DAX case instead of just turning it off.

[1]: https://patchwork.kernel.org/patch/9991681/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
