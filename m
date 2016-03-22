Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id CFBBA6B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 16:16:47 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id u190so326096162pfb.3
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 13:16:47 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id d82si4372965pfj.52.2016.03.22.13.16.46
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 13:16:47 -0700 (PDT)
Date: Tue, 22 Mar 2016 14:16:10 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 13/71] nvdimm: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160322201610.GB11164@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458499278-1516-14-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458499278-1516-14-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Vishal Verma <vishal.l.verma@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sun, Mar 20, 2016 at 09:40:20PM +0300, Kirill A. Shutemov wrote:
> PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
> with promise that one day it will be possible to implement page cache with
> bigger chunks than PAGE_SIZE.
> 
> This promise never materialized. And unlikely will.
> 
> We have many places where PAGE_CACHE_SIZE assumed to be equal to
> PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
> or PAGE_* constant should be used in a particular case, especially on the
> border between fs and mm.
> 
> Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
> breakage to be doable.
> 
> Let's stop pretending that pages in page cache are special. They are not.
> 
> The changes are pretty straight-forward:
> 
>  - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;
> 
>  - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};
> 
>  - page_cache_get() -> get_page();
> 
>  - page_cache_release() -> put_page();
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Vishal Verma <vishal.l.verma@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>

Sure, this seems right.  Thanks for making this simpler.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

> ---
>  drivers/nvdimm/btt.c  | 2 +-
>  drivers/nvdimm/pmem.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
> index c32cbb593600..f068b6513cd2 100644
> --- a/drivers/nvdimm/btt.c
> +++ b/drivers/nvdimm/btt.c
> @@ -1204,7 +1204,7 @@ static int btt_rw_page(struct block_device *bdev, sector_t sector,
>  {
>  	struct btt *btt = bdev->bd_disk->private_data;
>  
> -	btt_do_bvec(btt, NULL, page, PAGE_CACHE_SIZE, 0, rw, sector);
> +	btt_do_bvec(btt, NULL, page, PAGE_SIZE, 0, rw, sector);
>  	page_endio(page, rw & WRITE, 0);
>  	return 0;
>  }
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index ca5721c306bb..a1a29c711532 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -151,7 +151,7 @@ static int pmem_rw_page(struct block_device *bdev, sector_t sector,
>  	struct pmem_device *pmem = bdev->bd_disk->private_data;
>  	int rc;
>  
> -	rc = pmem_do_bvec(pmem, page, PAGE_CACHE_SIZE, 0, rw, sector);
> +	rc = pmem_do_bvec(pmem, page, PAGE_SIZE, 0, rw, sector);
>  	if (rw & WRITE)
>  		wmb_pmem();
>  
> -- 
> 2.7.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
