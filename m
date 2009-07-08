Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 880BA6B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 07:06:22 -0400 (EDT)
Date: Wed, 8 Jul 2009 13:14:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [rfc][patch 4/4] fs: tmpfs, ext2 use new truncate
Message-ID: <20090708111420.GB20924@duck.suse.cz>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144918.GF2714@wotan.suse.de> <20090707163829.GB14947@infradead.org> <20090708065327.GM2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090708065327.GM2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 08-07-09 08:53:27, Nick Piggin wrote:
> On Tue, Jul 07, 2009 at 12:38:29PM -0400, Christoph Hellwig wrote:
> > > @@ -68,7 +70,7 @@ void ext2_delete_inode (struct inode * i
> > >  
> > >  	inode->i_size = 0;
> > >  	if (inode->i_blocks)
> > > -		ext2_truncate (inode);
> > > +		ext2_truncate_blocks(inode, 0);
> > >  	ext2_free_inode (inode);
> > >  
> > >  	return;
> > 
> > > -void ext2_truncate(struct inode *inode)
> > > +static void ext2_truncate_blocks(struct inode *inode, loff_t offset)
> > >  {
> > >  	__le32 *i_data = EXT2_I(inode)->i_data;
> > >  	struct ext2_inode_info *ei = EXT2_I(inode);
> > > @@ -1032,27 +1074,8 @@ void ext2_truncate(struct inode *inode)
> > >  	int n;
> > >  	long iblock;
> > >  	unsigned blocksize;
> > > -
> > > -	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode) ||
> > > -	    S_ISLNK(inode->i_mode)))
> > > -		return;
> > > -	if (ext2_inode_is_fast_symlink(inode))
> > > -		return;
> > > -	if (IS_APPEND(inode) || IS_IMMUTABLE(inode))
> > > -		return;
> > > -
> > 
> > We can't move this to the caller easily.  ext2_delete_inode gets
> > called for all inodes, but we only want to go on truncating for the
> > limited set that passes this check.
> 
> Hmm, shouldn't they have no ->i_blocks in that case?
  Not necessarily. Inode can have extended attributes set and those can
be stored in a special block which is accounted in i_blocks.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
