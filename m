Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 201DC6B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 02:46:56 -0400 (EDT)
Date: Wed, 8 Jul 2009 08:53:27 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 4/4] fs: tmpfs, ext2 use new truncate
Message-ID: <20090708065327.GM2714@wotan.suse.de>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144918.GF2714@wotan.suse.de> <20090707163829.GB14947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707163829.GB14947@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 12:38:29PM -0400, Christoph Hellwig wrote:
> I'd still prefer this to be split into one patch for shmem, and one for
> ext2 to make bisecting easier.

Definitely agreed. I would prefer to even send individual fs patches
to respective maintainers so they can do their specific review and
QA on them and merge them as appropriate. The core change is
nicely back compatible, so there is no reason to tie it to the fs
patches.

 
> > @@ -68,7 +70,7 @@ void ext2_delete_inode (struct inode * i
> >  
> >  	inode->i_size = 0;
> >  	if (inode->i_blocks)
> > -		ext2_truncate (inode);
> > +		ext2_truncate_blocks(inode, 0);
> >  	ext2_free_inode (inode);
> >  
> >  	return;
> 
> > -void ext2_truncate(struct inode *inode)
> > +static void ext2_truncate_blocks(struct inode *inode, loff_t offset)
> >  {
> >  	__le32 *i_data = EXT2_I(inode)->i_data;
> >  	struct ext2_inode_info *ei = EXT2_I(inode);
> > @@ -1032,27 +1074,8 @@ void ext2_truncate(struct inode *inode)
> >  	int n;
> >  	long iblock;
> >  	unsigned blocksize;
> > -
> > -	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode) ||
> > -	    S_ISLNK(inode->i_mode)))
> > -		return;
> > -	if (ext2_inode_is_fast_symlink(inode))
> > -		return;
> > -	if (IS_APPEND(inode) || IS_IMMUTABLE(inode))
> > -		return;
> > -
> 
> We can't move this to the caller easily.  ext2_delete_inode gets
> called for all inodes, but we only want to go on truncating for the
> limited set that passes this check.

Hmm, shouldn't they have no ->i_blocks in that case?


> > -	if (mapping_is_xip(inode->i_mapping))
> > -		xip_truncate_page(inode->i_mapping, inode->i_size);
> > -	else if (test_opt(inode->i_sb, NOBH))
> > -		nobh_truncate_page(inode->i_mapping,
> > -				inode->i_size, ext2_get_block);
> > -	else
> > -		block_truncate_page(inode->i_mapping,
> > -				inode->i_size, ext2_get_block);
> 
> The patch header should have an explanation for why we don't need this
> anymore for the various existing callers.

OK. I guess it's not needed when blocks were completely outside
of i_size or the inode no longer has references and all blocks
will be freed. I will add the description.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
