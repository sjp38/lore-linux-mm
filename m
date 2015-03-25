Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id DD5026B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 05:41:52 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so23054800pdb.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:41:52 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id yy3si2862538pbb.193.2015.03.25.02.41.50
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 02:41:52 -0700 (PDT)
Date: Wed, 25 Mar 2015 20:41:35 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
Message-ID: <20150325094135.GI31342@dastard>
References: <55100B78.501@plexistor.com>
 <55100D10.6090902@plexistor.com>
 <55115A99.40705@plexistor.com>
 <20150325022633.GB31342@dastard>
 <5512725A.1010905@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5512725A.1010905@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On Wed, Mar 25, 2015 at 10:31:22AM +0200, Boaz Harrosh wrote:
> On 03/25/2015 04:26 AM, Dave Chinner wrote:
> <>
> >>> +	/* TODO: each DAX fs has some private mount option to enable DAX. If
> >>> +	 * We made that option a generic MS_DAX_ENABLE super_block flag we could
> >>> +	 * Avoid the 95% extra unneeded loop-on-all-inodes every freeze.
> >>> +	 * if (!(sb->s_flags & MS_DAX_ENABLE))
> >>> +	 *	return 0;
> >>> +	 */
> >>> +
> >>> +	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
> > 
> > missing locking.
> > 
> 
> I will please need help here. This is very deep inside the freeze process
> we area already holding bunch of locks. We know that nothing can be modified
> at this stage. We are completely read-only.

Which means we could stillbe reading new inodes in off disk and
hence the sb->s_inodes list can be changing. Memory reclaim can be
running via the shrinker, freeing clean inodes, hence the
sb->s_inodes list can be changing.

>From fs/inode.c:

/*
 * Inode locking rules:
.....
 * inode_sb_list_lock protects:
 *   sb->s_inodes, inode->i_sb_list

This...

> >>> +		/* TODO: For freezing we can actually do with write-protecting
> >>> +		 * the page. But I cannot find a ready made function that does
> >>> +		 * that for a giving mapping (with all the proper locking).
> >>> +		 * How performance sensitive is the all sb_freeze API?
> >>> +		 * For now we can just unmap the all mapping, and pay extra
> >>> +		 * on read faults.
> >>> +		 */
> >>> +		/* NOTE: Do not unmap private COW mapped pages it will not
> >>> +		 * modify the FS.
> >>> +		 */
> >>> +		if (IS_DAX(inode))
> >>> +			unmap_mapping_range(inode->i_mapping, 0, 0, 0);
> >>
> >> So what happens here is that we loop on all sb->s_inodes every freeze
> >> and in the not DAX case just do nothing.
> > 
> > Which is real bad and known to be a performance issue. See Josef's
> > recent sync scalability patchset posting that only tracks and walks
> > dirty inodes...
> 
> Sure but how hot is freeze? Josef's fixed the very hot sync path,
> but freeze happens once in a blue moon. Do we care?

Yes, because if you have 50 million cached inodes on a filesystem,
it's going to take a long time to traverse them all, and right now
the inode_sb_list_lock is a *global lock*.

> >> It could be nice to have a flag at the sb level to tel us if we need
> >> to expect IS_DAX() inodes at all, for example when we are mounted on
> >> an harddisk it should not be set.
> >>
> >> All of ext2/4 and now Dave's xfs have their own
> >> 	XFS_MOUNT_DAX / EXT2_MOUNT_DAX / EXT4_MOUNT_DAX
> >>
> >> Is it OK if I unify all this on sb->s_flags |= MS_MOUNT_DAX so I can check it
> >> here in Generic code? The option parsing will be done by each FS but
> >> the flag be global?
> > 
> > No, because as I mentioned in another thread we're going to end up
> > with filesystems that don't have "mount wide" DAX behaviour, and we
> > have to check every dirty inode anyway. And....
> > 
> 
> Sure! but let us contract with the FS, that please set the MS_MOUNT_DAX
> if there is any chance at all that IS_DAX() comes out true, so we loop
> here. 

The mount option is irrelevant here - we should only be looping over
dirty inodes.  We don't care if they are DAX or not - we have to
iterate them and ensure they are properly clean. We already have
infrastructure to do this - we should use it and fix the problem
once and for all rather than hacking special case code into random
places.

> BTW: We must loop this way on every sb inode because we do not have
> dirty inodes. There is no "dirty"ing going on in dax, not of inodes
> and not of pages.

Precisely the problem we need to address. We do have dirty inodes,
we just never set the fact they have dirty "pages" on them and hence
never do data writeback on them.

> > ... it's the wrong approach - sync_filesystem(sb) shoul dbe handling
> > this problem, so that sync and fsync work correctly, and then you
> > don't care about whether DAX is supported or not...
> > 
> 
> sync and fsync should and will work correctly, but this does not
> solve our problem. because what turns pages to read-only is the
> writeback. And we do not have this in dax. Therefore we need to
> do this here as a special case.

We can still use exactly the same dirty tracking as we use for data
writeback. The difference is that we don't need to go through all
teh page writeback; we can just flush the CPU caches and mark all
the mappings clean, then clear the I_DIRTY_PAGES flag and move on to
inode writeback....

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
