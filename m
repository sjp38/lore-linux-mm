Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDD4828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 08:22:04 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id f206so97557037wmf.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 05:22:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d13si19762188wma.91.2016.01.07.05.22.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 05:22:02 -0800 (PST)
Date: Thu, 7 Jan 2016 14:22:06 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 2/9] dax: fix conversion of holes to PMDs
Message-ID: <20160107132206.GE8380@quack.suse.cz>
References: <1452103263-1592-1-git-send-email-ross.zwisler@linux.intel.com>
 <1452103263-1592-3-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452103263-1592-3-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

On Wed 06-01-16 11:00:56, Ross Zwisler wrote:
> When we get a DAX PMD fault for a write it is possible that there could be
> some number of 4k zero pages already present for the same range that were
> inserted to service reads from a hole.  These 4k zero pages need to be
> unmapped from the VMAs and removed from the struct address_space radix tree
> before the real DAX PMD entry can be inserted.
> 
> For PTE faults this same use case also exists and is handled by a
> combination of unmap_mapping_range() to unmap the VMAs and
> delete_from_page_cache() to remove the page from the address_space radix
> tree.
> 
> For PMD faults we do have a call to unmap_mapping_range() (protected by a
> buffer_new() check), but nothing clears out the radix tree entry.  The
> buffer_new() check is also incorrect as the current ext4 and XFS filesystem
> code will never return a buffer_head with BH_New set, even when allocating
> new blocks over a hole.  Instead the filesystem will zero the blocks
> manually and return a buffer_head with only BH_Mapped set.
> 
> Fix this situation by removing the buffer_new() check and adding a call to
> truncate_inode_pages_range() to clear out the radix tree entries before we
> insert the DAX PMD.

Ho, hum, let me understand this. So we have a file, different processes are
mapping it. One process maps is with normal page granularity and another
process with huge page granularity. Thus when the first process read-faults
a few normal pages and then the second process write-faults the huge page
in the same range, we have a problem. Do I understand this correctly?
Because otherwise I don't understand how a single page table can have both
huge page and normal page in the same range...

And if this is indeed the problem then what prevents the unmapping and
truncation in huge page fault to race with mapping the same range again
using small pages? Sure now blocks are allocated so the mapping itself will
be consistent but radix tree will have the same issues it had before this
patch, won't it?

... thinking some more about this ...

OK, there is some difference - we will only have DAX exceptional entries
for the range covered by huge page and those we replace properly in
dax_radix_entry() code. So things are indeed fine *except* that nothing
seems so serialize dax_load() hole with PMD fault. The race like following
seems possible:

CPU1 - process 1		CPU2 - process 2

__dax_fault() - file f, index 1
  get_block() -> returns hole
				__dax_pmd_fault() - file f, index 0
				  get_block() -> allocates blocks
				  ...
				  truncate_pagecache_range()
  dax_load_hole()

Boom, we have hole page instantiated for allocated range (data corruption)
and corruption of radix tree entries as well. Actually this problem is
there even for two different processes doing normal page faults (one read,
one write) against the same page in the file.

... thinking about possible fixes ...

So we need some exclusion that makes sure pgoff->block mapping information
is uptodate at the moment we insert it into page tables. The simplest
reasonably fast thing I can see is:

When handling a read fault, things stay as is and filesystem protects the
fault with an equivalent of EXT4_I(inode)->i_mmap_sem held for reading. When
handling a write fault we first grab EXT4_I(inode)->i_mmap_sem for reading
and try a read fault. If __dax_fault() sees a hole returned from
get_blocks() during a write fault, it bails out. Filesystem grabs
EXT4_I(inode)->i_mmap_sem for writing and retries with different
get_blocks() callback which will allocate blocks. That way we get proper
exclusion for faults needing to allocate blocks. Thoughts?

								Honza

> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/dax.c | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 03cc4a3..9dc0c97 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -594,6 +594,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  	bool write = flags & FAULT_FLAG_WRITE;
>  	struct block_device *bdev;
>  	pgoff_t size, pgoff;
> +	loff_t lstart, lend;
>  	sector_t block;
>  	int result = 0;
>  
> @@ -647,15 +648,13 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  		goto fallback;
>  	}
>  
> -	/*
> -	 * If we allocated new storage, make sure no process has any
> -	 * zero pages covering this hole
> -	 */
> -	if (buffer_new(&bh)) {
> -		i_mmap_unlock_read(mapping);
> -		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
> -		i_mmap_lock_read(mapping);
> -	}
> +	/* make sure no process has any zero pages covering this hole */
> +	lstart = pgoff << PAGE_SHIFT;
> +	lend = lstart + PMD_SIZE - 1; /* inclusive */
> +	i_mmap_unlock_read(mapping);
> +	unmap_mapping_range(mapping, lstart, PMD_SIZE, 0);
> +	truncate_inode_pages_range(mapping, lstart, lend);
> +	i_mmap_lock_read(mapping);
>  
>  	/*
>  	 * If a truncate happened while we were allocating blocks, we may
> @@ -669,7 +668,8 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  		goto out;
>  	}
>  	if ((pgoff | PG_PMD_COLOUR) >= size) {
> -		dax_pmd_dbg(&bh, address, "pgoff unaligned");
> +		dax_pmd_dbg(&bh, address,
> +				"offset + huge page size > file size");
>  		goto fallback;
>  	}
>  
> -- 
> 2.5.0
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
