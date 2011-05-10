Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1BEC76B0025
	for <linux-mm@kvack.org>; Tue, 10 May 2011 08:41:23 -0400 (EDT)
Date: Tue, 10 May 2011 14:41:03 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/7] fs: block_page_mkwrite should wait for writeback
 to finish
Message-ID: <20110510124103.GC4402@quack.suse.cz>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
 <20110509230334.19566.17603.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110509230334.19566.17603.stgit@elm3c44.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Mon 09-05-11 16:03:34, Darrick J. Wong wrote:
> For filesystems such as nilfs2 and xfs that use block_page_mkwrite, modify that
> function to wait for pending writeback before allowing the page to become
> writable.  This is needed to stabilize pages during writeback for those two
> filesystems.
> 
> Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
> ---
>  fs/buffer.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
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
  Not that it matters much but it would seem more logical to me if we
waited only in not-error case (i.e. after the error handling below).

								Honza
>  	if (unlikely(ret)) {
>  		unlock_page(page);
>  		if (ret == -ENOMEM)
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
