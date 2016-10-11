Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B535B6B0253
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:42:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b80so497696wme.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 11:42:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l12si145827wmi.42.2016.10.11.11.42.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 11:42:30 -0700 (PDT)
Date: Tue, 11 Oct 2016 08:48:01 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v5 05/17] ext2: return -EIO on ext2_iomap_end() failure
Message-ID: <20161011064801.GA6952@quack2.suse.cz>
References: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475874544-24842-6-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475874544-24842-6-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Fri 07-10-16 15:08:52, Ross Zwisler wrote:
> Right now we just return 0 for success, but we really want to let callers
> know about this failure.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/ext2/inode.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index c7dbb46..368913c 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -830,8 +830,10 @@ ext2_iomap_end(struct inode *inode, loff_t offset, loff_t length,
>  {
>  	if (iomap->type == IOMAP_MAPPED &&
>  	    written < length &&
> -	    (flags & IOMAP_WRITE))
> +	    (flags & IOMAP_WRITE)) {
>  		ext2_write_failed(inode->i_mapping, offset + length);
> +		return -EIO;
> +	}

So this is wrong. This (written < length) happens when we fail to copy data
to / from userspace buffer into pagecache pages / DAX blocks. It may be
because the passed buffer pointer is just wrong, or just because the page
got swapped out and we have to swap it back in. It is a role of upper
layers to decide what went wrong and proceed accordingly but from filesystem
point of view we just have to cancel the operation we have prepared and
return to upper layers. So returning 0 in this case is correct.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
