Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 286336B004D
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 17:49:15 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id n7DLnFVu023195
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 22:49:16 +0100
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by wpaz1.hot.corp.google.com with ESMTP id n7DLnCMw007370
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 14:49:13 -0700
Received: by pzk30 with SMTP id 30so772017pzk.5
        for <linux-mm@kvack.org>; Thu, 13 Aug 2009 14:49:12 -0700 (PDT)
Date: Thu, 13 Aug 2009 14:49:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] Add MAP_HUGETLB for mmaping pseudo-anonymous huge
 page regions V2
In-Reply-To: <83949d066e2a7221a25dd74d12d6dcf7e8b4e9ba.1250156841.git.ebmunson@us.ibm.com>
Message-ID: <alpine.DEB.2.00.0908131443350.9805@chino.kir.corp.google.com>
References: <cover.1250156841.git.ebmunson@us.ibm.com> <e9b02974a0cca308927ff3a4a0765b93faa6d12f.1250156841.git.ebmunson@us.ibm.com> <83949d066e2a7221a25dd74d12d6dcf7e8b4e9ba.1250156841.git.ebmunson@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, mtk.manpages@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Aug 2009, Eric B Munson wrote:

> This patch adds a flag for mmap that will be used to request a huge
> page region that will look like anonymous memory to user space.  This
> is accomplished by using a file on the internal vfsmount.  MAP_HUGETLB
> is a modifier of MAP_ANONYMOUS and so must be specified with it.  The
> region will behave the same as a MAP_ANONYMOUS region using small pages.
> 
> Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
> ---
> Changes from V1
>  Rebase to newest linux-2.6 tree
>  Rename MAP_LARGEPAGE to MAP_HUGETLB to match flag name for huge page shm
> 
>  include/asm-generic/mman-common.h |    1 +
>  include/linux/hugetlb.h           |    7 +++++++
>  mm/mmap.c                         |   16 ++++++++++++++++
>  3 files changed, 24 insertions(+), 0 deletions(-)
> 
> diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
> index 3b69ad3..12f5982 100644
> --- a/include/asm-generic/mman-common.h
> +++ b/include/asm-generic/mman-common.h
> @@ -19,6 +19,7 @@
>  #define MAP_TYPE	0x0f		/* Mask for type of mapping */
>  #define MAP_FIXED	0x10		/* Interpret addr exactly */
>  #define MAP_ANONYMOUS	0x20		/* don't use a file */
> +#define MAP_HUGETLB	0x40		/* create a huge page mapping */
>  
>  #define MS_ASYNC	1		/* sync memory asynchronously */
>  #define MS_INVALIDATE	2		/* invalidate the caches */
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 78b6ddf..b84361c 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -109,12 +109,19 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
>  
>  #endif /* !CONFIG_HUGETLB_PAGE */
>  
> +#define HUGETLB_ANON_FILE "anon_hugepage"
> +
>  enum {
>  	/*
>  	 * The file will be used as an shm file so shmfs accounting rules
>  	 * apply
>  	 */
>  	HUGETLB_SHMFS_INODE     = 0x01,
> +	/*
> +	 * The file is being created on the internal vfs mount and shmfs
> +	 * accounting rules do not apply
> +	 */
> +	HUGETLB_ANONHUGE_INODE  = 0x02,
>  };
>  
>  #ifdef CONFIG_HUGETLBFS

While I think it's appropriate to use an enum here, these two "flags" 
can't be used together so it would probably be better to avoid the 
hexadecimal.

If flags were ever needed in the future, you could reserve the upper eight 
bits of the int for such purposes similiar to mempolicy flags.

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 34579b2..3612b20 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -29,6 +29,7 @@
>  #include <linux/rmap.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/perf_counter.h>
> +#include <linux/hugetlb.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/cacheflush.h>
> @@ -954,6 +955,21 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  	if (mm->map_count > sysctl_max_map_count)
>  		return -ENOMEM;
>  
> +	if (flags & MAP_HUGETLB) {
> +		if (file)
> +			return -EINVAL;
> +
> +		/*
> +		 * VM_NORESERVE is used because the reservations will be
> +		 * taken when vm_ops->mmap() is called
> +		 */
> +		len = ALIGN(len, huge_page_size(&default_hstate));
> +		file = hugetlb_file_setup(HUGETLB_ANON_FILE, len, VM_NORESERVE,
> +						HUGETLB_ANONHUGE_INODE);
> +		if (IS_ERR(file))
> +			return -ENOMEM;
> +	}
> +
>  	/* Obtain the address to map to. we verify (or select) it and ensure
>  	 * that it represents a valid section of the address space.
>  	 */

hugetlb_file_setup() can fail for reasons other than failing to reserve 
pages, so maybe it would be better to return PTR_ERR(file) instead of 
hardcoding -ENOMEM?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
