Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 827CF6B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:05:27 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 186so1649059itu.4
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:05:27 -0700 (PDT)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id q19si267361itb.25.2017.10.10.11.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 11:05:26 -0700 (PDT)
Date: Tue, 10 Oct 2017 12:05:12 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v7 07/12] dma-mapping: introduce dma_has_iommu()
Message-ID: <20171010180512.GA31734@obsidianresearch.com>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732935473.22363.1853399637339625023.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171009185840.GB15336@obsidianresearch.com>
 <CAPcyv4gXzC8OUgO_PciQ2phyq0YtmXjMGWvoPSVVuuZR7ohVCg@mail.gmail.com>
 <20171009191820.GD15336@obsidianresearch.com>
 <CAPcyv4h_uQGBAX6-bMkkZLO_YyQ6t4n_b8tH8wU_P0Jh23N5MQ@mail.gmail.com>
 <20171010172516.GA29915@obsidianresearch.com>
 <CAPcyv4jL5fN7jjXkQum8ERQ45eW63dCYp5Pm6aHY4OPudz4Wsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jL5fN7jjXkQum8ERQ45eW63dCYp5Pm6aHY4OPudz4Wsw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux API <linux-api@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Oct 10, 2017 at 10:39:27AM -0700, Dan Williams wrote:
> On Tue, Oct 10, 2017 at 10:25 AM, Jason Gunthorpe

> >> Have a look at the patch [1], I don't touch the ODP path.
> >
> > But, does ODP work OK already? I'm not clear on that..
> 
> It had better. If the mapping is invalidated I would hope that
> generates an io fault that gets handled by the driver to setup the new
> mapping. I don't see how it can work otherwise.

I would assume so too...

> > This is why ODP should be the focus because this cannot work fully
> > reliably otherwise..
> 
> The lease break time is configurable. If that application can't
> respond to a stop request within a timeout of its own choosing then it
> should not be using DAX mappings.

Well, no RDMA application can really do this, unless you set the
timeout to multiple minutes, on par with network timeouts.

Again, these details are why I think this kind of DAX and non ODP-MRs
are probably practically not too useful for a production system. Great
for test of course, but in that case SIGKILL would be fine too...

> > Well, what about using SIGKILL if the lease-break-time hits? The
> > kernel will clean up the MRs when the process exits and this will
> > fence DMA to that memory.
> 
> Can you point me to where the MR cleanup code fences DMA and quiesces
> the device?

Yes. The MR's are associated with an fd. When the fd is closed
ib_uverbs_close triggers ib_uverbs_cleanup_ucontext which runs through
all the objects, including MRs, and deletes them.

The specification for deleting a MR requires a synchronous fence with
the hardware. After MR deletion the hardware will not DMA to any pages
described by the old MR, and those pages will be unpinned.

> > But, still, if you really want to be fined graned, then I think
> > invalidating the impacted MR's is a better solution for RDMA than
> > trying to do it with the IOMMU...
> 
> If there's a better routine for handling ib_umem_lease_break() I'd
> love to use it. Right now I'm reaching for the only tool I know for
> kernel enforced revocation of DMA access.

Well, you'd have to code something in the MR code to keep track of DAX
MRs and issue an out of band invalidate to impacted MRs to create the
fence.

This probably needs some driver work, I'm not sure if all the hardware
can do out of band invalidate to any MR or not..

Generally speaking, in RDMA, when a new feature like this comes along
we have to push a lot of the work down to the driver authors, and the
approach has historically been that new features only work on some
hardware (as much as I dislike this, it is pragmatic)

So, not being able to support DAX on certain RDMA hardware is not
an unreasonable situation in our space.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
