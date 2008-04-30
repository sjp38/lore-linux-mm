Date: Wed, 30 Apr 2008 20:15:25 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: correct use of vmtruncate()?
Message-ID: <20080430101525.GJ108924158@sgi.com>
References: <20080429100601.GO108924158@sgi.com> <20080430074738.GC7791@skywalker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080430074738.GC7791@skywalker>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: David Chinner <dgc@sgi.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs-oss <xfs@oss.sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2008 at 01:17:38PM +0530, Aneesh Kumar K.V wrote:
> On Tue, Apr 29, 2008 at 08:06:01PM +1000, David Chinner wrote:
> > Folks,
> > 
> > It appears to me that vmtruncate() is not used correctly in
> > block_write_begin() and friends. The short summary is that it
> > appears that the usage in these functions implies that vmtruncate()
> > should cause truncation of blocks on disk but no filesystem
> > appears to do this, nor does the documentation imply they should.
> 
> Looking at ext*_truncate, I see we are freeing blocks as a part of vmtruncate.
> Or did I miss something ?

No I missed something. I was looking at block_truncate_page() which is
called by various truncate methods but does not do truncation itself.

Still doesn't help XFS, though, as updating different parts of the
inode in different transactions will result in non-atomic ->setattr
updates. Which, given that XFS tends to excel at exposing non-atomic
modifications in crash recovery, is a really bad thing.

Looking further, doing the truncate operation in ->truncate is
probably really stupid simply because the interface does not allow
errors to be returned to the caller. e.g. ufs_setattr() has this
comment:

/*
 * We don't define our `inode->i_op->truncate', and call it here,
 * because of:
 * - there is no way to know old size
 * - there is no way inform user about error, if it happens in `truncate'
 */

and I've just added a WARN_ON(error) to xfs_vn_truncate() so that
errors don't get lost silently.

UFS also uses block_write_begin(), so it will have exactly the same
problem as XFS - blocks beyond EOF don't get truncated away by
vmtruncate if an error occurs in block_write_begin().

AFAICT, gfs2 is another filesystem that does not have a ->truncate
callback - truncation is driven through the ->setattr interface.
However, gfs2_write_begin() calls vmtruncate() like
block_write_begin() on error from block_prepare_write() and hence
also has this bug. 

I'm sure there are other filesystems that, like XFS, UFS and GFS2,
don't do block truncation in ->truncate. Hence it really does seem
that calling vmtruncate() from anything other than a ->setattr method
is a bug because to do so is to make a false assumption about how
filesystems are implemented....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
