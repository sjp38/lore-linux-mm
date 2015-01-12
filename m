Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id CB4E16B0072
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:09:49 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id t59so11048037yho.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:09:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o22si9892450yha.64.2015.01.12.15.09.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 15:09:48 -0800 (PST)
Date: Mon, 12 Jan 2015 15:09:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 07/20] dax,ext2: Replace ext2_clear_xip_target with
 dax_clear_blocks
Message-Id: <20150112150947.eb6ccb5c45edb4e83cd48b28@linux-foundation.org>
In-Reply-To: <1414185652-28663-8-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-8-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Fri, 24 Oct 2014 17:20:39 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> This is practically generic code; other filesystems will want to call
> it from other places, but there's nothing ext2-specific about it.
> 
> Make it a little more generic by allowing it to take a count of the number
> of bytes to zero rather than fixing it to a single page.  Thanks to Dave
> Hansen for suggesting that I need to call cond_resched() if zeroing more
> than one page.
> 
> ...
>
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -20,8 +20,45 @@
>  #include <linux/fs.h>
>  #include <linux/genhd.h>
>  #include <linux/mutex.h>
> +#include <linux/sched.h>
>  #include <linux/uio.h>
>  
> +int dax_clear_blocks(struct inode *inode, sector_t block, long size)
> +{
> +	struct block_device *bdev = inode->i_sb->s_bdev;
> +	sector_t sector = block << (inode->i_blkbits - 9);
> +
> +	might_sleep();
> +	do {
> +		void *addr;
> +		unsigned long pfn;
> +		long count;
> +
> +		count = bdev_direct_access(bdev, sector, &addr, &pfn, size);
> +		if (count < 0)
> +			return count;
> +		BUG_ON(size < count);
> +		while (count > 0) {
> +			unsigned pgsz = PAGE_SIZE - offset_in_page(addr);
> +			if (pgsz > count)
> +				pgsz = count;
> +			if (pgsz < PAGE_SIZE)
> +				memset(addr, 0, pgsz);
> +			else
> +				clear_page(addr);

Are there any cache issues in all this code? flush_dcache_page(addr)?

> +			addr += pgsz;
> +			size -= pgsz;
> +			count -= pgsz;
> +			BUG_ON(pgsz & 511);
> +			sector += pgsz / 512;
> +			cond_resched();
> +		}
> +	} while (size);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(dax_clear_blocks);
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
