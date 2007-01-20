Date: Sat, 20 Jan 2007 04:50:39 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 6/10] mm: be sure to trim blocks
Message-ID: <20070120035039.GA30774@wotan.suse.de>
References: <20070113011159.9449.4327.sendpatchset@linux.site> <20070113011255.9449.33228.sendpatchset@linux.site> <87bql1lm6v.fsf@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bql1lm6v.fsf@sw.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dmitriy Monakhov <dmonakhov@sw.ru>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 14, 2007 at 05:25:44PM +0300, Dmitriy Monakhov wrote:
> Nick Piggin <npiggin@suse.de> writes:
> 
> > If prepare_write fails with AOP_TRUNCATED_PAGE, or if commit_write fails, then
> > we may have failed the write operation despite prepare_write having
> > instantiated blocks past i_size. Fix this, and consolidate the trimming into
> > one place.
> >
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> >
> > Index: linux-2.6/mm/filemap.c
> > ===================================================================
> > --- linux-2.6.orig/mm/filemap.c
> > +++ linux-2.6/mm/filemap.c
> > @@ -1911,22 +1911,9 @@ generic_file_buffered_write(struct kiocb
> >  		}
> >  
> >  		status = a_ops->prepare_write(file, page, offset, offset+bytes);
> > -		if (unlikely(status)) {
> > -			loff_t isize = i_size_read(inode);
> > +		if (unlikely(status))
> > +			goto fs_write_aop_error;
> May be it's stupid question but still..
> Why we treat non zero prepare_write() return code as error, it may be positive.
> Positive error code may be used as fine grained 'bytes' limiter in case of 
> blksize < pgsize as follows:
> 
>                 status = a_ops->prepare_write(file, page, offset, offset+bytes);
> 		if (unlikely(status)) {
>                         if (status > 0) {
>                                 bytes = min(bytes, status);
>                                 status = 0;
>                         } else {
>                 	        goto fs_write_aop_error;
>                         }
>                 }
> ---
> This is useful because fs may want to reduce 'bytes' by number of reasons,
> for example make it blksize bound. 
> Example : filesystem has 1k blksize and only two free blocks. And we try 
> write 4k bytes.
> Currently  write(fd, buff, 4096) will return -ENOSPC
> But after this fix write(fd, buff, 4096) will return as mutch as it can (2048).

It isn't a stupid question. Hmm, while it isn't documented in vfs.txt, it
seems like some filesystems actually do this. AFFS, maybe JFFS. So good
catch, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
