Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18B246B0253
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 02:50:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k4so5163797wmc.20
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 23:50:49 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 106si321767wrc.93.2017.10.12.23.50.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 23:50:47 -0700 (PDT)
Date: Fri, 13 Oct 2017 08:50:47 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v7 07/12] dma-mapping: introduce dma_has_iommu()
Message-ID: <20171013065047.GA26461@lst.de>
References: <20171009185840.GB15336@obsidianresearch.com> <CAPcyv4gXzC8OUgO_PciQ2phyq0YtmXjMGWvoPSVVuuZR7ohVCg@mail.gmail.com> <20171009191820.GD15336@obsidianresearch.com> <CAPcyv4h_uQGBAX6-bMkkZLO_YyQ6t4n_b8tH8wU_P0Jh23N5MQ@mail.gmail.com> <20171010172516.GA29915@obsidianresearch.com> <CAPcyv4jL5fN7jjXkQum8ERQ45eW63dCYp5Pm6aHY4OPudz4Wsw@mail.gmail.com> <20171010180512.GA31734@obsidianresearch.com> <CAPcyv4gCBu5ptmWyof+Z-p7NbuCygEs2rMe2wdL0n3QQbXhrzA@mail.gmail.com> <20171012182712.GA5772@obsidianresearch.com> <CAPcyv4g1zXq7MbtivoviHEME6Oi8YJOnVG3jBah3YpHXPAhg6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g1zXq7MbtivoviHEME6Oi8YJOnVG3jBah3YpHXPAhg6Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux API <linux-api@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Oct 12, 2017 at 01:10:33PM -0700, Dan Williams wrote:
> On Thu, Oct 12, 2017 at 11:27 AM, Jason Gunthorpe
> <jgunthorpe@obsidianresearch.com> wrote:
> > On Tue, Oct 10, 2017 at 01:17:26PM -0700, Dan Williams wrote:
> >
> >> Also keep in mind that what triggers the lease break is another
> >> application trying to write or punch holes in a file that is mapped
> >> for RDMA. So, if the hardware can't handle the iommu mapping getting
> >> invalidated asynchronously and the application can't react in the
> >> lease break timeout period then the administrator should arrange for
> >> the file to not be written or truncated while it is mapped.
> >
> > That makes sense, but why not return ENOSYS or something to the app
> > trying to alter the file if the RDMA hardware can't support this
> > instead of having the RDMA app deal with this lease break weirdness?
> 
> That's where I started, an inode flag that said "hands off, this file
> is busy", but Christoph pointed out that we should reuse the same
> mechanisms that pnfs is using. The pnfs protection scheme uses file
> leases, and once the kernel decides that a lease needs to be broken /
> layout needs to be recalled there is no stopping it, only delaying.

That was just a suggestion - the important statement is that a hands
off flag is just a no-go.

> However, chatting this over with a few more people I have an alternate
> solution that effectively behaves the same as how non-ODP hardware
> handles this case of hole punch / truncation today. So, today if this
> scenario happens on a page-cache backed mapping, the file blocks are
> unmapped and the RDMA continues into pinned pages that are no longer
> part of the file. We can achieve the same thing with the iommu, just
> re-target the I/O into memory that isn't part of the file. That way
> hardware does not see I/O errors and the DAX data consistency model is
> no worse than the page-cache case.

Yikes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
