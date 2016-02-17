Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1B46B0009
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 16:34:29 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id c200so235138184wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 13:34:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d84si43602278wmc.17.2016.02.17.13.34.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 13:34:28 -0800 (PST)
Date: Wed, 17 Feb 2016 22:34:50 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 3/6] ext4: Online defrag not supported with DAX
Message-ID: <20160217213450.GI14140@quack.suse.cz>
References: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
 <1455680059-20126-4-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455680059-20126-4-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Tue 16-02-16 20:34:16, Ross Zwisler wrote:
> Online defrag operations for ext4 are hard coded to use the page cache.
> See ext4_ioctl() -> ext4_move_extents() -> move_extent_per_page()
> 
> When combined with DAX I/O, which circumvents the page cache, this can
> result in data corruption.  This was observed with xfstests ext4/307 and
> ext4/308.
> 
> Fix this by only allowing online defrag for non-DAX files.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

We need to handle this eventually but for now we are fine. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

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
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
