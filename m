Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0969C6B0069
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 16:11:09 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so12221749wgh.23
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 13:11:09 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.197])
        by mx.google.com with ESMTP id cw9si1187303wjc.49.2014.10.08.13.11.08
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 13:11:08 -0700 (PDT)
Date: Wed, 8 Oct 2014 23:11:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1 5/7] dax: Add huge page fault support
Message-ID: <20141008201100.GB9232@node.dhcp.inet.fi>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
 <1412774729-23956-6-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1412774729-23956-6-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

On Wed, Oct 08, 2014 at 09:25:27AM -0400, Matthew Wilcox wrote:
> +
> +	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (pgoff >= size)
> +		return VM_FAULT_SIGBUS;
> +	/* If the PMD would cover blocks out of the file */
> +	if ((pgoff | PG_PMD_COLOUR) >= size)
> +		return VM_FAULT_FALLBACK;

IIUC, zero pading would work too.

> +
> +	memset(&bh, 0, sizeof(bh));
> +	block = ((sector_t)pgoff & ~PG_PMD_COLOUR) << (PAGE_SHIFT - blkbits);
> +
> +	/* Start by seeing if we already have an allocated block */
> +	bh.b_size = PMD_SIZE;
> +	length = get_block(inode, block, &bh, 0);

This makes me confused. get_block() return zero on success, right?
Why the var called 'lenght'?

> +	sector = bh.b_blocknr << (blkbits - 9);
> +	length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn, bh.b_size);
> +	if (length < 0)
> +		goto sigbus;
> +	if (length < PMD_SIZE)
> +		goto fallback;
> +	if (pfn & PG_PMD_COLOUR)
> +		goto fallback;	/* not aligned */

So, are you rely on pure luck to make get_block() allocate 2M aligned pfn?
Not really productive. You would need assistance from fs and
arch_get_unmapped_area() sides.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
