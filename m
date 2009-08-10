Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BFEA16B004D
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 03:07:47 -0400 (EDT)
Date: Mon, 10 Aug 2009 15:07:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for
	migration    aware file systems
Message-ID: <20090810070745.GA26533@localhost>
References: <200908051136.682859934@firstfloor.org> <20090805093643.E0C00B15D8@basil.firstfloor.org> <4A7FBFD1.2010208@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A7FBFD1.2010208@hitachi.com>
Sender: owner-linux-mm@kvack.org
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, "tytso@mit.edu" <tytso@mit.edu>, "hch@infradead.org" <hch@infradead.org>, "mfasheh@suse.com" <mfasheh@suse.com>, "aia21@cantab.net" <aia21@cantab.net>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "swhiteho@redhat.com" <swhiteho@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Hidehiro,

On Mon, Aug 10, 2009 at 02:36:01PM +0800, Hidehiro Kawai wrote:
> Hi,
> 
> Andi Kleen wrote:
> 
> > Index: linux/fs/ext3/inode.c
> > ===================================================================
> > --- linux.orig/fs/ext3/inode.c
> > +++ linux/fs/ext3/inode.c
> > @@ -1819,6 +1819,7 @@ static const struct address_space_operat
> >  	.direct_IO		= ext3_direct_IO,
> >  	.migratepage		= buffer_migrate_page,
> >  	.is_partially_uptodate  = block_is_partially_uptodate,
> > +	.error_remove_page	= generic_error_remove_page,
> >  };
> 
> (I'm sorry if I'm missing the point.)
> 
> If my understanding is correct, the following scenario can happen:
> 
> 1. An uncorrected error on a dirty page cache page is detected by
>    memory scrubbing
> 2. Kernel unmaps and truncates the page to recover from the error
> 3. An application reads data from the file location corresponding
>    to the truncated page
>    ==> Old or garbage data will be read into a new page cache page
> 4. The application modifies the data and write back it to the disk
> 5. The file will corrurpt!
> 
> (Yes, the application is wrong to not do the right thing, i.e. fsync,
>  but it's not user's fault!)

Right. Note that the data has already been corrupted and the above
scenario can be called as re-corruption. We set AS_EIO to trigger some
IO reporting mechanism so that it won't corrupt *silently*.

> A similar data corruption can be caused by a write I/O error,
> because dirty flag is cleared even if the page couldn't be written
> to the disk.

Yes.

> However, we have a way to avoid this kind of data corruption at
> least for ext3.  If we mount an ext3 filesystem with data=ordered
> and data_err=abort, all I/O errors on file data block belonging to
> the committing transaction are checked.  When I/O error is found,
> abort journaling and remount the filesystem with read-only to
> prevent further updates.  This kind of feature is very important
> for mission critical systems.

Agreed. We also set PG_error, which should be enough to trigger such
remount?

> If we merge this patch, we would face the data corruption problem
> again.
> 
> I think there are three options,
> 
> (1) drop this patch
> (2) merge this patch with new panic_on_dirty_page_cache_corruption
>     sysctl
> (3) implement a more sophisticated error_remove_page function

In fact we proposed a patch for preventing the re-corruption case, see

        http://lkml.org/lkml/2009/6/11/294

However it is hard to answer the (policy) question "How sticky should
the EIO bit remain?".

> >  static const struct address_space_operations ext3_writeback_aops = {
> > @@ -1834,6 +1835,7 @@ static const struct address_space_operat
> >  	.direct_IO		= ext3_direct_IO,
> >  	.migratepage		= buffer_migrate_page,
> >  	.is_partially_uptodate  = block_is_partially_uptodate,
> > +	.error_remove_page	= generic_error_remove_page,
> >  };
> 
> The writeback case would be OK. It's not much different from the I/O
> error case.
> 
> >  static const struct address_space_operations ext3_journalled_aops = {
> > @@ -1848,6 +1850,7 @@ static const struct address_space_operat
> >  	.invalidatepage		= ext3_invalidatepage,
> >  	.releasepage		= ext3_releasepage,
> >  	.is_partially_uptodate  = block_is_partially_uptodate,
> > +	.error_remove_page	= generic_error_remove_page,
> >  };
> >  
> >  void ext3_set_aops(struct inode *inode)
> 
> I'm not sure about the journalled case.  I'm going to take a look at
> it later.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
