Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id B8FC86B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 19:40:04 -0500 (EST)
Received: by igvi2 with SMTP id i2so23359576igv.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 16:40:04 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id p133si15136393iop.15.2015.11.19.16.40.02
        for <linux-mm@kvack.org>;
        Thu, 19 Nov 2015 16:40:03 -0800 (PST)
Date: Fri, 20 Nov 2015 11:37:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 11/11] xfs: add support for DAX fsync/msync
Message-ID: <20151120003733.GO14311@dastard>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
 <1447459610-14259-12-git-send-email-ross.zwisler@linux.intel.com>
 <20151116231222.GY19199@dastard>
 <20151117190341.GD28024@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151117190341.GD28024@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue, Nov 17, 2015 at 12:03:41PM -0700, Ross Zwisler wrote:
> On Tue, Nov 17, 2015 at 10:12:22AM +1100, Dave Chinner wrote:
> > On Fri, Nov 13, 2015 at 05:06:50PM -0700, Ross Zwisler wrote:
> > > To properly support the new DAX fsync/msync infrastructure filesystems
> > > need to call dax_pfn_mkwrite() so that DAX can properly track when a user
> > > write faults on a previously cleaned address.  They also need to call
> > > dax_fsync() in the filesystem fsync() path.  This dax_fsync() call uses
> > > addresses retrieved from get_block() so it needs to be ordered with
> > > respect to truncate.  This is accomplished by using the same locking that
> > > was set up for DAX page faults.
> > > 
> > > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > ---
> > >  fs/xfs/xfs_file.c | 18 +++++++++++++-----
> > >  1 file changed, 13 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> > > index 39743ef..2b490a1 100644
> > > --- a/fs/xfs/xfs_file.c
> > > +++ b/fs/xfs/xfs_file.c
> > > @@ -209,7 +209,8 @@ xfs_file_fsync(
> > >  	loff_t			end,
> > >  	int			datasync)
> > >  {
> > > -	struct inode		*inode = file->f_mapping->host;
> > > +	struct address_space	*mapping = file->f_mapping;
> > > +	struct inode		*inode = mapping->host;
> > >  	struct xfs_inode	*ip = XFS_I(inode);
> > >  	struct xfs_mount	*mp = ip->i_mount;
> > >  	int			error = 0;
> > > @@ -218,7 +219,13 @@ xfs_file_fsync(
> > >  
> > >  	trace_xfs_file_fsync(ip);
> > >  
> > > -	error = filemap_write_and_wait_range(inode->i_mapping, start, end);
> > > +	if (dax_mapping(mapping)) {
> > > +		xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
> > > +		dax_fsync(mapping, start, end);
> > > +		xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
> > > +	}
> > > +
> > > +	error = filemap_write_and_wait_range(mapping, start, end);
> > 
> > Ok, I don't understand a couple of things here.
> > 
> > Firstly, if it's a DAX mapping, why are we still calling
> > filemap_write_and_wait_range() after the dax_fsync() call that has
> > already written back all the dirty cachelines?
> > 
> > Secondly, exactly what is the XFS_MMAPLOCK_SHARED lock supposed to
> > be doing here? I don't see where dax_fsync() has any callouts to
> > get_block(), so the comment "needs to be ordered with respect to
> > truncate" doesn't make any obvious sense. If we have a racing
> > truncate removing entries from the radix tree, then thanks to the
> > mapping tree lock we'll either find an entry we need to write back,
> > or we won't find any entry at all, right?
> 
> You're right, dax_fsync() doesn't call out to get_block() any more.  It does
> save the results of get_block() calls from the page faults, though, and I was
> concerned about the following race:
> 
> fsync thread				truncate thread
> ------------				---------------
> dax_fsync()
> save tagged entries in pvec
> 
> 					change block mapping for inode so that
> 					entries saved in pvec are no longer
> 					owned by this inode
> 
> loop through pvec using stale results
> from get_block(), flushing and cleaning
> entries we no longer own

dax_fsync is trying to do lockless lookups on an object that has no
internal reference count or synchronisation mechanism. That simply
doesn't work. In contrast, the struct page has the page lock, and
then with that held we can do the page->mapping checks to serialise
against and detect races with invalidation.

If you note the code in clear_exceptional_entry() in the
invalidation code:

        spin_lock_irq(&mapping->tree_lock);
        /*
         * Regular page slots are stabilized by the page lock even
         * without the tree itself locked.  These unlocked entries
         * need verification under the tree lock.
         */
        if (!__radix_tree_lookup(&mapping->page_tree, index, &node, &slot))
                goto unlock;
        if (*slot != entry)
		goto unlock;
	radix_tree_replace_slot(slot, NULL);


it basically says exactly this: exception entries are only valid
when the lookup is done under the mapping tree lock. IOWs, while you
can find exceptional entries via lockless radix tree lookups, you
*can't use them* safely.

Hence dax_fsync() needs to validate the exceptional entries it finds
via the pvec lookup under the mapping tree lock, and then flush the
cache while still holding the mapping tree lock. At that point, it
is safe against invalidation races....

> In looking at the xfs_file_fsync() code, though, it seems like if this race
> existed it would also exist for page cache entries that were being put into a
> pvec in write_cache_pages(), and that we would similarly be writing back
> cached pages that no longer belong to this inode.

That's what the page->mapping checks in write_cache_pages() protect
against. Everywhere you see a "lock_page(); if (page->mapping !=
mapping)" style of operation, it is checking against a racing
page invalidation.

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
