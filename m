Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD346B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:50:32 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a12so2897006qka.7
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:50:32 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n50si1606952qtc.481.2017.11.01.15.50.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 15:50:31 -0700 (PDT)
Subject: Re: [PATCH 1/6] shmem: unexport shmem_add_seals()/shmem_get_seals()
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
 <20171031184052.25253-2-marcandre.lureau@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <bc39fa5e-e11f-6960-a338-528e689a7acb@oracle.com>
Date: Wed, 1 Nov 2017 15:50:23 -0700
MIME-Version: 1.0
In-Reply-To: <20171031184052.25253-2-marcandre.lureau@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

On 10/31/2017 11:40 AM, Marc-AndrA(C) Lureau wrote:
> The functions are called through shmem_fcntl() only.

And no danger in removing the EXPORTs as the routines only work
with shmem file structs.

> 
> Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> ---
>  include/linux/shmem_fs.h | 2 --
>  mm/shmem.c               | 6 ++----
>  2 files changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index b6c3540e07bc..557d0c3b6eca 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -109,8 +109,6 @@ extern void shmem_uncharge(struct inode *inode, long pages);
>  
>  #ifdef CONFIG_TMPFS
>  
> -extern int shmem_add_seals(struct file *file, unsigned int seals);
> -extern int shmem_get_seals(struct file *file);
>  extern long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
>  
>  #else
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 07a1d22807be..37260c5e12fa 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2722,7 +2722,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>  		     F_SEAL_GROW | \
>  		     F_SEAL_WRITE)
>  
> -int shmem_add_seals(struct file *file, unsigned int seals)
> +static int shmem_add_seals(struct file *file, unsigned int seals)
>  {
>  	struct inode *inode = file_inode(file);
>  	struct shmem_inode_info *info = SHMEM_I(inode);
> @@ -2791,16 +2791,14 @@ int shmem_add_seals(struct file *file, unsigned int seals)
>  	inode_unlock(inode);
>  	return error;
>  }
> -EXPORT_SYMBOL_GPL(shmem_add_seals);
>  
> -int shmem_get_seals(struct file *file)
> +static int shmem_get_seals(struct file *file)
>  {
>  	if (file->f_op != &shmem_file_operations)
>  		return -EINVAL;
>  
>  	return SHMEM_I(file_inode(file))->seals;
>  }
> -EXPORT_SYMBOL_GPL(shmem_get_seals);
>  
>  long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
>  {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
