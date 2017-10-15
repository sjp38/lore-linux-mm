Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 398A76B0033
	for <linux-mm@kvack.org>; Sun, 15 Oct 2017 11:14:56 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id s41so3723691uab.5
        for <linux-mm@kvack.org>; Sun, 15 Oct 2017 08:14:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y50sor2024325uay.177.2017.10.15.08.14.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 15 Oct 2017 08:14:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171013150348.GA11257@obsidianresearch.com>
References: <CAPcyv4gXzC8OUgO_PciQ2phyq0YtmXjMGWvoPSVVuuZR7ohVCg@mail.gmail.com>
 <20171009191820.GD15336@obsidianresearch.com> <CAPcyv4h_uQGBAX6-bMkkZLO_YyQ6t4n_b8tH8wU_P0Jh23N5MQ@mail.gmail.com>
 <20171010172516.GA29915@obsidianresearch.com> <CAPcyv4jL5fN7jjXkQum8ERQ45eW63dCYp5Pm6aHY4OPudz4Wsw@mail.gmail.com>
 <20171010180512.GA31734@obsidianresearch.com> <CAPcyv4gCBu5ptmWyof+Z-p7NbuCygEs2rMe2wdL0n3QQbXhrzA@mail.gmail.com>
 <20171012182712.GA5772@obsidianresearch.com> <CAPcyv4g1zXq7MbtivoviHEME6Oi8YJOnVG3jBah3YpHXPAhg6Q@mail.gmail.com>
 <20171013065047.GA26461@lst.de> <20171013150348.GA11257@obsidianresearch.com>
From: Matan Barak <matanb@dev.mellanox.co.il>
Date: Sun, 15 Oct 2017 18:14:53 +0300
Message-ID: <CAAKD3BBR2CmQvg-3bqPog0VFrEm=QU-b-xBDH-_Q+sXV9NkFUA@mail.gmail.com>
Subject: Re: [PATCH v7 07/12] dma-mapping: introduce dma_has_iommu()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma <linux-rdma@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux API <linux-api@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Liran Liss <liranl@mellanox.com>

On Fri, Oct 13, 2017 at 6:03 PM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> On Fri, Oct 13, 2017 at 08:50:47AM +0200, Christoph Hellwig wrote:
>
>> > However, chatting this over with a few more people I have an alternate
>> > solution that effectively behaves the same as how non-ODP hardware
>> > handles this case of hole punch / truncation today. So, today if this
>> > scenario happens on a page-cache backed mapping, the file blocks are
>> > unmapped and the RDMA continues into pinned pages that are no longer
>> > part of the file. We can achieve the same thing with the iommu, just
>> > re-target the I/O into memory that isn't part of the file. That way
>> > hardware does not see I/O errors and the DAX data consistency model is
>> > no worse than the page-cache case.
>>
>> Yikes.
>
> Well, as much as you say Yikes, Dan is correct, this does match the
> semantics RDMA MR's already have. They become non-coherent if their
> underlying object is changed, and there are many ways to get there.
> I've never thought about it, but it does sound like ftruncate,
> fallocate, etc on a normal file would break the MR coherency too??
>
> There have been efforts in the past driven by the MPI people to
> create, essentially, something like lease-break' SIGIO. Except it was
> intended to be general, and wanted solve all the problems related with
> MR de-coherence. This was complicated and never became acceptable to
> mainline.
>
> Instead ODP was developed, and ODP actually solves all the problem
> sanely.
>
> Thinking about it some more, and with your other comments on
> get_user_pages in this thread, I tend to agree. It doesn't make sense
> to develop a user space lease break API for MR's that is a DAX
> specific feature.
>
> Along the some lines, it also doesn't make sense to force-invalidate
> MR's linked to DAX regions, while leaving MR's linked to other
> regions that have the same problem alone.
>
> If you want to make non-ODP MR's work better, then you need to have a
> general overall solution to tell userspace when the MR becomes (or I
> guess, is becoming) non-coherent, that covers all the cases that break
> MR coherence, not just via DAX.
>
> Otherwise, I think Dan is right, keeping the current semantic of
> having MRs just do something wrong, but not corrupt memory, when they
> loose coherence, is broadly consistent with how non-ODP MRs work today.
>

I agree, keeping the current semantics is probably the best thing we
could do. It's a trade-off between breaking existing applications,
having a new lease API for DAX or just failing DAX in particular (as
opposed to other cases). For stable mappings, what we have is probably
sufficient. For mappings which could be changed, it's unclear to me
how you could guarantee non-racy behavior that is bounded by a
pre-defined time and guarantee no user-space errors. On top of that,
ODP (should) already solve that problem transparently.

IMHO, using iommu for that and causing DMA errors just because the
lease broke isn't the right thing to do.

> Jason

Matan

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
