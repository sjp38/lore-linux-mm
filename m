Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id E24E26B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 16:09:30 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id wk8so109112477pab.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 13:09:30 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id bd6si5744567pab.146.2016.09.15.13.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 13:09:30 -0700 (PDT)
Date: Thu, 15 Sep 2016 14:09:28 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Message-ID: <20160915200928.GA8200@linux.intel.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823220419.11717-3-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>

On Tue, Aug 23, 2016 at 04:04:12PM -0600, Ross Zwisler wrote:
> When DAX calls ext2_get_block() and the file offset points to a hole we
> currently don't set bh_result->b_size.  When we re-enable PMD faults DAX
> will need bh_result->b_size to tell it the size of the hole so it can
> decide whether to fault in a 4 KiB zero page or a 2 MiB zero page.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/ext2/inode.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index d5c7d09..dd55d74 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -773,6 +773,9 @@ int ext2_get_block(struct inode *inode, sector_t iblock, struct buffer_head *bh_
>  	if (ret > 0) {
>  		bh_result->b_size = (ret << inode->i_blkbits);
>  		ret = 0;
> +	} else if (ret == 0) {
> +		/* hole case, need to fill in bh_result->b_size */
> +		bh_result->b_size = 1 << inode->i_blkbits;
>  	}
>  	return ret;
>  
> -- 
> 2.9.0
> 

Jan, is it possible for ext2 to return 2 MiB of contiguous space to us via
ext2_get_block()?

I ask because we have all the infrastructure in place for ext2 to handle PMD
faults (ext2_dax_pmd_fault(), etc.), but I don't think in my testing I've ever
seen this actually happen.

ext2 can obviously return multiple blocks from ext2_get_block(), but can it
actually satisfy a whole PMD's worth (512 contiguous blocks)?  If so, what
steps do I need to take to get this to work in my testing?

If it can't happen, we should probably rip out ext2_dax_pmd_fault() so that we
don't have to keep falling back to PTEs via the PMD path.

Thanks,
- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
