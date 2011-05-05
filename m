Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8D74D6B0025
	for <linux-mm@kvack.org>; Thu,  5 May 2011 11:26:21 -0400 (EDT)
Date: Thu, 5 May 2011 17:26:01 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 0/3] data integrity: Stabilize pages during
 writeback for ext4
Message-ID: <20110505152601.GI5323@quack.suse.cz>
References: <20110411124229.47bc28f6@corrin.poochiereds.net>
 <1302543595-sup-4352@think>
 <1302569212.2580.13.camel@mingming-laptop>
 <20110412005719.GA23077@infradead.org>
 <1302742128.2586.274.camel@mingming-laptop>
 <20110422000226.GA22189@tux1.beaverton.ibm.com>
 <20110504173704.GE20579@tux1.beaverton.ibm.com>
 <20110504184644.GA23246@infradead.org>
 <1304536162-sup-3721@think>
 <20110504235706.GJ20579@tux1.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110504235706.GJ20579@tux1.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@redhat.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Joel Becker <jlbec@evilplan.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@kernel.dk>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mingming Cao <cmm@us.ibm.com>, linux-scsi <linux-scsi@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>

  Hello,

On Wed 04-05-11 16:57:06, Darrick J. Wong wrote:
> On Wed, May 04, 2011 at 03:21:55PM -0400, Chris Mason wrote:
> > Excerpts from Christoph Hellwig's message of 2011-05-04 14:46:44 -0400:
> > > This seems to miss out on a lot of the generic functionality like
> > > write_cache_pages and block_page_mkwrite and just patch it into
> > > the ext4 copy & paste variants.  Please make sure your patches also
> > > work for filesystem that use more of the generic functionality like
> > > xfs or ext2 (the latter one might be fun for the mmap case).
> > 
> > Probably after the block_commit_write in block_page_mkwrite()
> > Another question is, do we want to introduce a wait_on_stable_page_writeback()?
> 
> Something like this here?  It fixes block_page_mkwrite users and sticks in a
> simple page_mkwrite for fses that don't provide one at all.  From a quick wac
> run it seems to make xfs work.  ext2 seems to have some issues with modifying a
> buffer_head's bh_data without locking the bh during the update, so I guess it
> needs some review.
  Yes, ext2 is rather difficult because of all the metadata updates to
buffers happening. That would need a serious work I suspect.

> fs: Modify/provide generic writepage/page_mkwrite functions to wait for writeback
> 
> Modify the generic writepage function, and add an empty page_mkwrite function,
> to wait for page writeback to finish before allowing writes.  This is so that
> simple filesystems have stable pages during write operations.
> 
> Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
> ---
> 
>  fs/buffer.c  |    1 +
>  mm/filemap.c |   10 ++++++++++
>  2 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index a08bb8e..cf9a795 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -2361,6 +2361,7 @@ block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
>  	if (!ret)
>  		ret = block_commit_write(page, 0, end);
>  
> +	wait_on_page_writeback(page);
>  	if (unlikely(ret)) {
>  		unlock_page(page);
>  		if (ret == -ENOMEM)
> diff --git a/mm/filemap.c b/mm/filemap.c
> index c22675f..9cb4e51 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1713,8 +1713,18 @@ page_not_uptodate:
>  }
>  EXPORT_SYMBOL(filemap_fault);
>  
> +static int empty_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> +{
> +	struct page *page = vmf->page;
> +
> +	lock_page(page);
> +	wait_on_page_writeback(page);
> +	return VM_FAULT_LOCKED;
> +}
> +
  I guess you miss the whether the page has been truncated here (in which
case you should return VM_FAULT_NOPAGE).

>  const struct vm_operations_struct generic_file_vm_ops = {
>  	.fault		= filemap_fault,
> +	.page_mkwrite	= empty_page_mkwrite,
>  };
>  
>  /* This is used for a general mmap of a disk file */

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
