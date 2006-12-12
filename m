Date: Mon, 11 Dec 2006 22:36:30 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]  incorrect error handling inside
 generic_file_direct_write
Message-Id: <20061211223630.a96ef156.akpm@osdl.org>
In-Reply-To: <87lkld31vd.fsf@sw.ru>
References: <87k60y1rq4.fsf@sw.ru>
	<20061211124052.144e69a0.akpm@osdl.org>
	<87lkld31vd.fsf@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dmitriy Monakhov <dmonakhov@sw.ru>
Cc: Dmitriy Monakhov <dmonakhov@openvz.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, devel@openvz.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 12 Dec 2006 12:22:14 +0300
Dmitriy Monakhov <dmonakhov@sw.ru> wrote:

> >> @@ -2041,6 +2041,14 @@ generic_file_direct_write(struct kiocb *
> >>  			mark_inode_dirty(inode);
> >>  		}
> >>  		*ppos = end;
> >> +	} else if (written < 0) {
> >> +		loff_t isize = i_size_read(inode);
> >> +		/*
> >> +		 * generic_file_direct_IO() may have instantiated a few blocks
> >> +		 * outside i_size.  Trim these off again.
> >> +		 */
> >> +		if (pos + count > isize)
> >> +			vmtruncate(inode, isize);
> >>  	}
> >>  
> >
> > XFS (at least) can call generic_file_direct_write() with i_mutex not held. 
> How could it be ?
> 
> from mm/filemap.c:2046 generic_file_direct_write() comment right after 
> place where i want to add vmtruncate()
> /*
> 	 * Sync the fs metadata but not the minor inode changes and
> 	 * of course not the data as we did direct DMA for the IO.
> 	 * i_mutex is held, which protects generic_osync_inode() from
> 	 * livelocking.
> 	 */
> 
> > And vmtruncate() expects i_mutex to be held.
> generic_file_direct_IO must called under i_mutex too
> from mm/filemap.c:2388
>   /*
>    * Called under i_mutex for writes to S_ISREG files.   Returns -EIO if something
>    * went wrong during pagecache shootdown.
>    */
>   static ssize_t
>   generic_file_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,

yup, the comments are wrong.

> This means XFS generic_file_direct_write() call generic_file_direct_IO() without
> i_mutex held too?

Think so.  XFS uses blockdev_direct_IO_own_locking().  We'd need to check
with the XFS guys regarding its precise operation and what needs to be done
here.

> >
> > I guess a suitable solution would be to push this problem back up to the
> > callers: let them decide whether to run vmtruncate() and if so, to ensure
> > that i_mutex is held.
> >
> > The existence of generic_file_aio_write_nolock() makes that rather messy
> > though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
