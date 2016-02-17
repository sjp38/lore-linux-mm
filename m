Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id EE7A76B0009
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 16:50:50 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fl4so18090340pad.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 13:50:50 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id v16si4422442pfa.129.2016.02.17.13.50.50
        for <linux-mm@kvack.org>;
        Wed, 17 Feb 2016 13:50:50 -0800 (PST)
Date: Wed, 17 Feb 2016 14:50:37 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 3/6] ext4: Online defrag not supported with DAX
Message-ID: <20160217215037.GB30126@linux.intel.com>
References: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
 <1455680059-20126-4-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455680059-20126-4-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Tue, Feb 16, 2016 at 08:34:16PM -0700, Ross Zwisler wrote:
> Online defrag operations for ext4 are hard coded to use the page cache.
> See ext4_ioctl() -> ext4_move_extents() -> move_extent_per_page()
> 
> When combined with DAX I/O, which circumvents the page cache, this can
> result in data corruption.  This was observed with xfstests ext4/307 and
> ext4/308.
> 
> Fix this by only allowing online defrag for non-DAX files.

Jan,

Thinking about this a bit more, it's probably the case that the data
corruption I was observing was due to us skipping the writeback of the dirty
page cache pages because S_DAX was set.

I do think we have a problem with defrag because it is doing the extent
swapping using the page cache, and we won't flush the dirty pages due to
S_DAX being set.

This patch is the quick and easy answer, and is perhaps appropriate for v4.5.

Looking forward, though, what do you think the correct solution is?  Making an
extent swapper that doesn't use the page cache (as I believe XFS has? see
xfs_swap_extents()), or maybe just unsetting S_DAX while we do the defrag and
being careful to block out page faults and I/O?  Or is it acceptable to just
say that DAX and defrag are mutually exclusive for ext4?

Thanks,
- Ross

> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/ext4/ioctl.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
> index 0f6c369..e32c86f 100644
> --- a/fs/ext4/ioctl.c
> +++ b/fs/ext4/ioctl.c
> @@ -583,6 +583,11 @@ group_extend_out:
>  				 "Online defrag not supported with bigalloc");
>  			err = -EOPNOTSUPP;
>  			goto mext_out;
> +		} else if (IS_DAX(inode)) {
> +			ext4_msg(sb, KERN_ERR,
> +				 "Online defrag not supported with DAX");
> +			err = -EOPNOTSUPP;
> +			goto mext_out;
>  		}
>  
>  		err = mnt_want_write_file(filp);
> -- 
> 2.5.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
