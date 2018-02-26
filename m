Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8566B0007
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 04:44:30 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id r29so11152575wra.13
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 01:44:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q18si6368845wre.245.2018.02.26.01.44.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Feb 2018 01:44:29 -0800 (PST)
Date: Mon, 26 Feb 2018 10:44:28 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/5] dax: fix dax_mapping() definition in the FS_DAX=n
 + DEV_DAX=y case
Message-ID: <20180226094428.awvicgxhohj4ezpq@quack2.suse.cz>
References: <151937026001.18973.12034171121582300402.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151937027102.18973.18360014199243139223.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151937027102.18973.18360014199243139223.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>

On Thu 22-02-18 23:17:51, Dan Williams wrote:
> An address_space will only have dax exceptional entries when FS_DAX is
> enabled. The current reliance on S_DAX causes compile failures when
> S_DAX is defined for DEV_DAX, but FS_DAX is disabled. Make dax_mapping()
> always return false so that mm/truncate.c drops its link time
> dependencies on fs/dax.c.
> 
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Jan Kara <jack@suse.cz>
> Cc: <stable@vger.kernel.org>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/dax.h |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index 0185ecdae135..62e8cf7eb566 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -107,6 +107,10 @@ int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
>  int __dax_zero_page_range(struct block_device *bdev,
>  		struct dax_device *dax_dev, sector_t sector,
>  		unsigned int offset, unsigned int length);
> +static inline bool dax_mapping(struct address_space *mapping)
> +{
> +	return mapping->host && IS_DAX(mapping->host);
> +}
>  #else
>  static inline int __dax_zero_page_range(struct block_device *bdev,
>  		struct dax_device *dax_dev, sector_t sector,
> @@ -114,12 +118,11 @@ static inline int __dax_zero_page_range(struct block_device *bdev,
>  {
>  	return -ENXIO;
>  }
> -#endif
> -
>  static inline bool dax_mapping(struct address_space *mapping)
>  {
> -	return mapping->host && IS_DAX(mapping->host);
> +	return false;
>  }
> +#endif
>  
>  struct writeback_control;
>  int dax_writeback_mapping_range(struct address_space *mapping,
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
