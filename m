Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9E56B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 05:35:55 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p5so20898925pgn.7
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:35:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t77si5580947pgb.158.2017.09.26.02.35.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 02:35:54 -0700 (PDT)
Date: Tue, 26 Sep 2017 11:35:48 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/7] xfs: always use DAX if mount option is used
Message-ID: <20170926093548.GB13627@quack2.suse.cz>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-2-ross.zwisler@linux.intel.com>
 <20170925233812.GM10955@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925233812.GM10955@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue 26-09-17 09:38:12, Dave Chinner wrote:
> On Mon, Sep 25, 2017 at 05:13:58PM -0600, Ross Zwisler wrote:
> > Before support for the per-inode DAX flag was disabled the XFS the code had
> > an issue where the user couldn't reliably tell whether or not DAX was being
> > used to service page faults and I/O when the DAX mount option was used.  In
> > this case each inode within the mounted filesystem started with S_DAX set
> > due to the mount option, but it could be cleared if someone touched the
> > individual inode flag.
> > 
> > For example (v4.13 and before):
> > 
> >   # mount | grep dax
> >   /dev/pmem0 on /mnt type xfs
> >   (rw,relatime,seclabel,attr2,dax,inode64,sunit=4096,swidth=4096,noquota)
> > 
> >   # touch /mnt/a /mnt/b   # both files currently use DAX
> > 
> >   # xfs_io -c "lsattr" /mnt/*  # neither has the DAX inode option set
> >   ----------e----- /mnt/a
> >   ----------e----- /mnt/b
> > 
> >   # xfs_io -c "chattr -x" /mnt/a  # this clears S_DAX for /mnt/a
> > 
> >   # xfs_io -c "lsattr" /mnt/*
> >   ----------e----- /mnt/a
> >   ----------e----- /mnt/b
> 
> That's really a bug in the lsattr code, yes? If we've cleared the
> S_DAX flag for the inode, then why is it being reported in lsattr?
> Or if we failed to clear the S_DAX flag in the 'chattr -x' call,
> then isn't that the bug that needs fixing?
> 
> Remember, the whole point of the dax inode flag was to be able to
> override the mount option setting so that admins could turn off/on
> dax for the things that didn't/did work with DAX correctly so they
> didn't need multiple filesystems on pmem to segregate the apps that
> did/didn't work with DAX...

So I think there is some confusion that is created by the fact that whether
DAX is used or not is controlled by both a mount option and an inode flag.
We could define that "Inode flag always wins" which is what you seem to
suggest above but then mount option has no practical effect since on-disk
S_DAX flag will always overrule it.

Ross suggests that DAX should be used if "Inode flag or mount option is
set". Which is similar to how e.g. noatime inode flag works but does not
allow to selectively disable DAX.

So if we wanted both mount option to work and selective disabling of DAX,
we would need three states of inode setting - force DAX, disable DAX,
inherit from mount option.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
