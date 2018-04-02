Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id D985C6B0012
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 12:21:03 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d6-v6so3699388plo.2
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 09:21:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q25sor157241pgd.364.2018.04.02.09.21.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 09:21:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180330145402.5053-1-mike.kravetz@oracle.com>
References: <20180329041656.19691-1-mike.kravetz@oracle.com> <20180330145402.5053-1-mike.kravetz@oracle.com>
From: Anders Roxell <anders.roxell@linaro.org>
Date: Mon, 2 Apr 2018 18:21:01 +0200
Message-ID: <CADYN=9+FzfFt8kKjw-hnHx7CdPbTsH0OsNs1TAGHa6Hi7ndbZQ@mail.gmail.com>
Subject: Re: [PATCH v2] hugetlbfs: fix bug in pgoff overflow checking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Dan Rue <dan.rue@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 30 March 2018 at 16:54, Mike Kravetz <mike.kravetz@oracle.com> wrote:
> This is a fix for a regression in 32 bit kernels caused by an
> invalid check for pgoff overflow in hugetlbfs mmap setup.  The
> check incorrectly specified that the size of a loff_t was the
> same as the size of a long.  The regression prevents mapping
> hugetlbfs files at offsets greater than 4GB on 32 bit kernels.
>
> On 32 bit kernels conversion from a page based unsigned long can
> not overflow a loff_t byte offset.  Therefore, skip this check
> if sizeof(unsigned long) != sizeof(loff_t).
>
> Fixes: 63489f8e8211 ("hugetlbfs: check for pgoff value overflow")
> Cc: <stable@vger.kernel.org>
> Reported-by: Dan Rue <dan.rue@linaro.org>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Tested-by: Anders Roxell <anders.roxell@linaro.org>

> ---
>  fs/hugetlbfs/inode.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index b9a254dcc0e7..d508c7844681 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -138,10 +138,14 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>
>         /*
>          * page based offset in vm_pgoff could be sufficiently large to
> -        * overflow a (l)off_t when converted to byte offset.
> +        * overflow a loff_t when converted to byte offset.  This can
> +        * only happen on architectures where sizeof(loff_t) ==
> +        * sizeof(unsigned long).  So, only check in those instances.
>          */
> -       if (vma->vm_pgoff & PGOFF_LOFFT_MAX)
> -               return -EINVAL;
> +       if (sizeof(unsigned long) == sizeof(loff_t)) {
> +               if (vma->vm_pgoff & PGOFF_LOFFT_MAX)
> +                       return -EINVAL;
> +       }
>
>         /* must be huge page aligned */
>         if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
> --
> 2.13.6
>
