Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 865056B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 22:26:38 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so12552503pdb.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 19:26:38 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id xt6si1447568pbc.59.2015.03.24.19.26.36
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 19:26:37 -0700 (PDT)
Date: Wed, 25 Mar 2015 13:26:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
Message-ID: <20150325022633.GB31342@dastard>
References: <55100B78.501@plexistor.com>
 <55100D10.6090902@plexistor.com>
 <55115A99.40705@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55115A99.40705@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On Tue, Mar 24, 2015 at 02:37:45PM +0200, Boaz Harrosh wrote:
> On 03/23/2015 02:54 PM, Boaz Harrosh wrote:
> > From: Boaz Harrosh <boaz@plexistor.com>
> > 
> > When freezing an FS, we must write protect all IS_DAX()
> > inodes that have an mmap mapping on an inode. Otherwise
> > application will be able to modify previously faulted-in
> > file pages.
> > 
> > I'm actually doing a full unmap_mapping_range because
> > there is no readily available "mapping_write_protect" like
> > functionality. I do not think it is worth it to define one
> > just for here and just for some extra read-faults after an
> > fs_freeze.
> > 
> > How hot-path is fs_freeze at all?
> > 
> 
> OK So reinspecting this was a complete raw RFC. I need to do
> more work on this thing
> 
> comments below ...
> 
> > CC: Jan Kara <jack@suse.cz>
> > CC: Matthew Wilcox <matthew.r.wilcox@intel.com>
> > CC: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> > ---
> >  fs/dax.c           | 30 ++++++++++++++++++++++++++++++
> >  fs/super.c         |  3 +++
> >  include/linux/fs.h |  1 +
> >  3 files changed, 34 insertions(+)
> > 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index d0bd1f4..f3fc28b 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -549,3 +549,33 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
> >  	return dax_zero_page_range(inode, from, length, get_block);
> >  }
> >  EXPORT_SYMBOL_GPL(dax_truncate_page);
> > +
> > +/* This is meant to be called as part of freeze_super. otherwise we might
> > + * Need some extra locking before calling here.
> > + */
> > +void dax_prepare_freeze(struct super_block *sb)
> > +{
> > +	struct inode *inode;
> > +
> > +	/* TODO: each DAX fs has some private mount option to enable DAX. If
> > +	 * We made that option a generic MS_DAX_ENABLE super_block flag we could
> > +	 * Avoid the 95% extra unneeded loop-on-all-inodes every freeze.
> > +	 * if (!(sb->s_flags & MS_DAX_ENABLE))
> > +	 *	return 0;
> > +	 */
> > +
> > +	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {

missing locking.

> > +		/* TODO: For freezing we can actually do with write-protecting
> > +		 * the page. But I cannot find a ready made function that does
> > +		 * that for a giving mapping (with all the proper locking).
> > +		 * How performance sensitive is the all sb_freeze API?
> > +		 * For now we can just unmap the all mapping, and pay extra
> > +		 * on read faults.
> > +		 */
> > +		/* NOTE: Do not unmap private COW mapped pages it will not
> > +		 * modify the FS.
> > +		 */
> > +		if (IS_DAX(inode))
> > +			unmap_mapping_range(inode->i_mapping, 0, 0, 0);
> 
> So what happens here is that we loop on all sb->s_inodes every freeze
> and in the not DAX case just do nothing.

Which is real bad and known to be a performance issue. See Josef's
recent sync scalability patchset posting that only tracks and walks
dirty inodes...

> It could be nice to have a flag at the sb level to tel us if we need
> to expect IS_DAX() inodes at all, for example when we are mounted on
> an harddisk it should not be set.
> 
> All of ext2/4 and now Dave's xfs have their own
> 	XFS_MOUNT_DAX / EXT2_MOUNT_DAX / EXT4_MOUNT_DAX
> 
> Is it OK if I unify all this on sb->s_flags |= MS_MOUNT_DAX so I can check it
> here in Generic code? The option parsing will be done by each FS but
> the flag be global?

No, because as I mentioned in another thread we're going to end up
with filesystems that don't have "mount wide" DAX behaviour, and we
have to check every dirty inode anyway. And....

> > diff --git a/fs/super.c b/fs/super.c
> > index 2b7dc90..9ef490c 100644
> > --- a/fs/super.c
> > +++ b/fs/super.c
> > @@ -1329,6 +1329,9 @@ int freeze_super(struct super_block *sb)
> >  	/* All writers are done so after syncing there won't be dirty data */
> >  	sync_filesystem(sb);
> >  
> > +	/* Need to take care of DAX mmaped inodes */
> > +	dax_prepare_freeze(sb);
> > +
> 
> So if CONFIG_FS_DAX is not set this will not compile I need to
> define an empty one if not set

... it's the wrong approach - sync_filesystem(sb) shoul dbe handling
this problem, so that sync and fsync work correctly, and then you
don't care about whether DAX is supported or not...

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
