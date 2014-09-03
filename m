Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 25A056B0036
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 07:13:09 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id hn18so8868195igb.5
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 04:13:08 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id bu5si10377128pbb.194.2014.09.03.04.13.06
        for <linux-mm@kvack.org>;
        Wed, 03 Sep 2014 04:13:07 -0700 (PDT)
Date: Wed, 3 Sep 2014 21:13:02 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 20/21] ext4: Add DAX functionality
Message-ID: <20140903111302.GG20473@dastard>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <5422062f87eb5606f4632fd06575254379f40ddc.1409110741.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5422062f87eb5606f4632fd06575254379f40ddc.1409110741.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, willy@linux.intel.com

On Tue, Aug 26, 2014 at 11:45:40PM -0400, Matthew Wilcox wrote:
> From: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> This is a port of the DAX functionality found in the current version of
> ext2.
....
> diff --git a/fs/ext4/indirect.c b/fs/ext4/indirect.c
> index e75f840..fa9ec8d 100644
> --- a/fs/ext4/indirect.c
> +++ b/fs/ext4/indirect.c
> @@ -691,14 +691,22 @@ retry:
>  			inode_dio_done(inode);
>  			goto locked;
>  		}
> -		ret = __blockdev_direct_IO(rw, iocb, inode,
> -				 inode->i_sb->s_bdev, iter, offset,
> -				 ext4_get_block, NULL, NULL, 0);
> +		if (IS_DAX(inode))
> +			ret = dax_do_io(rw, iocb, inode, iter, offset,
> +					ext4_get_block, NULL, 0);
> +		else
> +			ret = __blockdev_direct_IO(rw, iocb, inode,
> +					inode->i_sb->s_bdev, iter, offset,
> +					ext4_get_block, NULL, NULL, 0);
>  		inode_dio_done(inode);
>  	} else {
>  locked:
> -		ret = blockdev_direct_IO(rw, iocb, inode, iter,
> -				 offset, ext4_get_block);
> +		if (IS_DAX(inode))
> +			ret = dax_do_io(rw, iocb, inode, iter, offset,
> +					ext4_get_block, NULL, DIO_LOCKING);
> +		else
> +			ret = blockdev_direct_IO(rw, iocb, inode, iter,
> +					offset, ext4_get_block);
>  
>  		if (unlikely((rw & WRITE) && ret < 0)) {
>  			loff_t isize = i_size_read(inode);

When direct IO fails ext4 falls back to buffered IO, right? And
dax_do_io() can return partial writes, yes?

So that means if you get, say, ENOSPC part way through a DAX write,
ext4 can start dirtying the page cache from
__generic_file_write_iter() because the DAX write didn't wholly
complete? And say this ENOSPC races with space being freed from
another inode, then the buffered write will succeed and we'll end up
with coherency issues, right?

This is not an idle question - XFS if firing asserts all over the
place when doing ENOSPC testing because DAX is returning partial
writes and the XFS direct IO code is expecting them to either wholly
complete or wholly fail. I can make the DAX variant do allow partial
writes, but I'm not going to add a useless fallback to buffered IO
for XFS when the (fully featured) direct allocation fails.

Indeed, I note that in the dax_fault code, any page found in the
page cache is explicitly removed and released, and the direct mapped
block replaces that page in the vma. IOWs, this code expects pages
to be clean as we're only supposed to have regions covered by holes
using cached pages (dax_load_hole()). So if we've done a buffered
write, we're going to toss out dirty pages the moment there is a
page fault on the range and map the unmodified backing store in
instead.

That just seems wrong. Maybe I've forgotten something, but this
looks like a wart that we don't need and shouldn't bake into this
interface as both ext4 and XFS can allocate into holes and extend
files from from the direct IO interfaces. Of course, correct me if
I'm wrong about ext4 capabilities...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
