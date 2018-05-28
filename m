Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 621C86B000D
	for <linux-mm@kvack.org>; Mon, 28 May 2018 06:57:30 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 44-v6so10296394wrt.9
        for <linux-mm@kvack.org>; Mon, 28 May 2018 03:57:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2-v6sor440700lfe.45.2018.05.28.03.57.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 May 2018 03:57:28 -0700 (PDT)
Date: Mon, 28 May 2018 13:57:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm/THP: use hugepage_vma_check() in
 khugepaged_enter_vma_merge()
Message-ID: <20180528105724.okg6c7i72r3v3jno@kshutemo-mobl1>
References: <20180522194430.426688-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180522194430.426688-1-songliubraving@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, rientjes@google.com, aarcange@redhat.com

On Tue, May 22, 2018 at 12:44:30PM -0700, Song Liu wrote:
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
> will not call khugepaged_enter(). Here is an example of failed madvise():
> 
>    /* mount /dev/shm with huge=advise:
>     *     mount -o remount,huge=advise /dev/shm */
>    /* create file /dev/shm/huge */
>    #define HUGE_FILE "/dev/shm/huge"
> 
>    fd = open(HUGE_FILE, O_RDONLY);
>    ptr = mmap(NULL, FILE_SIZE, PROT_READ, MAP_PRIVATE, fd, 0);
>    ret = madvise(ptr, FILE_SIZE, MADV_HUGEPAGE);
> 
> madvise() will return 0, but this memory region is never put in huge
> page (check from /proc/meminfo: ShmemHugePages).
> 
> This patch fixes these problems by reusing hugepage_vma_check() in
> khugepaged_enter_vma_merge().
> 
> vma->vm_flags is not yet updated in khugepaged_enter_vma_merge(),
> so we need to pass the new vm_flags to hugepage_vma_check() through
> a separate argument.
> 
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  mm/khugepaged.c | 26 ++++++++++++--------------
>  1 file changed, 12 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index d7b2a4b..9f74e51 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -430,18 +430,15 @@ int __khugepaged_enter(struct mm_struct *mm)
>  	return 0;
>  }
>  
> +static bool hugepage_vma_check(struct vm_area_struct *vma,
> +			       unsigned long vm_flags);
> +

The patch looks good to me.

But can we move hugepage_vma_check() here to avoid forward declaration of
the function?

-- 
 Kirill A. Shutemov
