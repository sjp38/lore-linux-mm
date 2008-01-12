Subject: Re: [PATCH 2/2][RFC][BUG] msync: updating ctime and mtime at
	syncing
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1200012249.20379.2.camel@codedot>
References: <1200006638.19293.42.camel@codedot>
	 <1200012249.20379.2.camel@codedot>
Content-Type: text/plain
Date: Sat, 12 Jan 2008 10:36:05 +0100
Message-Id: <1200130565.7999.8.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, Valdis.Kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 2008-01-11 at 03:44 +0300, Anton Salikhmetov wrote:

> +/*
> + * Update the ctime and mtime stamps after checking if they are to be updated.
> + */
> +void mapped_file_update_time(struct file *file)
> +{
> +	if (test_and_clear_bit(AS_MCTIME, &file->f_mapping->flags)) {
> +		get_file(file);
> +		file_update_time(file);
> +		fput(file);
> +	}
> +}
> +

I don't think you need the get/put file stuff here, because

> @@ -87,6 +87,8 @@ long do_fsync(struct file *file, int datasync)
>  		goto out;
>  	}
>  
> +	mapped_file_update_time(file);
> +
>  	ret = filemap_fdatawrite(mapping);
>  
>  	/*

at this call-site we already hold an extra reference on the file, and

> @@ -74,14 +79,17 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
>  			break;
>  		}
>  		file = vma->vm_file;
> -		if ((flags & MS_SYNC) && file && (vma->vm_flags & VM_SHARED)) {
> -			get_file(file);
> -			up_read(&mm->mmap_sem);
> -			error = do_fsync(file, 0);
> -			fput(file);
> -			if (error)
> -				return error;
> -			down_read(&mm->mmap_sem);
> +		if (file && (vma->vm_flags & VM_SHARED)) {
> +			mapped_file_update_time(file);
> +			if (flags & MS_SYNC) {
> +				get_file(file);
> +				up_read(&mm->mmap_sem);
> +				error = do_fsync(file, 0);
> +				fput(file);
> +				if (error)
> +					return error;
> +				down_read(&mm->mmap_sem);
> +			}
>  		}
>  
>  		start = vma->vm_end;

here we hold the mmap_sem so the vma reference on the file can't go
away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
