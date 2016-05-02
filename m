Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBD246B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 09:09:16 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so140278139lfq.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 06:09:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vy5si34057535wjc.182.2016.05.02.06.09.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 May 2016 06:09:15 -0700 (PDT)
Date: Mon, 2 May 2016 15:09:09 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 08/18] ext4: Pre-zero allocated blocks for DAX IO
Message-ID: <20160502130909.GE17362@quack2.suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-9-git-send-email-jack@suse.cz>
 <20160429180158.GC5888@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429180158.GC5888@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Fri 29-04-16 12:01:58, Ross Zwisler wrote:
> On Mon, Apr 18, 2016 at 11:35:31PM +0200, Jan Kara wrote:
> > ---
> >  fs/ext4/ext4.h  | 11 +++++++++--
> >  fs/ext4/file.c  |  4 ++--
> >  fs/ext4/inode.c | 42 +++++++++++++++++++++++++++++++++---------
> >  3 files changed, 44 insertions(+), 13 deletions(-)
> > 
> > diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> > index 35792b430fb6..173da8faff81 100644
> > --- a/fs/ext4/ext4.h
> > +++ b/fs/ext4/ext4.h
> > @@ -2521,8 +2521,8 @@ struct buffer_head *ext4_getblk(handle_t *, struct inode *, ext4_lblk_t, int);
> >  struct buffer_head *ext4_bread(handle_t *, struct inode *, ext4_lblk_t, int);
> >  int ext4_get_block_unwritten(struct inode *inode, sector_t iblock,
> >  			     struct buffer_head *bh_result, int create);
> > -int ext4_dax_mmap_get_block(struct inode *inode, sector_t iblock,
> > -			    struct buffer_head *bh_result, int create);
> > +int ext4_dax_get_block(struct inode *inode, sector_t iblock,
> > +		       struct buffer_head *bh_result, int create);
> >  int ext4_get_block(struct inode *inode, sector_t iblock,
> >  		   struct buffer_head *bh_result, int create);
> >  int ext4_dio_get_block(struct inode *inode, sector_t iblock,
> > @@ -3328,6 +3328,13 @@ static inline void ext4_clear_io_unwritten_flag(ext4_io_end_t *io_end)
> >  	}
> >  }
> >  
> > +static inline bool ext4_aligned_io(struct inode *inode, loff_t off, loff_t len)
> > +{
> > +	int blksize = 1 << inode->i_blkbits;
> > +
> > +	return IS_ALIGNED(off, blksize) && IS_ALIGNED(off + len, blksize);
> 
> This could be just a tiny bit simpler by doing
> 
> 	return IS_ALIGNED(off, blksize) && IS_ALIGNED(len, blksize);
> 						      ^^^
> 
> You've already made sure 'off' is aligned, so if 'len' is aligned 'off+len'
> will be aligned.

Good point, done.

> > diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> > index 23fd0e0a9223..6d5d5c1db293 100644
> > --- a/fs/ext4/inode.c
> > +++ b/fs/ext4/inode.c
> > @@ -3215,12 +3215,17 @@ static int ext4_releasepage(struct page *page, gfp_t wait)
> >  }
> >  
> >  #ifdef CONFIG_FS_DAX
> > -int ext4_dax_mmap_get_block(struct inode *inode, sector_t iblock,
> > -			    struct buffer_head *bh_result, int create)
> > +/*
> > + * Get block function for DAX IO and mmap faults. It takes care of converting
> > + * unwritten extents to written ones and initializes new / converted blocks
> > + * to zeros.
> > + */
> > +int ext4_dax_get_block(struct inode *inode, sector_t iblock,
> > +		       struct buffer_head *bh_result, int create)
> >  {
> >  	int ret;
> >  
> > -	ext4_debug("ext4_dax_mmap_get_block: inode %lu, create flag %d\n",
> > +	ext4_debug("ext4_dax_get_block: inode %lu, create flag %d\n",
> >  		   inode->i_ino, create);
> 
> This pattern could be improved by using "%s" and __func__ for the function
> name.  That way you don't have to hunt through all your debug code and update
> strings when you rename a function. More importantly it prevents the strings
> from getting out of sync with the function name, resulting in confusing debug
> messages.

Actually, ext4_debug() already automatically prepends the function name. So
I've just discarded it from the format string.

> >  	if (!create)
> >  		return _ext4_get_block(inode, iblock, bh_result, 0);
> > @@ -3233,9 +3238,9 @@ int ext4_dax_mmap_get_block(struct inode *inode, sector_t iblock,
> >  
> >  	if (buffer_unwritten(bh_result)) {
> >  		/*
> > -		 * We are protected by i_mmap_sem so we know block cannot go
> > -		 * away from under us even though we dropped i_data_sem.
> > -		 * Convert extent to written and write zeros there.
> > +		 * We are protected by i_mmap_sem or i_mutex so we know block
> > +		 * cannot go away from under us even though we dropped
> > +		 * i_data_sem. Convert extent to written and write zeros there.
> >  		 */
> >  		ret = ext4_get_block_trans(inode, iblock, bh_result,
> >  					   EXT4_GET_BLOCKS_CONVERT |
> > @@ -3250,6 +3255,14 @@ int ext4_dax_mmap_get_block(struct inode *inode, sector_t iblock,
> >  	clear_buffer_new(bh_result);
> >  	return 0;
> >  }
> > +#else
> > +/* Just define empty function, it will never get called. */
> > +int ext4_dax_get_block(struct inode *inode, sector_t iblock,
> > +		       struct buffer_head *bh_result, int create)
> > +{
> > +	BUG();
> > +	return 0;
> > +}
> 
> You don't need this stub.  All the uses of ext4_dax_get_block() are either
> within their own '#ifdef CONFIG_FS_DAX' sections, or they are in an 
> "if (IS_DAX)" conditional.  The latter will also be compiled out if
> CONFIG_FS_DAX isn't defined.  This is because of the way that S_DAX is
> defined:
> 
>   #define S_DAX		8192	/* Direct Access, avoiding the page cache */
>   #else
>   #define S_DAX		0	/* Make all the DAX code disappear */
>   #endif

OK, I agree it's likely not needed but I'm somewhat wary of relying on this
compiler optimization. In some more complex cases for some compilers they
needn't be able to infer that the code is actually dead and you'll get
compilation error. IMO not worth those 7 lines of trivial code... So I've
kept this.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
