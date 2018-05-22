Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 664BD6B0286
	for <linux-mm@kvack.org>; Tue, 22 May 2018 08:13:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y82-v6so8400901wmb.5
        for <linux-mm@kvack.org>; Tue, 22 May 2018 05:13:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v22-v6si3365810eda.271.2018.05.22.05.13.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 May 2018 05:13:21 -0700 (PDT)
Date: Tue, 22 May 2018 14:13:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/THP: use hugepage_vma_check() in
 khugepaged_enter_vma_merge()
Message-ID: <20180522121319.GB30663@dhcp22.suse.cz>
References: <20180521193853.3089484-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180521193853.3089484-1-songliubraving@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

[CC Kirill]

On Mon 21-05-18 12:38:53, Song Liu wrote:
> khugepaged_enter_vma_merge() is using a different approach to check
> whether a vma is valid for khugepaged_enter():
> 
>     if (!vma->anon_vma)
>             /*
>              * Not yet faulted in so we will register later in the
>              * page fault if needed.
>              */
>             return 0;
>     if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
>             /* khugepaged not yet working on file or special mappings */
>             return 0;
> 
> This check has some problems. One of the obvious problems is that
> it doesn't check shmem_file(), so that vma backed with shmem files
> will not call khugepaged_enter().
> 
> This patch fixes these problems by reusing hugepage_vma_check() in
> khugepaged_enter_vma_merge().

It would be great to be more explicit about what are the actual
consequences. khugepaged_enter_vma_merge is called from multiple
context. Some of then do not really care about !anon case (e.g. stack
expansion). hugepage_madvise is quite convoluted so I am not really sure
from a quick look (are we simply not going to merge vmas even if we
could?).

Have you noticed this by a code inspection or you have seen this
happening in real workloads (aka, is this worth backporting to stable
trees)?
 
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  mm/khugepaged.c | 12 ++++--------
>  1 file changed, 4 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index d7b2a4b..e50c2bd 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -430,18 +430,14 @@ int __khugepaged_enter(struct mm_struct *mm)
>  	return 0;
>  }
>  
> +static bool hugepage_vma_check(struct vm_area_struct *vma);
> +
>  int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
>  			       unsigned long vm_flags)
>  {
>  	unsigned long hstart, hend;
> -	if (!vma->anon_vma)
> -		/*
> -		 * Not yet faulted in so we will register later in the
> -		 * page fault if needed.
> -		 */
> -		return 0;
> -	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
> -		/* khugepaged not yet working on file or special mappings */
> +
> +	if (!hugepage_vma_check(vma))
>  		return 0;
>  	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
>  	hend = vma->vm_end & HPAGE_PMD_MASK;
> -- 
> 2.9.5

-- 
Michal Hocko
SUSE Labs
