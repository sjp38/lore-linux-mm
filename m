Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5DCAB6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 20:23:21 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 188so18788353pgb.3
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 17:23:21 -0700 (PDT)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id p19si4895531pgn.274.2017.09.25.17.23.19
        for <linux-mm@kvack.org>;
        Mon, 25 Sep 2017 17:23:20 -0700 (PDT)
Date: Tue, 26 Sep 2017 09:38:12 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/7] xfs: always use DAX if mount option is used
Message-ID: <20170925233812.GM10955@dastard>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-2-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925231404.32723-2-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Sep 25, 2017 at 05:13:58PM -0600, Ross Zwisler wrote:
> Before support for the per-inode DAX flag was disabled the XFS the code had
> an issue where the user couldn't reliably tell whether or not DAX was being
> used to service page faults and I/O when the DAX mount option was used.  In
> this case each inode within the mounted filesystem started with S_DAX set
> due to the mount option, but it could be cleared if someone touched the
> individual inode flag.
> 
> For example (v4.13 and before):
> 
>   # mount | grep dax
>   /dev/pmem0 on /mnt type xfs
>   (rw,relatime,seclabel,attr2,dax,inode64,sunit=4096,swidth=4096,noquota)
> 
>   # touch /mnt/a /mnt/b   # both files currently use DAX
> 
>   # xfs_io -c "lsattr" /mnt/*  # neither has the DAX inode option set
>   ----------e----- /mnt/a
>   ----------e----- /mnt/b
> 
>   # xfs_io -c "chattr -x" /mnt/a  # this clears S_DAX for /mnt/a
> 
>   # xfs_io -c "lsattr" /mnt/*
>   ----------e----- /mnt/a
>   ----------e----- /mnt/b

That's really a bug in the lsattr code, yes? If we've cleared the
S_DAX flag for the inode, then why is it being reported in lsattr?
Or if we failed to clear the S_DAX flag in the 'chattr -x' call,
then isn't that the bug that needs fixing?

Remember, the whole point of the dax inode flag was to be able to
override the mount option setting so that admins could turn off/on
dax for the things that didn't/did work with DAX correctly so they
didn't need multiple filesystems on pmem to segregate the apps that
did/didn't work with DAX...

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
