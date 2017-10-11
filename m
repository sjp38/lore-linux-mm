Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85E706B0260
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 07:54:12 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i124so2412448wmf.7
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 04:54:12 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id l28si436621edb.260.2017.10.11.04.54.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 04:54:11 -0700 (PDT)
Date: Wed, 11 Oct 2017 13:54:10 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH v8 13/14] IB/core: use MAP_DIRECT to fix / enable RDMA to
 DAX mappings
Message-ID: <20171011115410.GF30803@8bytes.org>
References: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150764701194.16882.9682569707416653741.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150764701194.16882.9682569707416653741.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Sean Hefty <sean.hefty@intel.com>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>, iommu@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Doug Ledford <dledford@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, David Woodhouse <dwmw2@infradead.org>, Hal Rosenstock <hal.rosenstock@gmail.com>

On Tue, Oct 10, 2017 at 07:50:12AM -0700, Dan Williams wrote:
> +static void ib_umem_lease_break(void *__umem)
> +{
> +	struct ib_umem *umem = umem;
> +	struct ib_device *idev = umem->context->device;
> +	struct device *dev = idev->dma_device;
> +	struct scatterlist *sgl = umem->sg_head.sgl;
> +
> +	iommu_unmap(umem->iommu, sg_dma_address(sgl) & PAGE_MASK,
> +			iommu_sg_num_pages(dev, sgl, umem->npages));
> +}

This looks like an invitation to break your code by random iommu-driver
changes. There is no guarantee that an iommu-backed dma-api
implemenation will map exactly iommu_sg_num_pages() pages for a given
sg-list. In other words, you are mixing the use of the IOMMU-API and the
DMA-API in an incompatible way that only works because you know the
internals of the iommu-drivers.

I've seen in another patch that your changes strictly require an IOMMU,
so you what you should do instead is to switch from the DMA-API to the
IOMMU-API and do the address-space management yourself.

Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
