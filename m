Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA58F830E7
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 03:42:24 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id le9so254163961pab.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 00:42:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id x87si37791620pfa.79.2016.08.29.00.42.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 00:42:23 -0700 (PDT)
Date: Mon, 29 Aug 2016 00:41:16 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Message-ID: <20160829074116.GA16491@infradead.org>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160826212934.GA11265@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-nvdimm@ml01.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Fri, Aug 26, 2016 at 03:29:34PM -0600, Ross Zwisler wrote:
> These changes don't remove the things in XFS needed by the old I/O and fault
> paths (e.g.  xfs_get_blocks_direct() is still there an unchanged).  Is the
> correct way forward to get buy-in from ext2/ext4 so that they also move to
> supporting an iomap based I/O path (xfs_file_iomap_begin(),
> xfs_iomap_write_direct(), etc?).  That would allow us to have parallel I/O and
> fault paths for a while, then remove the old buffer_head based versions when
> the three supported filesystems have moved to iomap.
> 
> If ext2 and ext4 don't choose to move to iomap, though, I don't think we want
> to have a separate I/O & fault path for iomap/XFS.  That seems too painful,
> and the old buffer_head version should continue to work, ugly as it may be.

We're going to move forward killing buffer_heads in XFS.  I think ext4
would dramatically benefit from this a well, as would ext2 (although I
think all that DAX work in ext2 is a horrible idea to start with).

If I don't get buy-in for the iomap DAX work in the dax code we'll just
have to keep it separate.  That buffer_head mess just isn't maintainable
the long run.

> 1) In your mail above you say "It also gets rid of the other warts of the DAX
>    path due to pretending to be like direct I/O".  I assume by this you mean
>    the code in dax_do_io() around DIO_LOCKING, inode_dio_begin(), etc?

Yes.

>    Perhaps there are other things as well in XFS, but this is what I see in
>    the DAX code.  If so, yep, this seems like a win.  I don't understand how
>    DIO_LOCKING is relevant to the DAX I/O path, as we never mix buffered and
>    direct access.

It's related to doing stupid copy and paste from direct I/O in the DAX
code.

>    The comment in dax_do_io() for the inode_dio_begin() call says that it
>    prevents the I/O from races with truncate.  Am I correct that we now get
>    this protection via the xfs_rw_ilock()/xfs_rw_iunlock() calls in
>    xfs_file_dax_write()?

Yes, XFS always has a lock over reads that serializes with truncate.
Currenrly it's the XFS i_iolock, but I'll remove that soon and use the
VFS i_rwsem instead.  For ext2/4 we could go straight to i_rwsem in
shared mode.

> 2) Just a nit, I noticed that you used "~(PAGE_SIZE - 1)" in several places in
>    iomap_dax_actor() and iomap_dax_fault() instead of PAGE_MASK.  Was this
>    intentional?

Mostly because that's how I think.  I'm fine using PAGE_MASK, though.

> 3) It's kind of weird having iomap_dax_fault() in fs/dax.c but having
>    iomap_dax_actor() and iomap_dax_rw() in fs/iomap.c?  I'm guessing the
>    latter is placed where it is because it uses iomap_apply(), which is local
>    to fs/iomap.c?  Anyway, it would be nice if we could keep them together, if
>    possible.

It's still work in progress and could use a few cleanups.

> 
> 4) In iomap_dax_actor() you do this check:
> 
> 	WARN_ON_ONCE(iomap->type != IOMAP_MAPPED);
> 
>    If we hit this we should bail with -EIO, yea?  Otherwise we could write to
>    unmapped space or something horrible.

Fine with me.

> 5) In iomap_dax_fault, I think the "I/O beyond the end of the file" check
>    might have been broken.  Take for example an I/O to the second page of a
>    file, where the file has size one page.  So:

sure, I can fix this up.

> 6) Regarding the "we don't even have the size hole problem" comment in your
>    mail, the current PMD logic requires us to know the size of the hole.

And a big part of the iomap interface is proper reporting of holes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
