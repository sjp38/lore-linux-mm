Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7566B0085
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 08:05:21 -0400 (EDT)
Date: Wed, 17 Jun 2009 14:05:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 07/11] vfs: Unmap underlying metadata of new data
	buffers only when buffer is mapped
Message-ID: <20090617120520.GD2612@duck.suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-8-git-send-email-jack@suse.cz> <20090617103543.GB29931@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090617103543.GB29931@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed 17-06-09 12:35:43, Nick Piggin wrote:
> On Mon, Jun 15, 2009 at 07:59:54PM +0200, Jan Kara wrote:
> > When we do delayed allocation of some buffer, we want to signal to VFS that
> > the buffer is new (set buffer_new) so that it properly zeros out everything.
> > But we don't have the buffer mapped yet so we cannot really unmap underlying
> > metadata in this state. Make VFS avoid doing unmapping of metadata when the
> > buffer is not yet mapped.
> 
> Is this a seperate bugfix for delalloc filesystems? What is the error
> case of attempting to unmap underlying metadata of non mapped buffer?
> Won't translate to a serious bug will it?
  If you do unmap_underlying_metadata on !mapped buffer, the kernel will
oops because it will try to dereference bh->b_bdev which is NULL. Ext4 or
XFS workaround this issue by setting b_bdev to the real device and b_blocknr
to ~0 so unmap_underlying_metadata does not oops.  As I didn't want to do
the same hack in ext3, I need this patch...
  You're right it's not directly connected with the mkwrite problem and
can go in separately. Given how late it is, I'd like to get patch number 2
reviewed (generic mkwrite changes), so that it can go together with patch
number 4 (ext4 fixes) in the current merge window. The rest is not that
urgent since it's not oopsable and you can hit it only when running out
of space (or hitting quota limit)...

								Honza

> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/buffer.c |   12 +++++++-----
> >  1 files changed, 7 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/buffer.c b/fs/buffer.c
> > index 80e2630..7eb1710 100644
> > --- a/fs/buffer.c
> > +++ b/fs/buffer.c
> > @@ -1683,8 +1683,9 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
> >  			if (buffer_new(bh)) {
> >  				/* blockdev mappings never come here */
> >  				clear_buffer_new(bh);
> > -				unmap_underlying_metadata(bh->b_bdev,
> > -							bh->b_blocknr);
> > +				if (buffer_mapped(bh))
> > +					unmap_underlying_metadata(bh->b_bdev,
> > +						bh->b_blocknr);
> >  			}
> >  		}
> >  		bh = bh->b_this_page;
> > @@ -1869,8 +1870,9 @@ static int __block_prepare_write(struct inode *inode, struct page *page,
> >  			if (err)
> >  				break;
> >  			if (buffer_new(bh)) {
> > -				unmap_underlying_metadata(bh->b_bdev,
> > -							bh->b_blocknr);
> > +				if (buffer_mapped(bh))
> > +					unmap_underlying_metadata(bh->b_bdev,
> > +						bh->b_blocknr);
> >  				if (PageUptodate(page)) {
> >  					clear_buffer_new(bh);
> >  					set_buffer_uptodate(bh);
> > @@ -2683,7 +2685,7 @@ int nobh_write_begin(struct file *file, struct address_space *mapping,
> >  			goto failed;
> >  		if (!buffer_mapped(bh))
> >  			is_mapped_to_disk = 0;
> > -		if (buffer_new(bh))
> > +		if (buffer_new(bh) && buffer_mapped(bh))
> >  			unmap_underlying_metadata(bh->b_bdev, bh->b_blocknr);
> >  		if (PageUptodate(page)) {
> >  			set_buffer_uptodate(bh);
> > -- 
> > 1.6.0.2
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
