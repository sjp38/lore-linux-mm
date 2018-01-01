Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD016B0286
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 10:52:44 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id j141so15142280qke.4
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 07:52:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z50si3419122qtb.99.2018.01.01.07.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jan 2018 07:52:43 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id w01FnvF5124297
	for <linux-mm@kvack.org>; Mon, 1 Jan 2018 10:52:41 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f7g3rbcmv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 Jan 2018 10:52:41 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 1 Jan 2018 15:52:39 -0000
Date: Mon, 1 Jan 2018 17:52:34 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] userfaultfd: convert to use anon_inode_getfd()
References: <20171229212403.22800-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171229212403.22800-1-ebiggers3@gmail.com>
Message-Id: <20180101155233.GA17038@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Biggers <ebiggers@google.com>

On Fri, Dec 29, 2017 at 03:24:03PM -0600, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Nothing actually calls userfaultfd_file_create() besides the
> userfaultfd() system call itself.  So simplify things by folding it into
> the system call and using anon_inode_getfd() instead of
> anon_inode_getfile().  Do the same in resolve_userfault_fork() as well.
> This removes over 50 lines with no change in functionality.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

> ---
>  fs/userfaultfd.c | 70 ++++++++------------------------------------------------
>  1 file changed, 9 insertions(+), 61 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 41a75f9f23fd..b87cc2c5cfb1 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -985,24 +985,14 @@ static int resolve_userfault_fork(struct userfaultfd_ctx *ctx,
>  				  struct uffd_msg *msg)
>  {
>  	int fd;
> -	struct file *file;
> -	unsigned int flags = new->flags & UFFD_SHARED_FCNTL_FLAGS;
> 
> -	fd = get_unused_fd_flags(flags);
> +	fd = anon_inode_getfd("[userfaultfd]", &userfaultfd_fops, new,
> +			      O_RDWR | (new->flags & UFFD_SHARED_FCNTL_FLAGS));
>  	if (fd < 0)
>  		return fd;
> 
> -	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, new,
> -				  O_RDWR | flags);
> -	if (IS_ERR(file)) {
> -		put_unused_fd(fd);
> -		return PTR_ERR(file);
> -	}
> -
> -	fd_install(fd, file);
>  	msg->arg.reserved.reserved1 = 0;
>  	msg->arg.fork.ufd = fd;
> -
>  	return 0;
>  }
> 
> @@ -1884,24 +1874,10 @@ static void init_once_userfaultfd_ctx(void *mem)
>  	seqcount_init(&ctx->refile_seq);
>  }
> 
> -/**
> - * userfaultfd_file_create - Creates a userfaultfd file pointer.
> - * @flags: Flags for the userfaultfd file.
> - *
> - * This function creates a userfaultfd file pointer, w/out installing
> - * it into the fd table. This is useful when the userfaultfd file is
> - * used during the initialization of data structures that require
> - * extra setup after the userfaultfd creation. So the userfaultfd
> - * creation is split into the file pointer creation phase, and the
> - * file descriptor installation phase.  In this way races with
> - * userspace closing the newly installed file descriptor can be
> - * avoided.  Returns a userfaultfd file pointer, or a proper error
> - * pointer.
> - */
> -static struct file *userfaultfd_file_create(int flags)
> +SYSCALL_DEFINE1(userfaultfd, int, flags)
>  {
> -	struct file *file;
>  	struct userfaultfd_ctx *ctx;
> +	int fd;
> 
>  	BUG_ON(!current->mm);
> 
> @@ -1909,14 +1885,12 @@ static struct file *userfaultfd_file_create(int flags)
>  	BUILD_BUG_ON(UFFD_CLOEXEC != O_CLOEXEC);
>  	BUILD_BUG_ON(UFFD_NONBLOCK != O_NONBLOCK);
> 
> -	file = ERR_PTR(-EINVAL);
>  	if (flags & ~UFFD_SHARED_FCNTL_FLAGS)
> -		goto out;
> +		return -EINVAL;
> 
> -	file = ERR_PTR(-ENOMEM);
>  	ctx = kmem_cache_alloc(userfaultfd_ctx_cachep, GFP_KERNEL);
>  	if (!ctx)
> -		goto out;
> +		return -ENOMEM;
> 
>  	atomic_set(&ctx->refcount, 1);
>  	ctx->flags = flags;
> @@ -1927,39 +1901,13 @@ static struct file *userfaultfd_file_create(int flags)
>  	/* prevent the mm struct to be freed */
>  	mmgrab(ctx->mm);
> 
> -	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, ctx,
> -				  O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
> -	if (IS_ERR(file)) {
> +	fd = anon_inode_getfd("[userfaultfd]", &userfaultfd_fops, ctx,
> +			      O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
> +	if (fd < 0) {
>  		mmdrop(ctx->mm);
>  		kmem_cache_free(userfaultfd_ctx_cachep, ctx);
>  	}
> -out:
> -	return file;
> -}
> -
> -SYSCALL_DEFINE1(userfaultfd, int, flags)
> -{
> -	int fd, error;
> -	struct file *file;
> -
> -	error = get_unused_fd_flags(flags & UFFD_SHARED_FCNTL_FLAGS);
> -	if (error < 0)
> -		return error;
> -	fd = error;
> -
> -	file = userfaultfd_file_create(flags);
> -	if (IS_ERR(file)) {
> -		error = PTR_ERR(file);
> -		goto err_put_unused_fd;
> -	}
> -	fd_install(fd, file);
> -
>  	return fd;
> -
> -err_put_unused_fd:
> -	put_unused_fd(fd);
> -
> -	return error;
>  }
> 
>  static int __init userfaultfd_init(void)
> -- 
> 2.15.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
