Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F00956B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 19:01:36 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x82so2917712qkb.11
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 16:01:36 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z48si1652399qtj.203.2017.11.01.16.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 16:01:36 -0700 (PDT)
Subject: Re: [PATCH 2/6] shmem: rename functions that are memfd-related
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
 <20171031184052.25253-3-marcandre.lureau@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c884ed14-cb4e-fa04-e5be-5a732e64f988@oracle.com>
Date: Wed, 1 Nov 2017 16:01:30 -0700
MIME-Version: 1.0
In-Reply-To: <20171031184052.25253-3-marcandre.lureau@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

On 10/31/2017 11:40 AM, Marc-AndrA(C) Lureau wrote:
> Those functions are called for memfd files, backed by shmem or
> hugetlb (the next patches will handle hugetlb).
> 
> Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
> ---
>  fs/fcntl.c               |  2 +-
>  include/linux/shmem_fs.h |  4 ++--
>  mm/shmem.c               | 10 +++++-----
>  3 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/fcntl.c b/fs/fcntl.c
> index 448a1119f0be..752c23743616 100644
> --- a/fs/fcntl.c
> +++ b/fs/fcntl.c
> @@ -417,7 +417,7 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
>  		break;
>  	case F_ADD_SEALS:
>  	case F_GET_SEALS:
> -		err = shmem_fcntl(filp, cmd, arg);
> +		err = memfd_fcntl(filp, cmd, arg);
>  		break;
>  	case F_GET_RW_HINT:
>  	case F_SET_RW_HINT:
> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index 557d0c3b6eca..0dac8c0f4aa4 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -109,11 +109,11 @@ extern void shmem_uncharge(struct inode *inode, long pages);
>  
>  #ifdef CONFIG_TMPFS
>  
> -extern long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
> +extern long memfd_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
>  
>  #else
>  
> -static inline long shmem_fcntl(struct file *f, unsigned int c, unsigned long a)
> +static inline long memfd_fcntl(struct file *f, unsigned int c, unsigned long a)
>  {
>  	return -EINVAL;
>  }

Do we want memfd_fcntl() to work for hugetlbfs if CONFIG_TMPFS is not
defined?  I admit that having CONFIG_HUGETLBFS defined without CONFIG_TMPFS
is unlikely, but I think possible.  Based on the above #ifdef/#else, I
think hugetlbfs seals will not work if CONFIG_TMPFS is not defined.

-- 
Mike Kravetz

> diff --git a/mm/shmem.c b/mm/shmem.c
> index 37260c5e12fa..b7811979611f 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2722,7 +2722,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>  		     F_SEAL_GROW | \
>  		     F_SEAL_WRITE)
>  
> -static int shmem_add_seals(struct file *file, unsigned int seals)
> +static int memfd_add_seals(struct file *file, unsigned int seals)
>  {
>  	struct inode *inode = file_inode(file);
>  	struct shmem_inode_info *info = SHMEM_I(inode);
> @@ -2792,7 +2792,7 @@ static int shmem_add_seals(struct file *file, unsigned int seals)
>  	return error;
>  }
>  
> -static int shmem_get_seals(struct file *file)
> +static int memfd_get_seals(struct file *file)
>  {
>  	if (file->f_op != &shmem_file_operations)
>  		return -EINVAL;
> @@ -2800,7 +2800,7 @@ static int shmem_get_seals(struct file *file)
>  	return SHMEM_I(file_inode(file))->seals;
>  }
>  
> -long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
> +long memfd_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
>  {
>  	long error;
>  
> @@ -2810,10 +2810,10 @@ long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
>  		if (arg > UINT_MAX)
>  			return -EINVAL;
>  
> -		error = shmem_add_seals(file, arg);
> +		error = memfd_add_seals(file, arg);
>  		break;
>  	case F_GET_SEALS:
> -		error = shmem_get_seals(file);
> +		error = memfd_get_seals(file);
>  		break;
>  	default:
>  		error = -EINVAL;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
