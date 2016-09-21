Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4A928024E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:22:47 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu14so99016253pad.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 08:22:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 3si41102372pad.284.2016.09.21.08.22.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 08:22:46 -0700 (PDT)
Date: Wed, 21 Sep 2016 09:22:44 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 1/9] ext4: allow DAX writeback for hole punch
Message-ID: <20160921152244.GB10516@linux.intel.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-2-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823220419.11717-2-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>, stable@vger.kernel.org

On Tue, Aug 23, 2016 at 04:04:11PM -0600, Ross Zwisler wrote:
> Currently when doing a DAX hole punch with ext4 we fail to do a writeback.
> This is because the logic around filemap_write_and_wait_range() in
> ext4_punch_hole() only looks for dirty page cache pages in the radix tree,
> not for dirty DAX exceptional entries.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Cc: <stable@vger.kernel.org>

Ted & Jan,

I'm still working on the latest version of the PMD work which integrates with
the new struct iomap faults.  At this point it doesn't look like I'm going to
make v4.9, but I think that this bug fix at least should probably go in alone?

Thanks,
- Ross

> ---
>  fs/ext4/inode.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 3131747..0900cb4 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -3890,7 +3890,7 @@ int ext4_update_disksize_before_punch(struct inode *inode, loff_t offset,
>  }
>  
>  /*
> - * ext4_punch_hole: punches a hole in a file by releaseing the blocks
> + * ext4_punch_hole: punches a hole in a file by releasing the blocks
>   * associated with the given offset and length
>   *
>   * @inode:  File inode
> @@ -3919,7 +3919,7 @@ int ext4_punch_hole(struct inode *inode, loff_t offset, loff_t length)
>  	 * Write out all dirty pages to avoid race conditions
>  	 * Then release them.
>  	 */
> -	if (mapping->nrpages && mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
> +	if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
>  		ret = filemap_write_and_wait_range(mapping, offset,
>  						   offset + length - 1);
>  		if (ret)
> -- 
> 2.9.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
