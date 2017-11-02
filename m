Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B84E66B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 20:18:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z80so3531083pff.11
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 17:18:47 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x85si2112983pff.344.2017.11.01.17.18.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 17:18:46 -0700 (PDT)
Subject: Re: [PATCH 5/6] shmem: add sealing support to hugetlb-backed memfd
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
 <20171031184052.25253-6-marcandre.lureau@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e9b1cda0-4216-3d04-233b-d229069bf529@oracle.com>
Date: Wed, 1 Nov 2017 17:18:37 -0700
MIME-Version: 1.0
In-Reply-To: <20171031184052.25253-6-marcandre.lureau@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

On 10/31/2017 11:40 AM, Marc-AndrA(C) Lureau wrote:
> Adapt add_seals()/get_seals() to work with hugetbfs-backed memory.
> 
> Teach memfd_create() to allow sealing operations on MFD_HUGETLB.
> 
> Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
> ---
>  mm/shmem.c | 51 ++++++++++++++++++++++++++++++---------------------
>  1 file changed, 30 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index b7811979611f..b7c59d993c19 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2717,6 +2717,19 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>  	return error;
>  }
>  
> +static unsigned int *memfd_get_seals(struct file *file)

I would have named this something like 'memfd_file_seal_ptr', and not
changed the name of memfd_get_seals below.  Just my preference, and it
does not carry as much weight as Hugh who originally write this code.

> +{
> +	if (file->f_op == &shmem_file_operations)
> +		return &SHMEM_I(file_inode(file))->seals;
> +
> +#ifdef CONFIG_HUGETLBFS
> +	if (file->f_op == &hugetlbfs_file_operations)
> +		return &HUGETLBFS_I(file_inode(file))->seals;
> +#endif
> +
> +	return NULL;
> +}
> +

As mentioned in patch 2, I think this code will need to be restructured
so that hugetlbfs file sealing will work even is CONFIG_TMPFS is not
defined.  The above routine is behind #ifdef CONFIG_TMPFS.

In general the code looks fine, but this config issue needs to be addressed.
-- 
Mike Kravetz

>  #define F_ALL_SEALS (F_SEAL_SEAL | \
>  		     F_SEAL_SHRINK | \
>  		     F_SEAL_GROW | \
> @@ -2725,7 +2738,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>  static int memfd_add_seals(struct file *file, unsigned int seals)
>  {
>  	struct inode *inode = file_inode(file);
> -	struct shmem_inode_info *info = SHMEM_I(inode);
> +	unsigned int *file_seals;
>  	int error;
>  
>  	/*
> @@ -2758,8 +2771,6 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
>  	 * other file types.
>  	 */
>  
> -	if (file->f_op != &shmem_file_operations)
> -		return -EINVAL;
>  	if (!(file->f_mode & FMODE_WRITE))
>  		return -EPERM;
>  	if (seals & ~(unsigned int)F_ALL_SEALS)
> @@ -2767,12 +2778,18 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
>  
>  	inode_lock(inode);
>  
> -	if (info->seals & F_SEAL_SEAL) {
> +	file_seals = memfd_get_seals(file);
> +	if (!file_seals) {
> +		error = -EINVAL;
> +		goto unlock;
> +	}
> +
> +	if (*file_seals & F_SEAL_SEAL) {
>  		error = -EPERM;
>  		goto unlock;
>  	}
>  
> -	if ((seals & F_SEAL_WRITE) && !(info->seals & F_SEAL_WRITE)) {
> +	if ((seals & F_SEAL_WRITE) && !(*file_seals & F_SEAL_WRITE)) {
>  		error = mapping_deny_writable(file->f_mapping);
>  		if (error)
>  			goto unlock;
> @@ -2784,7 +2801,7 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
>  		}
>  	}
>  
> -	info->seals |= seals;
> +	*file_seals |= seals;
>  	error = 0;
>  
>  unlock:
> @@ -2792,12 +2809,11 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
>  	return error;
>  }
>  
> -static int memfd_get_seals(struct file *file)
> +static int memfd_fcntl_get_seals(struct file *file)
>  {
> -	if (file->f_op != &shmem_file_operations)
> -		return -EINVAL;
> +	unsigned int *seals = memfd_get_seals(file);
>  
> -	return SHMEM_I(file_inode(file))->seals;
> +	return seals ? *seals : -EINVAL;
>  }
>  
>  long memfd_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
> @@ -2813,7 +2829,7 @@ long memfd_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
>  		error = memfd_add_seals(file, arg);
>  		break;
>  	case F_GET_SEALS:
> -		error = memfd_get_seals(file);
> +		error = memfd_fcntl_get_seals(file);
>  		break;
>  	default:
>  		error = -EINVAL;
> @@ -3657,7 +3673,7 @@ SYSCALL_DEFINE2(memfd_create,
>  		const char __user *, uname,
>  		unsigned int, flags)
>  {
> -	struct shmem_inode_info *info;
> +	unsigned int *file_seals;
>  	struct file *file;
>  	int fd, error;
>  	char *name;
> @@ -3667,9 +3683,6 @@ SYSCALL_DEFINE2(memfd_create,
>  		if (flags & ~(unsigned int)MFD_ALL_FLAGS)
>  			return -EINVAL;
>  	} else {
> -		/* Sealing not supported in hugetlbfs (MFD_HUGETLB) */
> -		if (flags & MFD_ALLOW_SEALING)
> -			return -EINVAL;
>  		/* Allow huge page size encoding in flags. */
>  		if (flags & ~(unsigned int)(MFD_ALL_FLAGS |
>  				(MFD_HUGE_MASK << MFD_HUGE_SHIFT)))
> @@ -3722,12 +3735,8 @@ SYSCALL_DEFINE2(memfd_create,
>  	file->f_flags |= O_RDWR | O_LARGEFILE;
>  
>  	if (flags & MFD_ALLOW_SEALING) {
> -		/*
> -		 * flags check at beginning of function ensures
> -		 * this is not a hugetlbfs (MFD_HUGETLB) file.
> -		 */
> -		info = SHMEM_I(file_inode(file));
> -		info->seals &= ~F_SEAL_SEAL;
> +		file_seals = memfd_get_seals(file);
> +		*file_seals &= ~F_SEAL_SEAL;
>  	}
>  
>  	fd_install(fd, file);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
