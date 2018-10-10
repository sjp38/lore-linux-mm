Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0D136B000A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 10:13:28 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 43-v6so3800214ple.19
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 07:13:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b3-v6sor13819054pgw.3.2018.10.10.07.13.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 07:13:27 -0700 (PDT)
Date: Wed, 10 Oct 2018 17:13:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: remove a redundant check in do_munmap()
Message-ID: <20181010141320.zxic4ryuzo63utom@kshutemo-mobl1>
References: <20181010125327.68803-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010125327.68803-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Wed, Oct 10, 2018 at 08:53:27PM +0800, Wei Yang wrote:
> A non-NULL vma returned from find_vma() implies:
> 
>    vma->vm_start <= start
> Since len != 0, the following condition always hods:

s/hods/holds/

>    vma->vm_start < start + len = end
> 
> This means the if check would never be true.

Have you considered overflow?

> This patch removes this redundant check and fix two typo in comment.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/mmap.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 8d6449e74431..94660ddfa2c1 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -414,7 +414,7 @@ static void vma_gap_update(struct vm_area_struct *vma)
>  {
>  	/*
>  	 * As it turns out, RB_DECLARE_CALLBACKS() already created a callback
> -	 * function that does exacltly what we want.
> +	 * function that does exactly what we want.
>  	 */
>  	vma_gap_callbacks_propagate(&vma->vm_rb, NULL);
>  }
> @@ -1621,7 +1621,7 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
>  #endif /* __ARCH_WANT_SYS_OLD_MMAP */
>  
>  /*
> - * Some shared mappigns will want the pages marked read-only
> + * Some shared mappings will want the pages marked read-only
>   * to track write events. If so, we'll downgrade vm_page_prot
>   * to the private version (using protection_map[] without the
>   * VM_SHARED bit).
> @@ -2705,12 +2705,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  	if (!vma)
>  		return 0;
>  	prev = vma->vm_prev;
> -	/* we have  start < vma->vm_end  */
> -
> -	/* if it doesn't overlap, we have nothing.. */
> +	/* we have vma->vm_start <= start < vma->vm_end */
>  	end = start + len;
> -	if (vma->vm_start >= end)
> -		return 0;
>  
>  	/*
>  	 * If we need to split any vma, do it now to save pain later.
> -- 
> 2.15.1
> 

-- 
 Kirill A. Shutemov
