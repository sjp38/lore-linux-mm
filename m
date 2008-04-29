Date: Wed, 30 Apr 2008 07:52:07 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: correct use of vmtruncate()?
Message-ID: <20080429215207.GT108924158@sgi.com>
References: <20080429100601.GO108924158@sgi.com> <481756A3.20601@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <481756A3.20601@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zach Brown <zach.brown@oracle.com>
Cc: David Chinner <dgc@sgi.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs-oss <xfs@oss.sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 10:10:59AM -0700, Zach Brown wrote:
> 
> > The obvious fix for this is that block_write_begin() and
> > friends should be calling ->setattr to do the truncation and hence
> > follow normal convention for truncating blocks off an inode.
> > However, even that appears to have thorns. e.g. in XFS we hold the
> > iolock exclusively when we call block_write_begin(), but it is not
> > held in all cases where ->setattr is currently called. Hence calling
> > ->setattr from block_write_begin in this failure case will deadlock
> > unless we also pass a "nolock" flag as well. XFS already
> > supports this (e.g. see the XFS fallocate implementation) but no other
> > filesystem does (some probably don't need to).
> 
> This paragraph in particular reminds me of an outstanding bug with
> O_DIRECT and ext*.  It isn't truncating partial allocations when a dio
> fails with ENOSPC.  This was noticed by a user who saw that fsck found
> bocks outside i_size in the file that saw ENOSPC if they tried to
> unmount and check the volume after the failed write.

That sounds very similar - ENOSPC seems to be one way of "easily"
generating the error condition that exposes this condition, but
I'm sure there are others as well...

> So, whether we decide that failed writes should call setattr or
> vmtruncate, we should also keep the generic O_DIRECT path in
> consideration.  Today it doesn't even try the supposed generic method of
> calling vmtrunate().

Certainly, though the locking will certainly be entertaining in
this path....

> (Though I'm sure XFS' dio code already handles freeing blocks :))

Not the dio code as such, but the close path does. Blocks beyond EOF get
truncated off in ->release or ->clear_inode (unless they were specifically
preallocated) and dio does not do delayed allocation so does not suffer
from the "need ->setattr issue" to truncate them away on ENOSPC. i.e. after
the error occurs and the app closes the fd, the blocks get truncated away.

Basically the problem I described is leaving delayed allocation blocks beyond
EOF without any page cache mappings to indicate they are there - allocated
blocks beyond EOF are not a problem...

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
