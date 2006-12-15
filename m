Date: Fri, 15 Dec 2006 10:43:41 +0000
From: 'Christoph Hellwig' <hch@infradead.org>
Subject: Re: [PATCH]  incorrect error handling inside generic_file_direct_write
Message-ID: <20061215104341.GA20089@infradead.org>
References: <20061212024027.6c2a79d3.akpm@osdl.org> <000001c71e60$7df9e010$e434030a@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001c71e60$7df9e010$e434030a@amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, Dmitriy Monakhov <dmonakhov@sw.ru>, 'Christoph Hellwig' <hch@infradead.org>, Dmitriy Monakhov <dmonakhov@openvz.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, devel@openvz.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

> +ssize_t
> +__generic_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
> +				unsigned long nr_segs, loff_t pos)

I'd still call this generic_file_aio_write_nolock.

> +	loff_t		*ppos = &iocb->ki_pos;

I'd rather use iocb->ki_pos directly in the few places ppos is referenced
currently.

>  	if (ret > 0 && ((file->f_flags & O_SYNC) || IS_SYNC(inode))) {
> -		ssize_t err;
> -
>  		err = sync_page_range_nolock(inode, mapping, pos, ret);
>  		if (err < 0)
>  			ret = err;
>  	}

So we're doing the sync_page_range once in __generic_file_aio_write
with i_mutex held.


>  	mutex_lock(&inode->i_mutex);
> -	ret = __generic_file_aio_write_nolock(iocb, iov, nr_segs,
> -			&iocb->ki_pos);
> +	ret = __generic_file_aio_write(iocb, iov, nr_segs, pos);
>  	mutex_unlock(&inode->i_mutex);
>  
>  	if (ret > 0 && ((file->f_flags & O_SYNC) || IS_SYNC(inode))) {

And then another time after it's unlocked, this seems wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
