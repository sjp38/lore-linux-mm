Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7AAF16B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 18:46:28 -0400 (EDT)
Date: Fri, 11 Sep 2009 15:46:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mmap : save some cycles for the shared anonymous
 mapping
Message-Id: <20090911154630.6fd232f1.akpm@linux-foundation.org>
In-Reply-To: <1252633966-20541-1-git-send-email-shijie8@gmail.com>
References: <1252633966-20541-1-git-send-email-shijie8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Sep 2009 09:52:46 +0800
Huang Shijie <shijie8@gmail.com> wrote:

> The shmem_zere_setup() does not change vm_start, pgoff or vm_flags,
> only some drivers change them (such as /driver/video/bfin-t350mcqb-fb.c).
> 
> Moving these codes to a more proper place to save cycles for shared anonymous mapping.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/mmap.c |   18 +++++++++---------
>  1 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 8101de4..840e91e 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1195,21 +1195,21 @@ munmap_back:
>  			goto unmap_and_free_vma;
>  		if (vm_flags & VM_EXECUTABLE)
>  			added_exe_file_vma(mm);
> +
> +		/* Can addr have changed??
> +		 *
> +		 * Answer: Yes, several device drivers can do it in their
> +		 *         f_op->mmap method. -DaveM
> +		 */
> +		addr = vma->vm_start;
> +		pgoff = vma->vm_pgoff;
> +		vm_flags = vma->vm_flags;
>  	} else if (vm_flags & VM_SHARED) {
>  		error = shmem_zero_setup(vma);
>  		if (error)
>  			goto free_vma;
>  	}
>  
> -	/* Can addr have changed??
> -	 *
> -	 * Answer: Yes, several device drivers can do it in their
> -	 *         f_op->mmap method. -DaveM
> -	 */
> -	addr = vma->vm_start;
> -	pgoff = vma->vm_pgoff;
> -	vm_flags = vma->vm_flags;
> -
>  	if (vma_wants_writenotify(vma))
>  		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
>  

hm, maybe we should nuke those locals and just use vma->foo everywhere.

Local variable pgoff never gets used again anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
