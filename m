Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 42DE26B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:23:30 -0400 (EDT)
Message-ID: <51C107E9.9050900@huawei.com>
Date: Wed, 19 Jun 2013 09:22:49 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mmap: allow MAP_HUGETLB for hugetlbfs files
References: <1371581225-27535-1-git-send-email-joern@logfs.org> <1371581225-27535-3-git-send-email-joern@logfs.org>
In-Reply-To: <1371581225-27535-3-git-send-email-joern@logfs.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joern Engel <joern@logfs.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hi Joerni 1/4 ?

On 2013/6/19 2:47, Joern Engel wrote:

> It is counterintuitive at best that mmap'ing a hugetlbfs file with
> MAP_HUGETLB fails, while mmap'ing it without will a) succeed and b)
> return huge pages.
> 
> Signed-off-by: Joern Engel <joern@logfs.org>
> ---
>  mm/mmap.c |   12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 2a594246..76eb6df 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -33,6 +33,7 @@
>  #include <linux/uprobes.h>
>  #include <linux/rbtree_augmented.h>
>  #include <linux/sched/sysctl.h>
> +#include <linux/magic.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/cacheflush.h>
> @@ -1313,6 +1314,11 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  	return addr;
>  }
>  
> +static inline int is_hugetlb_file(struct file *file)
> +{
> +	return file->f_inode->i_sb->s_magic == HUGETLBFS_MAGIC;
> +}
> +
>  SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  		unsigned long, prot, unsigned long, flags,
>  		unsigned long, fd, unsigned long, pgoff)
> @@ -1322,11 +1328,12 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  
>  	if (!(flags & MAP_ANONYMOUS)) {
>  		audit_mmap_fd(fd, flags);
> -		if (unlikely(flags & MAP_HUGETLB))
> -			return -EINVAL;
>  		file = fget(fd);
>  		if (!file)
>  			goto out;
> +		retval = -EINVAL;
> +		if (unlikely(flags & MAP_HUGETLB && !is_hugetlb_file(file)))

We already have is_file_hugepages().

Thanks,
Jianguo Wu

> +			goto out_fput;
>  	} else if (flags & MAP_HUGETLB) {
>  		struct user_struct *user = NULL;
>  		/*
> @@ -1346,6 +1353,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
>  
>  	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff);
> +out_fput:
>  	if (file)
>  		fput(file);
>  out:



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
