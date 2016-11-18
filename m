Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F27956B0481
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 16:51:14 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 3so274607085pgd.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 13:51:14 -0800 (PST)
Received: from mail-pg0-x22e.google.com (mail-pg0-x22e.google.com. [2607:f8b0:400e:c05::22e])
        by mx.google.com with ESMTPS id b88si9963528pfl.136.2016.11.18.13.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 13:51:13 -0800 (PST)
Received: by mail-pg0-x22e.google.com with SMTP id p66so106853059pga.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 13:51:13 -0800 (PST)
Date: Fri, 18 Nov 2016 13:51:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 (re-send)] xen/gntdev: Use mempolicy instead of VM_IO
 flag to avoid NUMA balancing
In-Reply-To: <1479413404-27332-1-git-send-email-boris.ostrovsky@oracle.com>
Message-ID: <alpine.LSU.2.11.1611181335560.9605@eggly.anvils>
References: <1479413404-27332-1-git-send-email-boris.ostrovsky@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, david.vrabel@citrix.com, jgross@suse.com, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, olaf@aepfle.de

On Thu, 17 Nov 2016, Boris Ostrovsky wrote:

> Commit 9c17d96500f7 ("xen/gntdev: Grant maps should not be subject to
> NUMA balancing") set VM_IO flag to prevent grant maps from being
> subjected to NUMA balancing.
> 
> It was discovered recently that this flag causes get_user_pages() to
> always fail with -EFAULT.
> 
> check_vma_flags
> __get_user_pages
> __get_user_pages_locked
> __get_user_pages_unlocked
> get_user_pages_fast
> iov_iter_get_pages
> dio_refill_pages
> do_direct_IO
> do_blockdev_direct_IO
> do_blockdev_direct_IO
> ext4_direct_IO_read
> generic_file_read_iter
> aio_run_iocb
> 
> (which can happen if guest's vdisk has direct-io-safe option).
> 
> To avoid this don't use vm_flags. Instead, use mempolicy that prohibits
> page migration (i.e. clear MPOL_F_MOF|MPOL_F_MORON) and make sure we
> don't consult task's policy (which may include those flags) if vma
> doesn't have one.
> 
> Reported-by: Olaf Hering <olaf@aepfle.de>
> Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: stable@vger.kernel.org

Hmm, sorry, but this seems overcomplicated to me: ingenious, but an
unusual use of the ->get_policy method, which is a little worrying,
since it has only been used for shmem (+ shm and kernfs) until now.

Maybe I'm wrong, but wouldn't substituting VM_MIXEDMAP for VM_IO
solve the problem more simply?

Hugh

> ---
> 
> Mis-spelled David's address.
> 
> Changes in v3:
> * Don't use __mpol_dup() and get_task_policy() which are not exported
>   for use by drivers. Add vm_operations_struct.get_policy().
> * Copy to stable
> 
> 
>  drivers/xen/gntdev.c |   27 ++++++++++++++++++++++++++-
>  1 files changed, 26 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index bb95212..632edd4 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -35,6 +35,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/slab.h>
>  #include <linux/highmem.h>
> +#include <linux/mempolicy.h>
>  
>  #include <xen/xen.h>
>  #include <xen/grant_table.h>
> @@ -433,10 +434,28 @@ static void gntdev_vma_close(struct vm_area_struct *vma)
>  	return map->pages[(addr - map->pages_vm_start) >> PAGE_SHIFT];
>  }
>  
> +#ifdef CONFIG_NUMA
> +/*
> + * We have this op to make sure callers (such as vma_policy_mof()) don't
> + * check current task's policy which may include migrate flags (MPOL_F_MOF
> + * or MPOL_F_MORON)
> + */
> +static struct mempolicy *gntdev_vma_get_policy(struct vm_area_struct *vma,
> +					       unsigned long addr)
> +{
> +	if (mpol_needs_cond_ref(vma->vm_policy))
> +		mpol_get(vma->vm_policy);
> +	return vma->vm_policy;
> +}
> +#endif
> +
>  static const struct vm_operations_struct gntdev_vmops = {
>  	.open = gntdev_vma_open,
>  	.close = gntdev_vma_close,
>  	.find_special_page = gntdev_vma_find_special_page,
> +#ifdef CONFIG_NUMA
> +	.get_policy = gntdev_vma_get_policy,
> +#endif
>  };
>  
>  /* ------------------------------------------------------------------ */
> @@ -1007,7 +1026,13 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
>  
>  	vma->vm_ops = &gntdev_vmops;
>  
> -	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP | VM_IO;
> +	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
> +
> +#ifdef CONFIG_NUMA
> +	/* Prevent NUMA balancing */
> +	if (vma->vm_policy)
> +		vma->vm_policy->flags &= ~(MPOL_F_MOF | MPOL_F_MORON);
> +#endif
>  
>  	if (use_ptemod)
>  		vma->vm_flags |= VM_DONTCOPY;
> -- 
> 1.7.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
