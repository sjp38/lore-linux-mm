Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E81C94402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 17:01:00 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id jx14so20041811pad.2
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 14:01:00 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vu1si18963621pab.153.2015.12.17.14.00.59
        for <linux-mm@kvack.org>;
        Thu, 17 Dec 2015 14:00:59 -0800 (PST)
Date: Thu, 17 Dec 2015 15:00:57 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [-mm PATCH v3 04/25] dax: fix lifetime of in-kernel dax mappings
 with dax_map_atomic()
Message-ID: <20151217220057.GA17702@linux.intel.com>
References: <20151210023731.30368.7209.stgit@dwillia2-desk3.jf.intel.com>
 <20151211181108.19091.50770.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151211181108.19091.50770.stgit@dwillia2-desk3.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, Dec 11, 2015 at 10:11:53AM -0800, Dan Williams wrote:
> The DAX implementation needs to protect new calls to ->direct_access()
> and usage of its return value against the driver for the underlying
> block device being disabled.  Use blk_queue_enter()/blk_queue_exit() to
> hold off blk_cleanup_queue() from proceeding, or otherwise fail new
> mapping requests if the request_queue is being torn down.
> 
> This also introduces blk_dax_ctl to simplify the interface from fs/dax.c
> through dax_map_atomic() to bdev_direct_access().
> 
> Cc: Jan Kara <jack@suse.com>
> Cc: Jens Axboe <axboe@fb.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Matthew Wilcox <willy@linux.intel.com>
> [willy: fix read() of a hole]
> Reviewed-by: Jeff Moyer <jmoyer@redhat.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
<>
> @@ -308,20 +351,18 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
>  		goto out;
>  	}
>  
> -	error = bdev_direct_access(bh->b_bdev, sector, &addr, &pfn, bh->b_size);
> -	if (error < 0)
> -		goto out;
> -	if (error < PAGE_SIZE) {
> -		error = -EIO;
> +	if (dax_map_atomic(bdev, &dax) < 0) {
> +		error = PTR_ERR(dax.addr);
>  		goto out;
>  	}
>  
>  	if (buffer_unwritten(bh) || buffer_new(bh)) {
> -		clear_pmem(addr, PAGE_SIZE);
> +		clear_pmem(dax.addr, PAGE_SIZE);
>  		wmb_pmem();
>  	}
> +	dax_unmap_atomic(bdev, &dax);
>  
> -	error = vm_insert_mixed(vma, vaddr, pfn);
> +	error = vm_insert_mixed(vma, vaddr, dax.pfn);

Since we're still using the contents of the struct blk_dax_ctl as an argument
to vm_insert_mixed(), shouldn't dax_unmap_atomic() be after this call?

Unless there is some reason to protect dax.addr with a blk queue reference,
but not dax.pfn?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
