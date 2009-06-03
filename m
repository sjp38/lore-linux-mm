Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B04EB6B004D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 19:39:28 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n53NRWDP018594
	for <linux-mm@kvack.org>; Wed, 3 Jun 2009 19:27:32 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n53NdMVD243238
	for <linux-mm@kvack.org>; Wed, 3 Jun 2009 19:39:22 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n53NdLB6007710
	for <linux-mm@kvack.org>; Wed, 3 Jun 2009 19:39:22 -0400
Subject: Re: [PATCH 07/23] vfs: Teach sendfile,splice,tee,and vmsplice to
	use file_hotplug_lock
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <1243893048-17031-7-git-send-email-ebiederm@xmission.com>
References: <m1oct739xu.fsf@fess.ebiederm.org>
	 <1243893048-17031-7-git-send-email-ebiederm@xmission.com>
Content-Type: text/plain
Date: Wed, 03 Jun 2009 16:39:23 -0700
Message-Id: <1244072363.6383.15.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.arastra.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-06-01 at 14:50 -0700, Eric W. Biederman wrote:
> From: Eric W. Biederman <ebiederm@maxwell.arastra.com>
> 
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
> ---
>  fs/read_write.c |   28 +++++++++----
>  fs/splice.c     |  111 +++++++++++++++++++++++++++++++++++++-----------------
>  2 files changed, 95 insertions(+), 44 deletions(-)
> 
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 718baea..c473d74 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -861,21 +861,24 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
>  		goto out;
>  	if (!(in_file->f_mode & FMODE_READ))
>  		goto fput_in;
> +	retval = -EIO;
> +	if (!file_hotplug_read_trylock(in_file))
> +		goto fput_in;
>  	retval = -EINVAL;
>  	in_inode = in_file->f_path.dentry->d_inode;
>  	if (!in_inode)
> -		goto fput_in;
> +		goto unlock_in;
>  	if (!in_file->f_op || !in_file->f_op->splice_read)
> -		goto fput_in;
> +		goto unlock_in;
>  	retval = -ESPIPE;
>  	if (!ppos)
>  		ppos = &in_file->f_pos;
>  	else
>  		if (!(in_file->f_mode & FMODE_PREAD))
> -			goto fput_in;
> +			goto unlock_in;
>  	retval = rw_verify_area(READ, in_file, ppos, count);
>  	if (retval < 0)
> -		goto fput_in;
> +		goto unlock_in;
>  	count = retval;
>  
>  	/*
> @@ -884,16 +887,19 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
>  	retval = -EBADF;
>  	out_file = fget_light(out_fd, &fput_needed_out);
>  	if (!out_file)
> -		goto fput_in;
> +		goto unlock_in;
>  	if (!(out_file->f_mode & FMODE_WRITE))
>  		goto fput_out;
> +	retval = -EIO;
> +	if (!file_hotplug_read_trylock(out_file))
> +		goto fput_out;
>  	retval = -EINVAL;
>  	if (!out_file->f_op || !out_file->f_op->sendpage)
> -		goto fput_out;
> +		goto unlock_out;
>  	out_inode = out_file->f_path.dentry->d_inode;
>  	retval = rw_verify_area(WRITE, out_file, &out_file->f_pos, count);
>  	if (retval < 0)
> -		goto fput_out;
> +		goto unlock_out;
>  	count = retval;
>  
>  	if (!max)
> @@ -902,11 +908,11 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
>  	pos = *ppos;
>  	retval = -EINVAL;
>  	if (unlikely(pos < 0))
> -		goto fput_out;
> +		goto unlock_out;
>  	if (unlikely(pos + count > max)) {
>  		retval = -EOVERFLOW;
>  		if (pos >= max)
> -			goto fput_out;
> +			goto unlock_out;
>  		count = max - pos;
>  	}
>  
> @@ -933,8 +939,12 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
>  	if (*ppos > max)
>  		retval = -EOVERFLOW;
>  
> +unlock_out:
> +	file_hotplug_read_unlock(out_file);
>  fput_out:
>  	fput_light(out_file, fput_needed_out);
> +unlock_in:
> +	file_hotplug_read_unlock(in_file);
>  fput_in:
>  	fput_light(in_file, fput_needed_in);
>  out:
> diff --git a/fs/splice.c b/fs/splice.c
> index 666953d..fc6b3a5 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -1464,15 +1464,21 @@ SYSCALL_DEFINE4(vmsplice, int, fd, const struct iovec __user *, iov,
>  
>  	error = -EBADF;
>  	file = fget_light(fd, &fput);
> -	if (file) {
> -		if (file->f_mode & FMODE_WRITE)
> -			error = vmsplice_to_pipe(file, iov, nr_segs, flags);
> -		else if (file->f_mode & FMODE_READ)
> -			error = vmsplice_to_user(file, iov, nr_segs, flags);
> +	if (!file)
> +		goto out;
>  
> -		fput_light(file, fput);
> -	}
> +	if (!file_hotplug_read_trylock(file))
> +		goto fput_file;
>  
> +	if (file->f_mode & FMODE_WRITE)
> +		error = vmsplice_to_pipe(file, iov, nr_segs, flags);
> +	else if (file->f_mode & FMODE_READ)
> +		error = vmsplice_to_user(file, iov, nr_segs, flags);
> +
> +	file_hotplug_read_unlock(file);
> +fput_file:
> +	fput_light(file, fput);
> +out:
>  	return error;
>  }
>  
> @@ -1489,21 +1495,39 @@ SYSCALL_DEFINE6(splice, int, fd_in, loff_t __user *, off_in,
>  
>  	error = -EBADF;
>  	in = fget_light(fd_in, &fput_in);
> -	if (in) {
> -		if (in->f_mode & FMODE_READ) {
> -			out = fget_light(fd_out, &fput_out);
> -			if (out) {
> -				if (out->f_mode & FMODE_WRITE)
> -					error = do_splice(in, off_in,
> -							  out, off_out,
> -							  len, flags);
> -				fput_light(out, fput_out);
> -			}
> -		}
> +	if (!in)
> +		goto out;
>  
> -		fput_light(in, fput_in);
> -	}
> +	if (!(in->f_mode & FMODE_READ))
> +		goto fput_in;
> +
> +	error = -EIO;
> +	if (!file_hotplug_read_trylock(in))
> +		goto fput_in;
> +
> +	error = -EBADF;
> +	out = fget_light(fd_out, &fput_out);
> +	if (!out)
> +		goto unlock_in;
> +
> +	if (!(out->f_mode & FMODE_WRITE))
> +		goto fput_out;
> +
> +	error = -EIO;
> +	if (!file_hotplug_read_trylock(out))
> +		goto fput_out;
> +
> +	error = do_splice(in, off_in, out, off_out, len, flags);
>  
> +	file_hotplug_read_unlock(out);
> +fput_out:
> +	fput_light(out, fput_out);
> +unlock_in:
> +	file_hotplug_read_unlock(in);
> +fput_in:
> +	fput_light(in, fput_in);
> +
> +out:
>  	return error;
>  }
>  
> @@ -1703,27 +1727,44 @@ static long do_tee(struct file *in, struct file *out, size_t len,
>  
>  SYSCALL_DEFINE4(tee, int, fdin, int, fdout, size_t, len, unsigned int, flags)
>  {
> -	struct file *in;
> -	int error, fput_in;
> +	struct file *in, *out;
> +	int error, fput_in, fput_out;
>  
>  	if (unlikely(!len))
>  		return 0;
>  
>  	error = -EBADF;
>  	in = fget_light(fdin, &fput_in);
> -	if (in) {
> -		if (in->f_mode & FMODE_READ) {
> -			int fput_out;
> -			struct file *out = fget_light(fdout, &fput_out);
> -
> -			if (out) {
> -				if (out->f_mode & FMODE_WRITE)
> -					error = do_tee(in, out, len, flags);
> -				fput_light(out, fput_out);
> -			}
> -		}
> - 		fput_light(in, fput_in);
> - 	}
> +	if (!in)
> +		goto out;
> +
> +	if (!(in->f_mode & FMODE_READ))
> +		goto unlock_in;   <<<<<<<

Shouldn't this be
		goto fput_in; 

? btw, its confusing to have labels and variables with same name:
fput_in and fput_out. You may want to rename labels ?

>  
> +	error = -EIO;
> +	if (!file_hotplug_read_trylock(in))
> +		goto fput_in;
> +
> +	error = -EBADF;
> +	out = fget_light(fdout, &fput_out);
> +	if (!out)
> +		goto unlock_in;
> +
> +	if (!(out->f_mode & FMODE_WRITE))
> +		goto fput_out;
> +
> +	if (!file_hotplug_read_trylock(out))
> +		goto fput_out;
> +
> +	error = do_tee(in, out, len, flags);
> +
> +	file_hotplug_read_unlock(out);
> +fput_out:
> +	fput_light(out, fput_out);
> +unlock_in:
> +	file_hotplug_read_unlock(in);
> +fput_in:
> +	fput_light(in, fput_in);
> +out:
>  	return error;
>  }

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
