Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64DD36B0253
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:56:14 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id h185so206885861vkg.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 07:56:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b69si24118928qhb.102.2016.04.15.07.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 07:56:13 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v2 3/5] dax: enable dax in the presence of known media errors (badblocks)
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-4-git-send-email-vishal.l.verma@intel.com>
Date: Fri, 15 Apr 2016 10:56:10 -0400
In-Reply-To: <1459303190-20072-4-git-send-email-vishal.l.verma@intel.com>
	(Vishal Verma's message of "Tue, 29 Mar 2016 19:59:48 -0600")
Message-ID: <x4937qm7wfp.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@ml01.01.org, Jens Axboe <axboe@fb.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-block@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

Vishal Verma <vishal.l.verma@intel.com> writes:

> From: Dan Williams <dan.j.williams@intel.com>
>
> 1/ If a mapping overlaps a bad sector fail the request.
>
> 2/ Do not opportunistically report more dax-capable capacity than is
>    requested when errors present.
>
> [vishal: fix a conflict with system RAM collision patches]
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Jeff Moyer <jmoyer@redhat.com>

> ---
>  block/ioctl.c         | 9 ---------
>  drivers/nvdimm/pmem.c | 8 ++++++++
>  2 files changed, 8 insertions(+), 9 deletions(-)
>
> diff --git a/block/ioctl.c b/block/ioctl.c
> index d8996bb..cd7f392 100644
> --- a/block/ioctl.c
> +++ b/block/ioctl.c
> @@ -423,15 +423,6 @@ bool blkdev_dax_capable(struct block_device *bdev)
>  			|| (bdev->bd_part->nr_sects % (PAGE_SIZE / 512)))
>  		return false;
>  
> -	/*
> -	 * If the device has known bad blocks, force all I/O through the
> -	 * driver / page cache.
> -	 *
> -	 * TODO: support finer grained dax error handling
> -	 */
> -	if (disk->bb && disk->bb->count)
> -		return false;
> -
>  	return true;
>  }
>  #endif
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index da10554..eac5f93 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -174,9 +174,17 @@ static long pmem_direct_access(struct block_device *bdev,
>  	struct pmem_device *pmem = bdev->bd_disk->private_data;
>  	resource_size_t offset = sector * 512 + pmem->data_offset;
>  
> +	if (unlikely(is_bad_pmem(&pmem->bb, sector, dax->size)))
> +		return -EIO;
>  	dax->addr = pmem->virt_addr + offset;
>  	dax->pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
>  
> +	/*
> +	 * If badblocks are present, limit known good range to the
> +	 * requested range.
> +	 */
> +	if (unlikely(pmem->bb.count))
> +		return dax->size;
>  	return pmem->size - pmem->pfn_pad - offset;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
