Date: Sat, 29 Sep 2007 15:10:43 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] splice mmap_sem deadlock
Message-ID: <20070929131043.GC14159@wotan.suse.de>
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk> <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org> <20070928181513.GB11717@kernel.dk> <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org> <20070928193017.GC11717@kernel.dk> <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 28, 2007 at 01:02:50PM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 28 Sep 2007, Jens Axboe wrote:
> > 
> > Hmm, part of me doesn't like this patch, since we now end up beating on
> > mmap_sem for each part of the vec. It's fine for a stable patch, but how
> > about
> > 
> > - prefaulting the iovec
> > - using __get_user()
> > - only dropping/regrabbing the lock if we have to fault
> 
> "__get_user()" doesn't help any. But we should do the same thing we do for 
> generic_file_write(), or whatever - probe it while in an atomic region.
> 
> So something like the appended might work. Untested.

I got an idea for getting rid of mmap_sem from here completely. Which
is why I was looking at these callers in the first place.

It would be really convenient and help me play with the idea if mmap_sem
is wrapped closely around get_user_pages where possible...

If you're really worried about mmap_sem batching here, can you just
avoid this complexity and do all the get_user()s up-front, before taking
mmap_sem at all? You only have to save PIPE_BUFFERS number of
them.

> 
> 		Linus
> ---
>  fs/splice.c |   32 +++++++++++++++++++++-----------
>  1 files changed, 21 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/splice.c b/fs/splice.c
> index c010a72..07e880e 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -1236,31 +1236,41 @@ static int get_iovec_page_array(const struct iovec __user *iov,
>  {
>  	int buffers = 0, error = 0;
>  
> -	/*
> -	 * It's ok to take the mmap_sem for reading, even
> -	 * across a "get_user()".
> -	 */
>  	down_read(&current->mm->mmap_sem);
>  
>  	while (nr_vecs) {
>  		unsigned long off, npages;
> +		struct iovec entry;
>  		void __user *base;
>  		size_t len;
>  		int i;
>  
>  		/*
> -		 * Get user address base and length for this iovec.
> +		 * We do not want to recursively take the mmap_sem semaphore
> +		 * on a page fault, since that could deadlock with a writer
> +		 * that comes in in the middle. So disable pagefaults, and
> +		 * do it the slow way if the copy fails..
>  		 */
> -		error = get_user(base, &iov->iov_base);
> -		if (unlikely(error))
> -			break;
> -		error = get_user(len, &iov->iov_len);
> -		if (unlikely(error))
> -			break;
> +		pagefault_disable();
> +		i = __copy_from_user_inatomic(&entry, iov, sizeof(entry));
> +		pagefault_enable();
> +
> +		if (unlikely(i)) {
> +			up_read(&current->mm->mmap_sem);
> +			i = copy_from_user(&entry, iov, sizeof(entry));
> +			down_read(&current->mm->mmap_sem);
> +			error = -EFAULT;
> +			if (i)
> +				break;
> +		}
> +
> +		len = entry.iov_len;
> +		base = entry.iov_base;
>  
>  		/*
>  		 * Sanity check this iovec. 0 read succeeds.
>  		 */
> +		error = 0;
>  		if (unlikely(!len))
>  			break;
>  		error = -EFAULT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
