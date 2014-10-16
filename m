Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0D76B006C
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 03:20:39 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so302477pdi.5
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:20:38 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xf5si381571pab.170.2014.10.17.00.20.37
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 00:20:38 -0700 (PDT)
Date: Thu, 16 Oct 2014 18:16:24 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 20/21] ext4: Add DAX functionality
Message-ID: <20141016221624.GL11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-21-git-send-email-matthew.r.wilcox@intel.com>
 <20141016125625.GR19075@thinkos.etherlink>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016125625.GR19075@thinkos.etherlink>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Oct 16, 2014 at 02:56:25PM +0200, Mathieu Desnoyers wrote:
> > +#define EXT4_MOUNT_DAX			0x00200	/* Execute in place */
> 
> Execute in place -> Direct Access stuff... (comment above)

Thanks!  Fixed.

> > +static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> > +{
> > +	return dax_fault(vma, vmf, ext4_get_block);
> > +					/* Is this the right get_block? */
> 
> perhaps this needs a TODO or FIXME or XXX to make sure an ext4
> maintainer does not miss this question.

Maybe I can ambush Ted in the halls tomorrow and find out?  :-)

> > +	.fsync		= ext4_sync_file,
> > +	.fallocate	= ext4_fallocate,
> 
> Perhaps adding comments saying that .splice_read and .splice_write are
> unavailable here would help understanding why we need a different file
> operations structure.

Good idea.  Done.

> > +static void ext4_end_io_unwritten(struct buffer_head *bh, int uptodate)
> > +{
> > +	struct inode *inode = bh->b_assoc_map->host;
> > +	/* XXX: breaks on 32-bit > 16GB. Is that even supported? */
> 
> Good question! It would be interesting to get an answer :)

Another thing to check tomorrow ...

> > +	if (!uptodate)
> > +		return;
> > +	WARN_ON(!buffer_unwritten(bh));
> > +	err = ext4_convert_unwritten_extents(NULL, inode, offset, bh->b_size);
> 
> err is simply unused here, that does not look good (silent failure).

I don't think I can do more than WARN_ON here.  Maybe we can change
b_end_io() to return an int instead of void ... I think Dave Chinner has
grand plans for changes in this area as part of replacing the buffer_head
abstraction.

> > @@ -3238,14 +3249,6 @@ static int ext4_block_zero_page_range(handle_t *handle,
> >  		return -ENOMEM;
> >  
> >  	blocksize = inode->i_sb->s_blocksize;
> > -	max = blocksize - (offset & (blocksize - 1));
> > -
> > -	/*
> > -	 * correct length if it does not fall between
> > -	 * 'from' and the end of the block
> > -	 */
> > -	if (length > max || length < 0)
> > -		length = max;
> >  
> >  	iblock = index << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
[...]
> > +
> > +	/*
> > +	 * correct length if it does not fall between
> > +	 * 'from' and the end of the block
> > +	 */
> 
> Shouldn't a length < 0 be treated as an error instead ?
> 
> > +	if (length > max || length < 0)
> > +		length = max;

Monkey see code in wrong place.  Monkey move code.  monkey not understand
code.

> > @@ -3572,6 +3579,11 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
> >  				 "both data=journal and dioread_nolock");
> >  			goto failed_mount;
> >  		}
> > +		if (test_opt(sb, DAX)) {
> > +			ext4_msg(sb, KERN_ERR, "can't mount with "
> > +				 "both data=journal and dax");
> 
> This limitation regarding ext4 and dax should be documented in dax
> Documentation.

Maybe the ext4 documentation too?  It seems kind of obvious to me that if
ypu're enabling in-place-updates that you can't journal the data you're
updating (well ... you could implement undo-log journalling, I suppose,
which would be quite a change for ext4)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
